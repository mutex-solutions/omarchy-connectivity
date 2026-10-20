import QtQuick
import qs.Commons

// One radio button in the cluster tile: a square that fills with the accent
// when the radio is on, exactly as the design mock's connectivity block.
//
// Click toggles; hold opens that radio's own section page (Wi-Fi, Bluetooth).
// A hold never toggles.
Item {
  id: r

  property string glyph: ""
  property Component iconComponent: null
  property bool checked: false

  signal tapped()
  signal held()

  property bool didHold: false

  Rectangle {
    anchors.fill: parent
    radius: Style.cornerRadius
    // The same active and inactive tokens a normal Deck tile uses, so a radio
    // in the block and a tile beside it read as the same kind of control.
    color: r.checked ? Util.alpha(Color.accent, Style.selectedFillAlpha)
                     : Util.alpha(Color.foreground, Style.normalFillAlpha)
    border.width: 1
    border.color: r.checked ? Util.alpha(Color.accent, 0.55)
                            : Util.alpha(Color.foreground, Style.normalBorderAlpha)
  }

  Text {
    anchors.centerIn: parent
    visible: r.iconComponent === null
    text: r.glyph
    color: r.checked ? Color.accent : Util.alpha(Color.foreground, 0.7)
    font.family: Style.font.family
    font.pixelSize: Style.font.display
  }

  // Components (the Tailscale mark) cannot take a binding from here, so the
  // colour is pushed whenever the state changes.
  Loader {
    id: iconLoader
    anchors.centerIn: parent
    sourceComponent: r.iconComponent
    onLoaded: r.applyIconColor()
  }

  function applyIconColor() {
    if (iconLoader.item && "color" in iconLoader.item)
      iconLoader.item.color = r.checked ? Color.accent : Util.alpha(Color.foreground, 0.7)
  }

  onCheckedChanged: applyIconColor()

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor

    onPressed: {
      r.didHold = false
      holdTimer.start()
    }

    onReleased: {
      holdTimer.stop()
      if (!r.didHold) r.tapped()
    }

    onCanceled: holdTimer.stop()
  }

  Timer {
    id: holdTimer
    interval: 450
    onTriggered: {
      r.didHold = true
      r.held()
    }
  }
}
