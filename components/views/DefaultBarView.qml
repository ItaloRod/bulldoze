import QtQuick
import ".."

Item {
    id: root

    property bool isExpanded: false
    property var activateLauncher
    property var activateWorkspace
    property var toggleGaming
    property var toggleNotifications
    property var toggleSettings
    property var toggleProfile
    property var togglePowerMenu

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
    readonly property int dynamicGap: 20

    readonly property int contentExpandedWidth: Math.max(480, Math.round(Math.max(leftContentWidth, rightContentWidth) * 2 + clockContentWidth + (dynamicGap * 2) + marginSpace))
    readonly property int contentCollapsedWidth: Math.round(clockContentWidth + marginSpace + 16)

    // =========================================================================
    // SINGLE ROW: MAIN ROW (Spotlight + Workspaces | Clock/Date | Status)
    // =========================================================================
    Item {
        id: mainRow
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        height: 26

        // Left: Workspace Pills
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

        // Right: System Tray + Gaming Mode + Settings + Profile Avatar
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

            gaming: root.gaming
            notifications: root.notifications
            userProfile: root.userProfile

            toggleGaming: root.toggleGaming
            toggleNotifications: root.toggleNotifications
            toggleSettings: root.toggleSettings
            toggleProfile: root.toggleProfile
            togglePowerMenu: root.togglePowerMenu
        }
    }
}


