import QtQuick
import Quickshell
import Quickshell.Widgets
import "../../modules"
import ".."

Item {
    id: root

    property var goBack
    property var resetTimer
    property var notifications

    Theme {
        id: theme
    }

    readonly property var notifMod: notifications
    readonly property var notifList: (notifMod && notifMod.list) ? notifMod.list : []
    readonly property int notifCount: notifList && notifList.length !== undefined ? notifList.length : 0

    // Top of stack is always index 0 (the latest notification)
    readonly property var currentNotif: (notifCount > 0) ? notifList[0] : null

    HoverHandler {
        onHoveredChanged: {
            if (hovered && root.resetTimer) {
                root.resetTimer()
            }
        }
    }

    Item {
        anchors {
            left: parent.left
            leftMargin: theme.contentInset + theme.notchConcaveWidth
            right: parent.right
            rightMargin: theme.contentInset + theme.notchConcaveWidth
            top: parent.top
            bottom: parent.bottom
        }

        // 1. App Icon Container (Left)
        Rectangle {
            id: appIconRect
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            width: 42
            height: 42
            radius: theme.radiusItem
            color: theme.itemFill
            border.width: 1
            border.color: theme.glassBorderSubtle
            visible: root.currentNotif !== null

            Text {
                anchors.centerIn: parent
                text: ""
                color: theme.accent
                font.pixelSize: theme.iconSizeLg
                visible: !notifIcon.visible || notifIcon.status !== Image.Ready
            }

            IconImage {
                id: notifIcon
                anchors.centerIn: parent
                width: 28
                height: 28
                source: (root.notifMod && root.currentNotif) ? root.notifMod.resolveIconSource(root.currentNotif) : ""
                visible: source !== "" && status === Image.Ready
            }
        }

        // 2. Dismiss Button (Right: ) - Pops top of stack to reveal previous notification
        Rectangle {
            id: closeBtn
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            width: 32
            height: 32
            radius: theme.radiusSmall
            visible: root.currentNotif !== null
            color: dismissMouse.containsMouse ? theme.hoverFill : "transparent"
            border.width: 1
            border.color: dismissMouse.containsMouse ? theme.glassBorderStrong : "transparent"
            scale: dismissMouse.pressed ? 0.90 : (dismissMouse.containsMouse ? 1.15 : 1.0)
            transformOrigin: Item.Center
            z: 10

            Behavior on color { ColorAnimation { duration: theme.animDurationFast } }
            Behavior on border.color { ColorAnimation { duration: theme.animDurationFast } }
            Behavior on scale {
                NumberAnimation {
                    duration: theme.animDurationFast
                    easing.type: Easing.OutBack
                    easing.overshoot: theme.buttonOvershoot
                }
            }

            Text {
                anchors.centerIn: parent
                text: ""
                color: dismissMouse.containsMouse ? theme.textStrong : theme.textMedium
                font.pixelSize: theme.iconSizeSm
            }

            MouseArea {
                id: dismissMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.notifMod) {
                        root.notifMod.pop()
                    }
                    if (root.resetTimer) {
                        root.resetTimer()
                    }
                    if (!root.notifMod || !root.notifMod.hasNotifications) {
                        if (root.goBack) root.goBack()
                    }
                }
            }
        }

        // 3. Text Column (Middle - Between icon and close button)
        Column {
            id: textColumn
            anchors {
                left: appIconRect.right
                leftMargin: theme.spacingMd
                right: closeBtn.left
                rightMargin: theme.spacingMd
                verticalCenter: parent.verticalCenter
            }
            spacing: 2
            visible: root.currentNotif !== null

            // Line 1: App Name / Sender + Stack counter badge (if multiple)
            Row {
                width: parent.width
                spacing: theme.spacingSm

                Text {
                    text: root.currentNotif ? (root.currentNotif.appName || "Sistema") : ""
                    color: theme.textMuted
                    font.pixelSize: theme.fontSizeSm
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                Text {
                    text: root.notifCount > 1 ? ("(" + root.notifCount + ")") : ""
                    color: theme.accent
                    font.pixelSize: theme.fontSizeXs
                    font.weight: Font.Bold
                    visible: root.notifCount > 1
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Line 2: Title / Summary (Bold)
            Text {
                width: parent.width
                text: root.currentNotif ? root.currentNotif.summary : ""
                color: theme.textStrong
                font.pixelSize: theme.fontSizeMd
                font.weight: Font.Bold
                elide: Text.ElideRight
                maximumLineCount: 1
                visible: text !== ""
            }

            // Line 3: Message / Body
            Text {
                width: parent.width
                text: root.currentNotif ? (root.currentNotif.body !== "" ? root.currentNotif.body : (root.currentNotif.summary !== "" ? "" : "Notificação sem conteúdo")) : ""
                color: theme.textMedium
                font.pixelSize: theme.fontSizeSm
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
                visible: text !== ""
            }
        }

        // 4. Empty State (when stack is empty)
        Row {
            anchors.centerIn: parent
            spacing: theme.spacingMd
            visible: root.currentNotif === null

            Text {
                text: ""
                color: theme.indicatorInactive
                font.pixelSize: theme.iconSizeLg
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "Nenhuma notificação ativa"
                color: theme.textMuted
                font.pixelSize: theme.fontSizeSubmenuBody
                font.weight: Font.Medium
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
