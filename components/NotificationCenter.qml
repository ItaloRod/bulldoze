import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import "."

Item {
    id: root

    property var notifications
    property bool open: false
    signal closeRequested()

    readonly property alias toastContainer: toastCardContainer
    readonly property alias fullCenterContainer: fullCenterContainer

    Theme {
        id: theme
    }

    readonly property var notifMod: notifications
    readonly property var notifList: (notifMod && notifMod.list) ? notifMod.list : []
    readonly property int notifCount: (notifMod && notifMod.count !== undefined) ? notifMod.count : 0

    // Temporary Pop-up (Toast) state for new incoming notifications
    property var toastNotif: null
    property bool toastVisible: false

    Connections {
        target: root.notifMod
        function onNotificationReceived(notif) {
            if (!root.open) {
                root.toastNotif = notif
                root.toastVisible = true
                toastTimer.restart()
            }
        }
    }

    Timer {
        id: toastTimer
        interval: 4500
        onTriggered: {
            root.toastVisible = false
        }
    }

    // Fullscreen dismiss overlay when Notification Center is open
    MouseArea {
        anchors.fill: parent
        visible: root.open
        onClicked: root.closeRequested()
    }

    // Focus grab for Escape key
    Item {
        focus: root.open
        Keys.onEscapePressed: root.closeRequested()
    }

    // -------------------------------------------------------------------------
    // 1. Temporary Toast Pop-up Card (When Notification Center is CLOSED)
    // -------------------------------------------------------------------------
    Item {
        id: toastCardContainer
        anchors {
            top: parent.top
            topMargin: 40
            right: parent.right
            rightMargin: 12
        }
        width: 380
        height: toastCard.implicitHeight
        visible: !root.open && root.toastVisible && root.toastNotif !== null
        opacity: visible ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
        }

        Rectangle {
            id: toastCard
            anchors.fill: parent
            radius: 16
            color: theme.glassFillDark
            border.width: 1
            border.color: theme.glassBorderSubtle
            implicitHeight: Math.max(72, toastContentCol.implicitHeight + 24)

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    if (root.toastNotif && root.toastNotif.actions && root.toastNotif.actions.length > 0) {
                        try { root.toastNotif.actions[0].execute() } catch(e) {}
                    }
                    root.toastVisible = false
                }
            }

            Column {
                id: toastContentCol
                anchors {
                    left: parent.left
                    leftMargin: 14
                    right: parent.right
                    rightMargin: 14
                    top: parent.top
                    topMargin: 12
                }
                spacing: 6

                Row {
                    width: parent.width
                    spacing: 8

                    IconImage {
                        width: 18
                        height: 18
                        anchors.verticalCenter: parent.verticalCenter
                        source: root.notifMod ? root.notifMod.resolveIconSource(root.toastNotif) : ""
                        visible: source !== "" && status === Image.Ready
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: (root.toastNotif && root.toastNotif.appName) ? root.toastNotif.appName : "Notificação"
                        color: theme.textStrong
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                        width: parent.width - 50
                        renderType: Text.NativeRendering
                    }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 18
                        height: 18
                        radius: 9
                        color: toastCloseMouse.containsMouse ? theme.hoverFill : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: ""
                            color: theme.textMuted
                            font.pixelSize: 10
                            renderType: Text.NativeRendering
                        }

                        MouseArea {
                            id: toastCloseMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                root.toastVisible = false
                            }
                        }
                    }
                }

                Text {
                    width: parent.width
                    text: (root.toastNotif && root.toastNotif.summary) ? root.toastNotif.summary : ""
                    color: theme.textStrong
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    wrapMode: Text.Wrap
                    renderType: Text.NativeRendering
                }

                Text {
                    width: parent.width
                    visible: text !== ""
                    text: (root.toastNotif && root.toastNotif.body) ? root.toastNotif.body : ""
                    color: theme.textMedium
                    font.pixelSize: 12
                    wrapMode: Text.Wrap
                    maximumLineCount: 3
                    elide: Text.ElideRight
                    renderType: Text.NativeRendering
                }
            }
        }
    }

    // -------------------------------------------------------------------------
    // 2. Full Notification Center (When OPEN)
    // -------------------------------------------------------------------------
    Item {
        id: fullCenterContainer
        anchors {
            top: parent.top
            topMargin: 32
            right: parent.right
            rightMargin: 0
            bottom: parent.bottom
            bottomMargin: 0
        }
        width: 392
        visible: root.open
        opacity: visible ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
        }

        MouseArea {
            anchors.fill: parent
        }

        // Subtle frosted glass backdrop for the notifications column
        Rectangle {
            id: panelBackdrop
            anchors.fill: parent
            topLeftRadius: 20
            bottomLeftRadius: 20
            topRightRadius: 0
            bottomRightRadius: 0
            color: Qt.rgba(0, 0, 0, 0.03)
            border.width: 0
        }

        Column {
            anchors {
                fill: parent
                leftMargin: 14
                rightMargin: 14
                topMargin: 10
                bottomMargin: 14
            }
            spacing: 12

            // Header: "Limpar Todas" button
            Item {
                width: parent.width
                height: root.notifCount > 0 ? 30 : 0
                visible: root.notifCount > 0

                // Clear All Button
                Rectangle {
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    visible: root.notifCount > 0
                    width: clearText.implicitWidth + 16
                    height: 24
                    radius: 12
                    color: clearMouse.containsMouse ? theme.hoverFill : theme.itemFill
                    border.width: 0

                    Text {
                        id: clearText
                        anchors.centerIn: parent
                        text: "Limpar Todas"
                        color: theme.textMedium
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        renderType: Text.NativeRendering
                    }

                    MouseArea {
                        id: clearMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.notifMod) {
                                root.notifMod.dismissAll()
                            }
                        }
                    }
                }
            }

            // Empty State
            Item {
                width: parent.width
                height: 100
                visible: root.notifCount === 0

                Text {
                    anchors.centerIn: parent
                    text: "Nenhuma notificação"
                    color: theme.textSubtle
                    font.pixelSize: 13
                    renderType: Text.NativeRendering
                }
            }

            // Notifications List
            ListView {
                id: notifList
                width: parent.width
                height: parent.height - 42
                clip: true
                spacing: 10
                model: root.notifList
                boundsBehavior: Flickable.StopAtBounds

                delegate: Rectangle {
                    id: notifCard
                    required property var modelData
                    required property int index

                    width: notifList.width
                    implicitHeight: Math.max(68, cardContentCol.implicitHeight + 20)
                    radius: 16
                    color: theme.glassFillDark
                    border.width: 0

                    Behavior on color {
                        ColorAnimation { duration: 120 }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (modelData && modelData.actions && modelData.actions.length > 0) {
                                try { modelData.actions[0].execute() } catch(e) {}
                            }
                        }
                    }

                    Column {
                        id: cardContentCol
                        anchors {
                            left: parent.left
                            leftMargin: 14
                            right: parent.right
                            rightMargin: 14
                            top: parent.top
                            topMargin: 10
                        }
                        spacing: 4

                        // Header Row of the card
                        Row {
                            width: parent.width
                            spacing: 8

                            IconImage {
                                width: 16
                                height: 16
                                anchors.verticalCenter: parent.verticalCenter
                                source: root.notifMod ? root.notifMod.resolveIconSource(modelData) : ""
                                visible: source !== "" && status === Image.Ready
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData && modelData.appName ? modelData.appName : "Notificação"
                                color: theme.textStrong
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                                width: parent.width - 44
                                renderType: Text.NativeRendering
                            }

                            // Dismiss Individual Notification Button ("X")
                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 18
                                height: 18
                                radius: 9
                                color: cardCloseMouse.containsMouse ? theme.hoverFill : "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    text: ""
                                    color: theme.textMuted
                                    font.pixelSize: 10
                                    renderType: Text.NativeRendering
                                }

                                MouseArea {
                                    id: cardCloseMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (root.notifMod && modelData) {
                                            root.notifMod.dismiss(modelData)
                                        }
                                    }
                                }
                            }
                        }

                        // Summary / Title
                        Text {
                            width: parent.width
                            text: modelData && modelData.summary ? modelData.summary : ""
                            color: theme.textStrong
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            wrapMode: Text.Wrap
                            renderType: Text.NativeRendering
                        }

                        // Body
                        Text {
                            width: parent.width
                            visible: text !== ""
                            text: modelData && modelData.body ? modelData.body : ""
                            color: theme.textMedium
                            font.pixelSize: 12
                            wrapMode: Text.Wrap
                            renderType: Text.NativeRendering
                        }
                    }
                }
            }
        }
    }
}
