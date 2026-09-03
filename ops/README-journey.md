# journey_v2 — full-loop acceptance against live staging

`ops/journey_v2.py` exercises the whole product loop over HTTPS against
`https://ds-api.beforeweplay.com`, as two real users D and s, through
password auth (`POST /v1/auth/register`), dynamics/invite/join, starter
pack, tasks, today, media, disposition, points, record, rewards/
consequences, explore compare, notifications, and away/back.

Run:

```
python3 ops/journey_v2.py
```

Prints one `[PASS]`/`[FAIL]` line per step (truncated response on failure)
and exits non-zero if anything failed. Test users are left in place on
staging (`journey+<epoch>-d@example.com` / `-s@example.com`); the emails are
printed at the end of the run.

No ssh / magic-link round trip needed — password registration has been live
since V9, so each run creates two fresh accounts directly.
