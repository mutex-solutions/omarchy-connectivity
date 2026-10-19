# Connectivity

Wi-Fi, Bluetooth, Tailscale and airplane mode as one control for Omarchy. A bar
widget, or a 2x2 section inside
[Deck](https://github.com/mutex-solutions/omarchy-deck).

## Standalone

```bash
omarchy plugin add https://github.com/mutex-solutions/omarchy-connectivity --enable
```

Click the icon for four switches.

## Inside Deck

```bash
omarchy plugin add https://github.com/mutex-solutions/omarchy-connectivity
```

```json
{ "id": "connectivity", "title": "Connectivity", "span": 2, "rows": 2,
  "file": "/home/YOU/.config/omarchy/plugins/mutex-solutions.connectivity/deck/Section.qml",
  "page": "/home/YOU/.config/omarchy/plugins/mutex-solutions.connectivity/deck/Page.qml" }
```

`install-bundle.sh` in the Deck repo wires it up with the other sections.

In the cluster, **click a radio to toggle it, hold it to open that radio's own
section page** (Wi-Fi or Bluetooth), which is how those pages stay reachable now
that the cluster replaces their tiles.

## How it is built

| File | Role |
| --- | --- |
| `State.qml` | the four radios, the derived airplane mode, and the 2x2 tile body |
| `Radio.qml` | one square in the cluster |
| `deck/Section.qml` | the five members Deck reads |
| `deck/Page.qml` | the four switches |
| `Panel.qml` | the standalone bar widget |

The 2x2 tile is the one place a section draws its own body: it supplies
`tileComponent`, and Deck loads it in place of the default glyph-and-label
content. That is what makes the cluster look like the design mock.

The notice is the other half: while airplane mode is on the section publishes an
info notice, and Deck draws it in the shared strip below the grid.

## Requirements

Omarchy 4.x, `tailscale`.

## Licence

MIT. See [LICENSE](LICENSE).
