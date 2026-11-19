# Algoriti Tech

**Algoriti Tech** builds practical software for real-world operations—starting with healthcare and clinic workflows in Bangladesh and expanding over time.

This repository is the company monorepo: products live in their own directories as they are developed and launched.

## Products

### AlgoritiQ *(initial product)*

**AlgoritiQ** is an offline-first **patient serial and queue management system** for clinics. It runs on a local network without requiring Internet for day-to-day use: a counter tablet hosts the queue, syncs to an Android TV display and a doctor’s laptop dashboard, supports Bengali tokens and announcements, and prints via Bluetooth.

| | |
|---|---|
| **Status** | Initial production — being tested in a doctor's chamber |
| **Location** | [`algoritiQ/`](./algoritiQ/) |
| **Docs** | [`algoritiQ/docs/`](./algoritiQ/docs/) · [Architecture](./algoritiQ/docs/architecture/) · [Dev setup](./algoritiQ/docs/dev-setup/) · [Prod build](./algoritiQ/docs/prod-build-deploy/) |

### AlgoritiDx

**AlgoritiDx** is a diagnostic center operations product in planning and discovery. It is intended for a PC/local-server setup, with candidate workflows covering patient registration, test orders, billing, sample tracking, and report delivery status. Initial scope will be validated with diagnostic centers.

| | |
|---|---|
| **Status** | Planning and discovery |
| **Location** | [`algoritiDx/`](./algoritiDx/) |
| **Docs** | [`algoritiDx/docs/`](./algoritiDx/docs/) |

### Future products

Additional products are planned and will be added under this repo as they are scoped and released. This README will be updated as each one is announced.

## Repository layout

```
algoriti-tech/
├── .gitignore         # Shared ignore rules for the monorepo
├── branding/          # Logos and brand guidelines (SVG)
├── README.md          # Company overview (this file)
├── algoritiQ/         # AlgoritiQ — patient serial management
└── algoritiDx/        # AlgoritiDx — diagnostic center operations
```

## Contact

- **Repository:** [github.com/nwoshadalve/algoriti-tech](https://github.com/nwoshadalve/algoriti-tech)
