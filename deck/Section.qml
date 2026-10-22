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

  // The block belongs to the square size. Half and compact use Deck's default
  // body; the full size gets the four radios in a row.
  readonly property Component tileSquare: state ? state.tileComponent : null
  readonly property Component tileFull: state ? state.tileFull : null
  readonly property var notice: state ? state.notice : null

  function toggle() {
    if (state) state.toggle()
  }

  Loader {
    id: stateLoader
    source: "../State.qml"
  }
}
