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

  property bool tailscaleUp: false

  readonly property bool wifi: Networking.wifiEnabled
  readonly property var btAdapter: Bluetooth.defaultAdapter
  readonly property bool bluetooth: !!btAdapter && btAdapter.enabled

  // Airplane is derived, not stored: it is on when every radio is off.
  readonly property bool airplane: !wifi && !bluetooth && !tailscaleUp

  readonly property bool active: wifi || bluetooth || tailscaleUp
  readonly property string label: "Connectivity"
  readonly property string icon: "≋"

  readonly property string detail: {
    var parts = []
    if (wifi) parts.push("Wi-Fi")
    if (bluetooth) parts.push("Bluetooth")
    if (tailscaleUp) parts.push("Tailscale")
    return parts.length ? parts.join(" · ") : "all off"
  }

  // The one notice this section can raise. Deck draws the strip; a section that
  // has nothing to say returns null.
  readonly property var notice: airplane
    ? ({ severity: "info", title: "Airplane mode is on", detail: "Every radio is off" })
    : null

  // The custom tile Deck loads when a section supplies one.
  property Component tileComponent: cluster

  function toggleWifi() {
    Networking.wifiEnabled = !Networking.wifiEnabled
  }

  function toggleBluetooth() {
    Quickshell.execDetached(["omarchy-bluetooth-power", bluetooth ? "off" : "on"])
  }

  function toggleTailscale() {
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
      if (tailscaleUp) Quickshell.execDetached(["tailscale", "down"])
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
          s.tailscaleUp = JSON.parse(text || "{}").BackendState === "Running"
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
    id: cluster

    Item {
      Grid {
        anchors.fill: parent
        columns: 2
        spacing: Style.space(8)
        readonly property real cell: (width - spacing) / 2

        Radio {
          width: parent.cell
          height: parent.cell
          glyph: "≋"
          checked: s.wifi
          onTapped: s.toggleWifi()
        }

        Radio {
          width: parent.cell
          height: parent.cell
          glyph: "ᛒ"
          checked: s.bluetooth
          onTapped: s.toggleBluetooth()
        }

        Radio {
          width: parent.cell
          height: parent.cell
          glyph: "◇"
          checked: s.tailscaleUp
          onTapped: s.toggleTailscale()
        }

        Radio {
          width: parent.cell
          height: parent.cell
          glyph: "✈\uFE0E"
          checked: s.airplane
          onTapped: s.toggleAirplane()
        }
      }
    }
  }
}
