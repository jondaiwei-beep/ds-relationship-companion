SET TIME ZONE 'UTC';

CREATE TABLE users (
    id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    email                   text NOT NULL,
    display_name            text,
    -- Notion 03 §2: age gate is a User property, never inferred.
    age_gate_confirmed_at   timestamptz,
    -- IANA timezone. Notion 04 §9: never a bare UTC offset.
    timezone                text NOT NULL DEFAULT 'UTC',
    -- Notion 04 §5: neutral surfaces by default; user may raise preview richness.
    notification_preview    text NOT NULL DEFAULT 'NEUTRAL',
    quiet_hours_start_min   integer,
    quiet_hours_end_min     integer,
    account_state           text NOT NULL DEFAULT 'ACTIVE',
    created_at              timestamptz NOT NULL DEFAULT now(),
    updated_at              timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT users_email_not_blank_ck CHECK (btrim(email) <> ''),
    CONSTRAINT users_notification_preview_ck
        CHECK (notification_preview IN ('NEUTRAL', 'RICH')),
    CONSTRAINT users_account_state_ck
        CHECK (account_state IN ('ACTIVE', 'SUSPENDED', 'DELETED')),
    CONSTRAINT users_quiet_hours_start_ck
        CHECK (quiet_hours_start_min IS NULL OR quiet_hours_start_min BETWEEN 0 AND 1439),
    CONSTRAINT users_quiet_hours_end_ck
        CHECK (quiet_hours_end_min IS NULL OR quiet_hours_end_min BETWEEN 0 AND 1439)
);

CREATE UNIQUE INDEX users_email_uq ON users (lower(email));

COMMENT ON COLUMN users.timezone IS
    'IANA timezone name. Notion 04 §9 forbids storing a bare UTC offset.';
COMMENT ON COLUMN users.age_gate_confirmed_at IS
    'Null until the user passes the neutral 18+ gate.';

COMMENT ON TABLE users IS 'Human users. All instants use timestamptz and are stored internally in UTC.';

CREATE TABLE dynamics (
    id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    mode                  text NOT NULL,
    desired_outcome       text NOT NULL,
    structure_level       text NOT NULL,
    state                 text NOT NULL DEFAULT 'DRAFT',
    reference_timezone    text NOT NULL,
    day_boundary_minutes  integer NOT NULL DEFAULT 0,
    paused_at             timestamptz,
    version               integer NOT NULL DEFAULT 0,
    created_at            timestamptz NOT NULL DEFAULT now(),
    updated_at            timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT dynamics_mode_check
        CHECK (mode IN ('SOLO', 'COUPLE')),
    CONSTRAINT dynamics_state_check
        CHECK (state IN (
            'DRAFT',
            'PENDING_PARTNER',
            'ACTIVE',
            'PAUSED',
            'ENDED'
        )),
    CONSTRAINT dynamics_day_boundary_minutes_check
        CHECK (day_boundary_minutes BETWEEN 0 AND 1439),
    CONSTRAINT dynamics_version_check
        CHECK (version >= 0),
    CONSTRAINT dynamics_paused_at_check
        CHECK (state = 'PAUSED' OR paused_at IS NULL)
);

COMMENT ON COLUMN dynamics.reference_timezone IS 'IANA time-zone identifier interpreted by the application.';
COMMENT ON COLUMN dynamics.day_boundary_minutes IS 'Relationship-day boundary as minutes after local midnight.';
COMMENT ON COLUMN dynamics.version IS 'Optimistic-locking version incremented by application writes.';

CREATE TABLE memberships (
    id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id       uuid NOT NULL REFERENCES users(id),
    dynamic_id    uuid NOT NULL REFERENCES dynamics(id),
    role_context  text NOT NULL,
    access_state  text NOT NULL DEFAULT 'ACTIVE',
    joined_at     timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT memberships_access_state_check
        CHECK (access_state IN ('ACTIVE', 'LEFT', 'BLOCKED'))
);

CREATE UNIQUE INDEX memberships_one_active_per_user_dynamic_uq
    ON memberships (user_id, dynamic_id)
    WHERE access_state = 'ACTIVE';

