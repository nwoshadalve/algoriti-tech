# Connectivity (printer, TV)

The receptionist's **Connectivity** page (side menu) shows whether the devices the counter needs are connected. The printer works now; the TV screen is a placeholder until that app exists.

## Printer

Tested model: **Rongta RPP02C**, 58 mm mobile POS printer. Any Bluetooth Classic (SPP) ESC/POS printer should work; no vendor SDK is used ([Android services](../standards/android-services.md)).

### Pair once, then it connects by itself

1. Switch the printer on, open **Connectivity**, tap **Choose printer**.
2. Paired printers are listed first, then printers found nearby. Tap the printer. If it is new, Android shows its own pairing dialog (code is usually `0000` or `1234`).
3. The tablet remembers the printer (`printer.name`, `printer.address` in the app's preferences) and connects.

After that nobody touches anything: the tablet reconnects whenever the link is lost (printer switched off and on, out of range, Bluetooth toggled, app restarted).

### Automatic reconnect

Owned by `PrinterController` (Dart); `PrinterChannel.kt` only moves bytes and reports the link.

- On start, if a printer is saved and Bluetooth is usable, it connects.
- When the link drops (the socket read fails, or Android reports the disconnect), it reconnects **at once**, then waits **2 s, 5 s, 10 s, 30 s, 60 s** between failed tries and keeps trying every 60 s. A counter printer must heal itself, so there is no give-up; the page shows *Not connected* with a live "Trying again in N s", and **Connect now** restarts the waits.
- Bluetooth off or not allowed: it does **not** try (nothing to try with). The page says why and offers **Turn Bluetooth on** or **Allow Bluetooth**; the moment that changes it connects.
- **Runs without the screen.** `bootstrap()` starts the controller the same way it starts the local API (once the tablet is licensed), so it lives in the process that the foreground keep-alive service holds ([Keep-alive](./keep-alive.md)). Closing the app, locking the screen or restarting the tablet does not stop it: the printer is connected whenever it is on and in range, before anyone signs in. Checked on the tablet: connected at the sign-in screen, still connected after the app was closed.
- Toasts tell the receptionist when it connects or the link is lost, on any page.

### What the page shows

Only the **connection**: *Connected*, *Connecting*, *Not connected* (with "Trying again in N s"), *No printer set up*, or why Bluetooth is not usable. Plus the printer's name and one action: **Choose printer** (first time), **Connect now**, **Test print**, **Turn Bluetooth on** or **Allow Bluetooth**.

Deliberately **not** shown: battery, charging, temperature, paper, cover. The RPP02C does not report battery, charging or temperature over Bluetooth (probed on the real printer and checked in Rongta's Android SDK, which only has low-power and over-heated flags), and the page is kept to what the receptionist needs to act on. There is also no *Change printer* or *Remove printer*: once paired, the tablet keeps that printer.

### Test print

**Test print** (only while connected) first asks in a popup ("Print a test token?" with **Cancel** and **Print test token**). On confirm it prints a real-looking token:

- chamber and doctor names of the chamber (or doctor) the receptionist is working at,
- queue type **Regular**, dummy number **০১**, dummy ID `PT-০০-০০০০১`, the current date and time.

Toasts: *Test token printed.* or *The test token did not print. Check paper and cover.* (also when the printer is not connected), or *The chamber or doctor details for the token could not be found.* Before sending, the printer's status is read once; a cover-open or out-of-paper printer is reported as failed instead of sending the job.

### Token slip

The patient token, always in **Bengali**, one slip about 3 cm of paper long:

```
 আল-খিদমাহ্ মেডিকেল সার্ভিসেস, চাঁদপুর     chamber (up to 2 lines)
        ডাঃ মোঃ রহিম উদ্দিন                doctor
 - - - - - - - - - - - - - - - - - - - -
 [ নিয়মিত ]                       ১২     queue type, token number (big)
 - - - - - - - - - - - - - - - - - - - -
          ID: PT-২৬-০০৪২১                registration ID
        ৩০/১০/২৬ · ১২:১৪ PM              date and time
```

No product name, no patient name or phone. Queue types: **নিয়মিত** (Regular), **রিপোর্ট** (Report), **ড্রেসিং** (Dressing). The token number counts from 1 per queue type per day (decided with the owner; the queue itself is built later and will use `TokenSlip`).

How it prints: `TokenSlipRenderer` (`data/`) draws the slip with Flutter's text engine (the printer has no Bengali font) onto a **384-dot-wide** picture, `encodeRasterJob` turns it into black and white and wraps it as ESC/POS (`ESC @`, `GS v 0` raster, `ESC d 3` feed), and `PrinterChannel.kt` sends the bytes in 1 KB chunks. The Bengali glyphs come from Android's system Bengali font (only Plus Jakarta Sans is bundled today); bundling Noto Sans Bengali would make slips identical on every tablet.

### Layout

Portrait: printer card, then TV card, one column. Landscape (content ≥ 720 dp): side by side. **Fits the screen with no scrolling** on phone, Honor Pad and tablet sizes in both orientations (a test fails if the page can scroll); a scroll view remains only as a safety net for very short windows. Light and dark themes; English and Bengali (`test/features/connectivity`).

### Code

| Where | What |
| --- | --- |
| `lib/features/connectivity/domain` | `PrinterDevice`, `PrinterLink`, `PrinterReading`, events, `PrinterStore` |
| `lib/features/connectivity/application/printer_controller.dart` | State, pairing, reconnect, polling |
| `lib/features/connectivity/presentation` | Page, printer card, picker sheet, TV card |
| `lib/platform/printer_gateway.dart` | Typed wrapper over the channels |
| `android/.../PrinterChannel.kt` | Bluetooth Classic SPP, pairing, status, test page |

Channels: `tech.algoriti.algoritiq/printer` (calls) and `.../printer/events` (link, Bluetooth state, scan results).

### Permissions

Android 12+: `BLUETOOTH_CONNECT` and `BLUETOOTH_SCAN` (`neverForLocation`), asked from the page with **Allow Bluetooth**. Older: the legacy `BLUETOOTH*` permissions (up to API 30).

### Not done yet

- TV screen connection.
- Issuing real tokens from the queue (patient registration and per-queue counters); this page only prints a test token.
