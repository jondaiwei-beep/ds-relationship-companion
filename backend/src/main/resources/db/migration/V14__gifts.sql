-- Giving a reward outright, rather than selling it.
--
-- None of the three captured competitors can do this: every positive movement
-- in their models is earn-then-spend, which leaves the giving partner acting
-- as an accountant enforcing a price list. A gift is the warm half of
-- authority — I can give you this because I decided to — and it needs to be
-- attributable, because the whole point is who it came from.
--
-- NULL means the person took it themselves with points (or it was free).
ALTER TABLE reward_redemptions
    ADD COLUMN given_by_user_id uuid REFERENCES users(id) ON DELETE SET NULL;

COMMENT ON COLUMN reward_redemptions.given_by_user_id IS
    'Set when the other member gave this rather than the subject spending on it.';
