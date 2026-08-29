-- Delivery observability (Notion 04 §13, 07 §2 item 8).
--
-- The dispatcher must be able to record WHY a delivery did not happen:
-- suppressed because the recipient left, suppressed as stale, or failed at the
-- provider. Without this the reliability incidents that Notion 07 tracks are
-- invisible.

ALTER TABLE outbox_records
    ADD COLUMN IF NOT EXISTS last_error text;

COMMENT ON COLUMN outbox_records.last_error IS
    'Why the last attempt did not deliver: "suppressed:<REASON>" for a deliberate '
    'non-send, or the provider error for a genuine failure. Never contains '
    'relationship content.';

-- Find records stuck behind a dead dispatcher's expired lease.
CREATE INDEX IF NOT EXISTS outbox_records_stuck_idx
    ON outbox_records (locked_until)
    WHERE state = 'PENDING' AND locked_until IS NOT NULL;
