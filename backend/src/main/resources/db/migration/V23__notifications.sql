-- Stored notifications: a durable record of every dispatched outbox event,
-- one row per recipient, so the client can show a history/inbox beyond what
-- a push provider delivered. Neutral body is kept alongside the real
-- title/body so the client can honour the lockscreen-privacy toggle without
-- a second round trip.
CREATE TABLE notifications (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         uuid NOT NULL REFERENCES users (id),
    dynamic_id      uuid NOT NULL REFERENCES dynamics (id),
    event_type      text NOT NULL,
    title           text NOT NULL,
    body            text NOT NULL,
    neutral_body    text NOT NULL,
    deep_link       text NOT NULL,
    created_at      timestamptz NOT NULL DEFAULT now(),
    read_at         timestamptz,
    outbox_id       uuid REFERENCES outbox_records (id),

    CONSTRAINT notifications_event_type_check
        CHECK (btrim(event_type) <> '')
);

CREATE INDEX notifications_user_created_idx ON notifications (user_id, created_at DESC);
CREATE INDEX notifications_user_unread_idx ON notifications (user_id) WHERE read_at IS NULL;

-- Per-user notification preferences beyond the device-level quiet-hours /
-- lockscreen-richness settings already on `users`: which event types are
-- muted (client-side signal only — never suppressed server-side, per Notion
-- 04 §7/§8 discipline: the record of what happened must never be dropped),
-- and an optional digest cadence.
CREATE TABLE notification_settings (
    user_id                 uuid PRIMARY KEY REFERENCES users (id),
    neutral_lockscreen      boolean NOT NULL DEFAULT false,
    deliver_digest_hours    integer,
    muted_types             text[] NOT NULL DEFAULT '{}',

    CONSTRAINT notification_settings_digest_hours_check
        CHECK (deliver_digest_hours IS NULL OR deliver_digest_hours > 0)
);
