import QtQuick
import Quickshell
import Quickshell.Widgets
import ".."

Item {
    id: root

    property var goBack
    property bool isActive: false

    Theme {
        id: theme
    }

    property var filteredApps: {
        const query = (typeof searchInput !== "undefined" && searchInput && searchInput.text) ? searchInput.text.toLowerCase().trim() : ""
        const apps = (typeof DesktopEntries !== "undefined" && DesktopEntries && DesktopEntries.applications) 
            ? (DesktopEntries.applications.values || DesktopEntries.applications) 
            : []
        const result = []
        if (!apps || apps.length === undefined) return result
        for (let i = 0; i < apps.length; i++) {
            const app = apps[i]
            if (!app || app.noDisplay) continue
            if (!query || (app.name && app.name.toLowerCase().includes(query)) || (app.genericName && app.genericName.toLowerCase().includes(query))) {
                result.push(app)
            }
        }
        return result
    }

    onIsActiveChanged: {
        if (isActive) {
            searchInput.text = ""
            appList.currentIndex = 0
            searchFocusTimer.restart()
        }
    }

    Timer {
        id: searchFocusTimer
        interval: 50
        onTriggered: {
            searchInput.forceActiveFocus()
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: theme.spacingLg
        spacing: theme.spacingMd

        // Top Search Header
        Row {
            width: parent.width
            height: 32
            spacing: theme.spacingMd

            // Back Button (Icon only)
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 32
                height: 32
                radius: theme.radiusSmall
                color: backMouse.containsMouse ? theme.hoverFill : "transparent"
                border.width: 1
                border.color: backMouse.containsMouse ? theme.glassBorderStrong : "transparent"
                scale: backMouse.pressed ? 0.92 : 1.0

                Behavior on color {
                    ColorAnimation { duration: theme.animDurationFast }
                }
                Behavior on border.color {
                    ColorAnimation { duration: theme.animDurationFast }
                }
                Behavior on scale {
                    NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic }
                }

                Text {
                    renderType: Text.NativeRendering
                    anchors.centerIn: parent
                    text: ""
                    color: backMouse.containsMouse ? theme.textStrong : theme.textMedium
                    font.pixelSize: theme.fontSizeMd
                }

                MouseArea {
                    id: backMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (root.goBack) root.goBack()
                }
            }

            // Search Icon
            Text {
                renderType: Text.NativeRendering
                anchors.verticalCenter: parent.verticalCenter
                text: ""
                color: theme.textSubtle
                font.pixelSize: theme.fontSizeMd
            }

            // Search Text Input
            TextInput {
                renderType: TextInput.NativeRendering
                id: searchInput
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 120
                color: theme.textStrong
                font.pixelSize: theme.fontSizeLg
                font.weight: Font.Medium
                focus: root.isActive
                clip: true
                selectionColor: theme.hoverFill

                Text {
                    renderType: Text.NativeRendering
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !searchInput.text
                    text: "Pesquisar aplicativos..."
                    color: theme.textSubtle
                    font.pixelSize: theme.fontSizeLg
                }

                onTextChanged: {
                    appList.currentIndex = 0
                }

                Keys.onEscapePressed: if (root.goBack) root.goBack()
                Keys.onDownPressed: event => {
                    if (root.filteredApps.length > 0) {
                        appList.currentIndex = Math.min(appList.currentIndex + 1, root.filteredApps.length - 1)
                        appList.positionViewAtIndex(appList.currentIndex, ListView.Contain)
                    }
                    event.accepted = true
                }
                Keys.onUpPressed: event => {
                    if (root.filteredApps.length > 0) {
                        appList.currentIndex = Math.max(appList.currentIndex - 1, 0)
                        appList.positionViewAtIndex(appList.currentIndex, ListView.Contain)
                    }
                    event.accepted = true
                }
                onAccepted: {
                    if (appList.currentIndex >= 0 && appList.currentIndex < root.filteredApps.length) {
                        root.filteredApps[appList.currentIndex].execute()
                        if (root.goBack) root.goBack()
                    } else if (root.filteredApps.length > 0) {
                        root.filteredApps[0].execute()
                        if (root.goBack) root.goBack()
                    }
                }
            }

            // ESC Hint Pill
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                height: 22
                implicitWidth: escText.implicitWidth + 12
                radius: 4
                color: theme.itemFill
                border.width: 1
                border.color: theme.glassBorderSubtle

                Text {
                    renderType: Text.NativeRendering
                    id: escText
                    anchors.centerIn: parent
                    text: "ESC"
                    color: theme.textSubtle
                    font.pixelSize: theme.fontSizeXs
                    font.weight: Font.DemiBold
                }
            }
        }

        // Separator
        Rectangle {
            width: parent.width
            height: 1
            color: theme.separator
        }

        // Applications List
        ListView {
            id: appList
            width: parent.width
            height: parent.height - 56
            clip: true
            model: root.filteredApps
            spacing: theme.spacingXs
            currentIndex: 0
            boundsBehavior: Flickable.StopAtBounds

            delegate: Rectangle {
                required property var modelData
                required property int index

                width: ListView.view.width
                height: 44
                radius: theme.radiusSmall
                color: (appList.currentIndex === index || itemMouse.containsMouse) ? theme.hoverFill : "transparent"
                border.width: 1
                border.color: (appList.currentIndex === index || itemMouse.containsMouse) ? theme.glassBorderStrong : "transparent"

                Behavior on color {
                    ColorAnimation { duration: theme.animDurationFast }
                }
                Behavior on border.color {
                    ColorAnimation { duration: theme.animDurationFast }
                }

                Row {
                    anchors {
                        left: parent.left
                        leftMargin: theme.spacingMd
                        right: parent.right
                        rightMargin: theme.spacingMd
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: theme.spacingMd

                    Item {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 24
                        height: 24

                        Text {
                            renderType: Text.NativeRendering
                            anchors.centerIn: parent
                            text: ""
                            color: theme.textStrong
                            font.pixelSize: 16
                            font.weight: Font.Bold
                            visible: !appIcon.visible || appIcon.status !== Image.Ready
                        }

                        IconImage {
                            id: appIcon
                            anchors.fill: parent
                            source: {
                                if (!modelData.icon) return ""
                                if (modelData.icon.startsWith("/") || modelData.icon.startsWith("file://") || modelData.icon.startsWith("image://")) {
                                    return modelData.icon.startsWith("/") ? ("file://" + modelData.icon) : modelData.icon
                                }
                                if (Quickshell.hasThemeIcon(modelData.icon)) {
                                    return Quickshell.iconPath(modelData.icon)
                                }
                                return ""
                            }
                            visible: source !== "" && status === Image.Ready
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Text {
                            renderType: Text.NativeRendering
                            text: modelData.name
                            color: theme.textStrong
                            font.pixelSize: theme.fontSizeMd
                            font.weight: Font.Medium
                        }

                        Text {
                            renderType: Text.NativeRendering
                            visible: modelData.genericName && modelData.genericName !== modelData.name
                            text: modelData.genericName || ""
                            color: theme.textMuted
                            font.pixelSize: theme.fontSizeXs
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: appList.currentIndex = index
                    onClicked: {
                        modelData.execute()
                        if (root.goBack) root.goBack()
                    }
                }
            }
        }
    }
}
