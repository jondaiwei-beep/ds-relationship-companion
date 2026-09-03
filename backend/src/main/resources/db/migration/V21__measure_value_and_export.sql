-- Phase 5 (product/06-build-order.md): kind=measure needs a place to store
-- the number the s reports, alongside tasks.unit.
ALTER TABLE occurrences ADD COLUMN value numeric(12,3);
