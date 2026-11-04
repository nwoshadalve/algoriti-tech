# TV app dev setup (Windows + Android TV emulator)

Native Kotlin project. Unlike the Flutter tablet path ([docs/dev-setup/README.md](../../docs/dev-setup/README.md)), **TV development uses emulators** for daily work; physical Google TV on clinic Wi-Fi is optional for acceptance.

Target clinic panel: **Android 11 (API 30)** Google TV ([components_selection.md](../../docs/components_selection.md)). Also test **API 34** TV image for current devices.

## Prerequisites

| Tool | Version | Notes |
| --- | --- | --- |
| JDK | **17** | Same as tablet (`JAVA_HOME`) |
| Android SDK | cmdline-tools | Reuse tablet `ANDROID_HOME` if already installed |
| Git | latest | Clone monorepo |

Default paths on this machine (tablet guide): Flutter `C:\dev\flutter`, Android **`C:\dev\android-sdk`**.

## 1. SDK packages (TV-specific)

After [minimal-android-sdk.md](../../docs/dev-setup/minimal-android-sdk.md) tablet packages, add:

```powershell
$env:Path = "C:\dev\android-sdk\cmdline-tools\latest\bin;C:\dev\android-sdk\platform-tools;$env:Path"
sdkmanager "emulator" "platforms;android-30" "platforms;android-34" `
  "system-images;android-30;android-tv;x86" `
  "system-images;android-34;android-tv;x86"
```

Accept licenses if prompted.

## 2. Create Android TV AVDs

Using Android Studio **Device Manager** (recommended):

| AVD name | System image | Purpose |
| --- | --- | --- |
| `AlgoritiQ_TV_API30_720p` | Android TV, API 30, 720p | Clinic hardware parity |
| `AlgoritiQ_TV_API34_1080p` | Android TV, API 34, 1080p | Daily dev |

Or `avdmanager` (adjust path to installed image):

```powershell
avdmanager create avd -n AlgoritiQ_TV_API30_720p -k "system-images;android-30;android-tv;x86" -d "tv_720p"
```

Enable **WHPX** or HAXM for emulator acceleration on Windows.

Start emulator:

```powershell
emulator -avd AlgoritiQ_TV_API30_720p
```

## 3. Build and run

```powershell
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.20.101-hotspot"
$env:ANDROID_HOME = "C:\dev\android-sdk"
$env:Path = "$env:JAVA_HOME\bin;C:\dev\android-sdk\platform-tools;C:\dev\android-sdk\emulator;$env:Path"
cd E:\Projects\algoriti-tech\algoritiQ\tv-app
.\gradlew :app:installDebug
adb devices
adb -e shell am start -n tech.algoriti.algoritiq_tv/.MainActivity
```

Use **`adb -e`** when a USB tablet is also connected (`-e` = emulator).

## Two-screen shell (v0.1)

The shipped TV UI has **two screens only**:

| Screen | When |
| --- | --- |
| **Connecting** | Until the first WebSocket `snapshot` is applied |
| **Main display** | Waiting-room board (ঘোষণা / অপেক্ষমাণ / doctor footer) |

Host: **`https://algoritiq.local:8443`** → WebSocket **`wss://algoritiq.local:8443/api/v1/ws/live?token=…`**.

Debug builds trust the tablet self-signed certificate and map `algoritiq.local` → `10.0.2.2` on the emulator so the host PC can forward port 8443 (`adb reverse tcp:8443 tcp:8443` when the API runs locally).

Optional Gradle properties in `tv-app/gradle.properties`:

```properties
tvDevApiHost=https://algoritiq.local:8443
tvDevSessionToken=<staff bearer token for dev>
```

## 4. Reaching the tablet API from emulator

The tablet hosts HTTPS on **port 8443** (not your PC). Debug builds use **`https://algoritiq.local:8443`**, and `DevClinicDns` maps that name to **`10.0.2.2`** (the emulator’s view of your **PC**).

**Tablet on USB + TV on emulator (typical dev):**

1. Forward the PC’s port 8443 to the tablet’s API:
   ```powershell
   adb -d forward tcp:8443 tcp:8443
   ```
   Re-run after unplugging USB or restarting `adb`. Check from the PC:
   ```powershell
   curl.exe -sk https://127.0.0.1:8443/api/v1/health
   ```
2. Set a staff bearer token (same as web admin sign-in) in `tv-app/gradle.properties`:
   ```properties
   tvDevSessionToken=<paste token here>
   ```
   Without this, the TV stays on **“add this TV to the tablet”** and never opens the WebSocket.
3. Reinstall the TV debug APK: `.\gradlew :app:installDebug`

**Alternative:** point the TV at the tablet’s Wi‑Fi IP (same LAN as the PC), e.g. `tvDevApiHost=https://192.168.1.110:8443`, and use a **physical TV** on that Wi‑Fi. Many emulators cannot reach the LAN IP reliably.

- Host machine services only (API on PC): **`https://10.0.2.2:<port>`** (not `localhost` on the PC curl).

TLS: use tablet dev certificate or debug network config documented in pairing runbooks.

## 5. Gradle checks

```powershell
.\gradlew check
.\gradlew :app:assembleDebug
```

## AI / agent shells

Integrated terminals may not inherit `PATH`. Prepend `JAVA_HOME`, `ANDROID_HOME\platform-tools`, and project `gradlew` directory before build.

## Troubleshooting

| Problem | Fix |
| --- | --- |
| `sdkmanager` not found | Add `cmdline-tools\latest\bin` to PATH |
| No TV system image | Run sdkmanager lines in §1 |
| Emulator slow | Enable WHPX; use x86_64 image |
| `INSTALL_FAILED` | Uninstall old debug: `adb -e uninstall tech.algoriti.algoritiq_tv` |
| D-pad focus stuck | TV emulator: use keyboard arrows + Enter |
| TV says add to tablet / never connects | Set `tvDevSessionToken` in `gradle.properties` and rebuild |
| TV emulator + tablet API | Run `adb -d forward tcp:8443 tcp:8443`; verify `curl.exe -sk https://127.0.0.1:8443/api/v1/health` |

See also: [app/docs/dev-setup.md](../../app/docs/dev-setup.md) for JDK/SDK baseline.
