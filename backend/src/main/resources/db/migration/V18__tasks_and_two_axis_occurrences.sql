-- Phase 1 (product/06-build-order.md): the expectation model is replaced by
-- Task + Occurrence with two independent axes — the s side's `outcome` and
-- the D side's `disposition` (product/03-domain.md). Pre-launch: the old
-- tables are dropped, not migrated.

-- ---------------------------------------------------------------------------
-- Members take a side. Authorization still runs on role_context; `side` says
-- who delivers and who disposes. Existing rows: creator D, partner S, unless
-- the preset already said otherwise.
ALTER TABLE memberships ADD COLUMN side text;
UPDATE memberships SET side = CASE
    WHEN role_preset = 'SUBMISSIVE' THEN 'S'
    WHEN role_preset = 'DOMINANT'   THEN 'D'
    WHEN role_context = 'CREATOR'   THEN 'D'
    ELSE 'S' END;
ALTER TABLE memberships
    ALTER COLUMN side SET NOT NULL,
    ADD CONSTRAINT memberships_side_ck CHECK (side IN ('D', 'S'));
ALTER TABLE invites ADD COLUMN intended_side text
    CHECK (intended_side IS NULL OR intended_side IN ('D', 'S'));

-- Relationship day starts at 04:00 by default (D-04). Stored in minutes so a
-- non-hour boundary stays representable.
ALTER TABLE dynamics
    ALTER COLUMN day_boundary_minutes SET DEFAULT 240,
    ADD COLUMN honorific_for_d text,
    ADD COLUMN honorific_for_s text;

-- ---------------------------------------------------------------------------
-- Out with the old model.
ALTER TABLE point_entries DROP CONSTRAINT point_entries_occurrence_id_fkey;
ALTER TABLE consequence_events DROP CONSTRAINT consequence_events_occurrence_id_fkey;
UPDATE point_entries SET occurrence_id = NULL;
UPDATE consequence_events SET occurrence_id = NULL;

DROP TABLE IF EXISTS occurrence_completions;
DROP TABLE IF EXISTS acknowledgements;
DROP TABLE IF EXISTS adjustment_requests;
DROP TABLE IF EXISTS occurrences;
DROP TABLE IF EXISTS expectation_recurrences;
DROP TABLE IF EXISTS expectation_definitions;

-- ---------------------------------------------------------------------------
CREATE TABLE tasks (
    id                 uuid PRIMARY KEY,
    dynamic_id         uuid NOT NULL REFERENCES dynamics(id) ON DELETE CASCADE,
    title              text NOT NULL CHECK (char_length(title) BETWEEN 1 AND 120),
    detail             text CHECK (detail IS NULL OR char_length(detail) <= 1000),
    kind               text NOT NULL CHECK (kind IN ('recurring', 'one_off', 'open', 'checkin', 'measure')),
    -- recurring: {"type":"daily"} | {"type":"weekdays","days":[1,3,5]} | {"type":"every_n_days","n":3,"from":"2026-09-03"}
    schedule           jsonb,
    times_per_day      integer NOT NULL DEFAULT 1 CHECK (times_per_day BETWEEN 1 AND 12),
    -- local time of day (dynamic timezone) a recurring/checkin slot is due; NULL = end of relationship day
    due_time           time,
    -- one_off only
    due_at             timestamptz,
    proof              text NOT NULL DEFAULT 'check' CHECK (proof IN ('check', 'photo', 'text', 'any')),
    points_earn        integer NOT NULL DEFAULT 0 CHECK (points_earn BETWEEN 0 AND 1000),
    requires_d_present boolean NOT NULL DEFAULT false,
    paused_until       timestamptz,
    unit               text,
    created_by         uuid NOT NULL REFERENCES users(id),
    status             text NOT NULL DEFAULT 'active' CHECK (status IN ('proposed', 'active', 'archived')),
    position           integer NOT NULL DEFAULT 0,
    created_at         timestamptz NOT NULL DEFAULT now(),
    updated_at         timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT tasks_recurring_has_schedule CHECK (kind <> 'recurring' OR schedule IS NOT NULL)
);
CREATE INDEX tasks_dynamic_status_idx ON tasks (dynamic_id, status, position);

CREATE TABLE consequences (
    id          uuid PRIMARY KEY,
    dynamic_id  uuid NOT NULL REFERENCES dynamics(id) ON DELETE CASCADE,
    -- Always a person on the D side. There is no code path that fills this
    -- from a job (invariant 2).
    issued_by   uuid NOT NULL REFERENCES users(id),
    template_id uuid REFERENCES consequence_agreements(id) ON DELETE SET NULL,
    title       text NOT NULL CHECK (char_length(title) BETWEEN 1 AND 200),
    detail      text CHECK (detail IS NULL OR char_length(detail) <= 1000),
    status      text NOT NULL DEFAULT 'issued' CHECK (status IN ('issued', 'done_by_s', 'confirmed', 'waived')),
    issued_at   timestamptz NOT NULL DEFAULT now(),
    done_at     timestamptz,
    decided_at  timestamptz
);
CREATE INDEX consequences_dynamic_idx ON consequences (dynamic_id, issued_at DESC);

