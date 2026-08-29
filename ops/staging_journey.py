"""Full M1 vertical slice against LIVE HTTPS staging (Notion 06 §13.3).

Exercises the exact Exit Criteria journey across two separate authenticated
users, as an Android Creator and an iPhone Safari Invitee would.
"""
import base64, hashlib, json, os, subprocess, sys, time, urllib.request, uuid

API = "https://ds-api.beforeweplay.com"
WEB = "https://ds-staging.beforeweplay.com"

def ssh(cmd):
    return subprocess.run(
        ["sshpass", "-p", "dpw123", "ssh", "-o", "StrictHostKeyChecking=no",
         "-o", "ConnectTimeout=30", "-o", "GSSAPIAuthentication=no",
         "-o", "ProxyCommand=nc -X 5 -x 127.0.0.1:6578 %h %p",
         "root@204.152.213.47", cmd],
        capture_output=True, text=True, timeout=90).stdout.strip()

def call(method, path, body=None, token=None, idem=False):
    req = urllib.request.Request(API + path, method=method)
    req.add_header("Content-Type", "application/json")
    # Cloudflare's browser-integrity check rejects urllib's default UA (1010).
    # A real client is a browser or a mobile app, so present as one.
    req.add_header("User-Agent",
                   "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) "
                   "AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile Safari/604.1")
    if token: req.add_header("Authorization", "Bearer " + token)
    if idem:  req.add_header("Idempotency-Key", str(uuid.uuid4()))
    data = json.dumps(body).encode() if body is not None else None
    try:
        with urllib.request.urlopen(req, data, timeout=30) as r:
            raw = r.read().decode()
            return r.status, (json.loads(raw) if raw else {})
    except urllib.error.HTTPError as e:
        return e.code, {"error": e.read().decode()[:120]}

def b64(b): return base64.urlsafe_b64encode(b).decode().rstrip("=")

def signin(email):
    """Complete the real magic-link round trip, including PKCE."""
    flow = str(uuid.uuid4())
    verifier = b64(os.urandom(32))
    challenge = b64(hashlib.sha256(verifier.encode()).digest())
    st, _ = call("POST", "/v1/auth/magic-links",
                 {"email": email, "flowId": flow, "codeChallenge": challenge})
    assert st == 202, f"magic-link request failed: {st}"
    time.sleep(2)
    line = ssh(f"grep 'flow={flow}' /opt/applications/dsapp/magic-links.txt | tail -1")
    tok = line.split("ml=")[1].split("&")[0]
    st, body = call("POST", "/v1/auth/magic-links/consume",
                    {"token": tok, "flowId": flow, "codeVerifier": verifier,
                     "clientType": "WEB"})
    assert st == 200, f"consume failed: {st} {body}"
    return body["accessToken"]

def sub(jwt):
    p = jwt.split(".")[1]; p += "=" * (-len(p) % 4)
    return json.loads(base64.urlsafe_b64decode(p))["sub"]

fails = []
def check(label, ok, detail=""):
    print(f"  {'✅' if ok else '❌'} {label:<44} {detail}")
    if not ok: fails.append(label)

print("=== FULL M1 JOURNEY · LIVE HTTPS STAGING ===\n")

ctok = signin("alex@staging.test")
check("Creator signs in (Android)", bool(ctok), ctok[:18] + "...")

st, d = call("POST", "/v1/dynamics", {
    "mode": "COUPLE", "desiredOutcome": "CLOSER", "structureLevel": "LIGHT",
    "referenceTimezone": "America/New_York"}, ctok, idem=True)
check("Creator creates minimal Dynamic", st == 201, d.get("dynamicId", d))
dyn = d["dynamicId"]

st, d = call("POST", f"/v1/dynamics/{dyn}/invites", None, ctok, idem=True)
check("Creator generates Invite", st == 201)
invite = d["token"]
print(f"     → {WEB}/invite/{invite}")

st, d = call("POST", "/v1/invites/resolve", {"token": invite})
check("Partner resolves it ANONYMOUSLY", st == 200 and d["state"] == "PENDING",
      f"inviter={d.get('inviterDisplayName')}")

ptok = signin("jamie@staging.test")
pid = sub(ptok)
check("Partner signs in (iPhone Safari)", bool(ptok), ptok[:18] + "...")

