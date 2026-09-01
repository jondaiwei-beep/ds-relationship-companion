-- Boundaries lite — the half of REQ-ACT-002 that was never built.
--
-- "Minimal setup collects Couple/Solo, starting role preset, structure level
-- and boundaries lite." Everything but the last clause shipped. For a product
-- whose definition is "consensual adult D/s couples", the missing clause is
-- the one that makes the rest safe to use: an expectation only means anything
-- against a background of what is off the table.
--
-- Two decisions are encoded here rather than left to the application.
--
-- 1. A boundary belongs to a PERSON, not to the Dynamic. The row keys on
--    (dynamic_id, user_id), and nothing in the product may let one member
--    write another's. Red line #4 is that no role can remove agency; if the
--    person giving direction could edit the limits of the person receiving
--    it, the feature would invert into the opposite of what it is for. The
--    server enforces the author, so no client mistake can breach it.
--
-- 2. A limit has a STANCE, not a score. `OFF` is a hard no; `ASK` means it
--    needs a conversation first; `CURIOUS` is an opening, not a consent.
--    Deliberately three, deliberately unranked — a numeric intensity would be
--    a compliance score with a friendlier name, which Non-goals forbid.
--
-- Nothing here is a consent certificate. 00-overview is explicit that
-- treating a contract as consent certification is a non-goal: this is a
-- shared note two people keep, and `updated_at` exists because it is expected
-- to change.

CREATE TABLE boundaries (
    id           uuid PRIMARY KEY,
    dynamic_id   uuid NOT NULL REFERENCES dynamics(id) ON DELETE CASCADE,

    -- The author. Only this user may write or delete the row.
    user_id      uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    label        text NOT NULL,
    stance       text NOT NULL,
    note         text,

    created_at   timestamptz NOT NULL DEFAULT now(),
    updated_at   timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT boundaries_stance_check
        CHECK (stance IN ('OFF', 'ASK', 'CURIOUS')),

    CONSTRAINT boundaries_label_length_check
        CHECK (char_length(label) BETWEEN 1 AND 120),

    CONSTRAINT boundaries_note_length_check
        CHECK (note IS NULL OR char_length(note) <= 500)
);

-- The same person naming the same thing twice is a duplicate, not a second
-- limit. Case-insensitive, so "Rope" and "rope" cannot both exist: a unique
-- INDEX rather than a constraint, because the comparison needs lower().
CREATE UNIQUE INDEX boundaries_unique_label
    ON boundaries (dynamic_id, user_id, lower(label));

-- Reading a person's own list, and reading a partner's, are both keyed this
-- way; the whole feature is "everything in this dynamic" or "mine".
CREATE INDEX boundaries_dynamic_user_idx ON boundaries (dynamic_id, user_id);

COMMENT ON TABLE boundaries IS
    'Boundaries lite (REQ-ACT-002). Authored per member; never writable by the other member.';
COMMENT ON COLUMN boundaries.stance IS
    'OFF = not this. ASK = talk to me first. CURIOUS = open to discussing. Unranked by design.';
