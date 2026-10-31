# Backup and restore

Admins use **Backup** in the web app (`/backup`) on the clinic tablet.

## What is saved

Each backup is a zip of the same Android data folders documented in [dev-setup](../dev-setup.md):

| Folder | Contents |
| --- | --- |
| **`app_flutter/`** | SQLite database (doctors, chambers, users, queue, settings, audit log, and the rest of clinic data) |
| **`shared_prefs/`** | License, language, theme, readiness flags, backup schedule, printer pairing prefs, sign-in mode, and other Flutter preferences |
| **`files/`** | File-backed data the database points at (for example **doctor photos**) |

**Never restored:** the app's own code that debug builds unpack into `app_flutter/flutter_assets` and `res_timestamp*`; it belongs to the installed version.

**Not inside the zip:** the app APK, bundled web UI assets, the secure-storage files (they are tied to one tablet's Keystore; the secrets are saved apart, see below), or the on-tablet **`clinic_backups/`** archive list (those stay under `no_backup/` separately). Automatic/manual copies on the tablet are the same zip layout when you download them.

Archives live under the app’s private storage (`clinic_backups/`), not inside the zip itself.

## Automatic backup

Choose **Off**, **Every day**, or **Every week**. While the app is running, the tablet creates an automatic copy when the interval has passed.

**Retention:** the tablet keeps the **14 newest** backups (`BackupPolicy.retentionLimit`). Whenever a backup is created, imported, or the list is loaded, older archives beyond that limit are **purged automatically**.

## Manual backup

**Back up now** creates an immediate copy and adds it to the list.

## Download

**Download** sends the zip to the browser (laptop or phone on the chamber Wi‑Fi). Store copies somewhere safe off the tablet.

## Restore on the same tablet

Pick **Restore** on a listed backup. Current clinic data is replaced with the archive; sign in again when prompted.

## New or replaced tablet

1. Install the AlgoritiQ app and **activate** the device.
2. Complete **Keep the tablet ready** (permissions), then on **Restore or start new** either tap **Start new** and finish clinic setup, or tap **Restore from backup** and choose the zip you saved from Backup.
3. Alternatively, after you can sign in on the web app: open **Backup**, upload the zip (**Choose zip file**), then tap **Restore** on that entry.

After restore, sign in with the **original** admin credentials from before the device was lost.

**Passwords and the website certificate.** Passwords are hashed with a secret (the *pepper*) and the website uses a TLS key, both kept in the Android Keystore, which never leaves a tablet. So every backup also carries these secrets (`secrets.json` inside the zip: pepper, TLS key and certificate, PIN registration), and a restore puts them back into the tablet's own Keystore. That is what keeps the original passwords working on a replaced tablet. **Treat the zip like the tablet itself:** it holds the clinic's data and the means to check its passwords, so keep it off shared drives.

**Backups made before this change** (no `secrets.json`) restore the users but their passwords no longer match on a different install. Use **Forgot password?** with the activation key (see [authentication](./authentication.md)) to set a new admin password.

## API

See `docs/api/openapi.yaml` (`/backups/*`). Implementation: `BackupChannel.kt`, `backup_service.dart`, `BackupPage.tsx`.
