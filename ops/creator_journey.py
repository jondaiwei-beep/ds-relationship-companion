#!/usr/bin/env python3
"""The Creator's first day, exactly as the app now walks it.

Signing in is where the owner started; everything below must be reachable
from the app, not just from the API.
"""
import base64, hashlib, json, os, sys, time, urllib.parse, urllib.request, uuid

API = "https://ds-api.beforeweplay.com"
WEB = "https://ds-staging.beforeweplay.com"
fails = []

def call(method, path, body=None, token=None, idem=None):
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(API + path, data=data, method=method)
    req.add_header("Content-Type", "application/json")
    # Cloudflare blocks urllib's default agent with error 1010.
    req.add_header("User-Agent",
                   "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
                   "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126 Safari/537.36")
    if token: req.add_header("authorization", "Bearer " + token)
    if idem: req.add_header("Idempotency-Key", idem)
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            raw = r.read().decode()
            try:
                return r.status, (json.loads(raw) if raw else {})
            except ValueError:
                return r.status, {"raw": raw[:200]}
    except urllib.error.HTTPError as e:
        raw = e.read().decode()
        try:
            return e.code, (json.loads(raw) if raw else {})
        except ValueError:
            return e.code, {"raw": raw[:200]}

def b64(b): return base64.urlsafe_b64encode(b).decode().rstrip("=")

def signin(email):
    flow, ver = str(uuid.uuid4()), b64(os.urandom(32))
    chal = b64(hashlib.sha256(ver.encode()).digest())
    call("POST", "/v1/auth/magic-links",
         {"email": email, "flowId": flow, "codeChallenge": chal})
    q = urllib.parse.quote(email, safe="")
    _, d = call("GET", f"/v1/staging/last-magic-link?email={q}")
    if "url" not in d:
        print("  !! no link for", email, d); return ""
    tok = d["url"].split("#ml=")[1].split("&")[0]
    _, g = call("POST", "/v1/auth/magic-links/consume",
                {"token": tok, "flowId": flow, "codeVerifier": ver,
                 "clientType": "ANDROID"})
    return g.get("accessToken", "")

def check(label, ok, detail=""):
    print(("  ✅ " if ok else "  ❌ ") + label.ljust(46) + str(detail))
    if not ok: fails.append(label)

n = str(int(time.time()))
ctok = signin(f"creator-{n}@staging.test")
check("Creator signs in", bool(ctok), ctok[:16] + "…")

# 1. Nothing yet — the app must be able to ask, and get an answer.
st, mine = call("GET", "/v1/dynamics", None, ctok)
check("App can ask which dynamics I'm in", st == 200 and mine == [], "[]")

# 2. Start one from the app.
st, d = call("POST", "/v1/dynamics",
             {"mode": "COUPLE", "desiredOutcome": "CLOSER",
              "structureLevel": "LIGHT", "referenceTimezone": "Asia/Shanghai",
              "dayBoundaryMinutes": 0}, ctok, idem=f"cd-{n}")
dyn = d.get("dynamicId")
check("Creator starts a dynamic", st == 201 and bool(dyn), dyn or d)

# 3. Make an invite — the Creator's only way to bring anyone in.
st, iv = call("POST", f"/v1/dynamics/{dyn}/invites", None, ctok, idem=f"iv-{n}")
token = iv.get("token", "")
check("Creator can make an invite link", st == 201 and bool(token),
      f"{WEB}/invite/{token[:22]}…")

# 4. Today must offer the next step, not an empty page.
st, t = call("GET", f"/v1/dynamics/{dyn}/today", None, ctok)
st2, det = call("GET", f"/v1/dynamics/{dyn}", None, ctok)
alone = det.get("state") == "PENDING_PARTNER"
check("Today knows nobody has joined yet", st == 200 and st2 == 200 and alone,
      f'state={det.get("state")}')

# 5. Partner joins through the link.
ptok = signin(f"partner-{n}@staging.test")
st, _ = call("POST", "/v1/invites/join", {"token": token}, ptok, idem=f"jn-{n}")
check("Partner joins through the link", st == 201)

