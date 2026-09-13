import QtQuick
import "."

Item {
    id: root

    Theme {
        id: theme
    }

    property color fillColor: theme.glassFillDark
    property color borderColor: "transparent"
    property int borderWidth: 0
    property real radius: Math.min(width, height) / 2

    LiquidGlass {
        anchors.fill: parent
        fillColor: root.fillColor
        radius: root.radius
        shadowEnabled: true
    }
}
