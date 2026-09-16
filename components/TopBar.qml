import QtQuick
import "."

Item {
    id: root

    property color iconColor: "#FFFFFF"
    property var openLauncher
    property var toggleNotifications

    height: 32

    Theme {
        id: theme
    }

    // Left Section: Home Icon (Arch Linux logo)
    Rectangle {
        id: homeButton
        anchors {
            left: parent.left
            leftMargin: 12
            verticalCenter: parent.verticalCenter
        }
        width: 28
        height: 28
        radius: 4
        color: homeMouse.containsMouse ? (root.iconColor === "#000000" ? "#1A000000" : "#1AFFFFFF") : "transparent"
        scale: homeMouse.pressed ? 0.92 : 1.0

        Behavior on scale {
            NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
        }

        Text {
            anchors.centerIn: parent
            text: ""
            color: root.iconColor
            font.pixelSize: 16
            font.weight: Font.Bold
            renderType: Text.NativeRendering
        }

        MouseArea {
            id: homeMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (root.openLauncher) {
                    root.openLauncher()
                }
            }
        }
    }

    // Right Section: System Tray & Clock/Date
    Row {
        anchors {
            right: parent.right
            rightMargin: 12
            verticalCenter: parent.verticalCenter
        }
        spacing: 14

        TopBarTray {
            id: topTray
            anchors.verticalCenter: parent.verticalCenter
            iconColor: root.iconColor
        }

        TopBarClock {
            id: topClock
            anchors.verticalCenter: parent.verticalCenter
            textColor: root.iconColor
            onClicked: {
                if (root.toggleNotifications) {
                    root.toggleNotifications()
                }
            }
        }
    }
}
