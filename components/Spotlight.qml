import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import "."

Item {
    id: root

    property bool open: false
    signal closeRequested()

    readonly property alias dialogBox: dialogBox

    visible: open
    focus: open

    Theme {
        id: theme
    }

    Process {
        id: execProc
    }

    readonly property string rawQuery: searchInput.text.trim()
    readonly property bool isCommandMode: rawQuery.startsWith(">")
    readonly property string commandText: isCommandMode ? rawQuery.slice(1).trim() : ""
    readonly property bool isWebSearchMode: rawQuery.startsWith("/")
    readonly property string webSearchText: isWebSearchMode ? rawQuery.slice(1).trim() : ""
    readonly property bool isAllAppsMode: rawQuery === "*"

    property var filteredApps: {
        if (!root.open || root.isCommandMode || root.isWebSearchMode) return []

        const allApps = (typeof DesktopEntries !== "undefined" && DesktopEntries && DesktopEntries.applications)
            ? (DesktopEntries.applications.values || DesktopEntries.applications)
            : []

        // Se digitou estritamente '*', exibe todos os aplicativos disponíveis
        if (root.isAllAppsMode) {
            const listAll = []
            for (let i = 0; i < allApps.length; i++) {
                const app = allApps[i]
                if (!app || app.noDisplay) continue
                listAll.push(app)
            }
            listAll.sort((a, b) => {
                const aName = (a.name || "").toLowerCase()
                const bName = (b.name || "").toLowerCase()
                return aName.localeCompare(bName)
            })
            return listAll
        }

        const query = root.rawQuery.toLowerCase()
        if (!query) return []

        const matched = []

        for (let i = 0; i < allApps.length; i++) {
            const app = allApps[i]
            if (!app || app.noDisplay) continue
            const name = (app.name || "").toLowerCase()
            const gen = (app.genericName || "").toLowerCase()

            if (name.includes(query) || gen.includes(query)) {
                matched.push(app)
            }
        }

        matched.sort((a, b) => {
            const aName = (a.name || "").toLowerCase()
            const bName = (b.name || "").toLowerCase()

            // 1. Exact match first
            const aExact = aName === query
            const bExact = bName === query
            if (aExact && !bExact) return -1
            if (!aExact && bExact) return 1

            // 2. Starts with query first
            const aStarts = aName.startsWith(query)
            const bStarts = bName.startsWith(query)
            if (aStarts && !bStarts) return -1
            if (!aStarts && bStarts) return 1

            // 3. Ascending length of name (shorter name first)
            if (aName.length !== bName.length) {
                return aName.length - bName.length
            }

            // 4. Alphabetical fallback
            return aName.localeCompare(bName)
        })

        return matched
    }

    readonly property int resultCount: {
        if (isCommandMode) return (commandText.length > 0 ? 1 : 0)
        if (isWebSearchMode) return (webSearchText.length > 0 ? 1 : 0)
        return filteredApps.length
    }
    readonly property bool hasExpandedView: resultCount > 0

    onOpenChanged: {
        if (open) {
            searchInput.text = ""
            resultsList.currentIndex = 0
            focusTimer.restart()
        }
    }

    Timer {
        id: focusTimer
        interval: 50
        onTriggered: {
            searchInput.forceActiveFocus()
        }
    }

    // Dismiss overlay on outside click
    MouseArea {
        anchors.fill: parent
        onClicked: root.closeRequested()
    }

    // Central Spotlight Modal Card
    Item {
        id: dialogBox
        anchors.horizontalCenter: parent.horizontalCenter
        y: Math.round(parent.height * 0.22)
        width: 640
        height: root.hasExpandedView ? Math.min(52 + 1 + root.resultCount * 52, 420) : 52

        Behavior on height {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
        }

        LiquidGlass {
            anchors.fill: parent
            radius: root.hasExpandedView ? 18 : 26
            fillColor: theme.glassFillDark
            shadowEnabled: true

            Behavior on radius {
                NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: searchInput.forceActiveFocus()
        }

        Column {
            anchors.fill: parent

            // 1. Search Bar Input Row
            Item {
                width: parent.width
                height: 52

                Row {
                    anchors {
                        left: parent.left
                        leftMargin: 18
                        right: parent.right
                        rightMargin: 18
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 12

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: {
                            if (root.isCommandMode) return ""
                            if (root.isWebSearchMode) return ""
                            if (root.isAllAppsMode) return ""
                            return ""
                        }
                        color: {
                            if (root.isCommandMode) return "#38BDF8"
                            if (root.isWebSearchMode) return "#FF7139"
                            if (root.isAllAppsMode) return "#88C0D0"
                            return theme.textSubtle
                        }
                        font.pixelSize: 18
                        renderType: Text.NativeRendering
                    }

                    TextInput {
                        id: searchInput
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 32
                        color: theme.textStrong
                        font.pixelSize: 16
                        font.weight: Font.Medium
                        clip: true
                        selectionColor: theme.hoverFill
                        renderType: TextInput.NativeRendering

                        onTextChanged: {
                            resultsList.currentIndex = 0
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: !searchInput.text
                            text: "Pesquisar aplicativos (* todos, / web, > comando)"
                            color: theme.textSubtle
                            font.pixelSize: 16
                            font.weight: Font.Normal
                            renderType: Text.NativeRendering
                        }

                        Keys.onEscapePressed: root.closeRequested()

                        Keys.onDownPressed: event => {
                            if (root.resultCount > 0) {
                                resultsList.currentIndex = Math.min(resultsList.currentIndex + 1, root.resultCount - 1)
                                resultsList.positionViewAtIndex(resultsList.currentIndex, ListView.Contain)
                            }
                            event.accepted = true
                        }

                        Keys.onUpPressed: event => {
                            if (root.resultCount > 0) {
                                resultsList.currentIndex = Math.max(resultsList.currentIndex - 1, 0)
                                resultsList.positionViewAtIndex(resultsList.currentIndex, ListView.Contain)
                            }
                            event.accepted = true
                        }

                        onAccepted: {
                            if (root.isCommandMode) {
                                if (root.commandText.length > 0) {
                                    root.executeCommand(root.commandText)
                                }
                            } else if (root.isWebSearchMode) {
                                if (root.webSearchText.length > 0) {
                                    root.executeWebSearch(root.webSearchText)
                                }
                            } else if (root.filteredApps.length > 0) {
                                const targetIdx = Math.max(0, Math.min(resultsList.currentIndex, root.filteredApps.length - 1))
                                root.filteredApps[targetIdx].execute()
                                root.closeRequested()
                            }
                        }
                    }
                }
            }

            // Divider
            Rectangle {
                width: parent.width
                height: root.hasExpandedView ? 1 : 0
                color: theme.separator
                visible: root.hasExpandedView
            }

            // 2. Results List View
            ListView {
                id: resultsList
                width: parent.width
                height: parent.height - 53
                clip: true
                visible: root.hasExpandedView
                model: {
                    if (root.isCommandMode) {
                        return root.commandText.length > 0 ? [root.commandText] : []
                    }
                    if (root.isWebSearchMode) {
                        return root.webSearchText.length > 0 ? [root.webSearchText] : []
                    }
                    return root.filteredApps
                }
                spacing: 2
                currentIndex: 0
                boundsBehavior: Flickable.StopAtBounds

                delegate: Rectangle {
                    id: delegateItem
                    required property var modelData
                    required property int index

                    width: resultsList.width - 12
                    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
                    height: 48
                    radius: theme.radiusSmall
                    color: (resultsList.currentIndex === index || rowMouse.containsMouse) ? theme.hoverFill : "transparent"

                    Behavior on color {
                        ColorAnimation { duration: 120 }
                    }

                    Row {
                        anchors {
                            left: parent.left
                            leftMargin: 12
                            right: parent.right
                            rightMargin: 12
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: 12

                        // Icon Container
                        Item {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 28
                            height: 28

                            Text {
                                anchors.centerIn: parent
                                visible: root.isCommandMode || root.isWebSearchMode || !appIcon.visible || appIcon.status !== Image.Ready
                                text: {
                                    if (root.isCommandMode) return ""
                                    if (root.isWebSearchMode) return ""
                                    return ""
                                }
                                color: {
                                    if (root.isCommandMode) return "#38BDF8"
                                    if (root.isWebSearchMode) return "#FF7139"
                                    return theme.textStrong
                                }
                                font.pixelSize: 18
                                renderType: Text.NativeRendering
                            }

                            IconImage {
                                id: appIcon
                                anchors.fill: parent
                                visible: !root.isCommandMode && (root.isWebSearchMode ? (source !== "") : (source !== "" && status === Image.Ready))
                                source: {
                                    if (root.isCommandMode) return ""
                                    if (root.isWebSearchMode) {
                                        return Quickshell.hasThemeIcon("firefox") ? Quickshell.iconPath("firefox") : ""
                                    }
                                    if (!modelData || !modelData.icon) return ""
                                    if (modelData.icon.startsWith("/") || modelData.icon.startsWith("file://") || modelData.icon.startsWith("image://")) {
                                        return modelData.icon.startsWith("/") ? ("file://" + modelData.icon) : modelData.icon
                                    }
                                    if (Quickshell.hasThemeIcon(modelData.icon)) {
                                        return Quickshell.iconPath(modelData.icon)
                                    }
                                    return ""
                                }
                            }
                        }

                        // Text Details
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 40
                            spacing: 2

                            Text {
                                text: {
                                    if (root.isCommandMode) return "Executar: " + modelData
                                    if (root.isWebSearchMode) return "Pesquisar no Firefox: " + modelData
                                    return modelData ? (modelData.name || "") : ""
                                }
                                color: theme.textStrong
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                elide: Text.ElideRight
                                width: parent.width
                                renderType: Text.NativeRendering
                            }

                            Text {
                                text: {
                                    if (root.isCommandMode) return "Abrir no terminal do sistema"
                                    if (root.isWebSearchMode) return "Abrir pesquisa no Mozilla Firefox"
                                    return (modelData && modelData.genericName ? modelData.genericName : (modelData && modelData.comment ? modelData.comment : ""))
                                }
                                visible: text !== ""
                                color: theme.textSubtle
                                font.pixelSize: 11
                                elide: Text.ElideRight
                                width: parent.width
                                renderType: Text.NativeRendering
                            }
                        }
                    }

                    MouseArea {
                        id: rowMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: resultsList.currentIndex = index
                        onClicked: {
                            if (root.isCommandMode) {
                                root.executeCommand(modelData)
                            } else if (root.isWebSearchMode) {
                                root.executeWebSearch(modelData)
                            } else {
                                modelData.execute()
                                root.closeRequested()
                            }
                        }
                    }
                }
            }
        }
    }

    function executeCommand(cmd) {
        if (!cmd) return
        const terminalBin = Quickshell.env("TERMINAL") || "kitty"
        execProc.exec([terminalBin, "--hold", "sh", "-c", cmd])
        root.closeRequested()
    }

    function executeWebSearch(query) {
        if (!query) return
        const trimmed = query.trim()
        if (!trimmed) return

        if (trimmed.startsWith("http://") || trimmed.startsWith("https://")) {
            execProc.exec(["firefox", trimmed])
        } else {
            execProc.exec(["firefox", "--search", trimmed])
        }
        root.closeRequested()
    }
}
