# Keeping the tablet's server available

The queue server lives in the tablet app. It must answer with the screen locked, after the app is closed, and after a restart — **including a PIN-locked tablet that nobody has unlocked yet**.

## How

- **One engine for the process** (`EngineHolder.kt`): the Flutter engine, and the API inside it, outlive the screen. The Activity only attaches to it.
- **Foreground service** (`KeepAliveService.kt`): keeps the process alive, shows a small "Queue server is running" notice, holds a CPU wake lock, a Wi-Fi lock and a multicast lock (for the [local name](./local-name.md)). Restarts itself if the system stops it.
- **Data before unlock** (`AlgoritiqApplication.kt`, `DeviceStorage.kt`): all app data (database, photos, settings, secure storage) lives in Android's *device-protected* storage, so it can be read before the first unlock ("Direct Boot"). Data from older versions is moved there once, the first time the tablet is unlocked after the update (photo paths in the database are updated too).
- **Boot start** (`BootReceiver.kt`, direct-boot aware): starts the service right after power-on (`LOCKED_BOOT_COMPLETED`, before the PIN is entered), and also on `BOOT_COMPLETED` / `QUICKBOOT_POWERON`, after an app update, and on unlock (`USER_PRESENT`). With no UI, the engine starts and only the API runs (`bootstrap()`); the screen is built when the app is opened.
- **Permission guide** (once, after first-time setup): *Keep the tablet ready* walks the user through the settings below.

## What the user is asked to allow

| Item | Why | Needed |
| --- | --- | --- |
| Run in the background (battery) | Android may pause the app to save battery | **Required** |
| Show the running notice | Android 13+ hides the service notice otherwise | **Required** |
| Allow Bluetooth | Android 12+ needs runtime permission to read Bluetooth state and open the turn-on dialog (works whether the radio is off or on) | **Required** when the tablet has Bluetooth |
| Start after a restart (auto-start) | Some makers (Honor, Xiaomi, Oppo…) block it by default; Android can't tell us (on the Honor Pad X7 the startup manager is listed but cannot be opened). Instead the app records each restart it was started for, only if the boot signal arrives within 10 minutes of power-on (a late re-sent signal does not count), and the row is ticked after one such restart (`AutoStartProbe`) | **Required** |

The guide re-reads Android's state when the user returns from a settings page (including auto-start on Honor-style tablets, via `AutoStartProbe`). **Continue** stays disabled until every required row is done — there is no skip. Each row uses a compact settings-style icon button; nothing changes silently. If a requirement breaks later, the guide returns. A screen lock (PIN) is fine and recommended.

When the user taps **Continue**, the foreground service and local HTTPS API start (`ReadinessController.acknowledge` + `ServerHost` below the readiness gate). The guide does not show a “background service running” banner during the checklist.

## Checked on the Honor Pad X7 (Android 15)

- Lock screen showing: the API kept answering.
- Restart with a PIN set, **never unlocked**: the API answered 16 s after power-on (user state `RUNNING_LOCKED`), with the same HTTPS certificate and database as before.
- Update from the previous version: data moved to device-protected storage with nothing lost (license, language, doctor, chambers, photo).
- Not yet checked: a fully sleeping screen over hours.

## Limits

- Device-protected data is encrypted with a key tied to the tablet, not to the PIN ([security](../principles/security-privacy.md#data-at-rest)).
- Right after updating from a version before this change, the first restart still waits for one unlock (the data has not been moved yet).
- A maker's "app launch" manager can still stop the service until auto-start is allowed.
- The tablet must stay plugged in: the wake lock keeps the CPU awake.

## Code

`android/app/src/main/kotlin/…/` (`AlgoritiqApplication`, `DeviceStorage`, `EngineHolder`, `KeepAliveService`, `BootReceiver`, `KeepAliveChannel`) · `lib/platform/keep_alive_gateway.dart` · `lib/features/readiness/`.
Tests: `test/features/readiness/`.
