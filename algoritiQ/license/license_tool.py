#!/usr/bin/env python3
"""AlgoritiQ license tool (vendor side).

Issues offline, device-bound activation keys signed with Ed25519.

    python license_tool.py keygen --key-id 1
    python license_tool.py issue --type doctor --chambers 2 \
        --device ABCDE-12344 --customer "Dr Example" --expires 2027-10-27
    python license_tool.py inspect <activation-key>

The signing key comes from --key <file> or the ALGORITIQ_LICENSE_KEY
environment variable (the key file's JSON), so it works on any machine.
Needs Python 3.9+ and `pip install cryptography`. See README.md.

The key layout below MUST match app/lib/features/licensing/domain/
(license_payload.dart, license_token.dart); license/tests/ guards it.
"""

from __future__ import annotations

import argparse
import base64
import csv
import datetime as dt
import hashlib
import json
import os
import secrets
import struct
import sys
from dataclasses import dataclass
from pathlib import Path

from cryptography.exceptions import InvalidSignature
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric.ed25519 import (
    Ed25519PrivateKey,
    Ed25519PublicKey,
)

KEY_ENV = "ALGORITIQ_LICENSE_KEY"
FORMAT_VERSION = 1
PAYLOAD_LEN = 20
SIGNATURE_LEN = 64
NEVER = 0xFFFF  # expiresDay value meaning "perpetual"
EPOCH = dt.date(1970, 1, 1)
TYPES = {"doctor": 1, "chamber": 2}
ALPHABET = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"  # Crockford base32


class LicenseError(Exception):
    """A problem the user can fix (bad input, missing key, ...)."""


# --- base32 / device code ---------------------------------------------------


def b32_encode(data: bytes) -> str:
    out, buffer, bits = [], 0, 0
    for byte in data:
        buffer = (buffer << 8) | byte
        bits += 8
        while bits >= 5:
            out.append(ALPHABET[(buffer >> (bits - 5)) & 31])
            bits -= 5
        buffer &= (1 << bits) - 1
    if bits:
        out.append(ALPHABET[(buffer << (5 - bits)) & 31])
    return "".join(out)


def b32_decode(text: str) -> bytes:
    """Case, spaces and dashes are ignored; O reads as 0 and I/L as 1."""
    out, buffer, bits = bytearray(), 0, 0
    for char in text.upper():
        if char == "-" or char.isspace():
            continue
        char = {"O": "0", "I": "1", "L": "1"}.get(char, char)
        value = ALPHABET.find(char)
        if value < 0:
            raise LicenseError(f'Invalid character "{char}"')
        buffer = (buffer << 5) | value
        bits += 5
        if bits >= 8:
            out.append((buffer >> (bits - 8)) & 255)
            bits -= 8
        buffer &= (1 << bits) - 1
    if buffer:
        raise LicenseError("Not a valid code (check for typos)")
    return bytes(out)


def device_code_from_android_id(android_id: str) -> bytes:
    """Same derivation as the app (DeviceCode.fromAndroidId)."""
    digest = hashlib.sha256(f"algoritiq:device:v1:{android_id}".encode()).digest()
    return digest[:6]


def format_device_code(device: bytes) -> str:
    text = b32_encode(device)
    return f"{text[:5]}-{text[5:]}"


def parse_device_code(text: str) -> bytes:
    device = b32_decode(text)
    if len(device) != 6:
        raise LicenseError(
            f'"{text}" is not a device code (expected XXXXX-XXXXX from the app)'
        )
    return device


# --- payload / token --------------------------------------------------------


