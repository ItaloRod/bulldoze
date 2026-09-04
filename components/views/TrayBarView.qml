import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import ".."

Item {
    id: root

    property int menuOpenCount: 0
    readonly property bool isAnyMenuOpen: menuOpenCount > 0

    Theme {
        id: theme
    }

    readonly property int itemCount: (SystemTray.items && SystemTray.items.values) ? SystemTray.items.values.length : 0
    readonly property int paddingLeft: theme.spacingSm
    readonly property int paddingRight: theme.spacingSm
    readonly property int idealWidth: Math.max(48, itemCount * 26 + Math.max(0, itemCount - 1) * 6 + paddingLeft + paddingRight)

    Row {
        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: SystemTray.items

            delegate: Item {
                id: trayItemRoot
                required property var modelData

                width: 26
                height: 26

                Rectangle {
                    id: itemTile
                    anchors.fill: parent
                    radius: theme.radiusSmall
                    color: itemMouse.containsMouse ? theme.hoverFill : "transparent"
                    border.width: 1
                    border.color: itemMouse.containsMouse ? theme.glassBorderStrong : "transparent"
                    scale: itemMouse.pressed ? 0.90 : (itemMouse.containsMouse ? 1.15 : 1.0)
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

                    IconImage {
                        id: itemIcon
                        anchors.centerIn: parent
                        width: 16
                        height: 16
                        source: {
                            const idStr = (modelData.id || "").toLowerCase();
                            const titleStr = (modelData.title || "").toLowerCase();
                            const tooltipStr = (modelData.tooltip || "").toLowerCase();
                            if (idStr.includes("bitwarden") || titleStr.includes("bitwarden") || tooltipStr.includes("bitwarden")) {
                                return "file:///home/paulo/.config/bulldoze/icons/bitwarden.svg";
                            }
                            if (!modelData.icon) return "";
                            if (modelData.icon.startsWith("/") || modelData.icon.startsWith("file://") || modelData.icon.startsWith("image://")) {
                                return modelData.icon.startsWith("/") ? ("file://" + modelData.icon) : modelData.icon;
                            }
                            return Quickshell.iconPath(modelData.icon, "");
                        }
                    }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        cursorShape: Qt.PointingHandCursor

                        onClicked: mouse => {
                            if (mouse.button === Qt.LeftButton) {
                                modelData.activate();
                            } else if (mouse.button === Qt.RightButton) {
                                if (modelData.hasMenu && modelData.menu) {
                                    menuAnchor.open();
                                } else if (modelData.secondaryActivate) {
                                    modelData.secondaryActivate();
                                }
                            }
                        }
                    }

                    QsMenuAnchor {
                        id: menuAnchor
                        menu: (modelData.hasMenu && modelData.menu) ? modelData.menu : null
                        anchor.item: itemTile
                        onOpened: root.menuOpenCount++
                        onClosed: root.menuOpenCount = Math.max(0, root.menuOpenCount - 1)
                    }
                }
            }
        }
    }
}
