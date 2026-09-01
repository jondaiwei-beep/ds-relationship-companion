-- The LDR flag the wizard has always collected and always discarded.
--
-- 00-overview names the design pressure case explicitly: "Android
-- direction-giving member + iPhone Safari receiving member + LDR + different
-- timezones". REQ-ACT-002 lists "LDR/Together" as one of the lightweight
-- choices minimal setup collects. The client asked the question, drew the
-- two options, and then dropped the answer before the request was sent.
--
-- Stored on the dynamic rather than the membership: being apart is a fact
-- about the couple, not about one person. Either member may correct it,
-- because either member can be the one who moves.
--
-- Nullable-free with a default of false so every existing dynamic reads as
-- Together, which is what they were asked and what they answered.
ALTER TABLE dynamics
    ADD COLUMN long_distance boolean NOT NULL DEFAULT false;

COMMENT ON COLUMN dynamics.long_distance IS
    'Couple is long-distance (REQ-ACT-002). Changes seeded content, never permissions.';
