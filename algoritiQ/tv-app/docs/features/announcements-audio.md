# Announcements & audio

Tablet owns text and audio generation; TV **downloads and plays** clips.

## Trigger

- On `token.called` (or recall) event, payload includes **`announcementUrl`** and ids for deduplication (`callId`, `announcementId` / attempt id per [patient-entry-and-queue-operations](../../../docs/features/patient-entry-and-queue-operations.md)).

## Playback rules

- **Serialized**: do not start a second clip while one is playing.
- **Dedupe**: ignore duplicate ids after reconnect; apply snapshot before resuming events ([connectivity-sync](../principles/connectivity-sync.md)).
- **Failure**: show serial on screen; log safe code; queue display still updates.

## Implementation

- **Media3 ExoPlayer** with OkHttp data source (same TLS as REST).
- Cache short clips on disk with bounded size; evict LRU.

## Out of scope (v1)

- TV-side TTS, transliteration, or LLM wording.
