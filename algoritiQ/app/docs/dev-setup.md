# App dev setup (Windows, physical tablet)

Minimal Flutter setup. Target device: HONOR Pad X7 (Android 15, API 35). No emulator, no Android Studio.
App supports any Android from **API 21 (5.0)** up — set via `minSdk` when the project is created (step 6).

Disk: ~4–5 GB total. Use drive **C:** (118 GB free); E: is tight.

## 1. Install JDK 17 and Git

```powershell
winget install EclipseAdoptium.Temurin.17.JDK
winget install Git.Git
```

Reopen the terminal, then check `java -version` shows 17.

## 2. Install Flutter (stable)

```powershell
git clone https://github.com/flutter/flutter.git -b stable C:\dev\flutter
```

Add `C:\dev\flutter\bin` to user `PATH`. Then `flutter --version`.

## 3. Android command-line tools only

1. Download **Command line tools only** (Windows) from <https://developer.android.com/studio#command-tools>.
2. Extract so this file exists: `C:\dev\android-sdk\cmdline-tools\latest\bin\sdkmanager.bat`
   (the zip's inner `cmdline-tools` contents go into `latest\`).

## 4. Environment variables (user scope)

```powershell
setx ANDROID_HOME "C:\dev\android-sdk"
setx JAVA_HOME "C:\Program Files\Eclipse Adoptium\jdk-17.<your-version>-hotspot"
```

Add to `PATH`: `%ANDROID_HOME%\cmdline-tools\latest\bin` and `%ANDROID_HOME%\platform-tools`.
Reopen the terminal.

## 5. Install SDK packages and accept licenses

```powershell
sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-35" "platforms;android-36" "build-tools;35.0.0" "build-tools;28.0.3"
flutter config --android-sdk C:\dev\android-sdk
flutter doctor --android-licenses
flutter doctor -v
```

Expected: Flutter ✓, Android toolchain ✓. Ignore Visual Studio / Chrome / Android Studio warnings.
Optional: disable web/desktop targets: `flutter config --no-enable-web --no-enable-windows-desktop`.

## 6. Project (already created)

Created with `flutter create --platforms=android --org tech.algoriti --project-name algoritiq_app`.
`android\app\build.gradle.kts` sets `minSdk = 21` (any Android 5.0+). `targetSdk` follows Flutter's default.
If a plugin later needs a higher `minSdk`, raise it only as far as required.

## 7. Connect the HONOR Pad X7

1. Settings → About tablet → tap **Build number** 7×.
2. Settings → System → Developer options → enable **USB debugging** and **Stay awake** (screen lock can drop the connection).
3. Plug in USB (mode: File transfer), accept the RSA prompt on the tablet. Use a data cable, directly in the PC (no hub).
4. Verify:

```powershell
adb devices      # must show "device", not "unauthorized"
flutter devices
```

Empty list? Try another cable/port, or install the HONOR USB driver (HiSuite).

## 8. Run with live updates

```powershell
cd E:\Projects\algoriti-tech\algoritiQ\app
flutter pub get
flutter run
```

In the terminal: `r` = hot reload, `R` = hot restart, `q` = quit.
Run it in your own terminal (an embedded/non-interactive terminal may exit right after launch).
First build is slow: Gradle also auto-installs NDK and Build-Tools 36 (~1 GB).

Screenshot / tap from the PC (useful for testing and AI-assisted debugging):

```powershell
adb exec-out screencap -p > shot.png
adb shell input tap <x> <y>
adb logcat -d -t 100
```
Optional wireless debug (Android 11+): Developer options → Wireless debugging → `adb pair` / `adb connect`.

## Troubleshooting

| Problem | Fix |
| --- | --- |
| `flutter` / `adb` not found | Reopen terminal; check `PATH` |
| Device `unauthorized` / not listed | Accept RSA prompt; `adb kill-server`; replug; USB mode File transfer |
| Drops when screen locks | Enable **Stay awake**; or `adb shell settings put global stay_on_while_plugged_in 7` |
| License errors | `flutter doctor --android-licenses` |
| Gradle needs JDK | `flutter config --jdk-dir "<JAVA_HOME>"` |
| First build slow | Normal (Gradle downloads ~1 GB once) |
| `Could not close incremental caches` (Kotlin) | Project on E:, pub cache on C:. `kotlin.incremental=false` is set in `android/gradle.properties`; stop daemons (`gradlew --stop`) and delete the plugin's `build/` folder |
| App shows the activation screen on a dev tablet | Issue a dev key: see [license/README.md](../../license/README.md) |

More detail: [../../docs/dev-setup/](../../docs/dev-setup/README.md).
