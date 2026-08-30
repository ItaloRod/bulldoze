import QtQuick
import QtQuick.Effects
import "../modules"

Row {
    id: root

    property var toggleWifi
    property var toggleBluetooth
    property var toggleAudio
    property var toggleGaming
    property var toggleNotifications
    property var toggleProfile
    property var togglePowerMenu

    property var network
    property var bluetooth
    property var audio
    property var gaming
    property var notifications
    property var userProfile

    Theme {
        id: theme
    }

    spacing: theme.spacingSm

    readonly property var net: network
    readonly property var bt: bluetooth
    readonly property var aud: audio
    readonly property var game: gaming
    readonly property var notif: notifications
    readonly property var prof: userProfile

    // 1. Wi-Fi Button
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 28
        height: 28
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
            color: wifiMouse.containsMouse ? theme.textStrong : (root.net.available ? theme.textMedium : theme.indicatorInactive)
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

    // 2. Bluetooth Button
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 28
        height: 28
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
            color: btMouse.containsMouse ? theme.textStrong : (root.bt.hasConnectedDevices ? theme.textStrong : (root.bt.enabled ? theme.textMedium : theme.indicatorInactive))
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

    // 3. Audio Button
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 28
        height: 28
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
            text: root.aud.icon
            color: audMouse.containsMouse ? theme.textStrong : (root.aud.muted ? theme.indicatorInactive : theme.textMedium)
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
                    root.aud.toggleMute()
                } else {
                    if (root.toggleAudio) root.toggleAudio()
                }
            }
        }
    }

    // 4. Gaming Profile Button
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 28
        height: 28
        radius: theme.radiusItem
        color: gameMouse.containsMouse ? theme.hoverFill : (root.game.anyActive ? theme.activeFill : "transparent")
        border.width: 1
        border.color: root.game.anyActive ? theme.glassBorderStrong : (gameMouse.containsMouse ? theme.glassBorderStrong : "transparent")
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
            color: gameMouse.containsMouse ? theme.textStrong : (root.game.anyActive ? theme.textStrong : theme.textMedium)
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

    // 5. Notifications Bell Button
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 28
        height: 28
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
            width: 7
            height: 7
            radius: 3.5
            color: theme.accent
            border.width: 1
            border.color: theme.glassFillDark
            visible: root.notif && root.notif.hasNotifications
        }

        MouseArea {
            id: notifMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: if (root.toggleNotifications) root.toggleNotifications()
        }
    }

    // 6. System Tray
    Tray {
        anchors.verticalCenter: parent.verticalCenter
    }

    // 7. Mini Avatar Button
    Rectangle {
        id: avatarBtn
        anchors.verticalCenter: parent.verticalCenter
        width: 28
        height: 28
        radius: 14
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
                source: root.prof.hasAvatar && root.prof.avatarPath !== "" ? ("file://" + root.prof.avatarPath) : ""
                visible: root.prof.hasAvatar && status === Image.Ready
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
                    radius: 13
                    color: "black"
                }
            }

            Text {
                anchors.centerIn: parent
                visible: !miniAvatarImg.visible
                text: root.prof.initial
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
