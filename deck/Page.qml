import QtQuick
import qs.Commons

// Connectivity page, rendered by Deck and by this plugin's own popup.
Item {
  id: page

  property var state: null
  property var host: null

  implicitHeight: col.implicitHeight

  component Rule: Rectangle {
    width: parent ? parent.width : 0
    height: 1
    color: Util.alpha(Color.foreground, 0.1)
  }

  component ToggleRow: Item {
    id: row
    property string glyph: ""
    property string title: ""
    property bool checked: false
    signal toggled()

    width: parent ? parent.width : 0
    height: Style.space(34)

    Rectangle {
      anchors.fill: parent
      radius: Style.cornerRadius
      color: hover.containsMouse ? Util.alpha(Color.foreground, Style.hoverFillAlpha) : "transparent"
    }

    Text {
      id: rowGlyph
      anchors.left: parent.left
      anchors.leftMargin: Style.space(8)
      anchors.verticalCenter: parent.verticalCenter
      width: Style.space(16)
      text: row.glyph
      color: row.checked ? Color.accent : Util.alpha(Color.foreground, 0.5)
      font.family: Style.font.family
      font.pixelSize: Style.font.body
    }

    Text {
      anchors.left: rowGlyph.right
      anchors.leftMargin: Style.space(8)
      anchors.verticalCenter: parent.verticalCenter
      text: row.title
      color: Color.foreground
      font.family: Style.font.family
      font.pixelSize: Style.font.body
    }

    Rectangle {
      anchors.right: parent.right
      anchors.rightMargin: Style.space(8)
      anchors.verticalCenter: parent.verticalCenter
      width: Style.space(34)
      height: Style.space(18)
      radius: height / 2
      color: row.checked ? Util.alpha(Color.accent, 0.85) : Util.alpha(Color.foreground, 0.2)

      Rectangle {
        width: Style.space(14)
        height: width
        radius: width / 2
        y: (parent.height - height) / 2
        x: row.checked ? parent.width - width - Style.space(2) : Style.space(2)
        color: "#ffffff"
      }
    }

    MouseArea {
      id: hover
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: row.toggled()
    }
  }

  Column {
    id: col
    width: parent.width
    spacing: Style.space(2)

    ToggleRow {
      glyph: "≋"
      title: "Wi-Fi"
      checked: page.state ? page.state.wifi : false
      onToggled: if (page.state) page.state.toggleWifi()
    }

    ToggleRow {
      glyph: "ᛒ"
      title: "Bluetooth"
      checked: page.state ? page.state.bluetooth : false
      onToggled: if (page.state) page.state.toggleBluetooth()
    }

    ToggleRow {
      glyph: "◇"
      title: "Tailscale"
      checked: page.state ? page.state.tailscaleUp : false
      onToggled: if (page.state) page.state.toggleTailscale()
    }

    Rule { }

    ToggleRow {
      glyph: "✈"
      title: "Airplane mode"
      checked: page.state ? page.state.airplane : false
      onToggled: if (page.state) page.state.toggleAirplane()
    }

    Text {
      width: parent.width
      text: "Airplane mode is derived: it reads as on when every radio is off."
      color: Util.alpha(Color.foreground, 0.45)
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
      wrapMode: Text.WordWrap
      leftPadding: Style.space(8)
      rightPadding: Style.space(8)
      topPadding: Style.space(6)
    }
  }
}
