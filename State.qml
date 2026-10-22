import QtQuick
import Quickshell
import Quickshell.Networking
import Quickshell.Bluetooth
import Quickshell.Io
import qs.Commons

// Connectivity state: the four radios of the design mock's cluster, plus the
// 2x2 tile body that renders them.
Item {
  id: s

  // Tailscale state and actions come from the upstream Service.qml the stock
  // panel uses. It is loaded by URL, never copied, so an Omarchy update to
  // that file reaches this section. The CLI probe below is the fallback.
  Loader {
    id: tailscaleUpstream
    source: "file:///usr/share/omarchy/shell/plugins/panels/tailscale/Service.qml"
  }

  readonly property var tailscaleService: tailscaleUpstream.item
  readonly property bool tailscaleUp: tailscaleService
    ? (tailscaleService.active === true)
    : cliTailscaleUp

  property bool cliTailscaleUp: false

  readonly property bool wifi: Networking.wifiEnabled
  readonly property var btAdapter: Bluetooth.defaultAdapter
  readonly property bool bluetooth: !!btAdapter && btAdapter.enabled

  // Airplane is derived, not stored: it is on when every radio is off.
  readonly property bool airplane: !wifi && !bluetooth && !tailscaleUp

  readonly property bool active: wifi || bluetooth || tailscaleUp
  readonly property string label: "Connectivity"
  readonly property string icon: "󰖩"

  readonly property string detail: {
    // The half tile has one short line; the names are on the radios in the
    // square and full views.
    var n = (wifi ? 1 : 0) + (bluetooth ? 1 : 0) + (tailscaleUp ? 1 : 0)
    if (airplane) return "airplane mode"
    if (n === 0) return "all off"
    return n + (n === 1 ? " radio on" : " radios on")
  }

  // The one notice this section can raise. Deck draws the strip; a section that
  // has nothing to say returns null.
  readonly property var notice: airplane
    ? ({ severity: "info", title: "Airplane mode is on", detail: "Every radio is off" })
    : null

  // The custom tile Deck loads when a section supplies one. The square is
  // the 2x2 block; the full size is a row of the same four radios.
  property Component tileComponent: cluster
  property Component tileFull: rowCluster

  // A radio's hold opens that radio's own section page. Deck owns the page
  // host, so this goes through Deck's IPC; outside Deck it is a no-op.
  function openSection(id) {
    Quickshell.execDetached(["omarchy-shell", "mutex-solutions.deck", "openSection", id])
  }

  function toggleWifi() {
    Networking.wifiEnabled = !Networking.wifiEnabled
  }

  function toggleBluetooth() {
    Quickshell.execDetached(["omarchy-bluetooth-power", bluetooth ? "off" : "on"])
  }

  function toggleTailscale() {
    if (tailscaleService && typeof tailscaleService.toggleTailscale === "function")
      tailscaleService.toggleTailscale()
    else
      Quickshell.execDetached(["tailscale", tailscaleUp ? "down" : "up"])
    settleTimer.restart()
  }

  function toggleAirplane() {
    if (airplane) {
      Networking.wifiEnabled = true
      Quickshell.execDetached(["omarchy-bluetooth-power", "on"])
    } else {
      Networking.wifiEnabled = false
      Quickshell.execDetached(["omarchy-bluetooth-power", "off"])
      if (tailscaleUp) {
        if (tailscaleService && typeof tailscaleService.down === "function")
          tailscaleService.down()
        else
          Quickshell.execDetached(["tailscale", "down"])
      }
    }
    settleTimer.restart()
  }

  Process {
    id: tailscaleProbe
    command: ["tailscale", "status", "--json"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          s.cliTailscaleUp = JSON.parse(text || "{}").BackendState === "Running"
        } catch (e) {
        }
      }
    }
  }

  function refresh() {
    if (!tailscaleProbe.running) tailscaleProbe.running = true
  }

  Timer {
    id: settleTimer
    interval: 900
    onTriggered: s.refresh()
  }

  Timer {
    interval: 15000
    running: true
    repeat: true
    onTriggered: s.refresh()
  }

  Component.onCompleted: refresh()

  Component {
    id: tailscaleMark
    // The 3x3 dot mark reads smaller than a font glyph at the same nominal
    // size; scale it up so it sits with Wi-Fi, Bluetooth and Airplane.
    TailscaleIcon { iconSize: Style.font.display * 1.35 }
  }

  Component {
    id: rowCluster

    Item {
      Row {
        anchors.fill: parent
        spacing: Style.space(9)

        Radio {
          width: (parent.width - 3 * parent.spacing) / 4
          height: parent.height
          glyph: "󰤨"
          caption: "Wi-Fi"
          checked: s.wifi
          onTapped: s.toggleWifi()
          onHeld: s.openSection("wifi")
        }

        Radio {
          width: (parent.width - 3 * parent.spacing) / 4
          height: parent.height
          glyph: "󰂯"
          caption: "Bluetooth"
          checked: s.bluetooth
          onTapped: s.toggleBluetooth()
          onHeld: s.openSection("bluetooth")
        }

        Radio {
          width: (parent.width - 3 * parent.spacing) / 4
          height: parent.height
          iconComponent: tailscaleMark
          caption: "Tailscale"
          checked: s.tailscaleUp
          onTapped: s.toggleTailscale()
          onHeld: s.openSection("tailscale")
        }

        Radio {
          width: (parent.width - 3 * parent.spacing) / 4
          height: parent.height
          glyph: "\uf072"
          caption: "Airplane"
          checked: s.airplane
          onTapped: s.toggleAirplane()
        }
      }
    }
  }

  Component {
    id: cluster

    Item {
      Grid {
        anchors.fill: parent
        columns: 2
        // The four radios are the tile, not a picture of it: Deck draws a
        // custom tile with no inset, so this spacing has to equal Deck's grid
        // gap (Style.space(9) in Panel.qml) and each cell becomes exactly one
        // grid unit. A different value here makes the 2x2 cluster wider or
        // narrower than the 2x2 cells it occupies.
        spacing: Style.space(9)
        readonly property real cell: (width - spacing) / 2

        Radio {
          width: parent.cell
          height: parent.cell
          glyph: "󰤨"
          caption: "Wi-Fi"
          checked: s.wifi
          onTapped: s.toggleWifi()
          onHeld: s.openSection("wifi")
        }

        Radio {
          width: parent.cell
          height: parent.cell
          glyph: "󰂯"
          caption: "Bluetooth"
          checked: s.bluetooth
          onTapped: s.toggleBluetooth()
          onHeld: s.openSection("bluetooth")
        }

        Radio {
          width: parent.cell
          height: parent.cell
          iconComponent: tailscaleMark
          caption: "Tailscale"
          checked: s.tailscaleUp
          onTapped: s.toggleTailscale()
          onHeld: s.openSection("tailscale")
        }

        Radio {
          width: parent.cell
          height: parent.cell
          glyph: "\uf072"
          caption: "Airplane"
          checked: s.airplane
          onTapped: s.toggleAirplane()
        }
      }
    }
  }
}
