import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick

PanelWindow {
    id: root

    WlrLayershell.namespace: "bulldoze-power"

    Theme {
        id: theme
    }

    property bool open: false
    visible: open || card.opacity > 0.001
    color: "transparent"
    focusable: true
    exclusiveZone: 0

    signal lockRequested()

    function run(action) {
        root.open = false
        if (action === "lock") {
            root.lockRequested()
        } else {
            command.exec(["sh", "-c", action])
        }
    }

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    Process {
        id: command
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.open = false
    }

    Item {
        id: card
        width: 42 + theme.spacingSm + (theme.spacingSm + theme.notchTopRadius)
        height: powerCol.implicitHeight + (theme.spacingSm + theme.notchTopRadius) * 2
        anchors {
            top: parent.top
            topMargin: theme.notchHeight + 14
            left: parent.left
        }

        transformOrigin: Item.Left
        scale: root.open ? 1.0 : 0.88
        opacity: root.open ? 1.0 : 0.0

        transform: Translate {
            x: root.open ? 0 : -28
            Behavior on x {
                NumberAnimation {
                    duration: root.open ? theme.animDurationSticky : theme.animDurationExit
                    easing.type: root.open ? Easing.OutBack : Easing.InCubic
                    easing.overshoot: theme.stickyOvershoot
                }
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: root.open ? theme.animDurationSticky : theme.animDurationExit
                easing.type: root.open ? Easing.OutBack : Easing.InCubic
                easing.overshoot: theme.stickyOvershoot
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: root.open ? theme.animDurationSticky : theme.animDurationExit
                easing.type: Easing.OutCubic
            }
        }

        SideGlassPanel {
            anchors.fill: parent
            side: "left"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: mouse => mouse.accepted = true
        }

        Column {
            id: powerCol
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                leftMargin: theme.spacingSm + theme.notchTopRadius
                rightMargin: theme.spacingSm
                topMargin: theme.spacingSm + theme.notchTopRadius
            }
            spacing: theme.spacingSm

            Repeater {
                model: [
                    { icon: "", label: "Bloquear", action: "lock" },
                    { icon: "", label: "Deslogar", action: "hyprctl dispatch exit || loginctl terminate-user $USER" },
                    { icon: "", label: "Reiniciar", action: "systemctl reboot" },
                    { icon: "", label: "Desligar", action: "systemctl poweroff" }
                ]

                delegate: Rectangle {
                    required property var modelData
                    width: 42
                    height: 42
                    radius: theme.radiusItem
                    color: btnMouse.containsMouse ? theme.hoverFill : theme.itemFill
                    border.width: 1
                    border.color: btnMouse.containsMouse ? theme.glassBorderStrong : theme.glassBorderSubtle
                    scale: btnMouse.pressed ? 0.92 : (btnMouse.containsMouse ? 1.10 : 1.0)

                    Behavior on color {
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
                        text: modelData.icon
                        color: theme.textStrong
                        font.pixelSize: theme.fontSizeXl
                    }

                    // Hover Tooltip Pill
                    Rectangle {
                        id: tooltip
                        anchors {
                            left: parent.right
                            leftMargin: theme.spacingSm
                            verticalCenter: parent.verticalCenter
                        }
                        width: tipText.implicitWidth + (theme.spacingMd * 2)
                        height: 30
                        radius: theme.radiusSmall
                        color: theme.glassFillDark
                        border.width: 1
                        border.color: theme.glassBorderStrong
                        opacity: btnMouse.containsMouse ? 1.0 : 0.0
                        scale: btnMouse.containsMouse ? 1.0 : 0.85
                        visible: opacity > 0.001

                        transform: Translate {
                            x: btnMouse.containsMouse ? 0 : -12
                            Behavior on x {
                                NumberAnimation {
                                    duration: theme.animDurationFast
                                    easing.type: Easing.OutBack
                                    easing.overshoot: theme.stickyOvershoot
                                }
                            }
                        }

                        Behavior on scale {
                            NumberAnimation {
                                duration: theme.animDurationFast
                                easing.type: Easing.OutBack
                                easing.overshoot: theme.stickyOvershoot
                            }
                        }

                        Behavior on opacity {
                            NumberAnimation {
                                duration: theme.animDurationFast
                                easing.type: Easing.OutCubic
                            }
                        }

                        Text {
                            id: tipText
                            anchors.centerIn: parent
                            text: modelData.label
                            color: theme.textStrong
                            font.pixelSize: theme.fontSizeSm
                            font.weight: Font.Medium
                        }
                    }

                    MouseArea {
                        id: btnMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.run(modelData.action)
                    }
                }
            }
        }
    }
}
