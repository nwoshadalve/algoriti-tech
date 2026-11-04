# Setup audio

Post-pairing screen to verify **TV speaker volume** and **announcement playback path** before clinic hours.

## Flow

1. Staff adjusts volume with D-pad (system or in-app guidance).
2. **Test announcement** — TV **GET**s a short clip from the tablet API (same path as production announcements).
3. Report **audio readiness** to tablet health (`tv` service id in [OpenAPI](../../../docs/api/openapi.yaml)).

## v1 scope

- Tablet prepares all announcement audio ([queue-product-decisions](../../../docs/features/queue-product-decisions.md)).
- **No** on-TV TTS voice picker (overrides [rnd_architechture.md](../../../docs/discussions/rnd_architechture.md) R&D notes).

## Failure

- Show Bengali guidance to check HDMI/audio output and volume; allow retry.
- Clinic can still open display if product allows skip-with-warning — document in ADR if implemented.

## Mock reference

[mock/tv-app/screens/setup-audio.html](../../../mock/tv-app/screens/setup-audio.html)
