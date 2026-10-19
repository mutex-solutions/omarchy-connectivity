import QtQuick
import qs.Commons

// One radio button in the cluster tile: a square that fills with the accent
// when the radio is on, exactly as the design mock's connectivity block.
Item {
  id: r

  property string glyph: ""
  property bool checked: false

  signal tapped()

  Rectangle {
    anchors.fill: parent
    radius: Style.cornerRadius
    color: r.checked ? Color.accent : Util.alpha(Color.foreground, 0.04)
    border.width: 1
    border.color: r.checked ? Color.accent : Util.alpha(Color.foreground, 0.28)

    Text {
      anchors.centerIn: parent
      text: r.glyph
      color: r.checked ? Color.background : Util.alpha(Color.foreground, 0.7)
      font.family: Style.font.family
      font.pixelSize: Style.font.heading
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: r.tapped()
  }
}