CREATE INDEX memberships_dynamic_id_idx
    ON memberships (dynamic_id);

COMMENT ON COLUMN memberships.role_context IS 'Application-defined preset describing the member role in this dynamic.';
COMMENT ON INDEX memberships_one_active_per_user_dynamic_uq IS 'Allows membership history while enforcing at most one active membership per user and dynamic.';

CREATE TABLE invites (
    id                     uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    dynamic_id             uuid NOT NULL REFERENCES dynamics(id),
    inviter_user_id        uuid NOT NULL REFERENCES users(id),
    intended_role_context  text NOT NULL,
    token_hash             bytea NOT NULL,
    expires_at             timestamptz NOT NULL,
    state                  text NOT NULL DEFAULT 'PENDING',
    created_at             timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT invites_token_hash_sha256_check
        CHECK (octet_length(token_hash) = 32),
    CONSTRAINT invites_state_check
        CHECK (state IN ('PENDING', 'ACCEPTED', 'EXPIRED', 'REVOKED')),
    CONSTRAINT invites_expiry_check
        CHECK (expires_at > created_at)
);

CREATE UNIQUE INDEX invites_one_pending_per_dynamic_uq
    ON invites (dynamic_id)
    WHERE state = 'PENDING';

COMMENT ON COLUMN invites.token_hash IS 'Raw 32-byte SHA-256 digest; invitation tokens must never be stored.';
COMMENT ON INDEX invites_one_pending_per_dynamic_uq IS 'Enforces at most one pending invitation per dynamic.';

CREATE TABLE expectation_definitions (
    id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    dynamic_id       uuid NOT NULL REFERENCES dynamics(id),
    kind             text NOT NULL,
    title            text NOT NULL,
    purpose          text,
    creator_user_id  uuid NOT NULL REFERENCES users(id),
    assignee_user_id uuid NOT NULL REFERENCES users(id),
    visibility       text NOT NULL,
    active           boolean NOT NULL DEFAULT true,
    created_at       timestamptz NOT NULL DEFAULT now(),
    updated_at       timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT expectation_definitions_kind_check
        CHECK (kind IN ('TASK', 'RITUAL')),
    CONSTRAINT expectation_definitions_title_check
        CHECK (btrim(title) <> ''),
    CONSTRAINT expectation_definitions_id_dynamic_uq
        UNIQUE (id, dynamic_id)
);

CREATE INDEX expectation_definitions_dynamic_active_idx
    ON expectation_definitions (dynamic_id, active);

COMMENT ON COLUMN expectation_definitions.visibility IS 'Application-defined visibility preset.';

CREATE TABLE occurrences (
    id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    definition_id     uuid NOT NULL,
    dynamic_id        uuid NOT NULL REFERENCES dynamics(id),
    state             text NOT NULL DEFAULT 'SCHEDULED',
    relationship_day  date NOT NULL,
    -- Nullable: Notion 03 §2 treats dueAt as optional. A Ritual may have no
    -- hard deadline; only the relationship_day is required.
    due_at             timestamptz,
    version            integer NOT NULL DEFAULT 0,
    created_at         timestamptz NOT NULL DEFAULT now(),
    updated_at         timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT occurrences_definition_dynamic_fk
        FOREIGN KEY (definition_id, dynamic_id)
        REFERENCES expectation_definitions (id, dynamic_id),
    CONSTRAINT occurrences_state_check
        CHECK (state IN (
            'SCHEDULED',
            'ACTIVE',
            'WAITING_ACK',
            'ACKNOWLEDGED',
            'NEEDS_REVIEW',
            'REVIEWED',
            'NEED_TO_DISCUSS',
            'RESCHEDULE_REQUESTED',
            'EXCUSE_REQUESTED',
            'EXCUSED',
            'CANCELLED'
        )),
    CONSTRAINT occurrences_version_check
        CHECK (version >= 0)
);

CREATE UNIQUE INDEX occurrences_one_nonterminal_per_definition_day_uq
    ON occurrences (definition_id, relationship_day)
    WHERE state NOT IN (
        'ACKNOWLEDGED',
        'REVIEWED',
        'EXCUSED',
        'CANCELLED'
    );

