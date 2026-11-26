-- UNFINISHED

CREATE TABLE users (
    user_id TEXT PRIMARY KEY,
    username TEXT,
);

-- encrypted balance
-- ct = ciphertext
CREATE TABLE balances (
    user_id TEXT PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
    balance_ct BLOB NOT NULL,
    ct_level INTEGER,
    ct_scale REAL,
    version INTEGER NOT NULL DEFAULT 0,
    updated_tx_id TEXT,
    updated_at TEXT NOT NULL (strftime('%FT%R:%fZ', 'now')) --<YYYY-MM-DD>T<HH:MM:SS.SSS>Z
);

CREATE TABLE products (
    product_id TEXT PRIMARY KEY,
    numeric_id INTEGER NOT NULL UNIQUE,
    name TEXT NOT NULL,
    unit_price INTEGER NOT NULL CHECK (unit_price >= 0),
    active INTEGER NOT NULL DEFAULT 1 CHECK (active IN (0,1))
);