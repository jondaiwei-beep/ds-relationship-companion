-- Phase 4 (product/06-build-order.md): 探索 — 两人比对 / 灵感卡 / 起步包
-- (product/04-explore.md).
--
--   * preference_items_custom — a dynamic's own custom PreferenceItems, on
--     top of the static system catalog shipped as JSON
--     (explore/domain/ExploreCatalog.kt reads it, not this table).
--   * preference_answers — each member's private want/ok/no/talk on an item
--     (system slug OR a custom item's uuid, hence item_id is text). Only
--     surfaced to the *other* member once both have answered
--     (04-explore.md "两人比对"); `no` is never attributed to a person.
--   * idea_card_states — per-dynamic state (saved/tried_again/tried_never)
--     against a static IdeaCard id.

-- ---------------------------------------------------------------------------
CREATE TABLE preference_items_custom (
    id          uuid PRIMARY KEY,
    dynamic_id  uuid NOT NULL REFERENCES dynamics(id) ON DELETE CASCADE,
    "group"     text NOT NULL,
    title       text NOT NULL CHECK (char_length(title) BETWEEN 1 AND 120),
    detail      text CHECK (detail IS NULL OR char_length(detail) <= 2000),
    created_by  uuid NOT NULL REFERENCES users(id),
    created_at  timestamptz NOT NULL DEFAULT now(),
    updated_at  timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX preference_items_custom_dynamic_idx ON preference_items_custom (dynamic_id);

-- ---------------------------------------------------------------------------
-- item_id: a static catalog slug (e.g. "service_ritual.kneel_greeting") OR a
-- preference_items_custom.id cast to text — deliberately not an FK so one
-- column can address both sources.
CREATE TABLE preference_answers (
    id              uuid PRIMARY KEY,
    dynamic_id      uuid NOT NULL REFERENCES dynamics(id) ON DELETE CASCADE,
    item_id         text NOT NULL,
    member_user_id  uuid NOT NULL REFERENCES users(id),
    answer          text NOT NULL CHECK (answer IN ('want', 'ok', 'no', 'talk')),
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now(),
    UNIQUE (dynamic_id, item_id, member_user_id)
);
CREATE INDEX preference_answers_dynamic_idx ON preference_answers (dynamic_id);
CREATE INDEX preference_answers_dynamic_item_idx ON preference_answers (dynamic_id, item_id);

-- ---------------------------------------------------------------------------
CREATE TABLE idea_card_states (
    id          uuid PRIMARY KEY,
    dynamic_id  uuid NOT NULL REFERENCES dynamics(id) ON DELETE CASCADE,
    card_id     text NOT NULL,
    status      text NOT NULL CHECK (status IN ('saved', 'tried_again', 'tried_never')),
    by_user_id  uuid NOT NULL REFERENCES users(id),
    created_at  timestamptz NOT NULL DEFAULT now(),
    updated_at  timestamptz NOT NULL DEFAULT now(),
    UNIQUE (dynamic_id, card_id)
);
CREATE INDEX idea_card_states_dynamic_idx ON idea_card_states (dynamic_id);
