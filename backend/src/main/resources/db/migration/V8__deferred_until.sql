-- Records the moment a delivery was pushed past a quiet window.
--
-- `not_before` cannot carry this: it is NOT NULL and is also moved by
-- ordinary retry backoff, so it cannot distinguish "waited out the night"
-- from "failed once and will try again shortly". Aggregation must only
-- collapse the former (Notion 04 §7) — silently merging an ordinary burst
-- of daytime activity would hide real events behind one vague line.
ALTER TABLE outbox_records
    ADD COLUMN deferred_until timestamptz;

COMMENT ON COLUMN outbox_records.deferred_until IS
    'Set only when quiet hours deferred this delivery. Used to aggregate the '
    'backlog into one message when the window ends; NULL for retry backoff.';

-- Marks the one record that stands for a collapsed quiet-hours backlog, so
-- it can carry the summary line instead of its own specific one.
ALTER TABLE outbox_records
    ADD COLUMN aggregated boolean NOT NULL DEFAULT false;
