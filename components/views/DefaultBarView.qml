import QtQuick
import ".."

Item {
    id: root

    property var activateLauncher
    property var activateWorkspace
    property var toggleNotifications
    property var toggleSettings

    property var gaming
    property var notifications
    property var userProfile

    Theme {
        id: theme
    }

    readonly property int marginSpace: theme.contentInset * 2
    readonly property int contentCollapsedWidth: Math.round(clockItem.implicitWidth + marginSpace + 16)

    // Center: Clock & Date (Always locked to the physical horizontal center of the notch)
    Clock {
        id: clockItem
        anchors.centerIn: parent
    }

    MouseArea {
        id: defaultBarClickArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        hoverEnabled: true
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                if (root.toggleNotifications) {
                    root.toggleNotifications()
                }
            } else {
                if (root.toggleSettings) {
                    root.toggleSettings()
                }
            }
        }
    }
}


