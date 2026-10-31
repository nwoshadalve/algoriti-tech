// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/brand_loader.dart';
import '../../../core/widgets/page_header.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../l10n/app_localizations.dart';
import '../../access/application/access_providers.dart';
import '../../access/application/access_service.dart';
import '../../access/application/tablet_session.dart';
import '../../access/domain/account.dart';
import '../../clinic/application/clinic_providers.dart';
import '../../clinic/domain/photo_store.dart';
import 'settings_profile_card.dart';
import 'settings_security_card.dart';

/// Profile, password, PIN and photo for the signed-in receptionist.
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  var _pinRefresh = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(tabletSessionProvider);
    if (session == null) {
      return const SizedBox.shrink();
    }
    final account = session.account;
    final size = MediaQuery.sizeOf(context);
    final wide = size.width >= 720 && size.width > size.height;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.md,
        Spacing.md,
        Spacing.lg + MediaQuery.paddingOf(context).bottom,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(
                title: l10n.navSettings,
                description: l10n.settingsIntro,
              ),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _SettingsPhotoCard(account: account)),
                    const SizedBox(width: Spacing.lg),
                    Expanded(
                      flex: 2,
                      child: _SettingsForms(
                        account: account,
                        pinRefresh: _pinRefresh,
                        onAccountUpdated: (next) => ref
                            .read(tabletSessionProvider.notifier)
                            .updateAccount(next),
                        onPasswordChanged: () => setState(() => _pinRefresh++),
                      ),
                    ),
                  ],
                )
              else ...[
                _SettingsPhotoCard(account: account),
                const SizedBox(height: Spacing.lg),
                _SettingsForms(
                  account: account,
                  pinRefresh: _pinRefresh,
                  onAccountUpdated: (next) => ref
                      .read(tabletSessionProvider.notifier)
                      .updateAccount(next),
                  onPasswordChanged: () => setState(() => _pinRefresh++),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsForms extends StatelessWidget {
  const _SettingsForms({
    required this.account,
    required this.pinRefresh,
    required this.onAccountUpdated,
    required this.onPasswordChanged,
  });

  final Account account;
  final int pinRefresh;
  final ValueChanged<Account> onAccountUpdated;
  final VoidCallback onPasswordChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsProfileCard(account: account, onSaved: onAccountUpdated),
        const SizedBox(height: Spacing.lg),
        SettingsSecurityCard(
          key: ValueKey(pinRefresh),
          account: account,
          refreshKey: pinRefresh,
          onPasswordChanged: onPasswordChanged,
        ),
      ],
    );
  }
}

enum _PhotoChoice { gallery, camera, remove }

class _SettingsPhotoCard extends ConsumerStatefulWidget {
  const _SettingsPhotoCard({required this.account});

  final Account account;

  @override
  ConsumerState<_SettingsPhotoCard> createState() => _SettingsPhotoCardState();
}

class _SettingsPhotoCardState extends ConsumerState<_SettingsPhotoCard> {
  Uint8List? _bytes;
  var _loading = true;
  var _busy = false;
  String? _message;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _SettingsPhotoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.account.photoVersion != widget.account.photoVersion) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final service = await ref.read(accessServiceProvider.future);
    final bytes = await service.photoOf(widget.account.id);
    if (!mounted) return;
    setState(() {
      _bytes = bytes == null ? null : Uint8List.fromList(bytes);
      _loading = false;
    });
  }

  Future<void> _chooseSource() async {
    final l10n = AppLocalizations.of(context);
    final hasPhoto = _bytes != null && _bytes!.isNotEmpty;
    final choice = await showModalBottomSheet<_PhotoChoice>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.photoFromGallery),
              onTap: () => Navigator.pop(context, _PhotoChoice.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.photoFromCamera),
              onTap: () => Navigator.pop(context, _PhotoChoice.camera),
            ),
            if (hasPhoto)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded),
                title: Text(l10n.removePhotoButton),
                onTap: () => Navigator.pop(context, _PhotoChoice.remove),
              ),
          ],
        ),
      ),
    );
    switch (choice) {
      case _PhotoChoice.gallery:
        await _pick(PhotoSource.gallery);
      case _PhotoChoice.camera:
        await _pick(PhotoSource.camera);
      case _PhotoChoice.remove:
        await _remove();
      case null:
        break;
    }
  }

  Future<void> _pick(PhotoSource source) async {
    if (_busy) return;
    final path = await ref.read(photoStoreProvider).pick(source);
    if (path == null || !mounted) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final bytes = await File(path).readAsBytes();
      final service = await ref.read(accessServiceProvider.future);
      final result = await service.changePhoto(
        accountId: widget.account.id,
        bytes: bytes,
      );
      if (!mounted) return;
      switch (result) {
        case PhotoSaved(:final account):
          ref.read(tabletSessionProvider.notifier).updateAccount(account);
          setState(() {
            _bytes = Uint8List.fromList(bytes);
            _message = AppLocalizations.of(context).settingsPhotoSaved;
            _error = false;
          });
        case PhotoTooLarge():
        case PhotoUnsupported():
          setState(() {
            _message = AppLocalizations.of(context).settingsPhotoFailed;
            _error = true;
          });
      }
    } on Object {
      if (!mounted) return;
      setState(() {
        _message = AppLocalizations.of(context).settingsPhotoFailed;
        _error = true;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final service = await ref.read(accessServiceProvider.future);
      final account = await service.removePhoto(widget.account.id);
      if (!mounted) return;
      ref.read(tabletSessionProvider.notifier).updateAccount(account);
      setState(() {
        _bytes = null;
        _message = AppLocalizations.of(context).settingsPhotoRemoved;
        _error = false;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _message = AppLocalizations.of(context).settingsPhotoFailed;
        _error = true;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final hasPhoto = _bytes != null && _bytes!.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md + Spacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.settingsPhotoTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              l10n.settingsPhotoHelp,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.md),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(Spacing.lg),
                child: Center(child: BrandLoader()),
              )
            else
              Row(
                children: [
                  if (hasPhoto)
                    ClipOval(
                      child: Image.memory(
                        _bytes!,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    UserAvatar(account: widget.account, size: 72),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busy ? null : _chooseSource,
                      child: Text(
                        hasPhoto ? l10n.changePhotoButton : l10n.addPhotoButton,
                      ),
                    ),
                  ),
                ],
              ),
            if (_message != null) ...[
              const SizedBox(height: Spacing.sm),
              Text(
                _message!,
                style: TextStyle(
                  color: _error ? theme.colorScheme.error : null,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
