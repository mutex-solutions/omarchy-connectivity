# Connectivity

Wi-Fi, Bluetooth, Tailscale and airplane mode as one popup for Omarchy.

The recommended [Deck](https://github.com/mutex-solutions/omarchy-deck) setup
uses the individual Wi-Fi, Bluetooth and Tailscale sections, so each radio can
be placed and sized on its own. For a compact cluster, this plugin also ships
an optional 2x2 block section: four radios in one tile. It is not installed by
Deck's bundle; add it from the catalogue when you want the block.

## Standalone

```bash
omarchy plugin add https://github.com/mutex-solutions/omarchy-connectivity --enable
```

Click the icon for four switches: Wi-Fi, Bluetooth, Tailscale and airplane
mode. Airplane mode is derived, not stored: it reads as on whenever every radio
is off, and switching it on turns them all off.

## Optional Deck block

The block is a normal Deck section (`deck/Section.qml`). It is not part of
Deck's default bundle; add it from the catalogue, or register it directly:

```json
{ "id": "connectivity", "title": "Connectivity block", "span": 2, "rows": 2,
  "file": "/home/YOU/.config/omarchy/plugins/mutex-solutions.connectivity/deck/Section.qml",
  "page": "/home/YOU/.config/omarchy/plugins/mutex-solutions.connectivity/deck/Page.qml" }
```

The active radios use the same selected and inactive fills as any other Deck
tile (`Style.selectedFillAlpha`, `Style.normalFillAlpha`), with an accent
border and accent glyph when on, so the block does not glare and does not look
like a different kind of control.

## How it is built

| File | Role |
| --- | --- |
| `State.qml` | the four radios and the derived airplane mode |
| `deck/Section.qml` | the optional 2x2 block |
| `Radio.qml` | one square in the block |
| `deck/Page.qml` | the four switches, rendered in this plugin's popup |
| `Panel.qml` | the standalone bar widget |

## Requirements

Omarchy 4.x, `tailscale`.

## Licence

MIT. See [LICENSE](LICENSE).
