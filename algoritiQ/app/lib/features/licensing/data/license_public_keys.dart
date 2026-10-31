// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:convert';
import 'dart:typed_data';

/// Vendor public keys by key id (public: safe to ship).
///
/// Add a new entry when rotating keys (`license_tool keygen --key-id N`);
/// keep old ones so already-issued licenses keep working.
final Map<int, Uint8List> licensePublicKeys = {
  1: base64Decode('xZBeKltv3pYol+WYFKKgdY8l9ay6tRnkC77Q8VyZOJ8='),
};
