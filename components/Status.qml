import QtQuick
import QtQuick.Effects
import "../modules"

Row {
    id: root

    property var toggleNotifications
    property var toggleSettings
    property var toggleProfile
    property var togglePowerMenu
    property var toggleGaming

    property var notifications
    property var userProfile
    property var gaming

    Theme {
        id: theme
    }

    spacing: theme.spacingSm

    readonly property var notif: notifications
    readonly property var prof: userProfile
    readonly property var game: gaming


    // 2. Gaming Profile Button
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

    // 3. Settings Gear Button
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 26
        height: 26
        radius: theme.radiusItem
        color: settingsMouse.containsMouse ? theme.hoverFill : "transparent"
        border.width: 1
        border.color: settingsMouse.containsMouse ? theme.glassBorderStrong : "transparent"
        scale: settingsMouse.pressed ? 0.90 : (settingsMouse.containsMouse ? 1.18 : 1.0)
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
            text: ""
            color: settingsMouse.containsMouse ? theme.textStrong : theme.textMedium
            font.pixelSize: theme.iconSizeSm
        }

        MouseArea {
            id: settingsMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: if (root.toggleSettings) root.toggleSettings()
        }
    }

    // 4. Mini Avatar Button
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
