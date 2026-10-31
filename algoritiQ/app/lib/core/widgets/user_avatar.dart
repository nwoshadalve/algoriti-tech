// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../theme/brand_colors.dart';
import '../../features/access/domain/account.dart';

/// Round avatar with the first letter of the person's name (photo later).
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.account, this.size = 40});

  final Account account;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initial = _initial(account);

    return Semantics(
      label: initial,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: BrandColors.coralAction,
          shape: BoxShape.circle,
        ),
        child: Text(
          initial,
          style: TextStyle(
            color: BrandColors.white,
            fontWeight: FontWeight.w700,
            fontSize: size * 0.42,
          ),
        ),
      ),
    );
  }

  static String _initial(Account account) {
    final source = account.firstName.isNotEmpty
        ? account.firstName
        : (account.displayName.isNotEmpty
              ? account.displayName
              : account.username);
    final trimmed = source.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed[0].toUpperCase();
  }
}
