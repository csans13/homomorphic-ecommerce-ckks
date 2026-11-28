import os
import sqlite3
from pathlib import Path
from dotenv import load_dotenv

BASE_DIR = Path(__file__).resolve().parent.parent
load_dotenv(BASE_DIR / ".env")

_raw_db_path = os.getenv("DB_PATH")
if _raw_db_path:
    _p = Path(_raw_db_path)
    DB_PATH = _p if _p.is_absolute() else (BASE_DIR / _p).resolve()
else:
    DB_PATH = BASE_DIR / "data" / "app.db"
SCHEMA_PATH = Path(__file__).resolve().parent / "schema.sql"


def get_connection() -> sqlite3.Connection:
    DB_PATH.parent.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON;")
    conn.execute("PRAGMA journal_mode = WAL;")
    conn.execute("PRAGMA busy_timeout = 5000;")
    return conn


def init_db() -> None:
    schema_sql = SCHEMA_PATH.read_text(encoding="utf-8")
    with get_connection() as conn:
        conn.executescript(schema_sql)


if __name__ == "__main__":
    try:
        init_db()
        with get_connection() as conn:
            sql_ver = conn.execute("SELECT sqlite_version()").fetchone()[0]
            tables = [
                row["name"]
                for row in conn.execute(
                    "SELECT name FROM sqlite_master WHERE type='table'"
                ).fetchall()
            ]
        print(f"Database initialized at: {DB_PATH}")
        print(f"SQLite version: {sql_ver}")
        print(f"Tables: {', '.join(tables)}")
    except sqlite3.Error as e:
        print("Database error:", e)
