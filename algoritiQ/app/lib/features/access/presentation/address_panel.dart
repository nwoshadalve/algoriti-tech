import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/app_localizations.dart';

/// The tablet's web address with a copy button and a QR code to scan.
///
/// With a [nameUrl] (`https://algoritiq.local:8443`) the name is the address
/// to type and the IP address is shown below it; the QR code always carries
/// the IP address, which every phone can reach.
class AddressPanel extends StatelessWidget {
  const AddressPanel({
    super.key,
    required this.url,
    this.nameUrl,
    this.qrSize = 112,
  });

  final String url;
  final String? nameUrl;
  final double qrSize;

  Future<void> _copy(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final message = AppLocalizations.of(context).addressCopied;
    await Clipboard.setData(ClipboardData(text: nameUrl ?? url));
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final copyButton = IconButton.outlined(
      onPressed: () => _copy(context),
      tooltip: l10n.copyAddressTooltip,
      icon: const Icon(Icons.copy_rounded),
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Always dark on white: scanners need the contrast in both themes.
        Semantics(
          label: url,
          image: true,
          child: Container(
            padding: const EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Radii.field),
            ),
            child: QrImageView(
              data: url,
              size: qrSize,
              padding: EdgeInsets.zero,
              backgroundColor: Colors.white,
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
        const SizedBox(width: Spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                nameUrl ?? url,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              if (nameUrl == null) ...[
                Text(l10n.guideScanHint, style: muted),
                const SizedBox(height: Spacing.xs),
                copyButton,
              ] else ...[
                // The IP address sits beside the copy button to save height.
                Row(
                  children: [
                    copyButton,
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: SelectableText(
                        l10n.guideAddressByIp(url),
                        style: muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.xs),
                Text(l10n.guideScanHint, style: muted),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
