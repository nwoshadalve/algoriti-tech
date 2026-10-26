# Prod build & deploy (AlgoritiQ)

Release artifacts for **clinic tablets** (Flutter host + bundled React dashboard). Assumes [dev setup](../dev-setup/README.md) with the same Android API level.

## Outputs

| Artifact | Use |
| --- | --- |
| `app-release.apk` | Sideload / direct install (v1 clinics) |
| `app-release.aab` | Google Play (when published) |

Host includes: native printer service, TLS backend shell, **SPA assets** from dashboard production build.

## Build pipeline (overview)

```text
1. dashboard: npm ci && npm run build
2. copy dist/ → tablet assets (path TBD in apps/tablet)
3. tablet: flutter build apk --release  (or appbundle)
4. sign with release keystore
5. deploy: adb install or MDM / manual copy
```

Automate steps 1–2 in a script when `apps/` exist (e.g. `tool/build_release.ps1`).

## Release signing

**Never commit** keystore or passwords.

1. Generate once (secure machine):

   ```powershell
   keytool -genkey -v -keystore algoritiq-upload.keystore -alias algoritiq -keyalg RSA -keysize 2048 -validity 10000
   ```

2. Store `algoritiq-upload.keystore` in a secrets vault / offline backup.  
3. In `apps/tablet/android/key.properties` (gitignored):

   ```properties
   storePassword=***
   keyPassword=***
   keyAlias=algoritiq
   storeFile=../path/to/algoritiq-upload.keystore
   ```

4. Wire `signingConfigs` in `android/app/build.gradle` (standard Flutter release docs).

Debug builds use the debug keystore; **do not** ship debug to clinics.

## Flutter release commands

```powershell
cd algoritiQ\apps\tablet
flutter pub get
flutter build apk --release
# output: build\app\outputs\flutter-apk\app-release.apk

flutter build appbundle --release
# output: build\app\outputs\bundle\release\app-release.aab
```

Optional: `--split-per-abi` for smaller APKs per architecture (note which ABI the HONOR pad uses — typically `arm64-v8a`).

## Dashboard in release

- Build with production env (no dev server URLs).  
- API/WS: **relative** `/api/v1`, `wss://` same host ([secure backend](../architecture/tablet-app/secure-backend-service.md)).  
- Fail build if `dist/` missing before `flutter build`.

## Versioning

| Field | Where |
| --- | --- |
| `version: x.y.z+build` | `apps/tablet/pubspec.yaml` |
| `versionCode` / `versionName` | Android from Flutter build name/number |

Bump **build** (+N) every clinic release; bump **x.y.z** for user-visible changes.

## Deploy to clinic tablet (v1)

1. Backup tablet data if replacing an existing install.  
2. Uninstall old package only if signing key changed (otherwise upgrade in place).  
3. Install:

   ```powershell
   adb install -r build\app\outputs\flutter-apk\app-release.apk
   ```

   Or copy APK to tablet and open (allow install from unknown sources if needed).

4. First launch: permission gate, pair printer, trust **HTTPS CA** on laptop ([architecture](../architecture/tablet-app/secure-backend-service.md)).  
5. Run acceptance checks from [R&D §9](../discussions/rnd_architechture.md).

## Prod vs debug differences

| | Debug (`flutter run`) | Release |
| --- | --- | --- |
| Signing | Debug key | Release keystore |
| Obfuscation | Off | Optional `--obfuscate` + split debug info |
| Performance | Slower | Optimized |
| Logging | Verbose | Reduce secrets in logs |

Test **release** on a physical tablet before clinic rollout (Bluetooth FGS, TLS, background).

## CI (later)

- Job: build dashboard → build AAB → store artifact.  
- Secrets: keystore as encrypted CI secret.  
- Tag release in git; attach APK/AAB to release notes.

## Checklist before clinic ship

- [ ] Release APK/AAB signed with production key  
- [ ] Dashboard bundle embedded; smoke test SPA over HTTPS on LAN  
- [ ] Printer + session + backend supervisor tested on HONOR Pad X7  
- [ ] `version` documented for support  
- [ ] Keystore backup verified  

## See also

- [Dev setup](../dev-setup/README.md)  
- [Components / hardware](../components_selection.md)
