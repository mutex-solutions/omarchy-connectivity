import QtQuick

// Deck adapter: the members Deck reads, forwarded to the shared State.
Item {
  id: s

  readonly property var state: stateLoader.item

  readonly property bool active: state ? state.active : false
  readonly property string label: state ? state.label : ""
  readonly property string detail: state ? state.detail : ""
  readonly property string icon: state ? state.icon : ""

  // The four radios are the surface; do not put a tinted tile behind them.
  readonly property bool tileBleed: true

  // This section draws its own tile body and publishes a notice.
  readonly property Component tileComponent: state ? state.tileComponent : null
  readonly property var notice: state ? state.notice : null

  function toggle() {
    if (state) state.toggle()
  }

  Loader {
    id: stateLoader
    source: "../State.qml"
  }
}