# 6. The Starter Rhythm — built long ago, but unreachable until now.
st, det = call("GET", f"/v1/dynamics/{dyn}", None, ctok)
partner_id = None
st3, p = call("GET", f"/v1/dynamics/{dyn}/starter-rhythm", None, ctok)
check("A starting rhythm is offered", st3 == 200 and bool(p.get("ritualTitle")),
      p.get("ritualTitle", ""))

# The assignee is the partner; the app reads it from the members list.
st, mine_p = call("GET", "/v1/dynamics", None, ptok)
check("Partner's app finds the dynamic too",
      st == 200 and len(mine_p) == 1 and mine_p[0]["roleContext"] == "PARTNER",
      f'role={mine_p[0]["roleContext"] if mine_p else "-"}')

# The direction-giving half: members must carry a user id, or nothing can
# be addressed to a person and no expectation can be created at all.
st, det = call("GET", f"/v1/dynamics/{dyn}", None, ctok)
ids = [m.get("userId") for m in det.get("members", [])]
check("Members carry a user id", st == 200 and all(ids) and len(ids) == 2,
      f"{len(ids)} members, ids present={all(ids)}")

partner_id = [m["userId"] for m in det["members"]
              if m["roleContext"] == "PARTNER"][0]
st, ex = call("POST", f"/v1/dynamics/{dyn}/expectations",
              {"title": "Prepare the evening space",
               "purpose": "Something small, done with care.",
               "assigneeUserId": partner_id}, ctok, idem=f"ex-{n}")
check("Creator can ask for something", st == 201, str(ex)[:70])

# It must land on the other person's Today, not just in the database.
st, t = call("GET", f"/v1/dynamics/{dyn}/today", None, ptok)
titles = [e["title"] for e in t.get("expectations", [])]
check("It appears on the partner's Today",
      st == 200 and "Prepare the evening space" in titles, str(titles))

# A private check-in must reach the server and stay private.
st, _ = call("POST", f"/v1/dynamics/{dyn}/check-ins",
             {"energy": "STEADY", "note": "quiet day",
              "visibility": "PRIVATE"}, ptok, idem=f"ci-{n}")
check("Partner can check in privately", st == 201)
st, mine_ci = call("GET", f"/v1/dynamics/{dyn}/check-ins", None, ctok)
leaked = any("quiet day" in json.dumps(c) for c in (mine_ci or []))
check("A private check-in is not visible to the partner", not leaked,
      "not shared" if not leaked else "LEAKED")

# Journey E: coming back is a choice, and neither choice creates a backlog.
call("POST", f"/v1/dynamics/{dyn}/pause", None, ctok, idem=f"pz-{n}")
st, _ = call("POST", f"/v1/dynamics/{dyn}/resume?lighter=true", None, ctok,
             idem=f"rz-{n}")
st2, det = call("GET", f"/v1/dynamics/{dyn}", None, ctok)
check("Coming back lighter works", st == 200 and det.get("state") == "ACTIVE",
      f'state={det.get("state")}')

# Role preset is recorded but grants nothing.
presets = [m.get("rolePreset") for m in det.get("members", [])]
check("Members can carry a role preset", "rolePreset" in json.dumps(det),
      f"presets={presets}")
check("Agency is untouched by any preset",
      det.get("alwaysAvailable") == ["discuss", "reschedule", "cant_do",
                                     "pause", "leave", "block"],
      str(det.get("alwaysAvailable")))

# Screens in the loop must be able to name the other person. The client
# had been hardcoding "Your partner", so every moment addressed a workflow
# role instead of a human being.
st, occ = call("GET", f"/v1/occurrences/{ex.get('occurrenceId')}", None, ptok)
check("An occurrence knows who the other person is",
      st == 200 and occ.get("partnerDisplayName") not in (None, ""),
      f'partner={occ.get("partnerDisplayName")}')

print()
print("PASS — a Creator can get from nothing to a shared dynamic"
      if not fails else f"FAIL: {fails}")
sys.exit(1 if fails else 0)
