import QtQuick
import "../../modules"
import ".."

Item {
    id: root

    property var goBack
    property var openSettings
    property var bluetooth

    Theme {
        id: theme
    }

    readonly property var bt: bluetooth

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
                    renderType: Text.NativeRendering
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

            // 3. Bluetooth Status (Icon + Device Name / Status Label)
            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: theme.spacingMd

                Text {
                    renderType: Text.NativeRendering
                    text: ""
                    color: root.bt.hasConnectedDevices ? theme.textStrong : (root.bt.enabled ? theme.textMedium : theme.textMuted)
                    font.pixelSize: theme.iconSizeXl
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 1

                    Text {
                        renderType: Text.NativeRendering
                        width: 160
                        text: !root.bt.enabled ? "Bluetooth Desligado" : (root.bt.hasConnectedDevices ? root.bt.connectedDevices[0] : "Sem Dispositivos")
                        color: root.bt.hasConnectedDevices ? theme.textStrong : (root.bt.enabled ? theme.textMedium : theme.textMuted)
                        font.pixelSize: theme.fontSizeSubmenuTitle
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                    }

                    Text {
                        renderType: Text.NativeRendering
                        width: 160
                        text: root.bt.hasConnectedDevices ? (root.bt.connectedDevices.length > 1 ? "+" + (root.bt.connectedDevices.length - 1) + " outros conectados" : "Dispositivo conectado") : (root.bt.enabled ? "Pronto para parear" : "Desativado")
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

            // 4. Pair New Device Button
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 32
                height: 32
                radius: theme.radiusSmall
                color: pairMouse.containsMouse ? theme.hoverFill : "transparent"
                border.width: 1
                border.color: pairMouse.containsMouse ? theme.glassBorderStrong : "transparent"
                scale: pairMouse.pressed ? 0.90 : (pairMouse.containsMouse ? 1.12 : 1.0)
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
                    renderType: Text.NativeRendering
                    anchors.centerIn: parent
                    text: ""
                    color: pairMouse.containsMouse ? theme.textStrong : theme.textMedium
                    font.pixelSize: theme.iconSizeSm
                }

                MouseArea {
                    id: pairMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.openSettings) root.openSettings()
                    }
                }
            }

            // 5. Bluetooth Manager Button
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 32
                height: 32
                radius: theme.radiusSmall
                color: mgrMouse.containsMouse ? theme.hoverFill : "transparent"
                border.width: 1
                border.color: mgrMouse.containsMouse ? theme.glassBorderStrong : "transparent"
                scale: mgrMouse.pressed ? 0.90 : (mgrMouse.containsMouse ? 1.12 : 1.0)
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
                    renderType: Text.NativeRendering
                    anchors.centerIn: parent
                    text: ""
                    color: mgrMouse.containsMouse ? theme.textStrong : theme.textMedium
                    font.pixelSize: theme.iconSizeSm
                }

                MouseArea {
                    id: mgrMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.openSettings) root.openSettings()
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
                color: root.bt.enabled ? theme.textStrong : theme.itemFill
                border.width: 1
                border.color: theme.glassBorderSubtle

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    x: root.bt.enabled ? parent.width - width - 2 : 2
                    width: 16
                    height: 16
                    radius: 8
                    color: root.bt.enabled ? theme.glassFillDark : theme.textMuted

                    Behavior on x {
                        NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.bt.toggle()
                }
            }
        }
    }
}
