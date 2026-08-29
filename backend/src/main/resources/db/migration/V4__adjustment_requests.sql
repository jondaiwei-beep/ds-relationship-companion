-- Adjustment path — Notion 03 §2, 02 §5, Journey D.
--
-- "Need to Discuss", "Request a new time" and "I can't do this right now" are
-- inviolable agency: no role may disable them (red line #4). None of them is a
-- Miss, a failure, or disobedience — adjustment is the NORMAL path when life
-- gets in the way (red line #3).

CREATE TABLE adjustment_requests (
    id                        uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    occurrence_id             uuid NOT NULL REFERENCES occurrences (id),
    requester_user_id         uuid NOT NULL REFERENCES users (id),

    -- What was asked for.
    type                      text NOT NULL,
    note                      text,
    -- Only meaningful for a reschedule request.
    requested_at_time         timestamptz,

    status                    text NOT NULL DEFAULT 'OPEN',

    -- How the partner resolved it, and who resolved it.
    resolution                text,
    resolver_user_id          uuid REFERENCES users (id),
    resolution_note           text,
    -- Set when a reschedule produced a new occurrence, so the UI can say
    -- "Rescheduled to ..." instead of the storage state "Cancelled".
    replacement_occurrence_id uuid REFERENCES occurrences (id),

    created_at                timestamptz NOT NULL DEFAULT now(),
    resolved_at               timestamptz,

    CONSTRAINT adjustment_requests_type_ck
        CHECK (type IN ('DISCUSS', 'RESCHEDULE', 'CANT_DO')),
    CONSTRAINT adjustment_requests_status_ck
        CHECK (status IN ('OPEN', 'RESOLVED', 'WITHDRAWN')),
    CONSTRAINT adjustment_requests_resolution_ck
        CHECK (resolution IS NULL OR resolution IN
               ('CONTINUE', 'ADJUST', 'RESCHEDULE', 'EXCUSE', 'CANCEL')),
    -- A resolved request must record who resolved it and how.
    CONSTRAINT adjustment_requests_resolved_ck
        CHECK (
            (status = 'OPEN' AND resolution IS NULL AND resolved_at IS NULL)
            OR (status = 'WITHDRAWN' AND resolved_at IS NOT NULL)
            OR (status = 'RESOLVED' AND resolution IS NOT NULL
                AND resolver_user_id IS NOT NULL AND resolved_at IS NOT NULL)
        ),
    -- A replacement only makes sense for a reschedule.
    CONSTRAINT adjustment_requests_replacement_ck
        CHECK (replacement_occurrence_id IS NULL OR resolution = 'RESCHEDULE')
);

-- At most ONE open request per occurrence: two competing asks on the same
-- thing would leave the partner unsure what they are answering.
CREATE UNIQUE INDEX adjustment_requests_one_open_per_occurrence_uq
    ON adjustment_requests (occurrence_id)
    WHERE status = 'OPEN';

CREATE INDEX adjustment_requests_occurrence_idx
    ON adjustment_requests (occurrence_id, created_at DESC);

COMMENT ON TABLE adjustment_requests IS
    'Discuss / Reschedule / Cant-do. None of these is a Miss (Notion 03 §4).';
COMMENT ON COLUMN adjustment_requests.replacement_occurrence_id IS
    'Set when a reschedule created a new occurrence. The original is stored as '
    'CANCELLED, but the UI must render it as "Rescheduled to ...", never as a '
    'failure the person caused.';
