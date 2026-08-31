#!/usr/bin/env python3
"""Make a real account that is already in the state you want to look at.

Every state below is reached by driving the same public API the app drives.
Nothing here is a fixture: the accounts exist on staging, the invite is a real
invite, and the completed occurrence really did travel to the creator's
Attention. That is the point — a seeded account and a hand-made one are the
same thing to the server, so what you see on the phone is what the code does.

    ops/seed.py fresh              a registered account, nothing set up yet
    ops/seed.py solo               through activation, one item on Today
    ops/seed.py invite-pending     a Dynamic with an invite waiting to be opened
    ops/seed.py paired             both joined; the partner has a live item with
                                   all four actions — the one to test Today with
    ops/seed.py waiting-response   partner completed; waiting to be acknowledged
    ops/seed.py acknowledged       the creator replied; the response is on Today
    ops/seed.py attention          the creator has something waiting in Attention

    ops/seed.py all                one of each, printed as a table

Prints the email and password to sign in with. Password is the same for every
seeded account so there is one less thing to copy.
"""
import argparse
import base64
import json
import sys
import urllib.error
import urllib.request
import uuid

API = "https://ds-api.beforeweplay.com"
PASSWORD = "Seedpass123!"

# Cloudflare's browser-integrity check answers urllib's default agent with
# error 1010, which arrives as an HTML page rather than JSON and reads like a
# server bug. Present as the client that actually exists.
UA = ("Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 "
      "(KHTML, like Gecko) Chrome/126 Mobile Safari/537.36")


def call(method, path, body=None, token=None, idem=False):
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(API + path, data=data, method=method)
    req.add_header("Content-Type", "application/json")
    req.add_header("User-Agent", UA)
    if token:
        req.add_header("authorization", "Bearer " + token)
    if idem:
        req.add_header("Idempotency-Key", str(uuid.uuid4()))
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            raw = r.read().decode()
            return r.status, (json.loads(raw) if raw else {})
    except urllib.error.HTTPError as e:
        raw = e.read().decode()
        try:
            return e.code, (json.loads(raw) if raw else {})
        except ValueError:
            return e.code, {"raw": raw[:200]}


def ok(status, body, what):
    if status not in (200, 201, 202, 204):
        sys.exit(f"✗ {what} failed: {status} {json.dumps(body)[:200]}")
    return body


def user_id(jwt):
    """The `sub` claim — starter-rhythm needs to be told who is assigned."""
    part = jwt.split(".")[1]
    part += "=" * (-len(part) % 4)
    return json.loads(base64.urlsafe_b64decode(part))["sub"]


def register(tag):
    """A new person. Email is unique per run so states never collide."""
    email = f"seed-{tag}-{uuid.uuid4().hex[:8]}@example.com"
    body = ok(*call("POST", "/v1/auth/register", {
        "email": email,
        "password": PASSWORD,
        "clientType": "ANDROID",
        "ageConfirmed": True,
    }), "register")
    return email, body["accessToken"]


def create_dynamic(token, outcome="ACCOUNTABILITY"):
    body = ok(*call("POST", "/v1/dynamics", {
        "mode": "COUPLE",
        "desiredOutcome": outcome,
        "structureLevel": "STEADY",
        "referenceTimezone": "Asia/Shanghai",
        "dayBoundaryMinutes": 240,
        "rolePreset": "SWITCH",
    }, token=token, idem=True), "create dynamic")
    return body["dynamicId"]


def starter_rhythm(token, dynamic_id, assignee=None):
    """Start the rhythm — this is what puts anything on Today at all.

    The assignee is explicit rather than implied: the server will not guess who
    carries an expectation, and a seeded account with an empty Today is worse
    than no seeded account, because it looks like a rendering bug.
    """
    return ok(*call("POST", f"/v1/dynamics/{dynamic_id}/starter-rhythm", {
        "assigneeUserId": assignee or user_id(token),
        "ritualTitle": None,
        "expectationTitle": None,
        "includeSecondExpectation": False,
    }, token=token, idem=True), "start starter rhythm")


def today(token, dynamic_id):
    return ok(*call("GET", f"/v1/dynamics/{dynamic_id}/today", token=token),
              "read today")


def first_occurrence(view):
    """The occurrence the app puts under the primary action."""
    for key in ("priorityItems", "laterItems"):
        for item in view.get(key) or []:
            if isinstance(item, dict) and item.get("occurrenceId"):
                return item["occurrenceId"]
    return None


def add_expectation(token, dynamic_id, title, assignee, purpose=None):
    """Create one expectation and get back the occurrence it activated.

    The starter rhythm only writes a recurring *definition*; a scheduler turns
    that into today's occurrence on its own five-minute tick. Seeding cannot
    wait for a clock, and an account whose Today is still empty is useless for
    looking at Today. Creating an expectation activates its occurrence in the
    same request, which is the same path the app's own "add" takes.
    """
    body = ok(*call("POST", f"/v1/dynamics/{dynamic_id}/expectations", {
        "title": title,
        "purpose": purpose,
        "assigneeUserId": assignee,
        "dueAt": None,
    }, token=token, idem=True), "create expectation")
    return body["occurrenceId"]


