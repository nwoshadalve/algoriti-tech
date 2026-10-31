// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/card_page.dart';
import '../../home/application/receptionist_work.dart';
import '../application/tablet_session.dart';
import 'admin_tablet_notice.dart';
import 'reset_password_card.dart';
import 'sign_in_card.dart';

/// Past the admin guide, the tablet asks who is using it. Signed in: the app
/// ([child]); an admin first sees [AdminTabletNotice]. Otherwise the sign-in screen, with a way to reset a forgotten
/// password.
///
/// The sign-in is checked again when the app returns to the front, so a reset
/// on another device signs this tablet out too.
class SignInGate extends ConsumerStatefulWidget {
  const SignInGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SignInGate> createState() => _SignInGateState();
}

class _SignInGateState extends ConsumerState<SignInGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tabletSessionProvider.notifier).restoreRemembered();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final session = ref.read(tabletSessionProvider.notifier);
    switch (state) {
      case AppLifecycleState.resumed:
        session.stillValid();
      case AppLifecycleState.detached:
        session.appClosed();
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(tabletSessionProvider, (previous, next) {
      if (next == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          ref.read(receptionistWorkProvider.notifier).syncSession(null);
        });
      }
    });

    final session = ref.watch(tabletSessionProvider);
    if (session == null) return const SignInFlow();
    if (session.showsAdminNotice) return const AdminTabletNotice();
    return widget.child;
  }
}

/// Sign-in, and from there the password reset and back.
class SignInFlow extends StatefulWidget {
  const SignInFlow({super.key});

  @override
  State<SignInFlow> createState() => _SignInFlowState();
}

class _SignInFlowState extends State<SignInFlow> {
  bool _resetting = false;
  bool _justReset = false;

  @override
  Widget build(BuildContext context) {
    return CardPage(
      child: _resetting
          ? ResetPasswordCard(
              onDone: () => setState(() {
                _resetting = false;
                _justReset = true;
              }),
              onBack: () => setState(() => _resetting = false),
            )
          : SignInCard(
              passwordWasReset: _justReset,
              onForgot: () => setState(() {
                _resetting = true;
                _justReset = false;
              }),
            ),
    );
  }
}
