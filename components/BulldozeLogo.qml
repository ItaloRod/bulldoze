import QtQuick

Text {
    renderType: Text.NativeRendering
    id: root

    property var activateLauncher

    Theme {
        id: theme
    }

    text: ""
    color: theme.textStrong

    font.pixelSize: 16
    font.weight: Font.Bold

    scale: logoMouse.pressed ? 0.90 : (logoMouse.containsMouse ? 1.18 : 1.0)
    transformOrigin: Item.Center

    Behavior on scale {
        NumberAnimation {
            duration: theme.animDurationFast
            easing.type: Easing.OutBack
            easing.overshoot: theme.buttonOvershoot
        }
    }

    MouseArea {
        id: logoMouse
        anchors.fill: parent
        anchors.margins: -8
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activateLauncher()
    }
}
