-- Notion 03 §2: Membership carries a role preset — Dominant / submissive /
-- Switch / Custom — as a STARTING POINT, not a permanent identity.
--
-- This is deliberately separate from role_context. That column records
-- position in the dynamic (who created it, who was invited) and is used for
-- authorization; the preset is how the members describe themselves, and it
-- must never grant or remove anything. Overloading one column would make a
-- self-description load-bearing for access.
--
-- Nullable: a couple that does not want to name it is not blocked, and the
-- product must never require this to be answered (red line #4).
ALTER TABLE memberships
    ADD COLUMN role_preset text;

ALTER TABLE memberships
    ADD CONSTRAINT memberships_role_preset_ck
        CHECK (role_preset IS NULL OR role_preset IN
               ('DOMINANT', 'SUBMISSIVE', 'SWITCH', 'CUSTOM'));

COMMENT ON COLUMN memberships.role_preset IS
    'How this member describes their role, as a starting point. Never used '
    'for authorization — see role_context for position in the dynamic.';