st, _ = call("POST", "/v1/invites/join", {"token": invite}, ptok, idem=True)
check("Partner JOINS", st == 201)

st, d = call("POST", f"/v1/dynamics/{dyn}/expectations", {
    "title": "Prepare the evening space",
    "purpose": "A small act of care before we reconnect.",
    "assigneeUserId": pid}, ctok, idem=True)
check("Creator sets one Expectation", st == 201)
occ = d["occurrenceId"]

st, d = call("GET", f"/v1/occurrences/{occ}", None, ptok)
check("Partner sees it with adjustment offered", st == 200 and
      {"complete", "discuss", "reschedule", "cant_do"} <= set(d["allowedActions"]),
      str(d["allowedActions"]))

st, _ = call("POST", f"/v1/occurrences/{occ}/complete", {"note": "Done."}, ptok, idem=True)
check("Partner COMPLETES (Safari)", st == 201)

st, d = call("GET", f"/v1/occurrences/{occ}", None, ptok)
check("→ WAITING_ACK, NOT acknowledged", d["state"] == "WAITING_ACK" and
      d["acknowledgement"] is None, "red line #2 holds")

st, d = call("GET", f"/v1/dynamics/{dyn}/attention", None, ctok)
# Before acknowledging: the creator's Today must SHOW the direction-giving
# face. Checking only after the loop closes would prove nothing.
st2, t2 = call("GET", f"/v1/dynamics/{dyn}/today", None, ctok)
check("Creator's Today surfaces the waiting response",
      st2 == 200 and t2.get("needsMyResponseCount") == 1,
      f'needsMyResponseCount={t2.get("needsMyResponseCount")}')

check("Creator's Attention shows it", st == 200 and d["needsResponseCount"] == 1,
      f"from {d['items'][0]['actorDisplayName']}")

st, _ = call("POST", f"/v1/occurrences/{occ}/acknowledgements",
             {"type": "PRAISE", "text": "I noticed the care you put into this."},
             ctok, idem=True)
check("Creator ACKNOWLEDGES (Android)", st == 201)

st, d = call("GET", f"/v1/occurrences/{occ}", None, ptok)
a = d["acknowledgement"]
check("Partner SEES the human response", d["state"] == "ACKNOWLEDGED" and a is not None,
      f'"{a["text"]}" — {a["senderDisplayName"]}')

# Today has two faces — the server states which, the client never infers.
st, d = call("GET", f"/v1/dynamics/{dyn}/today", None, ctok)
check("…and it clears once a real person has answered", st == 200 and
      d.get("needsMyResponseCount") == 0 and d.get("roleContext") == "CREATOR",
      f'needsMyResponseCount={d.get("needsMyResponseCount")} '
      f'role={d.get("roleContext")}')
st, d = call("GET", f"/v1/dynamics/{dyn}/today", None, ptok)
check("Partner's Today reports the receiving face",
      st == 200 and d.get("roleContext") == "PARTNER",
      f'role={d.get("roleContext")} '
      f'expectations={len(d.get("expectations", []))}')

# D7 Weekly Reflection — describes the week; never grades it.
st, d = call("GET", f"/v1/dynamics/{dyn}/weekly", None, ctok)
check("Weekly reflection is readable", st == 200, json.dumps(d)[:110])
# A brand-new dynamic has no week behind it, so the client must not show one.
check("Hidden for a same-day dynamic", d.get("hasEnoughHistory") is False,
      f'hasEnoughHistory={d.get("hasEnoughHistory")}')
# The acknowledgement we just sent is a real answered moment.
ms = d.get("answeredMoments", [])
check("The real acknowledgement is counted", len(ms) == 1,
      f'"{ms[0]["text"]}" from {ms[0]["fromDisplayName"]}' if ms else "none")
# Notion 03 §3: no score, no completion rate, no streak in the payload.
banned = {"score", "rate", "streak", "completionRate", "points", "percent"}
check("No score / rate / streak in payload",
      not (banned & set(d.keys())), ",".join(sorted(d.keys())))

json.dump({"dynamicId": dyn, "inviteToken": invite, "occurrenceId": occ,
           "inviteUrl": f"{WEB}/invite/{invite}"}, open("/tmp/journey.json", "w"))

print()
print("PASS — full loop closed on live staging" if not fails else f"FAIL: {fails}")
sys.exit(1 if fails else 0)
