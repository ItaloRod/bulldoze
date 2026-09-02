import QtQuick
import "../../modules"
import ".."

Item {
    id: root

    property var goBack
    property var openSettings
    property var network

    Theme {
        id: theme
    }

    readonly property var net: network

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

            // 3. Wi-Fi Status (Icon + SSID / Connection Label)
            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: theme.spacingMd

                Text {
                    text: ""
                    color: root.net.available ? theme.textStrong : theme.textMuted
                    font.pixelSize: theme.iconSizeXl
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 1

                    Text {
                        width: 160
                        text: root.net.available ? (root.net.ssid !== "" ? root.net.ssid : "Conectado") : (root.net.enabled ? "Desconectado" : "Wi-Fi Desativado")
                        color: root.net.available ? theme.textStrong : theme.textMedium
                        font.pixelSize: theme.fontSizeSubmenuTitle
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                    }

                    Text {
                        width: 160
                        text: root.net.available ? "Rede sem fio ativa" : "Sem conexão"
                        color: theme.textMuted
                        font.pixelSize: theme.fontSizeSubmenuBody
                        elide: Text.ElideRight
                    }
                }
            }
        }

        Row {
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            spacing: theme.spacingSm

            // 4. Settings Button
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 32
                height: 32
                radius: theme.radiusSmall
                color: setMouse.containsMouse ? theme.hoverFill : "transparent"
                border.width: 1
                border.color: setMouse.containsMouse ? theme.glassBorderStrong : "transparent"
                scale: setMouse.pressed ? 0.90 : (setMouse.containsMouse ? 1.12 : 1.0)
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
                    text: ""
                    color: setMouse.containsMouse ? theme.textStrong : theme.textMedium
                    font.pixelSize: theme.iconSizeSm
                }

                MouseArea {
                    id: setMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.openSettings) root.openSettings()
                    }
                }
            }

            // 5. Refresh Button
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 32
                height: 32
                radius: theme.radiusSmall
                color: refMouse.containsMouse ? theme.hoverFill : "transparent"
                border.width: 1
                border.color: refMouse.containsMouse ? theme.glassBorderStrong : "transparent"
                scale: refMouse.pressed ? 0.90 : (refMouse.containsMouse ? 1.12 : 1.0)
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
                    text: ""
                    color: (root.net && root.net.isScanning) ? theme.accent : (refMouse.containsMouse ? theme.textStrong : theme.textMedium)
                    font.pixelSize: theme.iconSizeSm
                }

                MouseArea {
                    id: refMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.net) root.net.scanNetworks(true)
                    }
                }
            }

            // 6. Vertical Separator
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 1
                height: 20
                color: theme.separator
            }

            // 7. Toggle Switch
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 38
                height: 20
                radius: 10
                color: root.net.enabled ? theme.textStrong : theme.itemFill
                border.width: 1
                border.color: theme.glassBorderSubtle

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    x: root.net.enabled ? parent.width - width - 2 : 2
                    width: 16
                    height: 16
                    radius: 8
                    color: root.net.enabled ? theme.glassFillDark : theme.textMuted

                    Behavior on x {
                        NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.net.toggle()
                }
            }
        }
    }
}