def invite(token, dynamic_id):
    body = ok(*call("POST", f"/v1/dynamics/{dynamic_id}/invites",
                    token=token, idem=True), "create invite")
    return body["token"], body.get("inviteUrl", "")


def join(token, invite_token):
    return ok(*call("POST", "/v1/invites/join", {"token": invite_token},
                    token=token, idem=True), "join invite")


def complete(token, occurrence_id, note=None):
    body = {"note": note} if note else None
    return ok(*call("POST", f"/v1/occurrences/{occurrence_id}/complete",
                    body, token=token, idem=True), "complete")


def acknowledge(token, occurrence_id, message):
    """The field is `text`, not `message`.

    An unknown field is ignored rather than rejected, so sending `message`
    returned 201 with an empty acknowledgement — the seeded "acknowledged"
    state looked right in the ledger and rendered as an empty quotation mark
    on Us. Caught by reading the words back out, not by the status code.
    """
    return ok(*call("POST", f"/v1/occurrences/{occurrence_id}/acknowledgements",
                    {"type": "COMMENT", "text": message},
                    token=token, idem=True), "acknowledge")


# --- states -----------------------------------------------------------------
#
# Each returns the accounts you sign in with, most interesting one first.

def state_fresh():
    email, _ = register("fresh")
    return [(email, "registered, no Dynamic yet — lands in activation")]


def state_solo():
    email, token = register("solo")
    d = create_dynamic(token)
    starter_rhythm(token, d)
    add_expectation(token, d, "Name one thing you are avoiding", user_id(token),
                    "Naming it is the whole task.")
    return [(email, "activated, one thing on Today (self-assigned, so no "
                    "action buttons — use `paired` to see those)")]


def state_invite_pending():
    email, token = register("inv")
    d = create_dynamic(token)
    starter_rhythm(token, d)
    tok, url = invite(token, d)
    return [(email, f"has an unopened invite — link: {url or tok}")]


def _paired(tag, expectation=None):
    """Both halves, joined. The base every two-person state builds on.

    When [expectation] is given it is assigned to the PARTNER, because only the
    assignee may complete: the creator asks, the partner does it, the creator
    acknowledges. Assigning it to the creator produces a row nobody can act on
    — it renders on Today with no buttons, which looks like a broken screen.
    """
    a_email, a = register(tag + "-a")
    d = create_dynamic(a)
    starter_rhythm(a, d)
    tok, _ = invite(a, d)
    b_email, b = register(tag + "-b")
    join(b, tok)
    occ = None
    if expectation:
        occ = add_expectation(a, d, expectation, user_id(b))
    return (a_email, a, b_email, b, d, occ)


def state_paired():
    a_email, _, b_email, _, _, _ = _paired("pair", "Say how today actually went")
    return [(a_email, "creator, partner joined, one thing on Today"),
            (b_email, "partner, joined")]


def state_waiting_response():
    a_email, a, b_email, b, d, occ = _paired("wait", "Say how today actually went")
    complete(b, occ, "seeded: done, waiting to be seen")
    return [(b_email, "did it; waiting to be acknowledged"),
            (a_email, "the other half — this one has it to acknowledge")]


def state_attention():
    a_email, a, b_email, b, d, occ = _paired("attn", "Name one thing you are avoiding")
    complete(b, occ, "seeded: for the creator to acknowledge")
    return [(a_email, "sign in as this one — Attention has something waiting"),
            (b_email, "the other half, waiting on a reply")]


def state_acknowledged():
    a_email, a, b_email, b, d, occ = _paired("ack", "Say how today actually went")
    complete(b, occ, "seeded: done")
    acknowledge(a, occ, "Seen — thank you for doing this.")
    return [(b_email, "the reply is on this Today"),
            (a_email, "the one who replied")]


STATES = {
    "fresh": state_fresh,
    "solo": state_solo,
    "invite-pending": state_invite_pending,
    "paired": state_paired,
    "waiting-response": state_waiting_response,
    "acknowledged": state_acknowledged,
    "attention": state_attention,
}


def main():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("state", choices=list(STATES) + ["all"])
    args = p.parse_args()

    wanted = list(STATES) if args.state == "all" else [args.state]
    print(f"api      {API}")
    print(f"password {PASSWORD}   (the same for every account below)\n")

    for name in wanted:
        print(f"── {name}")
        for email, what in STATES[name]():
            print(f"   {email}")
            print(f"      {what}")
        print()


if __name__ == "__main__":
    main()
