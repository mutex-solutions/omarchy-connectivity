# Connectivity

Wi-Fi, Bluetooth, Tailscale and airplane mode as one popup for Omarchy.

**Connectivity is deliberately not a [Deck](https://github.com/mutex-solutions/omarchy-deck)
section.** It is a composite of four radios, and a composite hides the
individual controls. Deck's catalogue carries Wi-Fi, Bluetooth and Tailscale as
sections of their own, and a user can place and size them however they want.
This plugin is the one-popup version for the bar.

## Standalone

```bash
omarchy plugin add https://github.com/mutex-solutions/omarchy-connectivity --enable
```

Click the icon for four switches: Wi-Fi, Bluetooth, Tailscale and airplane
mode. Airplane mode is derived, not stored: it reads as on whenever every radio
is off, and switching it on turns them all off.

## How it is built

| File | Role |
| --- | --- |
| `State.qml` | the four radios and the derived airplane mode |
| `deck/Page.qml` | the four switches, rendered in this plugin's popup |
| `Panel.qml` | the standalone bar widget |

The page is kept in `deck/` because the standalone popup loads it from there;
there is no `deck/Section.qml`, and Deck does not register this plugin.

## Requirements

Omarchy 4.x, `tailscale`.

## Licence

MIT. See [LICENSE](LICENSE).
