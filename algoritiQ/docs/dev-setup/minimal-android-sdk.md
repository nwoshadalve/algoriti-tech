# Minimal Android SDK (no emulators)

**Goal:** Smallest SDK install for **Flutter + physical device debug** on Windows.  
**Target tablet:** HONOR Pad X7, **Android 15** (API **35**).

## Disk expectation

Roughly **2–4 GB** with the packages below. A full Android Studio + emulator image set is often **15 GB+**.

## 1. Install JDK 17

Install Temurin 17 (or equivalent). Set `JAVA_HOME` and add `%JAVA_HOME%\bin` to `PATH`.

## 2. Command-line tools only

1. Create SDK root, e.g. `%LOCALAPPDATA%\Android\Sdk`.
2. Download **Android SDK Command-line Tools** for Windows from [developer.android.com/studio#command-tools](https://developer.android.com/studio#command-tools).
3. Extract so `sdkmanager.bat` lives at:

   `%LOCALAPPDATA%\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat`

   (If you have `cmdline-tools\bin\`, move contents to `cmdline-tools\latest\bin\`.)

4. Set user environment variables:

   - `ANDROID_HOME` = `%LOCALAPPDATA%\Android\Sdk`
   - `PATH` += `%ANDROID_HOME%\platform-tools`
   - `PATH` += `%ANDROID_HOME%\cmdline-tools\latest\bin`

## 3. Install minimal packages

Open PowerShell:

```powershell
sdkmanager --licenses
```

Accept licenses, then install **only**:

```powershell
sdkmanager `
  "platform-tools" `
  "platforms;android-35" `
  "build-tools;35.0.0"
```

**Do not install** (unless you change policy):

- `emulator`
- `system-images;...`
- `sources;android-...` (optional for IDE jump-to-source only)
- Old platforms you do not target

If `build-tools;35.0.0` is unavailable, run `sdkmanager --list` and pick the latest **35.x** build-tools for API 35.

### Optional single older platform

Only if a dependency forces it:

```powershell
sdkmanager "platforms;android-34"
```

## 4. Flutter

Install Flutter SDK, add `flutter\bin` to `PATH`, then:

```powershell
flutter doctor -v
```

If Android licenses are missing:

```powershell
flutter doctor --android-licenses
```

Expected for this setup:

- Flutter OK  
- Android toolchain OK  
- **No** Android Studio required  
- Device appears when tablet is connected

## 5. Physical device

On the tablet:

1. **Settings → About →** tap build number → enable **Developer options**.  
2. **Developer options → USB debugging** on.  
3. Connect USB; on PC: `adb devices` → device `device` (not `unauthorized`).

Install HONOR/USB driver from OEM or Windows Update if the device does not appear.

## 6. Verify

```powershell
adb devices
flutter devices
```

When the Flutter app exists:

```powershell
cd algoritiQ\apps\tablet
flutter run
```

Debug APK installs over USB; hot reload works on device.

## Maintenance

| Task | Command |
| --- | --- |
| List installed | `sdkmanager --list_installed` |
| Update platform-tools | `sdkmanager "platform-tools"` |
| Add API when target changes | `sdkmanager "platforms;android-36"` (example) |

Keep **one** target `platforms;android-*` aligned with `compileSdk` in the Flutter `android/app/build.gradle` when the project is created.
