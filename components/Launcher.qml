import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick

PanelWindow {
    id: root

    WlrLayershell.namespace: "bulldoze-launcher"

    Theme {
        id: theme
    }

    property bool open: false
    visible: open || card.opacity > 0.001
    color: "transparent"
    focusable: true
    exclusiveZone: 0

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

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    onOpenChanged: {
        if (open) {
            search.text = ""
            appList.currentIndex = 0
            search.forceActiveFocus()
        }
    }

    function toggle() {
        open = !open
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.open = false
    }

    Rectangle {
        id: card
        width: 580
        height: 480
        anchors.centerIn: parent
        radius: theme.radiusModal
        color: theme.glassFillDark
        border.width: 0
        border.color: "transparent"

        opacity: root.open ? 1.0 : 0.0
        transform: Translate {
            y: root.open ? 0 : -10
            Behavior on y {
                NumberAnimation {
                    duration: root.open ? theme.animDurationSlow : theme.animDurationExit
                    easing.type: root.open ? Easing.OutCubic : Easing.InQuad
                }
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: root.open ? theme.animDurationSlow : theme.animDurationExit
                easing.type: root.open ? Easing.OutCubic : Easing.InQuad
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: mouse => mouse.accepted = true
        }

        Column {
            anchors.fill: parent
            anchors.margins: theme.spacingXxl
            spacing: theme.spacingLg

            // Search Header
            Row {
                width: parent.width
                height: 38
                spacing: theme.spacingMd

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: ""
                    color: theme.textSubtle
                    font.pixelSize: theme.fontSizeLg
                }

                TextInput {
                    id: search
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 32
                    color: theme.textStrong
                    font.pixelSize: theme.fontSizeTitle
                    focus: root.open
                    clip: true
                    selectionColor: theme.hoverFill

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: !search.text
                        text: "Pesquisar aplicativos..."
                        color: theme.textSubtle
                        font.pixelSize: theme.fontSizeTitle
                    }

                    onTextChanged: {
                        appList.currentIndex = 0
                    }

                    Keys.onEscapePressed: root.open = false
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
                            root.open = false
                        } else if (root.filteredApps.length > 0) {
                            root.filteredApps[0].execute()
                            root.open = false
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: theme.separator
            }

            ListView {
                id: appList
                width: parent.width
                height: parent.height - 76
                clip: true
                model: root.filteredApps
                spacing: theme.spacingXs
                currentIndex: 0
                boundsBehavior: Flickable.StopAtBounds

                delegate: Rectangle {
                    required property var modelData
                    required property int index

                    width: ListView.view.width
                    height: 48
                    radius: theme.radiusItem
                    color: (appList.currentIndex === index || appMouse.containsMouse) ? theme.hoverFill : "transparent"

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
                            width: 24
                            height: 24

                            Text {
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
                                text: modelData.name
                                color: theme.textMedium
                                font.pixelSize: theme.fontSizeLg
                                font.weight: Font.Medium
                            }

                            Text {
                                visible: modelData.genericName && modelData.genericName !== modelData.name
                                text: modelData.genericName || ""
                                color: theme.textMuted
                                font.pixelSize: theme.fontSizeXs
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
                            root.open = false
                        }
                    }
                }
            }
        }
    }
}