CREATE INDEX occurrences_dynamic_day_idx
    ON occurrences (dynamic_id, relationship_day);

CREATE INDEX occurrences_due_active_idx
    ON occurrences (due_at)
    WHERE state IN (
        'SCHEDULED',
        'ACTIVE',
        'WAITING_ACK',
        'NEEDS_REVIEW',
        'RESCHEDULE_REQUESTED',
        'EXCUSE_REQUESTED'
    );

COMMENT ON COLUMN occurrences.relationship_day IS 'Date in the dynamic reference timezone after applying its configured day boundary.';
COMMENT ON COLUMN occurrences.version IS 'Optimistic-locking version incremented by application writes.';
COMMENT ON INDEX occurrences_one_nonterminal_per_definition_day_uq IS
    'Terminal states are ACKNOWLEDGED, REVIEWED, EXCUSED, CANCELLED. NEED_TO_DISCUSS is deliberately NOT terminal: an open discussion must still block a duplicate occurrence for the same definition/day, and should resolve back onto an active path (see docs/OPEN_SPEC_GAPS.md G-3).';

CREATE TABLE idempotency_keys (
    id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_user_id     uuid NOT NULL REFERENCES users(id),
    key_value         text NOT NULL,
    command_name      text NOT NULL,
    request_hash      bytea NOT NULL,
    state             text NOT NULL DEFAULT 'IN_PROGRESS',
    response_status   integer,
    response_body     bytea,
    created_at        timestamptz NOT NULL DEFAULT now(),
    completed_at      timestamptz,

    CONSTRAINT idempotency_keys_actor_key_uq
        UNIQUE (actor_user_id, key_value),
    -- Composite target so completions/acknowledgements can FK on
    -- (idempotency_id, actor) and prove the command belonged to that actor.
    CONSTRAINT idempotency_keys_id_actor_uq
        UNIQUE (id, actor_user_id),
    -- A COMPLETED key must carry a replayable response.
    CONSTRAINT idempotency_keys_completion_ck
        CHECK (
            (state = 'IN_PROGRESS' AND completed_at IS NULL)
            OR
            (state = 'COMPLETED' AND completed_at IS NOT NULL AND response_status IS NOT NULL)
        ),
    CONSTRAINT idempotency_keys_key_value_check
        CHECK (btrim(key_value) <> ''),
    CONSTRAINT idempotency_keys_command_name_check
        CHECK (btrim(command_name) <> ''),
    CONSTRAINT idempotency_keys_request_hash_check
        CHECK (octet_length(request_hash) = 32),
    CONSTRAINT idempotency_keys_state_check
        CHECK (state IN ('IN_PROGRESS', 'COMPLETED')),
    CONSTRAINT idempotency_keys_response_status_check
        CHECK (response_status IS NULL OR response_status BETWEEN 100 AND 599),
    CONSTRAINT idempotency_keys_completion_check
        CHECK (
            (state = 'IN_PROGRESS' AND response_status IS NULL AND response_body IS NULL)
            OR
            (state = 'COMPLETED' AND response_status IS NOT NULL)
        )
);

COMMENT ON COLUMN idempotency_keys.request_hash IS 'Raw 32-byte SHA-256 digest of the canonicalized command request.';
COMMENT ON COLUMN idempotency_keys.response_body IS 'Serialized response bytes returned for completed duplicate commands.';

CREATE TABLE occurrence_completions (
    id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    occurrence_id    uuid NOT NULL UNIQUE REFERENCES occurrences(id),
    actor_user_id    uuid NOT NULL REFERENCES users(id),
    completed_at     timestamptz NOT NULL DEFAULT now(),
    note             text,
    idempotency_id   uuid NOT NULL UNIQUE REFERENCES idempotency_keys(id)
);

COMMENT ON TABLE occurrence_completions IS 'At most one completion record exists for each occurrence.';

