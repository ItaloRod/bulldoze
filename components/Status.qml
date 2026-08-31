import QtQuick
import QtQuick.Effects
import "../modules"

Row {
    id: root

    property var toggleNotifications
    property var toggleProfile
    property var togglePowerMenu

    property var notifications
    property var userProfile

    Theme {
        id: theme
    }

    spacing: theme.spacingSm

    readonly property var notif: notifications
    readonly property var prof: userProfile

    // 1. System Tray
    Tray {
        anchors.verticalCenter: parent.verticalCenter
    }

    // 2. Notifications Bell Button
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 26
        height: 26
        radius: theme.radiusItem
        color: notifMouse.containsMouse ? theme.hoverFill : "transparent"
        border.width: 1
        border.color: notifMouse.containsMouse ? theme.glassBorderStrong : "transparent"
        scale: notifMouse.pressed ? 0.90 : (notifMouse.containsMouse ? 1.18 : 1.0)
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
            text: ""
            color: notifMouse.containsMouse ? theme.textStrong : (root.notif && root.notif.hasNotifications ? theme.textStrong : theme.textMedium)
            font.pixelSize: theme.iconSizeSm
        }

        // Notification active indicator dot
        Rectangle {
            anchors {
                top: parent.top
                topMargin: 4
                right: parent.right
                rightMargin: 4
            }
            width: 6
            height: 6
            radius: 3
            color: theme.accent
            border.width: 1
            border.color: theme.glassFillDark
            visible: Boolean(root.notif && root.notif.hasNotifications)
        }

        MouseArea {
            id: notifMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: if (root.toggleNotifications) root.toggleNotifications()
        }
    }

    // 2. Mini Avatar Button
    Rectangle {
        id: avatarBtn
        anchors.verticalCenter: parent.verticalCenter
        width: 26
        height: 26
        radius: 13
        color: avatarMouse.containsMouse ? theme.hoverFill : theme.itemFill
        border.width: 1
        border.color: avatarMouse.containsMouse ? theme.glassBorderStrong : theme.glassBorderSubtle
        scale: avatarMouse.pressed ? 0.90 : (avatarMouse.containsMouse ? 1.18 : 1.0)
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

        Item {
            anchors.fill: parent
            anchors.margins: 1

            Image {
                id: miniAvatarImg
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                source: root.prof && root.prof.hasAvatar && root.prof.avatarPath !== "" ? ("file://" + root.prof.avatarPath) : ""
                visible: Boolean(root.prof && root.prof.hasAvatar && status === Image.Ready)
                asynchronous: true
                cache: false
                layer.enabled: true
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: miniAvatarMask
                }
            }

            Item {
                id: miniAvatarMask
                anchors.fill: parent
                visible: false
                layer.enabled: true

                Rectangle {
                    anchors.fill: parent
                    radius: 12
                    color: "black"
                }
            }

            Text {
                anchors.centerIn: parent
                visible: !miniAvatarImg.visible
                text: root.prof ? root.prof.initial : "U"
                color: theme.textStrong
                font.pixelSize: theme.fontSizeSm
                font.weight: Font.Bold
            }
        }

        MouseArea {
            id: avatarMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (root.toggleProfile) root.toggleProfile()
                else if (root.togglePowerMenu) root.togglePowerMenu()
            }
        }
    }
}
