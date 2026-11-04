#!/usr/bin/env python3
"""Export TV mock session JSON from a clinic tablet algoritiq.sqlite backup."""

from __future__ import annotations

import json
import shutil
import sqlite3
import sys
from pathlib import Path

DEFAULT_DB = (
    Path(__file__).resolve().parents[4]
    / "tablet-backups"
    / "queue-reset-20261101"
    / "app_flutter"
    / "algoritiq.sqlite"
)
OUT_JSON = Path(__file__).resolve().parents[1] / "src" / "mock-session-data.json"
OUT_PHOTO = Path(__file__).resolve().parents[1] / "public" / "assets" / "doctor-photo.jpg"


def _try_adb_doctor_photo(photo_path: str) -> None:
    if not photo_path:
        return
    import subprocess

    rel = ""
    if photo_path:
        name = Path(photo_path).name
        rel = f"doctor_photos/{name}"
    serial = subprocess.run(
        ["adb", "devices"],
        capture_output=True,
        text=True,
        check=False,
    ).stdout
    device = None
    for line in serial.splitlines():
        if "\tdevice" in line and "emulator" not in line:
            device = line.split("\t")[0].strip()
            break
    if not device:
        return
    OUT_PHOTO.parent.mkdir(parents=True, exist_ok=True)
    cmd = [
        "adb",
        "-s",
        device,
        "exec-out",
        "run-as",
        "tech.algoriti.algoritiq_app",
        "cat",
        f"app_flutter/{rel}",
    ]
    result = subprocess.run(cmd, capture_output=True, check=False)
    if result.returncode == 0 and len(result.stdout) > 1000:
        OUT_PHOTO.write_bytes(result.stdout)


def _session_label(business_date: str) -> str:
    if not business_date:
        return ""
    try:
        y, m, d = business_date.split("-")
        months = {
            "01": "জানুয়ারি",
            "02": "ফেব্রুয়ারি",
            "03": "মার্চ",
            "04": "এপ্রিল",
            "05": "মে",
            "06": "জুন",
            "07": "জুলাই",
            "08": "আগস্ট",
            "09": "সেপ্টেম্বর",
            "10": "অক্টোবর",
            "11": "নভেম্বর",
            "12": "ডিসেম্বর",
        }
        bn_digits = str(int(d)).translate(str.maketrans("0123456789", "০১২৩৪৫৬৭৮৯"))
        bn_year = y.translate(str.maketrans("0123456789", "০১২৩৪৫৬৭৮৯"))
        return f"{bn_digits} {months.get(m, m)} {bn_year}"
    except ValueError:
        return business_date


def main() -> int:
    db_path = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_DB
    if not db_path.is_file():
        print(f"Database not found: {db_path}", file=sys.stderr)
        return 1

    con = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)
    con.row_factory = sqlite3.Row
    doc = con.execute(
        "SELECT id, name, specialty, degrees, designation, workplace, "
        "registration_number, photo_path FROM doctors LIMIT 1"
    ).fetchone()
    if not doc:
        print("No doctor row in database.", file=sys.stderr)
        return 1

    chamber = con.execute(
        "SELECT id, doctor_id, name, location, phone FROM chambers "
        "ORDER BY created_at ASC LIMIT 1"
    ).fetchone()
    if not chamber:
        print("No chamber row in database.", file=sys.stderr)
        return 1

    degrees = json.loads(doc["degrees"] or "[]")
    photo_path = doc["photo_path"] or ""
    photo_file = Path(photo_path).name if photo_path else ""
    photo_url = "/assets/doctor-photo.jpg"

    # Optional: copy sibling doctor_photos/ from backup folder if present.
    if photo_file:
        for candidate in (
            db_path.parent / "doctor_photos" / photo_file,
            db_path.parent.parent / "doctor_photos" / photo_file,
        ):
            if candidate.is_file():
                OUT_PHOTO.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(candidate, OUT_PHOTO)
                break

    if not OUT_PHOTO.is_file() or OUT_PHOTO.stat().st_size < 1000:
        _try_adb_doctor_photo(photo_path)

    session_row = con.execute(
        "SELECT business_date, config_snapshot_json FROM queue_sessions "
        "WHERE chamber_id = ? ORDER BY opened_at DESC LIMIT 1",
        (chamber["id"],),
    ).fetchone()

    queue_types = []
    if session_row and session_row["config_snapshot_json"]:
        snap = json.loads(session_row["config_snapshot_json"])
        for t in snap.get("types", []):
            if t.get("enabled", True):
                queue_types.append(
                    {
                        "id": t["id"],
                        "bengaliName": t.get("bengaliName") or t.get("englishName", ""),
                        "englishName": t.get("englishName", ""),
                    }
                )

    if not queue_types:
        queue_types = [
            {"id": "regular", "bengaliName": "সাধারণ", "englishName": "Regular"},
            {"id": "report", "bengaliName": "রিপোর্ট", "englishName": "Report"},
            {"id": "dressing", "bengaliName": "ড্রেসিং", "englishName": "Dressing"},
        ]

    payload = {
        "source": {"sqlite": str(db_path.resolve()), "exportedAt": "auto"},
        "doctor": {
            "id": doc["id"],
            "name": doc["name"],
            "degrees": degrees,
            "designation": doc["designation"] or "",
            "workplace": doc["workplace"] or "",
            "registrationNumber": doc["registration_number"] or "",
            "specialty": doc["specialty"] or "",
            "photoUrl": photo_url,
            "photoPathOnTablet": photo_path,
            "photoVersion": 1 if photo_path else 0,
        },
        "chamber": {
            "id": chamber["id"],
            "doctorId": chamber["doctor_id"],
            "name": chamber["name"],
            "location": chamber["location"] or "",
            "phone": chamber["phone"] or "",
        },
        "session": {
            "businessDate": session_row["business_date"] if session_row else "",
            "label": _session_label(session_row["business_date"] if session_row else ""),
        },
        "queueTypes": queue_types,
    }

    OUT_JSON.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"Wrote {OUT_JSON}")
    if OUT_PHOTO.is_file() and OUT_PHOTO.stat().st_size > 1000:
        print(f"Photo: {OUT_PHOTO} ({OUT_PHOTO.stat().st_size} bytes)")
    else:
        print(
            "Photo not copied — place JPEG at public/assets/doctor-photo.jpg "
            f"(tablet path: {photo_path})",
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
