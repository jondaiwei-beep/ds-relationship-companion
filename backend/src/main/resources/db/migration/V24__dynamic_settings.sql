-- Dynamic settings: `reference_timezone` and `day_boundary_minutes` already
-- exist (V1). This adds the remaining fields product/02-surfaces.md's 设置
-- screen references (称呼 honorific_for_d / honorific_for_s) plus a safeword.
ALTER TABLE dynamics
    ADD COLUMN honorific_for_d text,
    ADD COLUMN honorific_for_s text,
    ADD COLUMN safeword text;
