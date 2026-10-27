import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/card_page.dart';
import '../application/tablet_session.dart';
import 'reset_password_card.dart';
import 'sign_in_card.dart';

/// Past the admin guide, the tablet asks who is using it. Signed in: the app
/// ([child]). Otherwise the sign-in screen, with a way to reset a forgotten
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
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(tabletSessionProvider.notifier).stillValid();
    }
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = ref.watch(tabletSessionProvider) != null;
    return signedIn ? widget.child : const SignInFlow();
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
