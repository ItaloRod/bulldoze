import QtQuick
import Quickshell.Hyprland

Row {
    id: root

    Theme {
        id: theme
    }

    property var activateWorkspace

    spacing: theme.workspaceSpacing

    // Filter valid regular workspaces (id > 0) and sort by id
    readonly property var workspaceList: {
        const list = []
        for (const ws of Hyprland.workspaces.values) {
            if (ws && ws.id > 0) {
                list.push(ws)
            }
        }
        list.sort((a, b) => a.id - b.id)
        return list
    }

    Repeater {
        model: root.workspaceList

        Rectangle {
            id: pill
            required property var modelData

            readonly property bool active: Hyprland.focusedWorkspace ? (modelData.id === Hyprland.focusedWorkspace.id) : false

            width: active ? 22 : 6
            height: 6
            radius: 3
            color: pillMouse.containsMouse ? theme.textStrong : (active ? theme.textMedium : theme.indicatorInactive)
            scale: pillMouse.pressed ? 0.88 : (pillMouse.containsMouse ? 1.25 : 1.0)
            transformOrigin: Item.Center

            Behavior on width {
                NumberAnimation {
                    duration: theme.animDurationNormal
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: theme.animDurationFast
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: theme.animDurationFast
                    easing.type: Easing.OutBack
                    easing.overshoot: theme.buttonOvershoot
                }
            }

            MouseArea {
                id: pillMouse
                anchors.fill: parent
                anchors.margins: -8
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    if (modelData && modelData.activate) {
                        modelData.activate()
                    } else if (root.activateWorkspace) {
                        root.activateWorkspace(modelData.id)
                    }
                }
            }
        }
    }
}
