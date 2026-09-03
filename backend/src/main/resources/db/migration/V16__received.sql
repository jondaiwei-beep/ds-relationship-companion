-- Direction is received before it is carried out. The first link of the
-- Daily Dynamic Loop: the person who gave an instruction learns that the
-- other person has seen it, before anything is done about it.
ALTER TABLE occurrences ADD COLUMN received_at timestamptz;