@dataclass(frozen=True)
class Payload:
    """The signed content of a license (20 bytes, big-endian).

    0 version | 1 keyId | 2 type | 3 maxDoctors | 4 maxChambers | 5 reserved
    6-7 issuedDay | 8-9 expiresDay (0xFFFF = never) | 10-15 device | 16-19 id
    """

    key_id: int
    type: str
    max_doctors: int
    max_chambers: int
    issued_day: int
    expires_day: int | None
    device: bytes
    license_id: bytes

    def __post_init__(self) -> None:
        if self.type not in TYPES:
            raise LicenseError(f"Unknown license type {self.type!r}")
        for name, value, low in (
            ("key id", self.key_id, 0),
            ("doctors", self.max_doctors, 1),
            ("chambers", self.max_chambers, 1),
        ):
            if not low <= value <= 255:
                raise LicenseError(f"{name} must be {low}-255, got {value}")
        if self.type == "doctor" and self.max_doctors != 1:
            raise LicenseError("A doctor license covers exactly 1 doctor")
        if self.type == "chamber" and self.max_chambers != 1:
            raise LicenseError("A chamber license covers exactly 1 chamber")
        if len(self.device) != 6 or len(self.license_id) != 4:
            raise LicenseError("Bad device code or license id length")
        if not 0 <= self.issued_day < NEVER:
            raise LicenseError("Issue date out of range")
        if self.expires_day is not None:
            if not 0 <= self.expires_day < NEVER:
                raise LicenseError("Expiry date out of range")
            if self.expires_day < self.issued_day:
                raise LicenseError("Expiry is before the issue date")

    def encode(self) -> bytes:
        return struct.pack(
            ">BBBBBBHH6s4s",
            FORMAT_VERSION,
            self.key_id,
            TYPES[self.type],
            self.max_doctors,
            self.max_chambers,
            0,
            self.issued_day,
            NEVER if self.expires_day is None else self.expires_day,
            self.device,
            self.license_id,
        )

    @staticmethod
    def decode(data: bytes) -> "Payload":
        if len(data) != PAYLOAD_LEN:
            raise LicenseError("Bad license length")
        version, key_id, type_code, doctors, chambers, _, issued, expires, device, lid = (
            struct.unpack(">BBBBBBHH6s4s", data)
        )
        if version != FORMAT_VERSION:
            raise LicenseError(f"Unsupported license version {version}")
        names = {code: name for name, code in TYPES.items()}
        if type_code not in names:
            raise LicenseError(f"Unknown license type {type_code}")
        return Payload(
            key_id, names[type_code], doctors, chambers, issued,
            None if expires == NEVER else expires, device, lid,
        )

    @property
    def license_id_hex(self) -> str:
        return self.license_id.hex()

    @property
    def issued_on(self) -> dt.date:
        return EPOCH + dt.timedelta(days=self.issued_day)

    @property
    def expires_on(self) -> dt.date | None:
        if self.expires_day is None:
            return None
        return EPOCH + dt.timedelta(days=self.expires_day)

    def status_on(self, today: dt.date, grace_days: int = 14) -> str:
        if self.expires_on is None or today <= self.expires_on:
            return "active"
        return "grace" if (today - self.expires_on).days <= grace_days else "expired"


def encode_token(payload: bytes, signature: bytes) -> str:
    text = b32_encode(payload + signature)
    return "-".join(text[i : i + 5] for i in range(0, len(text), 5))


def decode_token(token: str) -> tuple[bytes, bytes]:
    data = b32_decode(token)
    if len(data) != PAYLOAD_LEN + SIGNATURE_LEN:
        raise LicenseError("Not a license key (wrong length)")
    return data[:PAYLOAD_LEN], data[PAYLOAD_LEN:]


# --- signing key ------------------------------------------------------------


@dataclass(frozen=True)
class SigningKey:
    key_id: int
    seed: bytes  # 32-byte Ed25519 private seed - SECRET
    public: bytes

    @staticmethod
    def generate(key_id: int) -> "SigningKey":
        private = Ed25519PrivateKey.generate()
        return SigningKey(
            key_id,
            private.private_bytes(
                serialization.Encoding.Raw,
                serialization.PrivateFormat.Raw,
                serialization.NoEncryption(),
            ),
            private.public_key().public_bytes(
                serialization.Encoding.Raw, serialization.PublicFormat.Raw
            ),
        )

    @staticmethod
    def from_json(text: str) -> "SigningKey":
        try:
            data = json.loads(text)
            key = SigningKey(
                int(data["keyId"]),
                base64.b64decode(data["privateKey"]),
                base64.b64decode(data["publicKey"]),
            )
        except (ValueError, KeyError, TypeError) as error:
            raise LicenseError(f"Unreadable signing key: {error}") from error
        if key.derived_public() != key.public:
            raise LicenseError("Signing key is corrupt (public key does not match)")
        return key

    def to_json(self) -> str:
        return json.dumps(
            {
                "keyId": self.key_id,
                "privateKey": base64.b64encode(self.seed).decode(),
                "publicKey": base64.b64encode(self.public).decode(),
            },
            indent=2,
        )

    def derived_public(self) -> bytes:
        return (
            Ed25519PrivateKey.from_private_bytes(self.seed)
            .public_key()
            .public_bytes(serialization.Encoding.Raw, serialization.PublicFormat.Raw)
        )

    def sign(self, message: bytes) -> bytes:
        return Ed25519PrivateKey.from_private_bytes(self.seed).sign(message)

    def verify(self, message: bytes, signature: bytes) -> bool:
        try:
            Ed25519PublicKey.from_public_bytes(self.public).verify(signature, message)
            return True
        except InvalidSignature:
            return False


