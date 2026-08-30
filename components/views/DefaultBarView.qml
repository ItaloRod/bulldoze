import QtQuick
import ".."

Item {
    id: root

    property bool isExpanded: false
    property var activateLauncher
    property var activateWorkspace
    property var toggleWifi
    property var toggleBluetooth
    property var toggleAudio
    property var toggleGaming
    property var toggleNotifications
    property var toggleProfile
    property var togglePowerMenu

    property var network
    property var bluetooth
    property var audio
    property var gaming
    property var notifications
    property var userProfile

    Theme {
        id: theme
    }

    readonly property real leftContentWidth: leftGroup.implicitWidth
    readonly property real clockContentWidth: clockItem.implicitWidth
    readonly property real rightContentWidth: rightGroup.implicitWidth
    readonly property int marginSpace: (theme.contentInset + theme.notchConcaveWidth) * 2
    readonly property int dynamicGap: 24

    readonly property int contentExpandedWidth: Math.max(660, Math.round(leftContentWidth + clockContentWidth + rightContentWidth + (dynamicGap * 2) + marginSpace))
    readonly property int contentCollapsedWidth: Math.round(clockContentWidth + marginSpace + 16)

    // Left Group: Logo and Workspace Pills
    Row {
        id: leftGroup
        anchors {
            left: parent.left
            leftMargin: theme.contentInset + theme.notchConcaveWidth
            verticalCenter: parent.verticalCenter
        }
        spacing: theme.groupSpacing
        opacity: root.isExpanded ? 1.0 : 0.0
        scale: root.isExpanded ? 1.0 : 0.90
        transformOrigin: Item.Left
        visible: opacity > 0.001

        Behavior on opacity {
            NumberAnimation {
                duration: root.isExpanded ? theme.animDurationSticky : theme.animDurationExit
                easing.type: Easing.OutCubic
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: root.isExpanded ? theme.animDurationSticky : theme.animDurationExit
                easing.type: root.isExpanded ? Easing.OutBack : Easing.InCubic
                easing.overshoot: theme.stickyOvershoot
            }
        }

        BulldozeLogo {
            anchors.verticalCenter: parent.verticalCenter
            activateLauncher: root.activateLauncher
        }

        WorkspacePills {
            anchors.verticalCenter: parent.verticalCenter
            activateWorkspace: root.activateWorkspace
        }
    }

    // Center: Clock (Dynamically centered in the space between left and right groups)
    Clock {
        id: clockItem
        anchors.verticalCenter: parent.verticalCenter
        isExpanded: root.isExpanded

        x: {
            if (!root.isExpanded) {
                return Math.round((parent.width - width) / 2)
            }
            const leftEnd = leftGroup.x + leftGroup.width
            const rightStart = rightGroup.x
            const availableSpace = rightStart - leftEnd
            return Math.round(leftEnd + (availableSpace - width) / 2)
        }

        Behavior on x {
            NumberAnimation {
                duration: root.isExpanded ? theme.animDurationSticky : theme.animDurationExit
                easing.type: Easing.OutCubic
            }
        }
    }

    // Right Group: Status Controls
    Status {
        id: rightGroup
        anchors {
            right: parent.right
            rightMargin: theme.contentInset + theme.notchConcaveWidth
            verticalCenter: parent.verticalCenter
        }
        opacity: root.isExpanded ? 1.0 : 0.0
        scale: root.isExpanded ? 1.0 : 0.90
        transformOrigin: Item.Right
        visible: opacity > 0.001

        Behavior on opacity {
            NumberAnimation {
                duration: root.isExpanded ? theme.animDurationSticky : theme.animDurationExit
                easing.type: Easing.OutCubic
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: root.isExpanded ? theme.animDurationSticky : theme.animDurationExit
                easing.type: root.isExpanded ? Easing.OutBack : Easing.InCubic
                easing.overshoot: theme.stickyOvershoot
            }
        }

        network: root.network
        bluetooth: root.bluetooth
        audio: root.audio
        gaming: root.gaming
        notifications: root.notifications
        userProfile: root.userProfile

        toggleWifi: root.toggleWifi
        toggleBluetooth: root.toggleBluetooth
        toggleAudio: root.toggleAudio
        toggleGaming: root.toggleGaming
        toggleNotifications: root.toggleNotifications
        toggleProfile: root.toggleProfile
        togglePowerMenu: root.togglePowerMenu
    }
}
