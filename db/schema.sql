  CREATE EXTENSION IF NOT EXISTS vector;

  DROP TABLE IF EXISTS threads, requests, responses;

  CREATE TABLE IF NOT EXISTS threads (
      id                BIGSERIAL PRIMARY KEY,
      session_id        TEXT NOT NULL UNIQUE,
      title             TEXT,
      summary           TEXT,
      summary_embedding vector(768),
      created_at        DOUBLE PRECISION NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW()),
      updated_at        DOUBLE PRECISION NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())
  );

  CREATE TABLE IF NOT EXISTS requests (
      id          BIGSERIAL PRIMARY KEY,
      thread_id   BIGINT NOT NULL REFERENCES threads(id) ON DELETE CASCADE,
      content     TEXT NOT NULL,
      embedding   vector(768),
      created_at  DOUBLE PRECISION NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW()),
      updated_at  DOUBLE PRECISION NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())
  );

  CREATE TABLE IF NOT EXISTS responses (
      id          BIGSERIAL PRIMARY KEY,
      request_id  BIGINT NOT NULL UNIQUE REFERENCES requests(id) ON DELETE CASCADE,
      content     TEXT NOT NULL,
      embedding   vector(768),
      created_at  DOUBLE PRECISION NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW()),
      updated_at  DOUBLE PRECISION NOT NULL DEFAULT EXTRACT(EPOCH FROM NOW())
  );

  CREATE INDEX IF NOT EXISTS requests_thread_id_idx
      ON requests(thread_id);

  CREATE INDEX IF NOT EXISTS threads_summary_embedding_hnsw_idx
      ON threads
      USING hnsw (summary_embedding vector_cosine_ops);

  -- Apply grants as the role that owns Tux's tables.
  GRANT SELECT, INSERT, UPDATE, DELETE
      ON ALL TABLES IN SCHEMA public
      TO tux, human;

  GRANT SELECT
      ON ALL TABLES IN SCHEMA public
      TO assistant;

  ALTER DEFAULT PRIVILEGES IN SCHEMA public
      GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO human;

  ALTER DEFAULT PRIVILEGES IN SCHEMA public
      GRANT SELECT ON TABLES TO assistant;

  GRANT USAGE, SELECT, UPDATE
      ON ALL SEQUENCES IN SCHEMA public
      TO tux, human;

  ALTER DEFAULT PRIVILEGES IN SCHEMA public
      GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO human;