def load_key(path: str | None) -> SigningKey:
    """Key from `path`, else from the ALGORITIQ_LICENSE_KEY variable."""
    if path:
        try:
            text = Path(path).read_text(encoding="utf-8")
        except OSError as error:
            raise LicenseError(f"Cannot read key file: {error}") from error
    else:
        text = os.environ.get(KEY_ENV, "")
    if not text.strip():
        raise LicenseError(f"Give --key <file> or set {KEY_ENV}")
    return SigningKey.from_json(text)


# --- issuing ----------------------------------------------------------------


def day_of(date: dt.date) -> int:
    return (date - EPOCH).days


def issue_license(
    key: SigningKey,
    *,
    type: str,
    max_doctors: int,
    max_chambers: int,
    device: bytes,
    issued: dt.date,
    expires: dt.date | None,
    license_id: bytes | None = None,
) -> tuple[str, Payload]:
    payload = Payload(
        key_id=key.key_id,
        type=type,
        max_doctors=max_doctors,
        max_chambers=max_chambers,
        issued_day=day_of(issued),
        expires_day=None if expires is None else day_of(expires),
        device=device,
        license_id=license_id or secrets.token_bytes(4),
    )
    data = payload.encode()
    return encode_token(data, key.sign(data)), payload


LEDGER_HEADER = [
    "issued", "licenseId", "customer", "type", "device",
    "doctors", "chambers", "expires", "keyId",
]


def ledger_row(payload: Payload, customer: str) -> list[str]:
    return [
        payload.issued_on.isoformat(),
        payload.license_id_hex,
        customer,
        payload.type,
        format_device_code(payload.device),
        str(payload.max_doctors),
        str(payload.max_chambers),
        payload.expires_on.isoformat() if payload.expires_on else "perpetual",
        str(payload.key_id),
    ]


def append_ledger(path: Path, row: list[str]) -> None:
    new = not path.exists()
    with path.open("a", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle, lineterminator="\n")
        if new:
            writer.writerow(LEDGER_HEADER)
        writer.writerow(row)


# --- commands ---------------------------------------------------------------


def cmd_keygen(args: argparse.Namespace) -> None:
    path = Path(args.dir) / f"key-{args.key_id}.json"
    if path.exists():
        raise LicenseError(f"{path} already exists; refusing to overwrite")
    key = SigningKey.generate(args.key_id)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(key.to_json(), encoding="utf-8")
    try:
        path.chmod(0o600)
    except OSError:
        pass
    print(f"Wrote {path}  (SECRET - back it up, never commit it)")
    print(f"Public key for the app (keyId {key.key_id}):")
    print(base64.b64encode(key.public).decode())


