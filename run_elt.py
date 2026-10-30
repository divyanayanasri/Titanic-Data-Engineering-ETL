"""
Part 6: Orchestrator. Extract+Load (Python) -> SQL files in order -> print DQ results.
Usage:  python run_elt.py
Env vars (optional): MYSQL_HOST, MYSQL_PORT, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE
"""
import re
import sys
from pathlib import Path

from sqlalchemy import text

from extract_load import extract_and_load

SQL_DIR = Path(__file__).parent / "sql"


def split_statements(sql: str):
    sql = re.sub(r"^\s*--.*$", "", sql, flags=re.MULTILINE)  # drop comment lines
    return [s.strip() for s in sql.split(";") if s.strip()]


def run_sql_file(engine, path: Path):
    with engine.begin() as conn:
        for stmt in split_statements(path.read_text()):
            conn.exec_driver_sql(stmt)
    print(f"[SQL ] {path.name} done")


def main() -> int:
    engine = extract_and_load()                      # E + L

    for sql_file in sorted(SQL_DIR.glob("*.sql")):   # T, in order: 01, 02, 03, 04
        run_sql_file(engine, sql_file)

    print("\n=== DATA QUALITY CHECKS ===")
    with engine.connect() as conn:
        rows = conn.execute(
            text("SELECT check_name, status FROM dq_results ORDER BY check_name")
        ).fetchall()
    for name, status in rows:
        print(f"{status}  {name}")

    failed = [n for n, s in rows if s != "PASS"]
    print("\nALL CHECKS PASSED" if not failed else f"\n{len(failed)} CHECK(S) FAILED")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
