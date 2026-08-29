-- Leave and Block — Notion 04 §8, Journey F. This is the safety feature.
--
-- G-2 DECISION (closes the open gap): a Block is recorded directionally
-- ("A blocked B") but takes effect as a MUTUAL separation. It ends the Dynamic
-- permanently, seals shared history from BOTH people, prevents reconnection,
-- and never tells the other person who blocked them.
--
-- Reasoning: in a safety-critical context for consensual adult couples, a
-- one-way block that still let the blocker browse the other person's shared
-- history would be a surveillance asymmetry, and telling someone "X blocked
-- you" hands an unsafe person a fact to react to.

-- Delivery must be able to fence by Dynamic without joining through
-- occurrences, so Leave/Block can cancel everything for a Dynamic in one
-- statement (see G-1 below).
ALTER TABLE outbox_records
    ADD COLUMN IF NOT EXISTS dynamic_id uuid REFERENCES dynamics (id);

CREATE INDEX IF NOT EXISTS outbox_records_dynamic_pending_idx
    ON outbox_records (dynamic_id)
    WHERE state = 'PENDING';

COMMENT ON COLUMN outbox_records.dynamic_id IS
    'Lets Leave/Block cancel every queued delivery for a Dynamic in one '
    'statement, and lets the dispatcher take the per-Dynamic delivery fence.';

-- Who ended it, and how. Kept separate from memberships because it is a
-- safety record, not operational state.
CREATE TABLE membership_terminations (
    id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    dynamic_id          uuid NOT NULL REFERENCES dynamics (id),
    -- The person who acted.
    actor_user_id       uuid NOT NULL REFERENCES users (id),
    -- For a block, the person blocked. Null for a plain leave.
    target_user_id      uuid REFERENCES users (id),
    kind                text NOT NULL,
    reason              text,
    created_at          timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT membership_terminations_kind_ck
        CHECK (kind IN ('LEAVE', 'BLOCK')),
    -- A block always names a target; a leave never does.
    CONSTRAINT membership_terminations_target_ck
        CHECK ((kind = 'BLOCK' AND target_user_id IS NOT NULL)
            OR (kind = 'LEAVE' AND target_user_id IS NULL))
);

CREATE INDEX membership_terminations_dynamic_idx
    ON membership_terminations (dynamic_id, created_at DESC);

COMMENT ON TABLE membership_terminations IS
    'Safety record of who left or blocked. A block is directional in the record '
    'but mutual in effect (G-2). The blocked person is never told who blocked them.';
