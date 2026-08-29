-- Email + password sign-up.
--
-- Magic links stay as a second path, but they cannot be the only door: a
-- person on a phone has to leave the app, find a mail client, and come back.
-- For a private product that someone opens in a spare minute, that is a wall
-- — and the first wall is where most people stop.
--
-- Nullable: every account created before this migration authenticates by
-- link, and existing members must not be locked out.
ALTER TABLE users
    ADD COLUMN password_hash text;

-- Notion 03 §2 names the age gate as a User property that is confirmed, never
-- inferred. Password sign-up is the first flow where a person states it
-- directly, so the column finally gets written.
COMMENT ON COLUMN users.password_hash IS
    'BCrypt hash. NULL for accounts that authenticate by magic link only.';
