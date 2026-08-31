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

    readonly property int contentExpandedWidth: Math.max(620, Math.round(Math.max(leftContentWidth, rightContentWidth) * 2 + clockContentWidth + (dynamicGap * 2) + marginSpace))
    readonly property int contentCollapsedWidth: Math.round(clockContentWidth + marginSpace + 16)

    // =========================================================================
    // ROW 1: MAIN ROW (Spotlight + Workspaces | Clock/Date | Notif + Profile)
    // =========================================================================
    Item {
        id: mainRow
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: root.isExpanded ? 7 : Math.round((parent.height - height) / 2)
        }
        height: 26

        Behavior on anchors.topMargin {
            NumberAnimation {
                duration: root.isExpanded ? theme.animDurationSticky : theme.animDurationExit
                easing.type: Easing.OutCubic
            }
        }

        // Left: Spotlight Logo + Workspace Pills
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

        // Center: Clock & Date (Always locked to the physical horizontal center of the notch)
        Clock {
            id: clockItem
            anchors.centerIn: parent
            isExpanded: root.isExpanded
        }

        // Right: System Tray + Notifications + Profile Avatar
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

            notifications: root.notifications
            userProfile: root.userProfile

            toggleNotifications: root.toggleNotifications
            toggleProfile: root.toggleProfile
            togglePowerMenu: root.togglePowerMenu
        }
    }

    // =========================================================================
    // ROW 2: CENTERED QUICK CONTROLS (Wi-Fi, Bluetooth, Audio, Gaming)
    // =========================================================================
    QuickControls {
        id: quickControlsRow
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: mainRow.bottom
            topMargin: 4
        }
        opacity: root.isExpanded ? 1.0 : 0.0
        scale: root.isExpanded ? 1.0 : 0.90
        transformOrigin: Item.Center
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

        toggleWifi: root.toggleWifi
        toggleBluetooth: root.toggleBluetooth
        toggleAudio: root.toggleAudio
        toggleGaming: root.toggleGaming
    }
}


