#!/usr/bin/env python3
"""Pull doctor photo (and optional DB) from the clinic tablet via adb."""

from __future__ import annotations

import subprocess
import sys
import zipfile
from io import BytesIO
from pathlib import Path

PKG = "tech.algoriti.algoritiq_app"
DEVICE_FLAG: list[str] = []
OUT_PHOTO = Path(__file__).resolve().parents[1] / "public" / "assets" / "doctor-photo.jpg"
BACKUP_ZIP_IN_APP = "cache/file_picker/1793437558336/clinic-backup.zip"


def _adb(*args: str) -> bytes:
    cmd = ["adb", *DEVICE_FLAG, "exec-out", "run-as", PKG, *args]
    result = subprocess.run(cmd, capture_output=True)
    if result.returncode != 0:
        raise RuntimeError(result.stderr.decode("utf-8", "ignore") or "adb failed")
    return result.stdout


def _pick_device() -> None:
    global DEVICE_FLAG
    listed = subprocess.run(
        ["adb", "devices"],
        capture_output=True,
        text=True,
        check=False,
    ).stdout
    for line in listed.splitlines():
        if "\tdevice" in line and "emulator" not in line:
            DEVICE_FLAG = ["-s", line.split("\t")[0].strip()]
            return


def main() -> int:
    _pick_device()
    OUT_PHOTO.parent.mkdir(parents=True, exist_ok=True)

    # 1) Direct cat of doctor_photos/*.jpg (newest in backup zip listing)
    for rel in (
        "doctor_photos/1793105806000.jpg",
        "app_flutter/doctor_photos/1793105806000.jpg",
    ):
        try:
            data = _adb("cat", rel)
            if len(data) > 1000 and data[:2] == b"\xff\xd8":
                OUT_PHOTO.write_bytes(data)
                print(f"Wrote {OUT_PHOTO} ({len(data)} bytes) from {rel}")
                return 0
        except RuntimeError:
            pass

    # 2) Clinic backup zip in app cache (from tablet export)
    try:
        blob = _adb("cat", BACKUP_ZIP_IN_APP)
        if blob[:2] != b"PK":
            raise RuntimeError("not a zip")
        with zipfile.ZipFile(BytesIO(blob)) as zf:
            for name in zf.namelist():
                if name.endswith(".jpg") and "doctor_photos" in name:
                    data = zf.read(name)
                    if len(data) > 1000:
                        OUT_PHOTO.write_bytes(data)
                        print(f"Wrote {OUT_PHOTO} from zip entry {name}")
                        return 0
    except (RuntimeError, zipfile.BadZipFile) as err:
        print(f"Zip fallback failed: {err}", file=sys.stderr)

    print("Could not pull doctor photo.", file=sys.stderr)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
