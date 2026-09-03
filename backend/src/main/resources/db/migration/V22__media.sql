-- Media upload (photo proof). Stores metadata only; bytes live on disk under
-- dsapp.media.dir. proof_ref on occurrences may hold this id — wiring that
-- association is the client's job, not this migration's.
CREATE TABLE media (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    dynamic_id      uuid NOT NULL REFERENCES dynamics (id),
    uploaded_by     uuid NOT NULL REFERENCES users (id),
    content_type    text NOT NULL,
    byte_size       bigint NOT NULL,
    created_at      timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT media_content_type_check
        CHECK (btrim(content_type) <> ''),
    CONSTRAINT media_byte_size_check
        CHECK (byte_size > 0)
);

CREATE INDEX media_dynamic_id_idx ON media (dynamic_id);
