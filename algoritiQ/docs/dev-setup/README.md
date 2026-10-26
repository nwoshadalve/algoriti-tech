# Dev setup (AlgoritiQ)

Local development for the **counter tablet** (Flutter) and **dashboard** (React). Target device: **HONOR Pad X7** — physical USB debugging, **no Android emulators** (minimal SDK disk use).

## Prerequisites

| Tool | Version (guide) | Notes |
| --- | --- | --- |
| Git | latest | Clone monorepo |
| Flutter | stable channel | Includes Dart |
| JDK | **17** | Android Gradle (Temurin or Oracle) |
| Node.js | **20 LTS** | Dashboard SPA only |
| USB cable | — | Tablet ↔ PC for `adb` |

## Quick path (Windows)

1. [Minimal Android SDK](./minimal-android-sdk.md) — cmdline-tools only, no emulator images.  
2. Install Flutter → [flutter.dev/docs/get-started](https://docs.flutter.dev/get-started/install/windows).  
3. `flutter doctor -v` — fix Android toolchain until **Android SDK** and **Connected device** are OK.  
4. Enable **Developer options → USB debugging** on the tablet; install OEM USB driver if `adb devices` is empty.  
5. From app root (when added): `flutter pub get` → `flutter run` (debug on device).

Detailed SDK package list: [minimal-android-sdk.md](./minimal-android-sdk.md).

## Repo layout (planned)

```text
algoritiQ/
  apps/tablet/          # Flutter host app
  apps/dashboard/       # React SPA → bundled into tablet assets for release
  docs/
```

Until apps exist, only docs and architecture live under `algoritiQ/`.

## Daily workflow

```powershell
# Terminal 1 — tablet (USB attached)
cd algoritiQ\apps\tablet
flutter devices
flutter run

# Terminal 2 — dashboard (browser against local dev server; tablet TLS host later)
cd algoritiQ\apps\dashboard
npm install
npm run dev
```

Use **debug** builds on device for Bluetooth, foreground services, and LAN HTTPS — behavior differs from desktop Chrome alone.

## Environment variables

| Variable | Example | Purpose |
| --- | --- | --- |
| `ANDROID_HOME` | `%LOCALAPPDATA%\Android\Sdk` | SDK root |
| `JAVA_HOME` | JDK 17 install path | Gradle |
| `PATH` | `%ANDROID_HOME%\platform-tools` | `adb` |

Optional: copy `.env.example` → `.env` in dashboard when introduced — never commit `.env`.

## What we skip in dev

- Android Emulator / system images (saves **many GB**)
- Full Android Studio (optional; use VS Code / Cursor + Flutter extension)
- Play Store signing keys (release only — [prod build](../prod-build-deploy/README.md))

## Troubleshooting

| Issue | Check |
| --- | --- |
| `adb` unauthorized | Accept RSA prompt on tablet |
| Flutter no devices | Cable, driver, USB mode “File transfer” |
| Gradle / SDK errors | API level matches [minimal-android-sdk.md](./minimal-android-sdk.md) |
| BT / LAN features fail on emulator | Use physical tablet only (by design) |

## See also

- [Architecture](../architecture/README.md)
- [Prod build & deploy](../prod-build-deploy/README.md)
