-- Phase 3 (product/06-build-order.md): 规矩 + 分.
--
--   * Rule — standing agreements (称呼/跪迎/禁慾/着装/汇报方式…), separate
--     from Task (which generates occurrences). D writes and edits; an s may
--     only propose (status='proposed' until the D accepts).
--   * Redemption requests — the s asks for a reward, the D decides. Only
--     `decide(approve)` ever writes a ledger row; `request`/`deny` never do.
--   * `dynamics.d_away_until` — the one-key 「我不在」.

-- ---------------------------------------------------------------------------
CREATE TABLE rules (
    id          uuid PRIMARY KEY,
    dynamic_id  uuid NOT NULL REFERENCES dynamics(id) ON DELETE CASCADE,
    title       text NOT NULL CHECK (char_length(title) BETWEEN 1 AND 120),
    body        text CHECK (body IS NULL OR char_length(body) <= 2000),
    "group"     text NOT NULL DEFAULT 'other'
                    CHECK ("group" IN ('protocol', 'ritual', 'restriction', 'appearance', 'reporting', 'other')),
    created_by  uuid NOT NULL REFERENCES users(id),
    status      text NOT NULL DEFAULT 'active' CHECK (status IN ('proposed', 'active', 'archived')),
    position    integer NOT NULL DEFAULT 0,
    created_at  timestamptz NOT NULL DEFAULT now(),
    updated_at  timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX rules_dynamic_group_idx ON rules (dynamic_id, "group", position) WHERE status <> 'archived';

-- ---------------------------------------------------------------------------
-- D「我不在」— one key that pauses every task that needs them present.
ALTER TABLE dynamics ADD COLUMN d_away_until timestamptz;

-- ---------------------------------------------------------------------------
-- "D 决定" rewards: no fixed price, the D sets the cost at approval time.
ALTER TABLE rewards ALTER COLUMN cost DROP NOT NULL;
COMMENT ON COLUMN rewards.cost IS
    'NULL = D decides at approval time. Never used for the instant redeem() path, which requires a price.';

-- ---------------------------------------------------------------------------
-- Redemption requests. `requested` writes no ledger row — affordability is
-- only checked, not moved, until the D decides. `denied` writes nothing
-- either: nobody owes anything for having asked.
ALTER TABLE reward_redemptions
    ADD COLUMN status text NOT NULL DEFAULT 'fulfilled'
        CHECK (status IN ('requested', 'approved', 'denied', 'fulfilled')),
    ADD COLUMN decided_by uuid REFERENCES users(id),
    ADD COLUMN decided_at timestamptz,
    ADD COLUMN note text CHECK (note IS NULL OR char_length(note) <= 500),
    ADD COLUMN point_entry_id uuid REFERENCES point_entries(id) ON DELETE SET NULL;

COMMENT ON COLUMN reward_redemptions.status IS
    'requested: s asked, nothing spent yet. approved: D decided yes, ledger row written. denied: D decided no, nothing spent. fulfilled: the existing instant redeem()/gift() path, and approved requests once handed over.';
