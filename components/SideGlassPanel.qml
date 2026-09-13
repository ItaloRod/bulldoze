import QtQuick
import "."

Item {
    id: root

    Theme {
        id: theme
    }

    property string side: "right" // "right" or "left"
    property color fillColor: theme.glassFillDark
    property color borderColor: "transparent"
    property int borderWidth: 0
    property real radius: theme.radiusIsland

    LiquidGlass {
        anchors.fill: parent
        fillColor: root.fillColor
        radius: root.radius
        shadowEnabled: true
    }
}
