import QtQuick

// Airplane mode as a single Deck control. The connectivity block groups all
// four radios; this file is the individual component for users who want each
// radio as its own tile.
Item {
  id: s

  readonly property var state: stateLoader.item

  readonly property bool active: state ? state.airplane : false
  readonly property string label: "Airplane"
  readonly property string detail: active ? "on" : "off"
  readonly property string icon: ""

  function toggle() {
    if (state) state.toggleAirplane()
  }

  Loader {
    id: stateLoader
    source: "../State.qml"
  }
}
