import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import Quickshell.Io
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

    Process {
        id: execProc
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
    // Deeplink Handler (Actions, Web URLs, Hyprland window focus / App launch)
    // -------------------------------------------------------------------------
    function handleDeeplink(notif) {
        if (!notif) return

        let handled = false

        // 1. Invoke default action if provided
        if (notif.actions && notif.actions.length > 0) {
            let defaultAction = null
            for (let i = 0; i < notif.actions.length; i++) {
                if (notif.actions[i] && notif.actions[i].identifier === "default") {
                    defaultAction = notif.actions[i]
                    break
                }
            }
            if (!defaultAction) {
                defaultAction = notif.actions[0]
            }
            if (defaultAction) {
                try {
                    defaultAction.invoke()
                    handled = true
                } catch(e) {
                    console.log("Error invoking notification action:", e)
                }
            }
        }

        // 2. Extract and open URL (web notifications, browsers, etc.)
        let url = extractUrl(notif)
        if (url) {
            try {
                Qt.openUrlExternally(url)
                handled = true
            } catch(e) {
                try {
                    execProc.exec(["xdg-open", url])
                    handled = true
                } catch(e2) {}
            }
        }

        // 3. Focus active window or launch app via desktop entry / appName
        if (!handled) {
            focusOrLaunchApp(notif)
        }

        root.closeRequested()
    }

    function extractUrl(notif) {
        if (!notif) return null
        if (notif.hints) {
            if (typeof notif.hints["url"] === "string" && notif.hints["url"].startsWith("http")) {
                return notif.hints["url"]
            }
            if (typeof notif.hints["x-kde-urls"] === "string" && notif.hints["x-kde-urls"].startsWith("http")) {
                return notif.hints["x-kde-urls"]
            }
            if (Array.isArray(notif.hints["x-kde-urls"]) && notif.hints["x-kde-urls"].length > 0) {
                return notif.hints["x-kde-urls"][0]
            }
        }
        let text = ((notif.summary || "") + " " + (notif.body || ""))
        let match = text.match(/https?:\/\/[^\s<>"')]+/)
        if (match) return match[0]
        return null
    }

    function focusOrLaunchApp(notif) {
        if (!notif) return
        let target = (notif.desktopEntry || notif.appName || "").trim()
        if (!target) return

        let cleanName = target.toLowerCase().replace(".desktop", "")
        execProc.exec(["hyprctl", "dispatch", "focuswindow", "class:(?i).*" + cleanName + ".*"])

        if (typeof DesktopEntries !== "undefined" && DesktopEntries && DesktopEntries.applications) {
            let apps = DesktopEntries.applications.values || DesktopEntries.applications
            for (let i = 0; i < apps.length; i++) {
                let app = apps[i]
                if (!app) continue
                let appId = (app.id || "").toLowerCase()
                let appTitle = (app.name || "").toLowerCase()
                if (appId.includes(cleanName) || appTitle.includes(cleanName)) {
                    try { app.execute() } catch(e) {}
                    break
                }
            }
        }
    }

    // -------------------------------------------------------------------------
    // 1. Temporary Toast Pop-up Card (When Notification Center is CLOSED)
    // -------------------------------------------------------------------------
    Item {
        id: toastCardContainer
        anchors {
            top: parent.top
            topMargin: 48
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
            implicitHeight: Math.max(76, toastLayoutRow.implicitHeight + 24)

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.handleDeeplink(root.toastNotif)
                    root.toastVisible = false
                }
            }

            Row {
                id: toastLayoutRow
                anchors {
                    left: parent.left
                    leftMargin: 14
                    right: parent.right
                    rightMargin: 14
                    top: parent.top
                    topMargin: 12
                }
                spacing: 12

                // App Icon Container
                Rectangle {
                    width: 36
                    height: 36
                    radius: 8
                    color: Qt.rgba(1, 1, 1, 0.08)
                    anchors.top: parent.top

                    IconImage {
                        id: toastAppIcon
                        anchors.centerIn: parent
                        width: 24
                        height: 24
                        source: root.notifMod ? root.notifMod.resolveIconSource(root.toastNotif) : ""
                        visible: source !== "" && status === Image.Ready
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: !toastAppIcon.visible
                        text: ""
                        color: theme.textMedium
                        font.pixelSize: 14
                        renderType: Text.NativeRendering
                    }
                }

                // Text Content
                Column {
                    width: parent.width - 48
                    spacing: 4

                    Row {
                        width: parent.width
                        spacing: 8

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: (root.toastNotif && root.toastNotif.appName) ? root.toastNotif.appName : "Notificação"
                            color: theme.textStrong
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                            width: parent.width - 24
                            renderType: Text.NativeRendering
                        }

                        // Close button
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
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.toastVisible = false
                            }
                        }
                    }

                    Text {
                        width: parent.width
                        visible: text !== ""
                        text: (root.toastNotif && root.toastNotif.summary) ? root.toastNotif.summary : ""
                        color: theme.textStrong
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
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
    }

    // -------------------------------------------------------------------------
    // 2. Full Notification Center (When OPEN) - Narrow Strip from Top to Bottom
    // -------------------------------------------------------------------------
    Item {
        id: fullCenterContainer
        anchors {
            top: parent.top
            topMargin: 48
            right: parent.right
            rightMargin: 12
            bottom: parent.bottom
            bottomMargin: 12
        }
        width: 380
        visible: root.open
        opacity: visible ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }

        MouseArea {
            anchors.fill: parent
        }

        // Empty State (when 0 notifications)
        Item {
            anchors.centerIn: parent
            width: parent.width
            height: 140
            visible: root.notifCount === 0

            Column {
                anchors.centerIn: parent
                spacing: 10

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: ""
                    color: Qt.rgba(1, 1, 1, 0.25)
                    font.pixelSize: 32
                    renderType: Text.NativeRendering
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Nenhuma notificação"
                    color: theme.textSubtle
                    font.pixelSize: 13
                    renderType: Text.NativeRendering
                }
            }
        }

        // Notifications List (up to 25 items)
        ListView {
            id: notifListView
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: clearFooter.visible ? clearFooter.top : parent.bottom
                bottomMargin: 10
            }
            clip: true
            spacing: 10
            model: root.notifList
            boundsBehavior: Flickable.StopAtBounds

            delegate: Rectangle {
                id: notifCard
                required property var modelData
                required property int index

                width: notifListView.width
                implicitHeight: Math.max(76, cardLayoutRow.implicitHeight + 24)
                radius: 16
                color: cardMouse.containsMouse ? theme.hoverFill : theme.glassFillDark
                border.width: 1
                border.color: theme.glassBorderSubtle

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }

                MouseArea {
                    id: cardMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.handleDeeplink(modelData)
                }

                Row {
                    id: cardLayoutRow
                    anchors {
                        left: parent.left
                        leftMargin: 14
                        right: parent.right
                        rightMargin: 14
                        top: parent.top
                        topMargin: 12
                    }
                    spacing: 12

                    // macOS-style App Icon Box
                    Rectangle {
                        width: 36
                        height: 36
                        radius: 8
                        color: Qt.rgba(1, 1, 1, 0.08)
                        anchors.top: parent.top

                        IconImage {
                            id: cardAppIcon
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            source: root.notifMod ? root.notifMod.resolveIconSource(modelData) : ""
                            visible: source !== "" && status === Image.Ready
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: !cardAppIcon.visible
                            text: ""
                            color: theme.textMedium
                            font.pixelSize: 14
                            renderType: Text.NativeRendering
                        }
                    }

                    // Content Column
                    Column {
                        width: parent.width - 48
                        spacing: 4

                        // Header Row: App Name, Relative Timestamp & Close Button
                        Row {
                            width: parent.width
                            spacing: 8

                            Text {
                                text: modelData && modelData.appName ? modelData.appName : "Notificação"
                                color: theme.textStrong
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                                width: parent.width - 110
                                anchors.verticalCenter: parent.verticalCenter
                                renderType: Text.NativeRendering
                            }

                            Text {
                                text: root.notifMod ? root.notifMod.getRelativeTime(modelData) : ""
                                color: theme.textMuted
                                font.pixelSize: 11
                                horizontalAlignment: Text.AlignRight
                                width: 70
                                anchors.verticalCenter: parent.verticalCenter
                                renderType: Text.NativeRendering
                            }

                            // Dismiss Individual Notification Button ("X")
                            Rectangle {
                                width: 18
                                height: 18
                                radius: 9
                                anchors.verticalCenter: parent.verticalCenter
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
                            visible: text !== ""
                            text: modelData && modelData.summary ? modelData.summary : ""
                            color: theme.textStrong
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            wrapMode: Text.Wrap
                            renderType: Text.NativeRendering
                        }

                        // Body Text
                        Text {
                            width: parent.width
                            visible: text !== ""
                            text: modelData && modelData.body ? modelData.body : ""
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
        }

        // Pinned Footer (Rodapé): Trash can icon to clear all notifications
        Item {
            id: clearFooter
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
            height: 38
            visible: root.notifCount > 0

            Rectangle {
                anchors.centerIn: parent
                width: 36
                height: 36
                radius: 18
                color: clearMouse.containsMouse ? theme.hoverFill : theme.glassFillDark
                border.width: 1
                border.color: clearMouse.containsMouse ? (theme.accentDestructive || "#FF5555") : theme.glassBorderSubtle

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }

                Text {
                    anchors.centerIn: parent
                    text: ""
                    color: clearMouse.containsMouse ? (theme.accentDestructive || "#FF5555") : theme.textMuted
                    font.pixelSize: 14
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
    }
}
