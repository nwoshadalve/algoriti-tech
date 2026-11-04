# Display states

Primary waiting-room experiences after pairing and audio setup.

## States

| State | When | UI |
| --- | --- | --- |
| **Idle** | Connected, no token called | Waiting lists; empty call panel |
| **Live** | Token called / queue active | Large serial in **ঘোষণা**; waiting lists updated |
| **Disconnected** | WS/API lost | Stale snapshot + banner **Disconnected — last update at …** |

## Content rules

- Serial + queue type labels only on board ([queue-product-decisions](../../../docs/features/queue-product-decisions.md)).
- Doctor/chamber footer from snapshot (`Doctor.name` with title, chamber name, photo via API).

## Connection banner

- Subtle connected indicator when live; prominent stale banner when disconnected.

## Mock references

- [display-idle.html](../../../mock/tv-app/screens/display-idle.html)
- [display-live.html](../../../mock/tv-app/screens/display-live.html)
- [display-disconnected.html](../../../mock/tv-app/screens/display-disconnected.html)

## Navigation (bootstrap)

Stub app uses internal routes for design review; production kiosk may use a single activity with state-driven content.
