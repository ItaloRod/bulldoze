import QtQuick
import Quickshell
import Quickshell.Widgets
import "../../modules"
import ".."

Item {
    id: root

    property var notifications
    property bool isExpanded: false
    property var dismissAll
    property var dismissOne

    Theme {
        id: theme
    }

    readonly property var notifMod: notifications
    readonly property var notifList: (notifMod && notifMod.list) ? notifMod.list : []
    readonly property int notifCount: notifList && notifList.length !== undefined ? notifList.length : 0
    readonly property var latestNotif: (notifCount > 0) ? notifList[0] : null

    // -------------------------------------------------------------------------
    // 1. EMPTY STATE (when there are no notifications)
    // -------------------------------------------------------------------------
    Row {
        anchors.centerIn: parent
        spacing: theme.spacingMd
        visible: root.notifCount === 0

        Text {
            renderType: Text.NativeRendering
            text: ""
            color: theme.indicatorInactive
            font.pixelSize: 18
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            renderType: Text.NativeRendering
            text: "Nenhuma notificação"
            color: theme.textMuted
            font.pixelSize: 13
            font.weight: Font.Medium
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // -------------------------------------------------------------------------
    // 2. COLLAPSED VIEW (Single card for latest notification)
    // -------------------------------------------------------------------------
    Item {
        id: collapsedCard
        anchors.fill: parent
        anchors.margins: 4
        visible: !root.isExpanded && root.notifCount > 0

        // App Icon
        Rectangle {
            id: cIconRect
            anchors {
                left: parent.left
                leftMargin: 4
                verticalCenter: parent.verticalCenter
            }
            width: 42
            height: 42
            radius: theme.radiusSmall
            color: theme.itemFill
            border.width: 1
            border.color: theme.glassBorderSubtle

            Text {
                renderType: Text.NativeRendering
                anchors.centerIn: parent
                text: ""
                color: theme.accent
                font.pixelSize: 20
                visible: !cIcon.visible || cIcon.status !== Image.Ready
            }

            IconImage {
                id: cIcon
                anchors.centerIn: parent
                width: 26
                height: 26
                source: (root.notifMod && root.latestNotif) ? root.notifMod.resolveIconSource(root.latestNotif) : ""
                visible: source !== "" && status === Image.Ready
            }
        }

        // Close Button ()
        Rectangle {
            id: cCloseBtn
            anchors {
                right: parent.right
                rightMargin: 4
                verticalCenter: parent.verticalCenter
            }
            width: 28
            height: 28
            radius: theme.radiusSmall
            color: cCloseMouse.containsMouse ? theme.hoverFill : "transparent"
            border.width: 1
            border.color: cCloseMouse.containsMouse ? theme.glassBorderStrong : "transparent"
            scale: cCloseMouse.pressed ? 0.90 : (cCloseMouse.containsMouse ? 1.15 : 1.0)
            transformOrigin: Item.Center

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
                renderType: Text.NativeRendering
                anchors.centerIn: parent
                text: ""
                color: cCloseMouse.containsMouse ? theme.textStrong : theme.textMuted
                font.pixelSize: 14
            }

            MouseArea {
                id: cCloseMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.dismissOne && root.latestNotif) {
                        root.dismissOne(root.latestNotif)
                    }
                }
            }
        }

        // Content Column
        Column {
            anchors {
                left: cIconRect.right
                leftMargin: 10
                right: cCloseBtn.left
                rightMargin: 10
                verticalCenter: parent.verticalCenter
            }
            spacing: 2

            // App Name + Time
            Row {
                width: parent.width
                spacing: 6

                Text {
                    renderType: Text.NativeRendering
                    text: root.latestNotif ? (root.latestNotif.appName || "Sistema") : ""
                    color: theme.textMuted
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                Text {
                    renderType: Text.NativeRendering
                    text: "•"
                    color: theme.textSubtle
                    font.pixelSize: 11
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    renderType: Text.NativeRendering
                    text: "agora"
                    color: theme.textSubtle
                    font.pixelSize: 11
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Summary
            Text {
                renderType: Text.NativeRendering
                width: parent.width
                text: root.latestNotif ? root.latestNotif.summary : ""
                color: theme.textStrong
                font.pixelSize: 14
                font.weight: Font.Bold
                elide: Text.ElideRight
                maximumLineCount: 1
                visible: text !== ""
            }

            // Body
            Text {
                renderType: Text.NativeRendering
                width: parent.width
                text: root.latestNotif ? root.latestNotif.body : ""
                color: theme.textMedium
                font.pixelSize: 12
                elide: Text.ElideRight
                maximumLineCount: 1
                visible: text !== ""
            }
        }
    }

    // -------------------------------------------------------------------------
    // 3. EXPANDED VIEW (Stacked list with BottomToTop order & clear button)
    // -------------------------------------------------------------------------
    Item {
        id: expandedContainer
        anchors.fill: parent
        anchors.margins: 4
        visible: root.isExpanded && root.notifCount > 0

        // Clear All Action Bar (at the very bottom)
        Rectangle {
            id: clearBar
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: 26
            color: "transparent"

            Rectangle {
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                width: 26
                height: 26
                radius: theme.radiusSmall
                color: clearMouse.containsMouse ? theme.hoverFill : "transparent"
                border.width: 1
                border.color: clearMouse.containsMouse ? theme.glassBorderStrong : "transparent"
                scale: clearMouse.pressed ? 0.90 : (clearMouse.containsMouse ? 1.15 : 1.0)
                transformOrigin: Item.Center

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
                    renderType: Text.NativeRendering
                    anchors.centerIn: parent
                    text: ""
                    color: clearMouse.containsMouse ? theme.textStrong : theme.textMuted
                    font.pixelSize: theme.iconSizeSm
                }

                MouseArea {
                    id: clearMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.dismissAll) root.dismissAll()
                    }
                }
            }
        }

        // Notifications List (BottomToTop: index 0 is at bottom, older above)
        ListView {
            id: notifListView
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                bottom: clearBar.top
                bottomMargin: 4
            }
            clip: true
            model: root.notifList
            verticalLayoutDirection: ListView.BottomToTop
            spacing: 6
            boundsBehavior: Flickable.StopAtBounds

            delegate: Rectangle {
                id: itemCard
                width: notifListView.width
                height: 60
                radius: theme.radiusSmall
                color: theme.itemFill
                border.width: 1
                border.color: theme.glassBorderSubtle

                // App Icon
                Rectangle {
                    id: dIconRect
                    anchors {
                        left: parent.left
                        leftMargin: 8
                        verticalCenter: parent.verticalCenter
                    }
                    width: 32
                    height: 32
                    radius: 6
                    color: theme.glassFillDark
                    border.width: 1
                    border.color: theme.glassBorderSubtle

                    Text {
                        renderType: Text.NativeRendering
                        anchors.centerIn: parent
                        text: ""
                        color: theme.accent
                        font.pixelSize: 15
                        visible: !dIcon.visible || dIcon.status !== Image.Ready
                    }

                    IconImage {
                        id: dIcon
                        anchors.centerIn: parent
                        width: 20
                        height: 20
                        source: (root.notifMod && modelData) ? root.notifMod.resolveIconSource(modelData) : ""
                        visible: source !== "" && status === Image.Ready
                    }
                }

                // Close Button ()
                Rectangle {
                    id: dCloseBtn
                    anchors {
                        right: parent.right
                        rightMargin: 6
                        verticalCenter: parent.verticalCenter
                    }
                    width: 24
                    height: 24
                    radius: theme.radiusSmall
                    color: dCloseMouse.containsMouse ? theme.hoverFill : "transparent"
                    border.width: 1
                    border.color: dCloseMouse.containsMouse ? theme.glassBorderStrong : "transparent"
                    scale: dCloseMouse.pressed ? 0.90 : (dCloseMouse.containsMouse ? 1.15 : 1.0)
                    transformOrigin: Item.Center

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
                        renderType: Text.NativeRendering
                        anchors.centerIn: parent
                        text: ""
                        color: dCloseMouse.containsMouse ? theme.textStrong : theme.textMuted
                        font.pixelSize: 12
                    }

                    MouseArea {
                        id: dCloseMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.dismissOne) {
                                root.dismissOne(modelData)
                            }
                        }
                    }
                }

                // Content Column
                Column {
                    anchors {
                        left: dIconRect.right
                        leftMargin: 8
                        right: dCloseBtn.left
                        rightMargin: 6
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 2

                    // App Name
                    Text {
                        renderType: Text.NativeRendering
                        width: parent.width
                        text: modelData ? (modelData.appName || "Sistema") : ""
                        color: theme.textMuted
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    // Summary
                    Text {
                        renderType: Text.NativeRendering
                        width: parent.width
                        text: modelData ? modelData.summary : ""
                        color: theme.textStrong
                        font.pixelSize: 14
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        visible: text !== ""
                    }

                    // Body
                    Text {
                        renderType: Text.NativeRendering
                        width: parent.width
                        text: modelData ? modelData.body : ""
                        color: theme.textMedium
                        font.pixelSize: 12
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        visible: text !== ""
                    }
                }
            }
        }
    }
}
