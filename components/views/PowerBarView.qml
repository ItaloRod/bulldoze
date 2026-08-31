import QtQuick
import QtQuick.Effects
import Quickshell.Io
import "../../modules"
import ".."

Item {
    id: root

    property var goBack
    property var lockScreen
    property var userProfile

    Theme {
        id: theme
    }

    readonly property var prof: userProfile

    Process {
        id: proc
    }

    function runAction(action) {
        if (action === "lock") {
            if (root.lockScreen) root.lockScreen()
        } else {
            proc.exec(["sh", "-c", action])
        }
        if (root.goBack) root.goBack()
    }

    Item {
        anchors {
            left: parent.left
            leftMargin: theme.contentInset + theme.notchConcaveWidth
            right: parent.right
            rightMargin: theme.contentInset + theme.notchConcaveWidth
            verticalCenter: parent.verticalCenter
        }
        height: parent.height

        Row {
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            spacing: theme.spacingSm

            // 1. Back Button (Icon only)
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 32
                height: 32
                radius: theme.radiusSmall
                color: backMouse.containsMouse ? theme.hoverFill : "transparent"
                border.width: 1
                border.color: backMouse.containsMouse ? theme.glassBorderStrong : "transparent"
                scale: backMouse.pressed ? 0.90 : (backMouse.containsMouse ? 1.12 : 1.0)
                transformOrigin: Item.Center

                Behavior on color { ColorAnimation { duration: theme.animDurationFast } }
                Behavior on border.color { ColorAnimation { duration: theme.animDurationFast } }
                Behavior on scale {
                    NumberAnimation {
                        duration: theme.animDurationFast
                        easing.type: Easing.OutBack
                        easing.overshoot: theme.buttonOvershoot
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: ""
                    color: backMouse.containsMouse ? theme.textStrong : theme.textMedium
                    font.pixelSize: theme.iconSizeSm
                }

                MouseArea {
                    id: backMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (root.goBack) root.goBack()
                }
            }

            // 2. Vertical Separator
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 1
                height: 20
                color: theme.separator
            }

            // 3. User Avatar
            Item {
                id: avatarContainer
                width: 32
                height: 32
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    anchors.fill: parent
                    radius: 16
                    color: theme.glassFillDark
                }

                Image {
                    id: avatarImg
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectCrop
                    source: root.prof.hasAvatar && root.prof.avatarPath !== "" ? ("file://" + root.prof.avatarPath) : ""
                    visible: root.prof.hasAvatar && status === Image.Ready
                    asynchronous: true
                    cache: false
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        maskEnabled: true
                        maskSource: avatarMask
                    }
                }

                Item {
                    id: avatarMask
                    anchors.fill: parent
                    visible: false
                    layer.enabled: true

                    Rectangle {
                        anchors.fill: parent
                        radius: 16
                        color: "black"
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: !avatarImg.visible
                    text: root.prof.initial
                    color: theme.textStrong
                    font.pixelSize: theme.fontSizeSm
                    font.weight: Font.Bold
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 16
                    color: "transparent"
                    border.width: 1
                    border.color: theme.glassBorder
                }
            }

            // 4. User Info (Name + Hostname) with Privacy Blur
            Item {
                id: userInfoBox
                width: 130
                height: 32
                anchors.verticalCenter: parent.verticalCenter

                Column {
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 1

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        blurEnabled: root.prof.privacyBlur > 0.001
                        blur: root.prof.privacyBlur
                        blurMax: 64
                        blurMultiplier: 3.0
                    }

                    Text {
                        width: parent.width
                        text: root.prof.displayName
                        color: theme.textStrong
                        opacity: 1.0 - (root.prof.privacyBlur * 0.7)
                        font.pixelSize: theme.fontSizeSubmenuTitle
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                    }

                    Row {
                        spacing: theme.spacingXs
                        opacity: 1.0 - (root.prof.privacyBlur * 0.7)

                        Text {
                            text: ""
                            color: theme.textMuted
                            font.pixelSize: 11
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: root.prof.hostName
                            color: theme.textMuted
                            font.pixelSize: theme.fontSizeSubmenuBody
                            anchors.verticalCenter: parent.verticalCenter
                            elide: Text.ElideRight
                        }
                    }
                }

                // Privacy Blur Placeholder Pill
                Column {
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 4
                    opacity: root.prof.privacyBlur
                    visible: opacity > 0.001

                    Rectangle {
                        width: 90
                        height: 10
                        radius: 5
                        color: theme.glassFillDark
                        border.width: 1
                        border.color: theme.glassBorderSubtle
                    }

                    Rectangle {
                        width: 60
                        height: 8
                        radius: 4
                        color: theme.glassFillDark
                        border.width: 1
                        border.color: theme.glassBorderSubtle
                    }
                }
            }

            // 5. Privacy Eye Toggle Button
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 28
                height: 28
                radius: theme.radiusSmall
                color: eyeMouse.containsMouse ? theme.hoverFill : (root.prof.privacyMode ? theme.activeFill : "transparent")
                border.width: 1
                border.color: root.prof.privacyMode ? theme.glassBorderStrong : (eyeMouse.containsMouse ? theme.glassBorderSubtle : "transparent")
                scale: eyeMouse.pressed ? 0.90 : (eyeMouse.containsMouse ? 1.10 : 1.0)
                transformOrigin: Item.Center

                Behavior on color { ColorAnimation { duration: theme.animDurationFast } }
                Behavior on border.color { ColorAnimation { duration: theme.animDurationFast } }
                Behavior on scale {
                    NumberAnimation {
                        duration: theme.animDurationFast
                        easing.type: Easing.OutBack
                        easing.overshoot: theme.buttonOvershoot
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: root.prof.privacyMode ? "" : ""
                    color: root.prof.privacyMode ? theme.textStrong : (eyeMouse.containsMouse ? theme.textStrong : theme.textMuted)
                    font.pixelSize: theme.iconSizeSm
                }

                MouseArea {
                    id: eyeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.prof.togglePrivacy()
                }
            }
        }

        Row {
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            spacing: theme.spacingSm

            // 6. Vertical Separator
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 1
                height: 20
                color: theme.separator
            }

            // 7. 4 Power Action Buttons
            Repeater {
                model: [
                    { icon: "", label: "Bloquear", action: "lock" },
                    { icon: "", label: "Deslogar", action: "hyprctl dispatch exit || loginctl terminate-user $USER" },
                    { icon: "", label: "Reiniciar", action: "systemctl reboot" },
                    { icon: "", label: "Desligar", action: "systemctl poweroff" }
                ]

                delegate: Rectangle {
                    required property var modelData
                    anchors.verticalCenter: parent.verticalCenter
                    width: 32
                    height: 32
                    radius: theme.radiusSmall
                    color: btnMouse.containsMouse ? theme.hoverFill : "transparent"
                    border.width: 1
                    border.color: btnMouse.containsMouse ? theme.glassBorderStrong : "transparent"
                    scale: btnMouse.pressed ? 0.90 : (btnMouse.containsMouse ? 1.15 : 1.0)
                    transformOrigin: Item.Center

                    Behavior on color { ColorAnimation { duration: theme.animDurationFast } }
                    Behavior on border.color { ColorAnimation { duration: theme.animDurationFast } }
                    Behavior on scale {
                        NumberAnimation {
                            duration: theme.animDurationFast
                            easing.type: Easing.OutBack
                            easing.overshoot: theme.buttonOvershoot
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: modelData.icon
                        color: btnMouse.containsMouse ? theme.textStrong : theme.textMedium
                        font.pixelSize: theme.iconSizeMd
                    }

                    MouseArea {
                        id: btnMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.runAction(modelData.action)
                    }
                }
            }
        }
    }
}