CREATE TABLE occurrences (
    id               uuid PRIMARY KEY,
    task_id          uuid NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    dynamic_id       uuid NOT NULL REFERENCES dynamics(id) ON DELETE CASCADE,
    -- relationship day, per dynamics.reference_timezone + day_boundary_minutes
    day              date NOT NULL,
    slot             integer NOT NULL DEFAULT 0,
    due_at           timestamptz,
    -- s axis
    outcome          text NOT NULL DEFAULT 'open' CHECK (outcome IN
                         ('open', 'delivered', 'delivered_late', 'cant_do',
                          'new_time_requested', 'discuss_requested', 'missed', 'paused')),
    outcome_at       timestamptz,
    outcome_note     text CHECK (outcome_note IS NULL OR char_length(outcome_note) <= 1000),
    proof_kind       text CHECK (proof_kind IS NULL OR proof_kind IN ('check', 'photo', 'text')),
    proof_ref        text,
    proposed_time    timestamptz,
    -- D axis — independent, never expires (invariant 3)
    disposition      text NOT NULL DEFAULT 'none' CHECK (disposition IN
                         ('none', 'seen', 'praised', 'let_go', 'make_up', 'punished')),
    disposition_at   timestamptz,
    disposition_note text CHECK (disposition_note IS NULL OR char_length(disposition_note) <= 1000),
    consequence_id   uuid REFERENCES consequences(id) ON DELETE SET NULL,
    make_up_day      date,
    make_up_of       uuid REFERENCES occurrences(id) ON DELETE SET NULL,
    -- read receipt, separate from disposition
    seen_at          timestamptz,
    points_credited  boolean NOT NULL DEFAULT false,
    version          integer NOT NULL DEFAULT 1,
    created_at       timestamptz NOT NULL DEFAULT now(),
    updated_at       timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT occurrences_punished_has_consequence
        CHECK (disposition <> 'punished' OR consequence_id IS NOT NULL),
    CONSTRAINT occurrences_make_up_has_day
        CHECK (disposition <> 'make_up' OR make_up_day IS NOT NULL)
);
-- Generation is idempotent by construction.
CREATE UNIQUE INDEX occurrences_task_day_slot_uq ON occurrences (task_id, day, slot);
CREATE INDEX occurrences_dynamic_day_idx ON occurrences (dynamic_id, day DESC);
CREATE INDEX occurrences_needs_d_idx ON occurrences (dynamic_id)
    WHERE outcome <> 'open' AND outcome <> 'paused' AND disposition = 'none';

ALTER TABLE point_entries
    ADD CONSTRAINT point_entries_occurrence_id_fkey
        FOREIGN KEY (occurrence_id) REFERENCES occurrences(id) ON DELETE SET NULL;
ALTER TABLE consequence_events
    ADD CONSTRAINT consequence_events_occurrence_id_fkey
        FOREIGN KEY (occurrence_id) REFERENCES occurrences(id) ON DELETE SET NULL;

-- Every change on either axis, so a withdrawn outcome or a revised
-- disposition keeps its trail.
CREATE TABLE occurrence_history (
    id            uuid PRIMARY KEY,
    occurrence_id uuid NOT NULL REFERENCES occurrences(id) ON DELETE CASCADE,
    at            timestamptz NOT NULL DEFAULT now(),
    -- NULL only for the day-end `missed` mark and pause/unpause sweeps
    by_user_id    uuid REFERENCES users(id),
    axis          text NOT NULL CHECK (axis IN ('outcome', 'disposition')),
    from_value    text NOT NULL,
    to_value      text NOT NULL,
    note          text
);
CREATE INDEX occurrence_history_occurrence_idx ON occurrence_history (occurrence_id, at);

-- ---------------------------------------------------------------------------
CREATE TABLE day_comments (
    id         uuid PRIMARY KEY,
    dynamic_id uuid NOT NULL REFERENCES dynamics(id) ON DELETE CASCADE,
    day        date NOT NULL,
    author_id  uuid NOT NULL REFERENCES users(id),
    body       text NOT NULL CHECK (char_length(body) BETWEEN 1 AND 2000),
    created_at timestamptz NOT NULL DEFAULT now(),
    deleted_at timestamptz
);
CREATE INDEX day_comments_day_idx ON day_comments (dynamic_id, day, created_at);

CREATE TABLE private_notes (
    id         uuid PRIMARY KEY,
    dynamic_id uuid NOT NULL REFERENCES dynamics(id) ON DELETE CASCADE,
    day        date NOT NULL,
    author_id  uuid NOT NULL REFERENCES users(id),
    body       text NOT NULL CHECK (char_length(body) <= 5000),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (dynamic_id, day, author_id)
);

CREATE TABLE d_notes (
    id         uuid PRIMARY KEY,
    dynamic_id uuid NOT NULL REFERENCES dynamics(id) ON DELETE CASCADE,
    author_id  uuid NOT NULL REFERENCES users(id),
    body       text NOT NULL CHECK (char_length(body) BETWEEN 1 AND 1000),
    remind_at  timestamptz,
    reminded_at timestamptz,
    done_at    timestamptz,
    created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX d_notes_author_idx ON d_notes (dynamic_id, author_id, done_at, remind_at);

-- Points reasons follow the domain doc. Old rows are renamed in place.
ALTER TABLE point_entries DROP CONSTRAINT point_entries_reason_check;
UPDATE point_entries SET reason = CASE reason
    WHEN 'COMPLETION'      THEN 'task_earn'
    WHEN 'MANUAL_AWARD'    THEN 'd_award'
    WHEN 'MANUAL_DEDUCT'   THEN 'd_deduct'
    WHEN 'REWARD_PURCHASE' THEN 'redemption'
    WHEN 'CONSEQUENCE'     THEN 'd_deduct'
    ELSE reason END;
ALTER TABLE point_entries ADD CONSTRAINT point_entries_reason_check CHECK (
    reason IN ('task_earn', 'd_award', 'd_deduct', 'redemption', 'redemption_refund')
);
-- Only the automatic credit may lack an actor; every deduction is a person's.
ALTER TABLE point_entries ADD CONSTRAINT point_entries_deduction_by_person
    CHECK (amount > 0 OR actor_user_id IS NOT NULL);
