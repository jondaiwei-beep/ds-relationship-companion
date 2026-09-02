-- Streaks, proof and chance — owner direction 2026-09-02.
--
-- All three exist in the competitors. What differs is where they live and how
-- they behave; see product/design/streaks-proof-chance.md. Two of the three
-- differences are enforced here rather than left to the application.

-- ---------------------------------------------------------------------------
-- Proof: a photo attached to a COMPLETION.
--
-- Obedience puts `Proof` on a punishment, as a camera, defaulting to
-- Disabled. Kneel gives `Verify` a whole sub-tab. Both frame it as auditing —
-- the receiving partner supplies evidence and the other checks it.
--
-- Ours attaches to the completion, so it reads as "look what I did" rather
-- than "prove you did". There is deliberately NO "proof required" column
-- anywhere: the moment a photo can be demanded, the act is done for the
-- camera and the other person is inspecting rather than paying attention.
-- Optional is the entire difference between a gift and an audit, so the
-- schema simply offers nowhere to record a requirement.
ALTER TABLE occurrence_completions
    ADD COLUMN proof_media_id text;

COMMENT ON COLUMN occurrence_completions.proof_media_id IS
    'Optional photo the completer chose to attach. Never required — no column exists to demand one.';

-- ---------------------------------------------------------------------------
-- Chance: which agreed consequence, never whether there is one.
--
-- Obedience's `Randomize` is a form field: "add multiple punishments and let
-- fate decide". The appeal is real — not knowing is part of the play — and
-- the risk is only in what the dice is allowed to decide.
--
-- A person still presses "hold to it". Only then may chance pick which of the
-- couple's agreed consequences applies. `consequence_events.issued_by_user_id`
-- stays NOT NULL, so no path exists where a machine decides that someone
-- faces a consequence at all.
ALTER TABLE consequence_events
    ADD COLUMN chosen_by_chance boolean NOT NULL DEFAULT false;

COMMENT ON COLUMN consequence_events.chosen_by_chance IS
    'The couple asked to be surprised by WHICH consequence. A person still decided THAT there is one.';
