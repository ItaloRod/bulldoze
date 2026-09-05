import Quickshell
import Quickshell.Wayland
import QtQuick

PanelWindow {
    id: root

    WlrLayershell.namespace: "bulldoze-osd"

    Theme {
        id: theme
    }

    property string message: ""
    property real value: 0
    property bool showing: false
    visible: showing || card.opacity > 0.001
    color: "transparent"
    exclusiveZone: 0

    anchors {
        bottom: true
        left: true
        right: true
    }

    margins.bottom: 0
    implicitHeight: 90

    function show(label, amount) {
        message = label
        value = Math.max(0, Math.min(1, amount))
        showing = true
        timeout.restart()
    }

    Timer {
        id: timeout
        interval: 1800
        onTriggered: root.showing = false
    }

    Item {
        id: card
        width: 300
        height: 74
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }

        transformOrigin: Item.Bottom
        scale: root.showing ? 1.0 : 0.90
        opacity: root.showing ? 1.0 : 0.0

        transform: Translate {
            y: root.showing ? 0 : 28
            Behavior on y {
                NumberAnimation {
                    duration: root.showing ? theme.animDurationSticky : theme.animDurationExit
                    easing.type: root.showing ? Easing.OutBack : Easing.InCubic
                    easing.overshoot: theme.stickyOvershoot
                }
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: root.showing ? theme.animDurationSticky : theme.animDurationExit
                easing.type: root.showing ? Easing.OutBack : Easing.InCubic
                easing.overshoot: theme.stickyOvershoot
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: root.showing ? theme.animDurationSticky : theme.animDurationExit
                easing.type: Easing.OutCubic
            }
        }

        BottomGlassPanel {
            anchors.fill: parent
        }

        Column {
            anchors {
                centerIn: parent
                verticalCenterOffset: -theme.notchTopRadius / 2
            }
            width: 236
            spacing: theme.spacingSm

            Row {
                width: parent.width
                spacing: theme.spacingSm

                Text {
                    renderType: Text.NativeRendering
                    text: root.message
                    color: theme.textStrong
                    font.pixelSize: theme.fontSizeSm
                    font.weight: Font.DemiBold
                }
            }

            Rectangle {
                width: parent.width
                height: 6
                radius: 3
                color: theme.itemFill
                border.width: 1
                border.color: theme.glassBorderSubtle

                Rectangle {
                    width: Math.round(parent.width * root.value)
                    height: parent.height
                    radius: parent.radius
                    color: theme.textMedium

                    Behavior on width {
                        NumberAnimation {
                            duration: theme.animDurationFast
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }
}
