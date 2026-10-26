"""Tests for license_tool.py. Run from the license/ folder:

    python -m unittest discover -s tests -v
"""

import base64
import datetime as dt
import io
import json
import os
import sys
import tempfile
import unittest
from contextlib import redirect_stderr, redirect_stdout
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import license_tool as tool  # noqa: E402

VECTOR = json.loads(
    (Path(__file__).parent / "fixtures" / "python_license_vector.json").read_text(
        encoding="utf-8"
    )
)
TODAY = dt.date(2026, 10, 27)


def make_key(key_id: int = 1) -> "tool.SigningKey":
    return tool.SigningKey.generate(key_id)


def issue(key, **overrides):
    args = dict(
        type="doctor", max_doctors=1, max_chambers=2,
        device=tool.device_code_from_android_id("tablet-1"),
        issued=TODAY, expires=None,
    )
    args.update(overrides)
    return tool.issue_license(key, **args)


def run_cli(*argv, env=None):
    out, err = io.StringIO(), io.StringIO()
    old_env = dict(os.environ)
    os.environ.update(env or {})
    try:
        with redirect_stdout(out), redirect_stderr(err):
            code = tool.main(list(argv))
    finally:
        os.environ.clear()
        os.environ.update(old_env)
    return code, out.getvalue(), err.getvalue()


class Base32Test(unittest.TestCase):
    def test_round_trip(self):
        data = bytes(i * 3 % 256 for i in range(84))
        self.assertEqual(tool.b32_decode(tool.b32_encode(data)), data)

    def test_ignores_case_dashes_and_confusable_characters(self):
        data = bytes([1, 2, 3, 4, 5])
        text = tool.b32_encode(data).lower().replace("0", "o").replace("1", "l")
        self.assertEqual(tool.b32_decode(f" {text[:4]}-{text[4:]} "), data)

    def test_rejects_invalid_characters(self):
        with self.assertRaises(tool.LicenseError):
            tool.b32_decode("ABC!")


class DeviceCodeTest(unittest.TestCase):
    def test_format_and_round_trip(self):
        device = tool.device_code_from_android_id("tablet-1")
        text = tool.format_device_code(device)
        self.assertRegex(text, r"^[0-9A-Z]{5}-[0-9A-Z]{5}$")
        self.assertEqual(tool.parse_device_code(text.lower()), device)

    def test_typo_in_code_is_rejected(self):
        # Real codes have two zero padding bits; a made-up/typo'd one fails.
        with self.assertRaises(tool.LicenseError):
            tool.parse_device_code("ABCDE-12345")

    def test_wrong_length_is_rejected(self):
        with self.assertRaises(tool.LicenseError):
            tool.parse_device_code("ABCDE")


class PayloadTest(unittest.TestCase):
    def test_encode_decode_round_trip(self):
        _, payload = issue(make_key(), expires=dt.date(2027, 10, 27))
        self.assertEqual(tool.Payload.decode(payload.encode()), payload)

    def test_layout_is_20_bytes_with_fixed_offsets(self):
        _, payload = issue(
            make_key(3), type="chamber", max_doctors=4, max_chambers=1,
            expires=dt.date(2027, 10, 27),
        )
        data = payload.encode()
        self.assertEqual(len(data), 20)
        self.assertEqual(list(data[:6]), [1, 3, 2, 4, 1, 0])
        self.assertEqual(data[10:16], payload.device)

    def test_doctor_license_must_have_one_doctor(self):
        with self.assertRaises(tool.LicenseError):
            issue(make_key(), type="doctor", max_doctors=2)

    def test_chamber_license_must_have_one_chamber(self):
        with self.assertRaises(tool.LicenseError):
            issue(make_key(), type="chamber", max_doctors=3, max_chambers=2)

    def test_expiry_before_issue_is_rejected(self):
        with self.assertRaises(tool.LicenseError):
            issue(make_key(), expires=TODAY - dt.timedelta(days=1))

    def test_status_active_grace_expired(self):
        _, payload = issue(make_key(), expires=dt.date(2027, 10, 27))
        self.assertEqual(payload.status_on(dt.date(2027, 10, 27)), "active")
        self.assertEqual(payload.status_on(dt.date(2027, 11, 5)), "grace")
        self.assertEqual(payload.status_on(dt.date(2027, 11, 20)), "expired")

    def test_perpetual_never_expires(self):
        _, payload = issue(make_key())
        self.assertEqual(payload.status_on(dt.date(2090, 1, 1)), "active")


class SigningTest(unittest.TestCase):
    def test_signature_verifies(self):
        key = make_key()
        token, _ = issue(key)
        data, signature = tool.decode_token(token)
        self.assertTrue(key.verify(data, signature))

    def test_tampering_breaks_the_signature(self):
        key = make_key()
        token, _ = issue(key, expires=dt.date(2027, 1, 1))
        data, signature = tool.decode_token(token)
        forged = bytearray(data)
        forged[4] = 99  # e.g. raise the chamber limit
        self.assertFalse(key.verify(bytes(forged), signature))

    def test_other_key_does_not_verify(self):
        token, _ = issue(make_key())
        data, signature = tool.decode_token(token)
        self.assertFalse(make_key().verify(data, signature))

    def test_token_length_is_stable(self):
        token, _ = issue(make_key())
        self.assertEqual(len(token.replace("-", "")), 135)

    def test_not_a_key(self):
        with self.assertRaises(tool.LicenseError):
            tool.decode_token("hello")


