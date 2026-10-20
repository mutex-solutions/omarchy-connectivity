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
    TailscaleIcon { iconSize: Style.font.display }
  }

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
          glyph: "󰤨"
          checked: s.wifi
          onTapped: s.toggleWifi()
          onHeld: s.openSection("wifi")
        }

        Radio {
          width: parent.cell
          height: parent.cell
          glyph: "󰂯"
          checked: s.bluetooth
          onTapped: s.toggleBluetooth()
          onHeld: s.openSection("bluetooth")
        }

        Radio {
          width: parent.cell
          height: parent.cell
          iconComponent: tailscaleMark
          checked: s.tailscaleUp
          onTapped: s.toggleTailscale()
          onHeld: s.openSection("tailscale")
        }

        Radio {
          width: parent.cell
          height: parent.cell
          glyph: "\uf072"
          checked: s.airplane
          onTapped: s.toggleAirplane()
        }
      }
    }
  }
}
