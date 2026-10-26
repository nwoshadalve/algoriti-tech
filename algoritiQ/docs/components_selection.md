# Components Selection

Role in the system is defined in [architecture/overview.md](architecture/overview.md) (summary) and [rnd_architechture.md](discussions/rnd_architechture.md) (detail).

Prices were checked on **23 October 2026** and may change. Prefer **Star Tech** or **Ryans** for purchase; confirm stock and warranty on the invoice before buying.

## Summary

| Component | Qty (typical) | Status | Est. unit price (BDT) |
| --- | --- | --- | --- |
| Counter tablet (host) | 1 (travels) | **Selected** | ৳16,500–৳17,000 |
| Waiting-room Android TV | 1 per chamber | Shortlisted | ৳17,679–৳27,500 |
| Thermal printer | 1 (travels) | **Selected** | ৳3,600 |
| Wi‑Fi router | 1 per chamber | Shortlisted | ৳1,949–৳2,450 |
| Mini UPS / IPS (router) | 1 per chamber | Shortlisted | ৳1,800–৳1,900 |
| Doctor laptop | 1 (travels) | Bring your own | — |

**Rough one-time hardware (2 chambers):** about ৳17k tablet + ৳3.6k printer + 2× (TV + router + UPS). Example with mid-range TV (SINGER 32″): **~৳78k** before paper and cables.

---

## Android tablet (queue host)

**Status: Selected**

### Component name

HONOR Pad X7 Wi‑Fi (4 GB RAM + 128 GB storage), model **JMS-W09**

### Role

Authoritative host: queue database, local HTTP/WebSocket server, Bluetooth printing, Bengali receipt rendering, announcement audio preparation for the TV.

### Specifications

- Operating system: Android 15 with MagicOS 9
- Processor: Qualcomm Snapdragon 680, 6 nm, octa-core, up to 2.4 GHz
- Graphics: Adreno 610
- Memory: 4 GB RAM
- Storage: 128 GB; microSD expansion up to 1 TB
- Display: 8.7-inch IPS/TFT LCD, 1340 × 800, up to 90 Hz
- Wi‑Fi: Wi‑Fi 5 (802.11 a/b/g/n/ac), 2.4 GHz and 5 GHz
- Bluetooth: 5.0 (BLE supported)
- USB: USB Type-C with OTG
- Battery: 7020 mAh; 10 W wired charging
- Dimensions / weight: 211.8 × 124.8 × 8 mm; 365 g
- Warranty: 1 year (confirm official warranty on purchase)

### Estimated price

