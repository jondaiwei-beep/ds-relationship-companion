-- Free redemptions.
--
-- `cost = 0` is legal — some rewards are simply on offer — but the ledger
-- forbids a zero-amount row, because a balance movement of nothing is a bug
-- everywhere else in the system and the constraint should stay strict. Taking
-- a free reward is still an event the other person should see, so it is
-- recorded here rather than as a zero-value purchase.
CREATE TABLE reward_redemptions (
    id              uuid PRIMARY KEY,
    dynamic_id      uuid NOT NULL REFERENCES dynamics(id) ON DELETE CASCADE,
    reward_id       uuid NOT NULL REFERENCES rewards(id) ON DELETE CASCADE,
    subject_user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at      timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX reward_redemptions_dynamic_idx
    ON reward_redemptions (dynamic_id, created_at DESC);
