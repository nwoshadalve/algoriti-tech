# Local name (`algoritiq.local`)

The tablet gives itself a name other devices on the clinic Wi-Fi can type instead of an IP address. It needs no router setup and no internet.

## How it works

- The tablet announces itself with **mDNS** (the "Bonjour" name service): devices ask "where is `algoritiq.local`?" and the tablet answers with its address.
- Before taking a name it asks the network if anyone uses it. If so it tries `algoritiq-2.local`, `-3`, … (two tablets on one Wi-Fi), up to 9.
- It answers with the Wi-Fi **IPv4 and IPv6 link-local** address, announces again when either changes (checked every 30 s), and says goodbye when the server stops.
- The HTTPS server listens on IPv6 and IPv4 together, so either address works.
- Everything runs in the background with the server, also on a locked or restarted tablet ([keep-alive](./keep-alive.md)). A multicast lock held by the service keeps the Wi-Fi chip passing these packets with the screen off.

## What the user sees

The admin guide shows `https://algoritiq.local:8443` to type, the IP address below it, and a QR code. The **QR code carries the IP address**: every phone can open that. The name appears a few seconds after the server starts; until then (or if no name is free) only the IP is shown.

The browser still shows the one-time certificate warning: no trusted certificate can exist for a `.local` name.

## Why the tablet never says "no IPv6"

Windows asks for IPv4 and IPv6 together. A "this name has no IPv6 address" reply (the standard way to say it) made Windows fail most lookups (0 of 8), and saying nothing made lookups take about 3 s and fail sometimes. Answering with a real IPv6 address makes them instant (12 of 12, 0.2 s). So the tablet announces its link-local IPv6 address and answers IPv6 questions with it; with no IPv6 it stays silent.

## Checked

On the Honor Pad X7 (Android 15) from a Windows PC: lookups by name worked 12 of 12; in deep sleep with the screen off 12 of 12; after a restart with the PIN never entered, within about 20 s.
Not checked: phones (Android and iPhone), Mac, Linux. Android Chrome in particular may not resolve `.local`; that is why the QR uses the IP.

## Limits

- Some networks block multicast between devices (guest Wi-Fi, "client isolation"): the name will not resolve there, the IP address will not work either.
- A router that gives the tablet a new IP is handled (announced again); keeping the IP fixed in the router is still best.

## Code

`lib/api/mdns/` (`mdns_message.dart` packets, `mdns_socket.dart` UDP socket, `local_name_responder.dart`) · wired in `lib/api/api_host.dart` and `server_controller.dart` · `KeepAliveService.kt` (multicast lock), `KeepAliveChannel.kt` (`localAddressesV6`) · `AddressPanel`.
Tests: `test/api/mdns/`, `test/api/server_controller_test.dart`, `test/features/access/admin_guide_test.dart`.
