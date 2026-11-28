PRAGMA foreign_keys = ON;
PRAGMA journal_mode = WAL;
PRAGMA busy_timeout = 5000;

CREATE TABLE IF NOT EXISTS users (
    user_id TEXT PRIMARY KEY,
    username TEXT,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'disabled')),
    activated_at TEXT NOT NULL DEFAULT (strftime('%FT%R:%fZ', 'now')) --<YYYY-MM-DD>T<HH:MM:SS.SSS>Z
);

CREATE TABLE IF NOT EXISTS user_crypto (
  user_id TEXT PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
  profile TEXT NOT NULL,
  poly_modulus_degree INTEGER NOT NULL,
  coeff_mod_bit_sizes TEXT NOT NULL, -- e.g. json_array(60,40,40,40,60)
  global_scale REAL NOT NULL, -- Δ
  params_blob BLOB NOT NULL, -- serialized public context
  public_key_blob BLOB NOT NULL, -- pk
  relin_key_blob BLOB NOT NULL, -- rk
  lib_name TEXT NOT NULL, -- 'tenseal'
  lib_version TEXT NOT NULL,
  format_version INTEGER NOT NULL DEFAULT 1,
  updated_at TEXT NOT NULL DEFAULT (strftime('%FT%R:%fZ', 'now'))
);

-- encrypted balance
-- ct = ciphertext
CREATE TABLE IF NOT EXISTS balances (
    user_id TEXT PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
    balance_ct BLOB NOT NULL,
    ct_level INTEGER,
    ct_scale REAL,
    version INTEGER NOT NULL DEFAULT 0,
    updated_tx_id TEXT,
    updated_at TEXT NOT NULL DEFAULT (strftime('%FT%R:%fZ', 'now'))
);

CREATE TABLE IF NOT EXISTS products (
    product_id TEXT PRIMARY KEY,
    numeric_id INTEGER NOT NULL UNIQUE,
    name TEXT NOT NULL,
    unit_price INTEGER NOT NULL CHECK (unit_price >= 0),
    active INTEGER NOT NULL DEFAULT 1 CHECK (active IN (0,1))
);

CREATE TABLE IF NOT EXISTS discounts (
    code TEXT PRIMARY KEY,
    numeric_id INTEGER NOT NULL UNIQUE,
    percent REAL NOT NULL DEFAULT 0 CHECK (percent>=0 AND percent<=1),
    amount INTEGER NOT NULL DEFAULT 0 CHECK (amount >= 0),
    active INTEGER NOT NULL DEFAULT 1 CHECK (active IN (0,1))
);

CREATE TABLE IF NOT EXISTS transactions (
    tx_id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    user_seq INTEGER NOT NULL,
    meta_ct BLOB NOT NULL,
    total_ct BLOB NOT NULL,
    balance_after_ct BLOB,
    ct_level INTEGER,
    ct_scale REAL,
    created_at TEXT NOT NULL DEFAULT (strftime('%FT%R:%fZ', 'now')),
    UNIQUE (user_id, user_seq)
);

CREATE INDEX IF NOT EXISTS idx_tx_user_created ON transactions(user_id, user_seq DESC);