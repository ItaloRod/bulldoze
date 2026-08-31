import QtQuick
import QtQuick.Effects
import "../modules"

Row {
    id: root

    property var toggleWifi
    property var toggleBluetooth
    property var toggleAudio
    property var toggleGaming

    property var network
    property var bluetooth
    property var audio
    property var gaming

    Theme {
        id: theme
    }

    spacing: theme.spacingSm

    readonly property var net: network
    readonly property var bt: bluetooth
    readonly property var aud: audio
    readonly property var game: gaming

    // 1. Wi-Fi Button
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 26
        height: 26
        radius: theme.radiusItem
        color: wifiMouse.containsMouse ? theme.hoverFill : "transparent"
        border.width: 1
        border.color: wifiMouse.containsMouse ? theme.glassBorderStrong : "transparent"
        scale: wifiMouse.pressed ? 0.90 : (wifiMouse.containsMouse ? 1.18 : 1.0)
        transformOrigin: Item.Center

        Behavior on color {
            ColorAnimation { duration: theme.animDurationFast }
        }
        Behavior on border.color {
            ColorAnimation { duration: theme.animDurationFast }
        }
        Behavior on scale {
            NumberAnimation {
                duration: theme.animDurationFast
                easing.type: Easing.OutBack
                easing.overshoot: theme.buttonOvershoot
            }
        }

        Text {
            anchors.centerIn: parent
            text: ""
            color: wifiMouse.containsMouse ? theme.textStrong : (root.net && root.net.available ? theme.textMedium : theme.indicatorInactive)
            font.pixelSize: theme.iconSizeSm
        }

        MouseArea {
            id: wifiMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: if (root.toggleWifi) root.toggleWifi()
        }
    }

    // 3. Bluetooth Button
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 26
        height: 26
        radius: theme.radiusItem
        color: btMouse.containsMouse ? theme.hoverFill : "transparent"
        border.width: 1
        border.color: btMouse.containsMouse ? theme.glassBorderStrong : "transparent"
        scale: btMouse.pressed ? 0.90 : (btMouse.containsMouse ? 1.18 : 1.0)
        transformOrigin: Item.Center

        Behavior on color {
            ColorAnimation { duration: theme.animDurationFast }
        }
        Behavior on border.color {
            ColorAnimation { duration: theme.animDurationFast }
        }
        Behavior on scale {
            NumberAnimation {
                duration: theme.animDurationFast
                easing.type: Easing.OutBack
                easing.overshoot: theme.buttonOvershoot
            }
        }

        Text {
            anchors.centerIn: parent
            text: ""
            color: btMouse.containsMouse ? theme.textStrong : (root.bt && root.bt.hasConnectedDevices ? theme.textStrong : (root.bt && root.bt.enabled ? theme.textMedium : theme.indicatorInactive))
            font.pixelSize: theme.iconSizeSm
        }

        MouseArea {
            id: btMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: if (root.toggleBluetooth) root.toggleBluetooth()
        }
    }

    // 4. Audio Button
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 26
        height: 26
        radius: theme.radiusItem
        color: audMouse.containsMouse ? theme.hoverFill : "transparent"
        border.width: 1
        border.color: audMouse.containsMouse ? theme.glassBorderStrong : "transparent"
        scale: audMouse.pressed ? 0.90 : (audMouse.containsMouse ? 1.18 : 1.0)
        transformOrigin: Item.Center

        Behavior on color {
            ColorAnimation { duration: theme.animDurationFast }
        }
        Behavior on border.color {
            ColorAnimation { duration: theme.animDurationFast }
        }
        Behavior on scale {
            NumberAnimation {
                duration: theme.animDurationFast
                easing.type: Easing.OutBack
                easing.overshoot: theme.buttonOvershoot
            }
        }

        Text {
            anchors.centerIn: parent
            text: root.aud ? root.aud.icon : ""
            color: audMouse.containsMouse ? theme.textStrong : (root.aud && root.aud.muted ? theme.indicatorInactive : theme.textMedium)
            font.pixelSize: theme.iconSizeSm
        }

        MouseArea {
            id: audMouse
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape: Qt.PointingHandCursor
            onClicked: mouse => {
                if (mouse.button === Qt.RightButton) {
                    if (root.aud) root.aud.toggleMute()
                } else {
                    if (root.toggleAudio) root.toggleAudio()
                }
            }
        }
    }

    // 5. Gaming Profile Button
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 26
        height: 26
        radius: theme.radiusItem
        color: gameMouse.containsMouse ? theme.hoverFill : (root.game && root.game.anyActive ? theme.activeFill : "transparent")
        border.width: 1
        border.color: root.game && root.game.anyActive ? theme.glassBorderStrong : (gameMouse.containsMouse ? theme.glassBorderStrong : "transparent")
        scale: gameMouse.pressed ? 0.90 : (gameMouse.containsMouse ? 1.18 : 1.0)
        transformOrigin: Item.Center

        Behavior on color {
            ColorAnimation { duration: theme.animDurationFast }
        }
        Behavior on border.color {
            ColorAnimation { duration: theme.animDurationFast }
        }
        Behavior on scale {
            NumberAnimation {
                duration: theme.animDurationFast
                easing.type: Easing.OutBack
                easing.overshoot: theme.buttonOvershoot
            }
        }

        Text {
            anchors.centerIn: parent
            text: ""
            color: gameMouse.containsMouse ? theme.textStrong : (root.game && root.game.anyActive ? theme.textStrong : theme.textMedium)
            font.pixelSize: theme.iconSizeSm
        }

        MouseArea {
            id: gameMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: if (root.toggleGaming) root.toggleGaming()
        }
    }
}