def cmd_issue(args: argparse.Namespace) -> None:
    key = load_key(args.key)
    if args.type == "doctor":
        if args.doctors not in (None, 1):
            raise LicenseError("A doctor license covers exactly 1 doctor")
        doctors, chambers = 1, args.chambers or 1
    else:
        if args.chambers not in (None, 1):
            raise LicenseError("A chamber license covers exactly 1 chamber")
        doctors, chambers = args.doctors or 1, 1

    expires = None
    if not args.perpetual:
        try:
            expires = dt.date.fromisoformat(args.expires)
        except ValueError as error:
            raise LicenseError("--expires must be YYYY-MM-DD") from error
    issued = dt.datetime.now(dt.timezone.utc).date()

    token, payload = issue_license(
        key,
        type=args.type,
        max_doctors=doctors,
        max_chambers=chambers,
        device=parse_device_code(args.device),
        issued=issued,
        expires=expires,
    )
    row = ledger_row(payload, args.customer)
    if not args.no_ledger:
        append_ledger(Path(args.ledger), row)

    if args.json:
        print(json.dumps({
            "activationKey": token,
            "licenseId": payload.license_id_hex,
            "type": payload.type,
            "device": format_device_code(payload.device),
            "maxDoctors": payload.max_doctors,
            "maxChambers": payload.max_chambers,
            "issued": payload.issued_on.isoformat(),
            "expires": payload.expires_on.isoformat() if payload.expires_on else None,
            "ledgerRow": row,
        }))
    else:
        print(f"License {payload.license_id_hex} for device "
              f"{format_device_code(payload.device)}:\n")
        print(token)


def cmd_inspect(args: argparse.Namespace) -> None:
    token = "".join(args.token)
    if not token:
        raise LicenseError("Missing activation key")
    data, signature = decode_token(token)
    payload = Payload.decode(data)
    expires = payload.expires_on.isoformat() if payload.expires_on else "never"
    today = dt.datetime.now(dt.timezone.utc).date()
    print(f"licenseId : {payload.license_id_hex}")
    print(f"keyId     : {payload.key_id}")
    print(f"type      : {payload.type}")
    print(f"doctors   : {payload.max_doctors}")
    print(f"chambers  : {payload.max_chambers}")
    print(f"device    : {format_device_code(payload.device)}")
    print(f"issued    : {payload.issued_on.isoformat()}")
    print(f"expires   : {expires} ({payload.status_on(today)})")
    if args.key or os.environ.get(KEY_ENV):
        key = load_key(args.key)
        ok = key.key_id == payload.key_id and key.verify(data, signature)
        print(f"signature : {'OK' if ok else 'INVALID'}")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="license_tool.py",
        description="AlgoritiQ license tool (vendor side). Keep the signing key private.",
    )
    commands = parser.add_subparsers(dest="command", required=True)

    keygen = commands.add_parser("keygen", help="create a signing key pair")
    keygen.add_argument("--key-id", type=int, default=1, help="key id 0-255")
    keygen.add_argument("--dir", default="keys", help="output directory")
    keygen.set_defaults(run=cmd_keygen)

    issue = commands.add_parser("issue", help="issue an activation key for one device")
    issue.add_argument("--key", help=f"key file (or set {KEY_ENV})")
    issue.add_argument("--type", required=True, choices=list(TYPES),
                       help="doctor = 1 doctor, N chambers; chamber = 1 chamber, N doctors")
    issue.add_argument("--device", required=True, help="device code XXXXX-XXXXX")
    issue.add_argument("--doctors", type=int, help="max doctors (chamber license)")
    issue.add_argument("--chambers", type=int, help="max chambers (doctor license)")
    expiry = issue.add_mutually_exclusive_group(required=True)
    expiry.add_argument("--expires", metavar="YYYY-MM-DD", help="last valid day")
    expiry.add_argument("--perpetual", action="store_true", help="no expiry")
    issue.add_argument("--customer", default="", help="name for the ledger")
    issue.add_argument("--ledger", default=str(Path(__file__).with_name("ledger.csv")),
                       help="ledger CSV path (default: license/ledger.csv)")
    issue.add_argument("--no-ledger", action="store_true", help="do not write the ledger")
    issue.add_argument("--json", action="store_true", help="machine-readable output")
    issue.set_defaults(run=cmd_issue)

    inspect = commands.add_parser("inspect", help="show what an activation key contains")
    inspect.add_argument("token", nargs="+", help="activation key")
    inspect.add_argument("--key", help=f"key file (or set {KEY_ENV}); also checks the signature")
    inspect.set_defaults(run=cmd_inspect)
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    try:
        args.run(args)
    except LicenseError as error:
        print(f"Error: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
