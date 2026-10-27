import '../../../platform/keep_alive_gateway.dart';

enum ReadinessKind { background, notifications, autoStart }

enum ReadinessState {
  /// All good.
  done,

  /// Android is set up in a way that can stop the server.
  needed,

  /// Android cannot tell us; the user confirms it by hand.
  unconfirmed,
}

/// One thing that helps the local API stay available.
final class ReadinessItem {
  const ReadinessItem({
    required this.kind,
    required this.state,
    required this.isRequired,
  });

  final ReadinessKind kind;
  final ReadinessState state;

  /// Without it Android will stop the server when the app is not on screen.
  final bool isRequired;

  bool get isDone => state == ReadinessState.done;
}

/// The checklist for [status]. [autoStartConfirmed] is the user's own word
/// for the vendor-specific auto-start page, which cannot be read.
List<ReadinessItem> evaluateReadiness(KeepAliveStatus status) {
  ReadinessState done(bool ok) =>
      ok ? ReadinessState.done : ReadinessState.needed;
  return [
    ReadinessItem(
      kind: ReadinessKind.background,
      state: done(status.batteryOptimizationIgnored),
      isRequired: true,
    ),
    ReadinessItem(
      kind: ReadinessKind.notifications,
      state: done(status.notificationsGranted),
      isRequired: true,
    ),
    ReadinessItem(
      kind: ReadinessKind.autoStart,
      state: !status.autoStartRequired || status.autoStartGranted
          ? ReadinessState.done
          : ReadinessState.needed,
      isRequired: true,
    ),
  ];
}
