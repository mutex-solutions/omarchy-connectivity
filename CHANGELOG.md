# Changelog

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
