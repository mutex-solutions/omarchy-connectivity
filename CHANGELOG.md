# Changelog

## 0.1.4

- **No longer a Deck section.** Connectivity is a standalone bar popup, not a
  composite tile. Wi-Fi, Bluetooth and Tailscale are individual sections in
  Deck's catalogue, and a user can place and size them however they want.
  `deck/Section.qml`, the custom 2x2 cluster and its `Radio`/`TailscaleIcon`
  components are gone; `deck/Page.qml` remains because the standalone popup
  renders it.

## 0.1.3

- The cluster now fills its 2x2 tile exactly. Deck draws a custom tile with no
  inset, and the internal gap is the grid gap, so each radio is one grid unit
  and the four together are the big square. Before this, the four squares
  floated inside a padded tile.

## 0.1.2

- A hold on the Tailscale radio opens the Tailscale section's page
  (`mutex-solutions.tailscale`), matching Wi-Fi and Bluetooth. The radio still
  toggles on a tap; the page is where machines, exit nodes and sign-in live.

## 0.1.1

- Tailscale state and the toggle now come from the upstream
  `panels/tailscale/Service.qml`, loaded by URL. The CLI probe remains as the
  fallback when the file is missing. Nothing is copied, so an Omarchy update to
  that service reaches this section.
- Verified in the shell: the service loaded, reported active after its first
  poll, and `tailscaleUp` followed it while the CLI fallback agreed.

## 0.1.0

First release.

- One 2x2 tile holding the four radios from the design mock: Wi-Fi, Bluetooth,
  Tailscale and airplane mode.
- Standalone the same controls appear as four switches in the popup.
- Airplane mode is derived, not stored: it reads as on whenever every radio is
  off, and switching it on turns them all off.
- Publishes an info notice while airplane mode is on, which Deck renders in its
  notice strip.
