import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "."

Item {
    id: root

    property color iconColor: "#FFFFFF"
    property int menuOpenCount: 0
    readonly property bool isAnyMenuOpen: menuOpenCount > 0

    implicitHeight: 32
    implicitWidth: trayRow.implicitWidth

    Theme {
        id: theme
    }

    Row {
        id: trayRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        Repeater {
            model: SystemTray.items

            delegate: Item {
                id: trayDelegate
                required property var modelData

                width: 20
                height: 20
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    id: hoverBackground
                    anchors.fill: parent
                    radius: 4
                    color: itemMouse.containsMouse ? (root.iconColor === "#000000" ? "#1A000000" : "#1AFFFFFF") : "transparent"
                    scale: itemMouse.pressed ? 0.90 : (itemMouse.containsMouse ? 1.08 : 1.0)

                    Behavior on scale {
                        NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
                    }

                    IconImage {
                        id: baseIcon
                        anchors.centerIn: parent
                        width: 16
                        height: 16
                        visible: false // MultiEffect renders this with colorization
                        source: {
                            const idStr = (modelData.id || "").toLowerCase()
                            const titleStr = (modelData.title || "").toLowerCase()
                            const tooltipStr = (modelData.tooltip || "").toLowerCase()
                            if (idStr.includes("bitwarden") || titleStr.includes("bitwarden") || tooltipStr.includes("bitwarden")) {
                                return "file:///home/paulo/.config/bulldoze/icons/bitwarden.svg"
                            }
                            if (!modelData.icon) return ""
                            if (modelData.icon.startsWith("/") || modelData.icon.startsWith("file://") || modelData.icon.startsWith("image://")) {
                                return modelData.icon.startsWith("/") ? ("file://" + modelData.icon) : modelData.icon
                            }
                            return Quickshell.iconPath(modelData.icon, "")
                        }
                    }

                    MultiEffect {
                        id: tintedIcon
                        anchors.fill: baseIcon
                        source: baseIcon
                        colorization: 1.0
                        colorizationColor: root.iconColor
                        visible: baseIcon.source !== ""
                    }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        cursorShape: Qt.PointingHandCursor

                        onClicked: mouse => {
                            if (mouse.button === Qt.LeftButton) {
                                modelData.activate()
                            } else if (mouse.button === Qt.RightButton) {
                                if (modelData.hasMenu && modelData.menu) {
                                    menuAnchor.open()
                                } else if (modelData.secondaryActivate) {
                                    modelData.secondaryActivate()
                                }
                            }
                        }
                    }

                    QsMenuAnchor {
                        id: menuAnchor
                        menu: (modelData.hasMenu && modelData.menu) ? modelData.menu : null
                        anchor.item: hoverBackground
                        onOpened: root.menuOpenCount++
                        onClosed: root.menuOpenCount = Math.max(0, root.menuOpenCount - 1)
                    }
                }
            }
        }
    }
}
