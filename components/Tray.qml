import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

Row {
    id: root

    spacing: 6

    Repeater {
        model: SystemTray.items

        delegate: Item {
            required property var modelData

            width: 16
            height: 16

            IconImage {
                anchors.fill: parent
                source: {
                    const idStr = (modelData.id || "").toLowerCase();
                    const titleStr = (modelData.title || "").toLowerCase();
                    const tooltipStr = (modelData.tooltip || "").toLowerCase();
                    if (idStr.includes("bitwarden") || titleStr.includes("bitwarden") || tooltipStr.includes("bitwarden")) {
                        return "file:///home/paulo/.config/bulldoze/icons/bitwarden.svg";
                    }
                    if (!modelData.icon) return "";
                    if (modelData.icon.startsWith("/") || modelData.icon.startsWith("file://") || modelData.icon.startsWith("image://")) {
                        return modelData.icon.startsWith("/") ? ("file://" + modelData.icon) : modelData.icon
                    }
                    return Quickshell.iconPath(modelData.icon, "")
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: modelData.activate()
            }
        }
    }
}
