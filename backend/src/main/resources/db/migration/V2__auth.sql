-- V2__passwordless_auth.sql

-- Normalize email identity before enabling this in production:
-- verify there are no duplicate lower(trim(email)) values first.
CREATE UNIQUE INDEX users_normalized_email_uq
    ON users ((lower(btrim(email))));

ALTER TABLE invites
    ADD COLUMN accepted_by_user_id uuid NULL REFERENCES users(id),
    ADD COLUMN accepted_at timestamptz NULL,
    ADD COLUMN expired_at timestamptz NULL,
    ADD COLUMN revoked_at timestamptz NULL,

    ADD CONSTRAINT invites_token_hash_length_ck
        CHECK (octet_length(token_hash) = 32),

    ADD CONSTRAINT invites_expiry_ck
        CHECK (expires_at > created_at),

    ADD CONSTRAINT invites_state_ck
        CHECK (state IN ('PENDING', 'ACCEPTED', 'EXPIRED', 'REVOKED')),

    ADD CONSTRAINT invites_state_timestamp_ck CHECK (
        (state = 'PENDING'
            AND accepted_by_user_id IS NULL
            AND accepted_at IS NULL
            AND expired_at IS NULL
            AND revoked_at IS NULL)
        OR
        (state = 'ACCEPTED'
            AND accepted_by_user_id IS NOT NULL
            AND accepted_at IS NOT NULL
            AND expired_at IS NULL
            AND revoked_at IS NULL)
        OR
        (state = 'EXPIRED'
            AND accepted_by_user_id IS NULL
            AND accepted_at IS NULL
            AND expired_at IS NOT NULL
            AND revoked_at IS NULL)
        OR
        (state = 'REVOKED'
            AND accepted_by_user_id IS NULL
            AND accepted_at IS NULL
            AND expired_at IS NULL
            AND revoked_at IS NOT NULL)
    );

CREATE UNIQUE INDEX invites_token_hash_uq ON invites(token_hash);
CREATE UNIQUE INDEX memberships_user_dynamic_uq
    ON memberships(user_id, dynamic_id);

CREATE OR REPLACE FUNCTION enforce_invite_transition()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF OLD.state <> 'PENDING' AND NEW.state <> OLD.state THEN
        RAISE EXCEPTION 'terminal invite state cannot be changed';
    END IF;

    IF NEW.state = 'ACCEPTED'
       AND (OLD.state <> 'PENDING' OR clock_timestamp() >= OLD.expires_at) THEN
        RAISE EXCEPTION 'expired invite cannot be accepted';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER invites_transition_trg
BEFORE UPDATE ON invites
FOR EACH ROW EXECUTE FUNCTION enforce_invite_transition();


CREATE TABLE magic_link_tokens (
    id                  uuid PRIMARY KEY,
    flow_id             uuid NOT NULL UNIQUE,
    normalized_email    text NOT NULL,
    token_hash          bytea NOT NULL UNIQUE,
    verifier_hash       bytea NOT NULL,
    continuation_invite_id uuid NULL REFERENCES invites(id),
    state               text NOT NULL DEFAULT 'PENDING',
    created_at           timestamptz NOT NULL DEFAULT clock_timestamp(),
    expires_at           timestamptz NOT NULL,
    consumed_at          timestamptz NULL,
    expired_at           timestamptz NULL,
    revoked_at           timestamptz NULL,

    CONSTRAINT magic_link_email_normalized_ck
        CHECK (
            normalized_email = lower(btrim(normalized_email))
            AND length(normalized_email) BETWEEN 3 AND 320
        ),

    CONSTRAINT magic_link_hash_length_ck
        CHECK (
            octet_length(token_hash) = 32
            AND octet_length(verifier_hash) = 32
        ),

    CONSTRAINT magic_link_expiry_ck
        CHECK (expires_at > created_at),

    CONSTRAINT magic_link_state_ck
        CHECK (state IN ('PENDING', 'CONSUMED', 'EXPIRED', 'REVOKED')),

    CONSTRAINT magic_link_state_timestamp_ck CHECK (
        (state = 'PENDING'
            AND consumed_at IS NULL
            AND expired_at IS NULL
            AND revoked_at IS NULL)
        OR
        (state = 'CONSUMED'
            AND consumed_at IS NOT NULL
            AND expired_at IS NULL
            AND revoked_at IS NULL)
        OR
        (state = 'EXPIRED'
            AND consumed_at IS NULL
            AND expired_at IS NOT NULL
            AND revoked_at IS NULL)
        OR
        (state = 'REVOKED'
            AND consumed_at IS NULL
            AND expired_at IS NULL
            AND revoked_at IS NOT NULL)
    )
);

CREATE INDEX magic_link_email_pending_idx
    ON magic_link_tokens(normalized_email)
    WHERE state = 'PENDING';

