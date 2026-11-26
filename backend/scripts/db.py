import sqlite3
from pathlib import Path

DB_PATH = Path(__file__).resolve().parent.parent / "data" / "app.db"
DB_PATH.parent.mkdir(parents=True, exist_ok=True)

connection = sqlite3.connect(DB_PATH)

try:
    print(f"Database connected: {DB_PATH}")
    sql_ver = connection.execute('SELECT sqlite_version()').fetchone()
    print(f"SQLite version: {sql_ver[0]}")

except sqlite3.Error as e:
    print("Database error:", e)

finally:
    connection.close()
    print("Database connection closed")
