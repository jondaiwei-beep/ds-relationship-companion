-- Ritual recurrence + Check-in — Notion 02 §A3, 03 §2.
--
-- Deliberately NOT an RRULE engine. Notion 06 §11 forbids a universal rule DSL
-- in Core Beta, and the Starter Rhythm only needs "every day at 20:30" and
-- "every Monday at 20:30". Two frequencies, a local time, and a timezone.

CREATE TABLE expectation_recurrences (
    id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    definition_id       uuid NOT NULL REFERENCES expectation_definitions (id),

    frequency           text NOT NULL,
    -- ISO weekday 1..7 (Mon..Sun). Required for WEEKLY, absent for DAILY.
    weekday             integer,

    -- LOCAL WALL-CLOCK time. Notion 04 §9: never a bare UTC offset — after a
    -- DST change a 20:30 ritual must still fire at 20:30 local.
    local_time          time NOT NULL,
    -- The recurrence's own IANA zone, which may differ from the Dynamic's.
    timezone            text NOT NULL,

    -- Generation barrier. Resume advances this instead of replaying missed
    -- days, so returning never produces a backlog to catch up on (Journey E).
    eligible_from_day   date,

    active              boolean NOT NULL DEFAULT true,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT expectation_recurrences_frequency_ck
        CHECK (frequency IN ('DAILY', 'WEEKLY')),
    CONSTRAINT expectation_recurrences_weekday_ck
        CHECK ((frequency = 'WEEKLY' AND weekday BETWEEN 1 AND 7)
            OR (frequency = 'DAILY' AND weekday IS NULL)),
    -- One recurrence per definition keeps Core Beta simple.
    CONSTRAINT expectation_recurrences_definition_uq UNIQUE (definition_id)
);

CREATE INDEX expectation_recurrences_active_idx
    ON expectation_recurrences (active) WHERE active;

-- Link generated occurrences back to their recurrence.
ALTER TABLE occurrences
    ADD COLUMN IF NOT EXISTS recurrence_id uuid REFERENCES expectation_recurrences (id);

-- Idempotent generation. The existing partial index only covers NON-TERMINAL
-- rows, so once an occurrence is acknowledged a second run could create a
-- duplicate for the same day. This full unique constraint prevents that.
CREATE UNIQUE INDEX occurrences_one_per_recurrence_day_uq
    ON occurrences (recurrence_id, relationship_day)
    WHERE recurrence_id IS NOT NULL;

COMMENT ON COLUMN expectation_recurrences.eligible_from_day IS
    'Generation barrier. Resume sets this to the current relationship day so '
    'paused days are never back-filled (Notion 03 §4).';
COMMENT ON INDEX occurrences_one_per_recurrence_day_uq IS
    'Makes generation idempotent even after an occurrence reaches a terminal '
    'state, which the partial non-terminal index does not cover.';

-- Check-ins — Notion 03 §2.
CREATE TABLE check_ins (
    id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    dynamic_id          uuid NOT NULL REFERENCES dynamics (id),
    creator_user_id     uuid NOT NULL REFERENCES users (id),
    relationship_day    date NOT NULL,

    mood                text,
    energy              text,
    need                text,
    note                text,

    -- Notion 04 §3: visibility is EXPLICIT. There is no "in a dynamic so
    -- obviously shared" default, and Solo -> Couple never auto-shares.
    visibility          text NOT NULL DEFAULT 'PRIVATE',

    created_at          timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT check_ins_visibility_ck
        CHECK (visibility IN ('PRIVATE', 'SHARED')),
    CONSTRAINT check_ins_energy_ck
        CHECK (energy IS NULL OR energy IN ('LOW', 'STEADY', 'HIGH'))
);

CREATE INDEX check_ins_dynamic_day_idx
    ON check_ins (dynamic_id, relationship_day DESC);
CREATE INDEX check_ins_creator_idx
    ON check_ins (creator_user_id, created_at DESC);

COMMENT ON COLUMN check_ins.visibility IS
    'PRIVATE check-ins are filtered in the READ query, never merely hidden in '
    'the UI, and never produce a shared timeline event or notification.';
