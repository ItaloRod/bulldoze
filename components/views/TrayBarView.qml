import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import ".."

Item {
    id: root

    property var notifications
    property var toggleNotifications

    property int menuOpenCount: 0
    readonly property bool isAnyMenuOpen: menuOpenCount > 0

    Theme {
        id: theme
    }

    readonly property int itemCount: (SystemTray.items && SystemTray.items.values) ? SystemTray.items.values.length : 0
    readonly property int paddingLeft: theme.spacingSm
    readonly property int paddingRight: theme.spacingSm
    readonly property int idealWidth: (itemCount * 26) + (itemCount > 0 ? (itemCount * 6 + 8) : 0) + 26 + paddingLeft + paddingRight

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

        // Separator between system tray and notification bell button
        Rectangle {
            width: 1
            height: 14
            anchors.verticalCenter: parent.verticalCenter
            color: theme.glassBorderSubtle
            visible: root.itemCount > 0
        }

        // Notification Center Bell Tile
        Item {
            id: notifButtonContainer
            width: 26
            height: 26
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                id: notifTile
                anchors.fill: parent
                radius: theme.radiusSmall
                color: notifMouse.containsMouse ? theme.hoverFill : "transparent"
                border.width: 1
                border.color: notifMouse.containsMouse ? theme.glassBorderStrong : "transparent"
                scale: notifMouse.pressed ? 0.90 : (notifMouse.containsMouse ? 1.15 : 1.0)
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
                    color: (root.notifications && root.notifications.hasNotifications) ? theme.textStrong : theme.textMuted
                    font.pixelSize: 13
                    renderType: Text.NativeRendering
                }

                // Unread Count Badge
                Rectangle {
                    anchors {
                        top: parent.top
                        right: parent.right
                        topMargin: 0
                        rightMargin: 0
                    }
                    width: (root.notifications && root.notifications.count > 9) ? 14 : 12
                    height: 12
                    radius: 6
                    color: "#FF3B30"
                    visible: Boolean(root.notifications && root.notifications.hasNotifications)

                    Text {
                        anchors.centerIn: parent
                        text: root.notifications ? (root.notifications.count > 99 ? "99+" : root.notifications.count) : ""
                        color: "#FFFFFF"
                        font.pixelSize: 8
                        font.weight: Font.Bold
                        renderType: Text.NativeRendering
                    }
                }

                MouseArea {
                    id: notifMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.toggleNotifications) {
                            root.toggleNotifications()
                        }
                    }
                }
            }
        }
    }
}
