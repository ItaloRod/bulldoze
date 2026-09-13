import QtQuick
import "."

Item {
    id: root

    Theme {
        id: theme
    }

    property var blurSource: null
    property real topOffset: 0
    property color fillColor: theme.glassFill
    property color borderColor: theme.glassBorderSubtle
    property int borderWidth: 1
    property bool showBorder: true
    property real radius: (height <= 48) ? height / 2 : theme.radiusIsland

    LiquidGlass {
        anchors.fill: parent
        fillColor: root.fillColor
        radius: root.radius
        borderEnabled: root.showBorder
        borderWidth: root.borderWidth
        shadowEnabled: true
    }
}
