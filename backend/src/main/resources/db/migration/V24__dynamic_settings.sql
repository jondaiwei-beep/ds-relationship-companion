-- Dynamic settings: `reference_timezone`, `day_boundary_minutes` (V1) and the
-- honorifics (V18) already exist. Only the safeword is new (product/02-surfaces.md 设置).
ALTER TABLE dynamics ADD COLUMN safeword text;