- **Target purchase: ~৳17,000**
- [Star Tech — ৳16,500](https://www.startech.com.bd/honor-pad-x7)
- [Ryans — ৳16,500](https://www.ryans.com/category/regular-tablet) (listing: HONOR Pad X7 Wi‑Fi 4/128)
- [Pickaboo — ৳16,999](https://www.pickaboo.com/product-detail/honor-pad-x7-4gb-128gb-wi-fi)
- [HONOR Pad X7 (manufacturer)](https://www.honor.com/global/tablets/honor-pad-x7/)

### Notes

Keep the tablet on charge and the clinic app in the foreground during sessions. 4 GB RAM is sufficient for this dedicated workload.

---

## Android TV (display + built-in speakers)

**Status: Shortlisted — buy one per chamber (fixed in room)**

### Component name (recommended)

**SINGER SLE32GP6100TV** — 32″ HD Android Google TV  
*(Alternative budget: **Smart SEL-32A24K** 32″ Android TV; alternative brand: **Xiaomi TV A Pro 32 2026** Google TV.)*

### Role

Read-only queue display; play announcement audio from the tablet (download/cache + play). Requires installing the clinic TV app (sideload or Play Store when published). Disable guest-network / AP isolation on the chamber router.

### Specifications (recommended: SINGER)

- Screen: 32″, HD 1366 × 768
- OS: Android 11 (Google TV)
- Processor: quad-core
- RAM / storage: 1.5 GB / 16 GB
- Wi‑Fi: dual-band
- Speakers: 2 × 10 W, Dolby Audio
- Warranty: 3-year panel, 3-year parts (SINGER; per retailer listing)

### Specifications (budget alternative: Smart SEL-32A24K)

- Screen: 32″, HD 1280 × 720
- OS: Android 14
- RAM / storage: 1 GB / 8 GB *(tighter for a custom app; test early)*
- Speakers: 10 W + 10 W
- Warranty: per Smart policy via retailer

### Estimated price

| Model | Est. price (BDT) | Retailer |
| --- | --- | --- |
| Smart SEL-32A24K 32″ Android TV | ৳17,679 | [Star Tech](https://www.startech.com.bd/smart-sel-32a24k-tv) |
| Xiaomi TV A Pro 32 2026 (Google TV) | ৳23,500 | [Star Tech](https://www.startech.com.bd/xiaomi-tv-a-pro-32-2026) |
| SINGER SLE32GP6100TV 32″ Google TV | ৳27,500 | [Star Tech](https://www.startech.com.bd/singer-sle32gp6100tv-32-inch-google-tv) |

### Notes

Prefer **≥1.5 GB RAM** on the TV for a stable kiosk-style app. Verify Bengali audio playback at clinic volume before finalizing the model. A small **Android TV box with built-in speaker** is cheaper but is a separate category with weaker retail support; a 32″ smart TV matches the original “TV + speaker” requirement.

---

## Portable thermal printer

**Status: Selected**

### Component name

**Rongta RPP02C** — 58 mm portable POS printer (Bluetooth + USB)

### Role

Print patient token receipts; Bengali via **bitmap/ESC/POS raster** from the tablet (not built-in printer fonts).

### Specifications

- Technology: direct thermal, ESC/POS
- Print width: ~48 mm effective (384 dots @ 203 dpi)
- Speed: ~50–80 mm/s
- Connectivity: Bluetooth 5.2 (SPP + BLE), USB Type-C
- Battery: 2500 mAh (typical), DC 5 V charging
- Memory: 64 KB RAM, 2 MB flash (per retailer spec)
- Weight: ~215 g
- Warranty: 1 year (Star Tech / Ryans listings)

### Estimated price

- **৳3,600**
- [Star Tech — ৳3,600](https://www.startech.com.bd/rongta-rpp02c-58mm-mobile-pos-printer)
- [Ryans — ৳3,600](https://www.ryans.com/category/pos-printer-rongta)
- [Rongta RPP02C (manufacturer)](https://www.rongtatech.com/rpp02c-58mm-thermal-mobile-receipt-printer_p127.html)

### Consumables

58 mm thermal rolls (continuous); keep spare rolls in each chamber bag.

---

## Wi‑Fi router (chamber LAN)

**Status: Shortlisted — one per chamber**

### Component name (recommended)

**TP-Link Archer C54** or **Mercusys AC12G** — dual-band AC1200 class router

### Role

Private clinic SSID; tablet, TV, and laptop on the same subnet. **Turn off AP/client isolation** so devices can reach the tablet host.

### Specifications (example: Mercusys AC12G per Ryans)

- Wi‑Fi: dual-band, Wi‑Fi 5, gigabit ports (model-dependent)
- Coverage: ~1500 sq ft (manufacturer claim)
- No cellular required

### Estimated price

| Model | Est. price (BDT) | Retailer |
| --- | --- | --- |
| Mercusys AC12 AC1200 | ৳1,949 | [Star Tech](https://www.startech.com.bd/networking/router) |
| TP-Link Archer C54 AC1200 | ৳2,290 | [Ryans router category](https://www.ryans.com/category/network-network-router) |
| Mercusys AC12G AC1300 gigabit | ৳2,450 | [Ryans](https://www.ryans.com/mercusys-ac12g-ac1300-dual-band-wireless-gigabit-router) |

Upgrade path (busier Wi‑Fi / more devices): **ASUS RT-AX53U** Wi‑Fi 6 — [৳6,450–৳7,500 at Star Tech](https://www.startech.com.bd/asus-rt-ax53u-ax1800-dual-band-wifi-router).

---

## Mini UPS / IPS (router backup)

**Status: Shortlisted — one per chamber**

### Component name

**PC Power PCMU1018** — 8800 mAh multifunction mini UPS (router / ONU)

### Role

Keep router (and optionally ONU) alive during short outages so the TV can stay on Wi‑Fi. Tablet and printer still need their own power; this does not backup the whole clinic.

### Specifications

- Capacity: 8800 mAh
- Output: 9 V / 12 V DC and USB (per retailer); max ~18 W total
- Protection: over-charge/discharge, overload, short circuit
- Warranty: 1 year (Star Tech listing)

### Estimated price

- **৳1,800–৳1,900**
- [Star Tech — PCMU1018](https://www.startech.com.bd/pc-power-pcmu1018-8800mah-mini-ups)

Match the UPS output voltage to the router’s adapter (usually 9 V or 12 V).

---

## Doctor laptop (monitoring dashboard)

**Status: Bring your own — no fixed SKU**

### Role

Browser dashboard client only; connects to the tablet over chamber Wi‑Fi. Not the database host.

### Minimum practical specs

- Any Windows/macOS/Linux laptop with a modern browser
- Reliable Wi‑Fi; battery OK for short use but mains power preferred in the chamber
- No special GPU required

### Estimated price

— (existing device)

---

## Purchase checklist

1. **Tablet:** HONOR Pad X7 Wi‑Fi 4/128, official warranty, ~৳17k.
2. **Printer:** RPP02C + test Bengali bitmap print before bulk paper purchase.
3. **Per chamber:** TV + dual-band router + mini UPS; configure SSID/password; disable client isolation.
4. **Acceptance:** pair printer, run host app 2+ hours, TV reconnect test, router power-cycle test (see architecture doc §9).