CREATE INDEX magic_link_expiry_idx
    ON magic_link_tokens(expires_at)
    WHERE state = 'PENDING';

CREATE OR REPLACE FUNCTION enforce_magic_link_transition()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF OLD.state <> 'PENDING' AND NEW.state <> OLD.state THEN
        RAISE EXCEPTION 'terminal magic-link state cannot be changed';
    END IF;

    IF NEW.state = 'CONSUMED'
       AND (OLD.state <> 'PENDING' OR clock_timestamp() >= OLD.expires_at) THEN
        RAISE EXCEPTION 'expired magic link cannot be consumed';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER magic_link_transition_trg
BEFORE UPDATE ON magic_link_tokens
FOR EACH ROW EXECUTE FUNCTION enforce_magic_link_transition();


CREATE TABLE auth_sessions (
    id                      uuid PRIMARY KEY,
    user_id                 uuid NOT NULL REFERENCES users(id),
    client_type             text NOT NULL,
    continuation_invite_id  uuid NULL REFERENCES invites(id),
    csrf_token_hash         bytea NULL,
    created_at              timestamptz NOT NULL DEFAULT clock_timestamp(),
    last_used_at            timestamptz NOT NULL DEFAULT clock_timestamp(),
    idle_expires_at         timestamptz NOT NULL,
    absolute_expires_at     timestamptz NOT NULL,
    revoked_at              timestamptz NULL,
    revoked_reason          text NULL,

    CONSTRAINT auth_session_client_type_ck
        CHECK (client_type IN ('ANDROID', 'WEB')),

    CONSTRAINT auth_session_expiry_ck
        CHECK (
            idle_expires_at > created_at
            AND absolute_expires_at > created_at
            AND idle_expires_at <= absolute_expires_at
        ),

    CONSTRAINT auth_session_csrf_ck CHECK (
        (client_type = 'WEB' AND octet_length(csrf_token_hash) = 32)
        OR
        (client_type = 'ANDROID' AND csrf_token_hash IS NULL)
    ),

    CONSTRAINT auth_session_revocation_ck CHECK (
        (revoked_at IS NULL AND revoked_reason IS NULL)
        OR
        (revoked_at IS NOT NULL AND revoked_reason IS NOT NULL)
    )
);

CREATE INDEX auth_sessions_user_idx ON auth_sessions(user_id);
CREATE INDEX auth_sessions_expiry_idx
    ON auth_sessions(idle_expires_at)
    WHERE revoked_at IS NULL;


CREATE TABLE refresh_tokens (
    id                  uuid PRIMARY KEY,
    session_id          uuid NOT NULL REFERENCES auth_sessions(id) ON DELETE CASCADE,
    parent_token_id     uuid NULL UNIQUE REFERENCES refresh_tokens(id),
    token_hash          bytea NOT NULL UNIQUE,
    state               text NOT NULL DEFAULT 'ACTIVE',
    issued_at           timestamptz NOT NULL DEFAULT clock_timestamp(),
    expires_at          timestamptz NOT NULL,
    rotated_at          timestamptz NULL,
    revoked_at          timestamptz NULL,

    CONSTRAINT refresh_token_hash_length_ck
        CHECK (octet_length(token_hash) = 32),

    CONSTRAINT refresh_token_expiry_ck
        CHECK (expires_at > issued_at),

    CONSTRAINT refresh_token_state_ck
        CHECK (state IN ('ACTIVE', 'ROTATED', 'REVOKED')),

    CONSTRAINT refresh_token_state_timestamp_ck CHECK (
        (state = 'ACTIVE' AND rotated_at IS NULL AND revoked_at IS NULL)
        OR
        (state = 'ROTATED' AND rotated_at IS NOT NULL AND revoked_at IS NULL)
        OR
        (state = 'REVOKED' AND rotated_at IS NULL AND revoked_at IS NOT NULL)
    )
);

-- Exactly one usable refresh token per session.
CREATE UNIQUE INDEX refresh_tokens_one_active_per_session_uq
    ON refresh_tokens(session_id)
    WHERE state = 'ACTIVE';

CREATE INDEX refresh_tokens_expiry_idx
    ON refresh_tokens(expires_at)
    WHERE state = 'ACTIVE';

CREATE OR REPLACE FUNCTION enforce_refresh_token_transition()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF OLD.state <> 'ACTIVE' AND NEW.state <> OLD.state THEN
        RAISE EXCEPTION 'terminal refresh-token state cannot be changed';
    END IF;

    IF NEW.state = 'ROTATED'
       AND (OLD.state <> 'ACTIVE' OR clock_timestamp() >= OLD.expires_at) THEN
        RAISE EXCEPTION 'expired refresh token cannot be rotated';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER refresh_token_transition_trg
BEFORE UPDATE ON refresh_tokens
FOR EACH ROW EXECUTE FUNCTION enforce_refresh_token_transition();
