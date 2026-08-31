import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Effects

FocusScope {
    id: root

    property bool open: false
    property var closeLauncher
    focus: true

    Theme {
        id: theme
    }

    property var filteredApps: {
        const query = (typeof search !== "undefined" && search && search.text) ? search.text.toLowerCase().trim() : ""
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

    onOpenChanged: {
        if (open) {
            search.text = ""
            appList.currentIndex = 0
            search.forceActiveFocus()
            Qt.callLater(() => {
                if (root.open) search.forceActiveFocus()
            })
            searchFocusTimer.restart()
            searchFocusRetryTimer.restart()
        }
    }

    onVisibleChanged: {
        if (visible && open) {
            search.forceActiveFocus()
            searchFocusTimer.restart()
            searchFocusRetryTimer.restart()
        }
    }

    Component.onCompleted: {
        if (open) {
            search.forceActiveFocus()
        }
    }

    Timer {
        id: searchFocusTimer
        interval: 40
        repeat: false
        onTriggered: {
            if (root.open) {
                search.forceActiveFocus()
            }
        }
    }

    Timer {
        id: searchFocusRetryTimer
        interval: 120
        repeat: false
        onTriggered: {
            if (root.open && !search.activeFocus) {
                search.forceActiveFocus()
            }
        }
    }

    // Main Container inside Bottom Dock
    Item {
        anchors {
            fill: parent
            leftMargin: theme.notchConcaveWidth + theme.spacingLg
            rightMargin: theme.notchConcaveWidth + theme.spacingLg
            topMargin: theme.spacingXl
            bottomMargin: theme.borderThickness + theme.spacingMd
        }

        // -----------------------------------------------------------------
        // 1. TOP SECTION: RESULTS LIST (Above Search Bar)
        // -----------------------------------------------------------------
        ListView {
            id: appList
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: separatorLine.top
                bottomMargin: theme.spacingMd
            }
            clip: true
            model: root.filteredApps
            spacing: theme.spacingXs
            currentIndex: 0
            boundsBehavior: Flickable.StopAtBounds

            // Empty state label
            Item {
                anchors.fill: parent
                visible: root.filteredApps.length === 0

                Column {
                    anchors.centerIn: parent
                    spacing: theme.spacingSm

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: ""
                        color: theme.textMuted
                        font.pixelSize: 32
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: search.text ? "Nenhum aplicativo encontrado" : "Digite para buscar aplicativos..."
                        color: theme.textMuted
                        font.pixelSize: theme.fontSizeMd
                    }
                }
            }

            delegate: Rectangle {
                required property var modelData
                required property int index

                width: ListView.view.width
                height: 38
                radius: theme.radiusItem
                color: (appList.currentIndex === index || appMouse.containsMouse) ? theme.hoverFill : "transparent"
                border.width: appList.currentIndex === index ? 1 : 0
                border.color: appList.currentIndex === index ? theme.glassBorderStrong : "transparent"

                Behavior on color {
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
                        width: 22
                        height: 22

                        Text {
                            anchors.centerIn: parent
                            text: ""
                            color: theme.textStrong
                            font.pixelSize: 15
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
                        spacing: 0

                        Text {
                            text: modelData.name
                            color: appList.currentIndex === index ? theme.textStrong : theme.textMedium
                            font.pixelSize: theme.fontSizeMd
                            font.weight: appList.currentIndex === index ? Font.Bold : Font.Medium
                        }

                        Text {
                            visible: modelData.genericName && modelData.genericName !== modelData.name
                            text: modelData.genericName || ""
                            color: theme.textMuted
                            font.pixelSize: theme.fontSizeXs
                        }
                    }

                    // Right-aligned Enter hint when focused
                    Item {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: appList.currentIndex === index
                        width: 20
                        height: 20

                        Rectangle {
                            anchors.fill: parent
                            radius: theme.radiusSmall
                            color: theme.glassFillDark
                            border.width: 1
                            border.color: theme.glassBorderSubtle

                            Text {
                                anchors.centerIn: parent
                                text: "↵"
                                color: theme.textMedium
                                font.pixelSize: 11
                                font.weight: Font.Bold
                            }
                        }
                    }
                }

                MouseArea {
                    id: appMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        modelData.execute()
                        if (root.closeLauncher) root.closeLauncher()
                    }
                }
            }
        }

        // -----------------------------------------------------------------
        // 2. SEPARATOR LINE
        // -----------------------------------------------------------------
        Rectangle {
            id: separatorLine
            anchors {
                left: parent.left
                right: parent.right
                bottom: searchRow.top
                bottomMargin: theme.spacingMd
            }
            height: 1
            color: theme.separator
        }

        // -----------------------------------------------------------------
        // 3. BOTTOM SECTION: SEARCH INPUT BAR (At the Bottom Bezel)
        // -----------------------------------------------------------------
        Row {
            id: searchRow
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                bottomMargin: theme.spacingXs
            }
            height: 36
            spacing: theme.spacingMd

            // Search Icon
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: ""
                color: search.text ? theme.accent : theme.textSubtle
                font.pixelSize: theme.fontSizeMd
            }

            // Text Input
            TextInput {
                id: search
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 90
                color: theme.textStrong
                font.pixelSize: theme.fontSizeLg
                font.weight: Font.Medium
                focus: true
                clip: true
                selectionColor: theme.hoverFill

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !search.text
                    text: "Pesquisar aplicativos..."
                    color: theme.textSubtle
                    font.pixelSize: theme.fontSizeLg
                }

                onTextChanged: {
                    appList.currentIndex = 0
                }

                Keys.onEscapePressed: {
                    if (root.closeLauncher) root.closeLauncher()
                }
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
                        if (root.closeLauncher) root.closeLauncher()
                    } else if (root.filteredApps.length > 0) {
                        root.filteredApps[0].execute()
                        if (root.closeLauncher) root.closeLauncher()
                    }
                }
            }

            // ESC Badge
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 36
                height: 22
                radius: theme.radiusSmall
                color: theme.glassFillDark
                border.width: 1
                border.color: theme.glassBorderSubtle

                Text {
                    anchors.centerIn: parent
                    text: "ESC"
                    color: theme.textSubtle
                    font.pixelSize: 10
                    font.weight: Font.Bold
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (root.closeLauncher) root.closeLauncher()
                }
            }
        }
    }
}
