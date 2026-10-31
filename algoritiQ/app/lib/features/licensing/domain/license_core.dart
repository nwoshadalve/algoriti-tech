// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
/// Offline license verification (public key only; the app cannot create keys).
///
/// Keys are issued by `algoritiQ/license/license_tool.py`; the byte layout in
/// `LicensePayload` must stay in sync with that script (a shared test vector in
/// `license/tests/fixtures/` guards it).
library;

export 'device_code.dart' show DeviceCode;
export 'license_payload.dart' show LicensePayload, LicenseStatus, LicenseType;
export 'license_verifier.dart'
    show
        LicenseCheck,
        LicenseInvalid,
        LicenseRejection,
        LicenseValid,
        LicenseVerifier;
