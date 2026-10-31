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

## Typing the address

Android apps cannot listen on ports below 1024 (the tablet's limit is exactly 1024), so the address always carries the port: `algoritiq.local:8443`. Without a scheme, many browsers (Firefox, Safari, most phone browsers) try plain `http://`, which used to fail silently on the TLS-only port.

The server socket now sniffs the first byte of each connection (`lib/api/https_server_socket.dart`): a TLS handshake goes to the HTTPS server as before; a plain HTTP request gets a **307 redirect** to `https://<the host the visitor typed>:8443/<same path>` and is closed. The redirect uses only the visitor's own host name or IP (checked against a strict pattern), never anything else from the request, and is not cached. Anything that is not HTTP gets `400`; a connection that says nothing is dropped after 5 s.

## Why the tablet never says "no IPv6"

Windows asks for IPv4 and IPv6 together. A "this name has no IPv6 address" reply (the standard way to say it) made Windows fail most lookups (0 of 8), and saying nothing made lookups take about 3 s and fail sometimes. Answering with a real IPv6 address makes them instant (12 of 12, 0.2 s). So the tablet announces its link-local IPv6 address and answers IPv6 questions with it; with no IPv6 it stays silent.

## Checked

On the Honor Pad X7 (Android 15) from a Windows PC: lookups by name worked 12 of 12; in deep sleep with the screen off 12 of 12; after a restart with the PIN never entered, within about 20 s.
Not checked: phones (Android and iPhone), Mac, Linux. Android Chrome in particular may not resolve `.local`; that is why the QR uses the IP.

## If the IP or the router changes

- **New IP, same router:** the tablet checks its addresses every 30 s and announces the new one. Devices cache a name for 2 minutes, so the name works again within about 2 minutes (an open page may need a refresh).
- **Different router or Wi-Fi:** same thing, as long as the new network lets devices talk to each other (no "client isolation"). If another tablet there already uses `algoritiq.local`, this one becomes `algoritiq-2.local`; check the admin guide.
- The certificate belongs to the tablet, not to the address, so the browser warning does not come back for a new IP.
- Checked: Wi-Fi switched off and on (name back in 5 s). Not checked on real hardware: a changed IP or a different router (covered by unit tests only).

## Check it yourself

1. Tablet on the clinic Wi-Fi, set up, admin guide on screen (it shows the name).
2. On a PC on the same Wi-Fi: `ping algoritiq.local` answers with the tablet's IP.
3. Open `https://algoritiq.local:8443/api/v1/health`, accept the warning: `{"status":"ok"}`.
4. Restart the tablet without unlocking it and repeat step 2 after about 30 s.

## Limits

- Some networks block multicast between devices (guest Wi-Fi, "client isolation"): the name will not resolve there, the IP address will not work either.
- A router that gives the tablet a new IP is handled (announced again); keeping the IP fixed in the router is still best.

## Code

`lib/api/https_server_socket.dart` (plain HTTP to https) · `lib/api/mdns/` (`mdns_message.dart` packets, `mdns_socket.dart` UDP socket, `local_name_responder.dart`) · wired in `lib/api/api_host.dart` and `server_controller.dart` · `KeepAliveService.kt` (multicast lock), `KeepAliveChannel.kt` (`localAddressesV6`) · `AddressPanel`.
Tests: `test/api/https_server_socket_test.dart`, `test/api/mdns/`, `test/api/server_controller_test.dart`, `test/features/access/admin_guide_test.dart`.