CREATE TABLE acknowledgements (
    id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    occurrence_id    uuid NOT NULL UNIQUE REFERENCES occurrences(id),
    sender_user_id   uuid NOT NULL REFERENCES users(id),
    type             text NOT NULL,
    text             text,
    sent_at          timestamptz NOT NULL DEFAULT now(),
    idempotency_id   uuid NOT NULL UNIQUE REFERENCES idempotency_keys(id),

    CONSTRAINT acknowledgements_type_check
        CHECK (type IN ('ACKNOWLEDGE', 'PRAISE', 'COMMENT', 'REVIEW')),
    CONSTRAINT acknowledgements_text_check
        CHECK (
            type IN ('ACKNOWLEDGE', 'PRAISE')
            OR (text IS NOT NULL AND btrim(text) <> '')
        )
);

COMMENT ON COLUMN acknowledgements.sender_user_id IS 'Non-null user reference guarantees a human sender.';

CREATE TABLE relationship_events (
    id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_user_id  uuid REFERENCES users(id),
    dynamic_id     uuid NOT NULL REFERENCES dynamics(id),
    event_type     text NOT NULL,
    object_ref     text NOT NULL,
    occurred_at    timestamptz NOT NULL DEFAULT now(),
    payload        jsonb NOT NULL DEFAULT '{}'::jsonb,

    CONSTRAINT relationship_events_event_type_check
        CHECK (btrim(event_type) <> ''),
    CONSTRAINT relationship_events_object_ref_check
        CHECK (btrim(object_ref) <> ''),
    CONSTRAINT relationship_events_payload_object_check
        CHECK (jsonb_typeof(payload) = 'object')
);

CREATE INDEX relationship_events_dynamic_occurred_idx
    ON relationship_events (dynamic_id, occurred_at, id);

COMMENT ON TABLE relationship_events IS 'Immutable append-only relationship history; actor_user_id may be null for system-generated events.';

CREATE FUNCTION prevent_relationship_event_mutation()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE EXCEPTION
        USING
            ERRCODE = '55000',
            MESSAGE = 'relationship_events is append-only; UPDATE and DELETE are prohibited';
END;
$$;

CREATE TRIGGER relationship_events_append_only
BEFORE UPDATE OR DELETE ON relationship_events
FOR EACH ROW
EXECUTE FUNCTION prevent_relationship_event_mutation();

CREATE TABLE outbox_records (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    aggregate_type  text NOT NULL,
    aggregate_id    uuid NOT NULL,
    event_type      text NOT NULL,
    payload         jsonb NOT NULL,
    dedupe_key      text NOT NULL UNIQUE,
    not_before      timestamptz NOT NULL DEFAULT now(),
    state           text NOT NULL DEFAULT 'PENDING',
    attempts        integer NOT NULL DEFAULT 0,
    locked_until    timestamptz,
    created_at      timestamptz NOT NULL DEFAULT now(),
    sent_at         timestamptz,

    CONSTRAINT outbox_records_aggregate_type_check
        CHECK (btrim(aggregate_type) <> ''),
    CONSTRAINT outbox_records_event_type_check
        CHECK (btrim(event_type) <> ''),
    CONSTRAINT outbox_records_dedupe_key_check
        CHECK (btrim(dedupe_key) <> ''),
    CONSTRAINT outbox_records_payload_object_check
        CHECK (jsonb_typeof(payload) = 'object'),
    CONSTRAINT outbox_records_state_check
        CHECK (state IN ('PENDING', 'SENT', 'FAILED', 'CANCELLED')),
    CONSTRAINT outbox_records_attempts_check
        CHECK (attempts >= 0),
    CONSTRAINT outbox_records_sent_state_check
        CHECK (
            (state = 'SENT' AND sent_at IS NOT NULL)
            OR
            (state <> 'SENT' AND sent_at IS NULL)
        )
);

CREATE INDEX outbox_records_claim_idx
    ON outbox_records (not_before, created_at, id)
    INCLUDE (locked_until, attempts)
    WHERE state = 'PENDING';

COMMENT ON INDEX outbox_records_claim_idx IS 'Supports ordered FOR UPDATE SKIP LOCKED claiming of due, unlocked pending records.';