class KeyFileTest(unittest.TestCase):
    def test_round_trip_json(self):
        key = make_key(5)
        again = tool.SigningKey.from_json(key.to_json())
        self.assertEqual((again.key_id, again.seed, again.public),
                         (key.key_id, key.seed, key.public))

    def test_mismatched_public_key_is_rejected(self):
        data = json.loads(make_key().to_json())
        data["publicKey"] = json.loads(make_key().to_json())["publicKey"]
        with self.assertRaises(tool.LicenseError):
            tool.SigningKey.from_json(json.dumps(data))

    def test_missing_key_gives_a_clear_error(self):
        os.environ.pop(tool.KEY_ENV, None)
        with self.assertRaisesRegex(tool.LicenseError, tool.KEY_ENV):
            tool.load_key(None)


class VectorTest(unittest.TestCase):
    """The same vector is verified by the app's Dart tests."""

    def test_reproduces_the_shared_vector(self):
        seed = base64.b64decode(VECTOR["seedBase64"])
        public = base64.b64decode(VECTOR["publicKeyBase64"])
        key = tool.SigningKey(VECTOR["keyId"], seed, public)
        self.assertEqual(key.derived_public(), public)

        device = tool.device_code_from_android_id(VECTOR["androidId"])
        self.assertEqual(tool.format_device_code(device), VECTOR["deviceCode"])

        token, _ = tool.issue_license(
            key,
            type=VECTOR["type"],
            max_doctors=VECTOR["maxDoctors"],
            max_chambers=VECTOR["maxChambers"],
            device=device,
            issued=dt.date.fromisoformat(VECTOR["issued"]),
            expires=dt.date.fromisoformat(VECTOR["expires"]),
            license_id=bytes.fromhex(VECTOR["licenseIdHex"]),
        )
        # Ed25519 is deterministic: any change to the format changes this key.
        self.assertEqual(token, VECTOR["activationKey"])


class CliTest(unittest.TestCase):
    def setUp(self):
        self.dir = tempfile.TemporaryDirectory()
        self.addCleanup(self.dir.cleanup)
        self.key = make_key()
        self.env = {tool.KEY_ENV: self.key.to_json()}
        self.ledger = str(Path(self.dir.name) / "ledger.csv")
        self.device = tool.format_device_code(
            tool.device_code_from_android_id("tablet-1")
        )

    def issue_json(self, *extra):
        code, out, err = run_cli(
            "issue", "--device", self.device, "--ledger", self.ledger, "--json",
            *extra, env=self.env,
        )
        self.assertEqual((code, err), (0, ""))
        return json.loads(out)

    def test_issue_with_key_from_environment(self):
        result = self.issue_json(
            "--type", "doctor", "--chambers", "2", "--expires", "2099-01-01",
            "--customer", 'Dr "Example", MD',
        )
        data, signature = tool.decode_token(result["activationKey"])
        self.assertTrue(self.key.verify(data, signature))
        self.assertEqual(result["maxChambers"], 2)
        self.assertEqual(result["maxDoctors"], 1)
        self.assertEqual(result["expires"], "2099-01-01")

    def test_ledger_row_is_appended_and_escaped(self):
        self.issue_json("--type", "chamber", "--doctors", "3", "--perpetual",
                        "--customer", 'Clinic "A", Dhaka')
        lines = Path(self.ledger).read_text(encoding="utf-8").splitlines()
        self.assertEqual(lines[0], ",".join(tool.LEDGER_HEADER))
        self.assertIn('"Clinic ""A"", Dhaka"', lines[1])
        self.assertTrue(lines[1].endswith(",chamber," + self.device + ",3,1,perpetual,1"))

    def test_inspect_checks_the_signature(self):
        token = self.issue_json("--type", "doctor", "--perpetual")["activationKey"]
        code, out, _ = run_cli("inspect", token, env=self.env)
        self.assertEqual(code, 0)
        self.assertIn("type      : doctor", out)
        self.assertIn("signature : OK", out)

        other = {tool.KEY_ENV: make_key().to_json()}
        _, out, _ = run_cli("inspect", token, env=other)
        self.assertIn("signature : INVALID", out)

    def test_rejects_a_mistyped_device_code(self):
        code, _, err = run_cli(
            "issue", "--device", "ABCDE-12345", "--type", "doctor", "--perpetual",
            "--ledger", self.ledger, env=self.env,
        )
        self.assertEqual(code, 1)
        self.assertIn("Error:", err)

    def test_requires_a_signing_key(self):
        env = {tool.KEY_ENV: ""}
        code, _, err = run_cli(
            "issue", "--device", self.device, "--type", "doctor", "--perpetual",
            "--ledger", self.ledger, env=env,
        )
        self.assertEqual(code, 1)
        self.assertIn(tool.KEY_ENV, err)

    def test_keygen_refuses_to_overwrite(self):
        args = ("keygen", "--key-id", "9", "--dir", self.dir.name)
        self.assertEqual(run_cli(*args)[0], 0)
        code, _, err = run_cli(*args)
        self.assertEqual(code, 1)
        self.assertIn("refusing to overwrite", err)

    def test_doctor_license_rejects_several_doctors(self):
        code, _, err = run_cli(
            "issue", "--device", self.device, "--type", "doctor", "--doctors", "2",
            "--perpetual", "--ledger", self.ledger, env=self.env,
        )
        self.assertEqual(code, 1)
        self.assertIn("exactly 1 doctor", err)


if __name__ == "__main__":
    unittest.main()
