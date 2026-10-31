// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/toast/toast_controller.dart';
import '../../../l10n/app_localizations.dart';

/// The tablet's web address, with a copy button and a QR code to scan.
///
/// With a [nameUrl] (`https://algoritiq.local:8443`) the name is the address
/// to type and the IP address is shown below it; the QR code always carries
/// the IP address, which every phone can reach.
///
/// With [sideBySide] (wide landscape) the QR code is on the left and the
/// address, IP and hint on the right. Otherwise the address takes the full
/// width on top, and the QR code sits beside the IP and hint below it.
class AddressPanel extends StatelessWidget {
  const AddressPanel({
    super.key,
    required this.url,
    this.nameUrl,
    required this.sideBySide,
  });

  final String url;
  final String? nameUrl;
  final bool sideBySide;

  static const _qrSize = 96.0;

  Future<void> _copy(BuildContext context) async {
    final toaster = ProviderScope.containerOf(context)
        .read(toastControllerProvider.notifier);
    final message = AppLocalizations.of(context).addressCopied;
    await Clipboard.setData(ClipboardData(text: nameUrl ?? url));
    toaster.success(message);
  }

  @override
  Widget build(BuildContext context) {
    final line = _AddressLine(
      address: nameUrl ?? url,
      onCopy: () => _copy(context),
    );
    final extras = _AddressExtras(
      ipAddress: nameUrl == null ? null : Uri.parse(url).authority,
    );
    final qr = _QrTile(data: url, size: _qrSize);

    if (sideBySide) {
      return Row(
        children: [
          qr,
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                line,
                const SizedBox(height: Spacing.sm),
                extras,
              ],
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        line,
        const SizedBox(height: Spacing.sm),
        Row(
          children: [
            qr,
            const SizedBox(width: Spacing.md),
            Expanded(child: extras),
          ],
        ),
      ],
    );
  }
}

/// Always dark on white: scanners need the contrast in both themes.
class _QrTile extends StatelessWidget {
  const _QrTile({required this.data, required this.size});

  final String data;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: data,
      image: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Radii.field),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.sm),
          // The painter, not QrImageView: that one measures itself in a
          // LayoutBuilder, which the equal-height step panels cannot contain.
          child: CustomPaint(
            size: Size.square(size),
            painter: QrPainter(
              data: data,
              version: QrVersions.auto,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Colors.black,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The address to type, in one line (scaled down if it must be), and a copy
/// button.
class _AddressLine extends StatelessWidget {
  const _AddressLine({required this.address, required this.onCopy});

  final String address;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: SelectableText.rich(_addressSpan(theme)),
          ),
        ),
        const SizedBox(width: Spacing.sm),
        IconButton.outlined(
          onPressed: onCopy,
          tooltip: l10n.copyAddressTooltip,
          icon: const Icon(Icons.copy_rounded),
        ),
      ],
    );
  }

  /// The scheme and port are quieter than the name, which is what people type.
  TextSpan _addressSpan(ThemeData theme) {
    final uri = Uri.parse(address);
    final quiet = TextStyle(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w500,
    );
    return TextSpan(
      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      children: [
        TextSpan(text: '${uri.scheme}://', style: quiet),
        TextSpan(text: uri.host),
        if (uri.hasPort) TextSpan(text: ':${uri.port}', style: quiet),
      ],
    );
  }
}

/// The IP address (when the address above is the name) and the QR hint.
class _AddressExtras extends StatelessWidget {
  const _AddressExtras({required this.ipAddress});

  /// `192.168.1.110:8443`.
  final String? ipAddress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final ip = ipAddress;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (ip != null) ...[
          Text(l10n.guideAddressByIp, style: muted),
          SelectableText(
            ip,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: Spacing.sm),
        ],
        Text(l10n.guideScanHint, style: muted),
      ],
    );
  }
}
