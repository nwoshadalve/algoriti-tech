#!/usr/bin/env python3
"""Reset queue type rows to clinic template and drop per-chamber overrides.

Usage (local copy of algoritiq.sqlite):
  python tool/reset_queue_types.py path/to/algoritiq.sqlite
"""
from __future__ import annotations

import json
import sqlite3
import sys
from pathlib import Path

SEEDS = (
    (
        "regular",
        "Regular",
        "সাধারণ",
        1001,
        1099,
        1,
    ),
    (
        "report",
        "Report",
        "রিপোর্ট",
        2001,
        2099,
        2,
    ),
    (
        "dressing",
        "Dressing",
        "ড্রেসিং",
        3001,
        3099,
        3,
    ),
)


def reset(conn: sqlite3.Connection) -> None:
    conn.execute("BEGIN")
    conn.execute("DELETE FROM queue_types WHERE owner_key != 'clinic'")
    conn.execute(
        "DELETE FROM queue_types WHERE owner_key = 'clinic' "
        "AND id NOT IN ('regular', 'report', 'dressing')"
    )
    for row_id, en, bn, start, end, order in SEEDS:
        conn.execute(
            """
            INSERT INTO queue_types (
              id, owner_key, english_name, bengali_name,
              start_number, end_number, display_order, enabled
            ) VALUES (?, 'clinic', ?, ?, ?, ?, ?, 1)
            ON CONFLICT(id, owner_key) DO UPDATE SET
              english_name = excluded.english_name,
              bengali_name = excluded.bengali_name,
              start_number = excluded.start_number,
              end_number = excluded.end_number,
              display_order = excluded.display_order,
              enabled = 1
            """,
            (row_id, en, bn, start, end, order),
        )
    rows = conn.execute(
        "SELECT key, value FROM app_settings WHERE key LIKE 'queue.chamber.%'"
    ).fetchall()
    inherit_json = json.dumps({"useClinicDefaults": True}, separators=(",", ":"))
    for key, raw in rows:
        try:
            decoded = json.loads(raw)
        except json.JSONDecodeError:
            decoded = {}
        if not isinstance(decoded, dict):
            decoded = {}
        boundary = decoded.get("dayBoundaryOverride")
        auto = decoded.get("autoStartOverride")
        next_val: dict[str, object] = {"useClinicDefaults": True}
        if boundary is not None:
            next_val["dayBoundaryOverride"] = boundary
        if auto is not None:
            next_val["autoStartOverride"] = auto
        conn.execute(
            "UPDATE app_settings SET value = ? WHERE key = ?",
            (json.dumps(next_val, separators=(",", ":")), key),
        )
    conn.execute("COMMIT")
    conn.execute("PRAGMA wal_checkpoint(TRUNCATE)")


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: python tool/reset_queue_types.py <algoritiq.sqlite>", file=sys.stderr)
        return 2
    path = Path(sys.argv[1])
    if not path.is_file():
        print(f"No file: {path}", file=sys.stderr)
        return 1
    conn = sqlite3.connect(path)
    try:
        reset(conn)
    finally:
        conn.close()
    print(f"Reset queue types in {path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
