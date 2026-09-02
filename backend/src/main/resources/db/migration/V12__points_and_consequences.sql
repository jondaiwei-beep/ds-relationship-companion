-- Points, rewards and consequences — owner decision 2026-09-02.
--
-- Reverses the earlier non-goal. The reasoning and the four constraints that
-- survive it are recorded in product/00-overview.md under "Points and
-- consequences"; this file enforces the two of them that belong in the
-- schema, so a future bug cannot quietly break either.
--
--   1. A person always decides a consequence.  ->  issued_by_user_id NOT NULL
--   2. Points never mark a moment as answered. ->  no occurrence state is
--      written here; the ledger is a separate table and the acknowledgement
--      path is untouched.

-- ---------------------------------------------------------------------------
-- Ledger. Append-only: a balance is a sum, never a stored number that can
-- drift from its own history or be edited without a trace.
CREATE TABLE point_entries (
    id            uuid PRIMARY KEY,
    dynamic_id    uuid NOT NULL REFERENCES dynamics(id) ON DELETE CASCADE,

    -- Whose balance moves. In a couple this is normally the receiving member.
    subject_user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- Signed: awards are positive, spending a reward is negative.
    amount        integer NOT NULL,

    -- Why, in the app's own terms. Free text is the note, not this.
    reason        text NOT NULL,

    -- The occurrence that earned it, when there was one.
    occurrence_id uuid REFERENCES occurrences(id) ON DELETE SET NULL,

    -- The reward that was bought, when that is what happened.
    reward_id     uuid,

    -- Who caused it. NULL means the rule engine awarded it on completion,
    -- which is allowed for points and never for consequences.
    actor_user_id uuid REFERENCES users(id) ON DELETE SET NULL,

    note          text,
    created_at    timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT point_entries_amount_nonzero CHECK (amount <> 0),
    CONSTRAINT point_entries_reason_check CHECK (
        reason IN ('COMPLETION', 'MANUAL_AWARD', 'MANUAL_DEDUCT', 'REWARD_PURCHASE', 'CONSEQUENCE')
    ),
    CONSTRAINT point_entries_note_length CHECK (note IS NULL OR char_length(note) <= 500)
);

CREATE INDEX point_entries_balance_idx ON point_entries (dynamic_id, subject_user_id);
CREATE INDEX point_entries_recent_idx ON point_entries (dynamic_id, created_at DESC);

COMMENT ON TABLE point_entries IS
    'Append-only points ledger. Balance = SUM(amount). Never updated or deleted.';
COMMENT ON COLUMN point_entries.actor_user_id IS
    'Who acted. NULL only for automatic completion awards.';

-- ---------------------------------------------------------------------------
-- What points can be spent on. Set by the member giving direction, since the
-- whole point of a reward is that it is in their gift.
CREATE TABLE rewards (
    id            uuid PRIMARY KEY,
    dynamic_id    uuid NOT NULL REFERENCES dynamics(id) ON DELETE CASCADE,
    created_by_user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    title         text NOT NULL,
    detail        text,

    -- What it costs. Zero is legal: some rewards are simply on offer.
    cost          integer NOT NULL,

    -- Withdrawn rather than deleted, so history that references it still reads.
    active        boolean NOT NULL DEFAULT true,

    created_at    timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT rewards_cost_check CHECK (cost >= 0),
    CONSTRAINT rewards_title_length CHECK (char_length(title) BETWEEN 1 AND 120),
    CONSTRAINT rewards_detail_length CHECK (detail IS NULL OR char_length(detail) <= 500)
);

CREATE INDEX rewards_dynamic_idx ON rewards (dynamic_id) WHERE active;

-- ---------------------------------------------------------------------------
-- Agreed consequences. The couple writes these in advance; a person invokes
-- them. See product/design/agreed-consequences.md.
CREATE TABLE consequence_agreements (
    id            uuid PRIMARY KEY,
    dynamic_id    uuid NOT NULL REFERENCES dynamics(id) ON DELETE CASCADE,
    created_by_user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    label         text NOT NULL,
    consequence   text NOT NULL,

    -- Points deducted alongside, when the couple wants that. Optional.
    point_cost    integer NOT NULL DEFAULT 0,

    active        boolean NOT NULL DEFAULT true,
    created_at    timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT consequence_agreements_label_length CHECK (char_length(label) BETWEEN 1 AND 120),
    CONSTRAINT consequence_agreements_text_length CHECK (char_length(consequence) BETWEEN 1 AND 500),
    CONSTRAINT consequence_agreements_cost_check CHECK (point_cost >= 0)
);

CREATE INDEX consequence_agreements_dynamic_idx
    ON consequence_agreements (dynamic_id) WHERE active;

-- ---------------------------------------------------------------------------
-- What was actually invoked, and by whom.
--
-- `issued_by_user_id` is NOT NULL and there is no code path that fills it
-- from anything but the authenticated caller. That is the schema-level
-- guarantee that no timer, sweep or scheduler can ever issue a consequence:
-- the constraint holds even if someone later writes the wrong service code.
CREATE TABLE consequence_events (
    id            uuid PRIMARY KEY,
    dynamic_id    uuid NOT NULL REFERENCES dynamics(id) ON DELETE CASCADE,
    agreement_id  uuid REFERENCES consequence_agreements(id) ON DELETE SET NULL,
    occurrence_id uuid REFERENCES occurrences(id) ON DELETE SET NULL,

    issued_by_user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subject_user_id   uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    -- WAIVED is shown as prominently as ISSUED. Mercy is the move an
    -- automatic system cannot make, and hiding it would waste it.
    outcome       text NOT NULL,

    note          text,
    created_at    timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT consequence_events_outcome_check CHECK (outcome IN ('ISSUED', 'WAIVED')),
    CONSTRAINT consequence_events_note_length CHECK (note IS NULL OR char_length(note) <= 500)
);

CREATE INDEX consequence_events_dynamic_idx ON consequence_events (dynamic_id, created_at DESC);

COMMENT ON COLUMN consequence_events.issued_by_user_id IS
    'Always a real person. The software never issues a consequence (REQ-REVIEW-001).';

-- ---------------------------------------------------------------------------
-- Per-dynamic settings, so a couple who wants the structure without the
-- economy can have it.
ALTER TABLE dynamics
    ADD COLUMN points_enabled boolean NOT NULL DEFAULT true,
    -- Awarded automatically when an occurrence is completed. Zero turns the
    -- automatic half off while leaving manual awards available.
    ADD COLUMN points_per_completion integer NOT NULL DEFAULT 1;

ALTER TABLE dynamics
    ADD CONSTRAINT dynamics_points_per_completion_check
        CHECK (points_per_completion BETWEEN 0 AND 100);
