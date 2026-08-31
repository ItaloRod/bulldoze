import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import "../../modules"
import ".."

Item {
    id: root

    property var goBack
    property var network
    property var bluetooth
    property var gaming
    property var wallpaperEngine

    // Sidebar Category: "wifi" | "bluetooth" | "wallpaper" | "gaming"
    property string activeCategory: "wifi"
    property string activeGamingTab: "bulldoptimizer"

    Theme {
        id: theme
    }

    readonly property var net: network
    readonly property var bt: bluetooth
    readonly property var game: gaming
    readonly property var wp: wallpaperEngine

    property string selectedWifiSsid: ""
    property string wifiPasswordInput: ""
    property bool showPasswordText: false

    onVisibleChanged: {
        if (visible) {
            root.selectedWifiSsid = ""
            root.wifiPasswordInput = ""
            if (root.net && root.net.enabled) root.net.scanNetworks(true)
            if (root.bt && root.bt.enabled) root.bt.refresh()
            if (root.game) root.game.loadConfig()
            if (root.wp) {
                root.wp.loadWallpapers()
                root.wp.loadConfig()
            }
        } else {
            if (root.bt) root.bt.stopScan()
        }
    }

    onActiveCategoryChanged: {
        root.selectedWifiSsid = ""
        root.wifiPasswordInput = ""
        if (activeCategory === "wifi" && root.net && root.net.enabled) {
            root.net.scanNetworks(true)
        } else if (activeCategory === "bluetooth" && root.bt && root.bt.enabled) {
            root.bt.refresh()
        } else if (activeCategory === "wallpaper" && root.wp) {
            root.wp.loadWallpapers()
            root.wp.loadConfig()
        } else if (activeCategory === "gaming" && root.game) {
            root.game.loadConfig()
        }
    }

    // Reusable Component: Setting Pill Button
    component SettingPill: Rectangle {
        id: pill
        property string label: ""
        property bool active: false
        signal clicked()

        implicitWidth: pillText.implicitWidth + 24
        height: 28
        radius: theme.radiusSmall
        color: active ? theme.activeFill : (pMouse.containsMouse ? theme.hoverFill : theme.itemFill)
        border.width: 1
        border.color: active ? theme.glassBorderStrong : theme.glassBorderSubtle

        Behavior on color { ColorAnimation { duration: theme.animDurationFast } }

        Text {
            id: pillText
            anchors.centerIn: parent
            text: pill.label
            color: pill.active ? theme.textStrong : theme.textMedium
            font.pixelSize: theme.fontSizeXs
            font.weight: pill.active ? Font.DemiBold : Font.Medium
        }

        MouseArea {
            id: pMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: pill.clicked()
        }
    }

    // Reusable Component: Setting Toggle Row
    component SettingToggleRow: Rectangle {
        id: toggleRow
        property string iconGlyph: ""
        property string title: ""
        property string subtitle: ""
        property bool checked: false
        signal toggled()

        width: parent ? parent.width : 500
        implicitHeight: Math.max(38, contentCol.implicitHeight + 8)
        radius: theme.radiusSmall
        color: rowMouse.containsMouse ? theme.hoverFill : "transparent"

        Behavior on color { ColorAnimation { duration: theme.animDurationFast } }

        Item {
            anchors {
                left: parent.left
                leftMargin: theme.spacingSm
                right: rowSwitch.left
                rightMargin: theme.spacingSm
                verticalCenter: parent.verticalCenter
            }
            height: contentCol.implicitHeight

            Text {
                id: rowIcon
                visible: toggleRow.iconGlyph !== ""
                text: toggleRow.iconGlyph
                color: toggleRow.checked ? theme.textStrong : theme.textMuted
                font.pixelSize: theme.fontSizeMd
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
            }

            Column {
                id: contentCol
                anchors {
                    left: rowIcon.visible ? rowIcon.right : parent.left
                    leftMargin: rowIcon.visible ? theme.spacingSm : 0
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                spacing: 1

                Text {
                    width: parent.width
                    text: toggleRow.title
                    color: theme.textStrong
                    font.pixelSize: theme.fontSizeSm
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    visible: toggleRow.subtitle !== ""
                    text: toggleRow.subtitle
                    color: theme.textMuted
                    font.pixelSize: theme.fontSizeXs
                    elide: Text.ElideRight
                }
            }
        }

        Rectangle {
            id: rowSwitch
            anchors {
                right: parent.right
                rightMargin: theme.spacingSm
                verticalCenter: parent.verticalCenter
            }
            width: 36
            height: 22
            radius: 11
            color: toggleRow.checked ? theme.textStrong : theme.itemFill
            border.width: 1
            border.color: theme.glassBorderSubtle

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                x: toggleRow.checked ? parent.width - width - 2 : 2
                width: 18
                height: 18
                radius: 9
                color: toggleRow.checked ? theme.glassFillDark : theme.textMuted

                Behavior on x {
                    NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic }
                }
            }
        }

        MouseArea {
            id: rowMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: toggleRow.toggled()
        }
    }

    // Reusable Component: Section Header
    component SectionHeader: Item {
        property string title: ""
        width: parent ? parent.width : 500
        height: 22

        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: parent.title
            color: theme.textSubtle
            font.pixelSize: 11
            font.weight: Font.DemiBold
            font.capitalization: Font.AllUppercase
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: theme.spacingXxl
        spacing: theme.spacingMd

        // 1. TOP HEADER
        Row {
            width: parent.width
            height: 38
            spacing: theme.spacingMd

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: theme.spacingSm
                width: parent.width - 44

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 32
                    height: 32
                    radius: theme.radiusSmall
                    color: theme.itemFill
                    border.width: 1
                    border.color: theme.glassBorderSubtle

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        color: theme.textStrong
                        font.pixelSize: theme.fontSizeMd
                    }
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 1

                    Text {
                        text: "Ajustes do Sistema"
                        color: theme.textStrong
                        font.pixelSize: theme.fontSizeLg
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: {
                            if (root.activeCategory === "wifi") return "Rede sem fio & Conexões Wi-Fi"
                            if (root.activeCategory === "bluetooth") return "Dispositivos & Conexões Bluetooth"
                            if (root.activeCategory === "wallpaper") return "Gerenciador de Wallpapers & Visuais"
                            return "Jogos & Otimização de Performance"
                        }
                        color: theme.textMuted
                        font.pixelSize: theme.fontSizeXs
                    }
                }
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 32
                height: 32
                radius: theme.radiusSmall
                color: closeMouse.containsMouse ? theme.hoverFill : theme.itemFill
                border.width: 1
                border.color: closeMouse.containsMouse ? theme.glassBorderStrong : theme.glassBorderSubtle
                scale: closeMouse.pressed ? 0.92 : 1.0

                Behavior on color { ColorAnimation { duration: theme.animDurationFast } }
                Behavior on scale { NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic } }

                Text {
                    anchors.centerIn: parent
                    text: ""
                    color: theme.textStrong
                    font.pixelSize: theme.fontSizeSm
                }

                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (root.goBack) root.goBack()
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: theme.separator
        }

        // 2. MAIN SPLIT BODY
        Row {
            width: parent.width
            height: parent.height - 38 - 1 - theme.spacingMd * 2
            spacing: theme.spacingLg

            // SIDEBAR: (1. Wifi, 2. Bluetooth, 3. Wallpaper, 4. Gaming)
            Column {
                width: 190
                height: parent.height
                spacing: theme.spacingSm

                // 1. Wi-Fi
                Rectangle {
                    width: parent.width
                    height: 40
                    radius: theme.radiusSmall
                    color: root.activeCategory === "wifi" ? theme.activeFill : (catWifiMouse.containsMouse ? theme.hoverFill : theme.itemFill)
                    border.width: 1
                    border.color: root.activeCategory === "wifi" ? theme.glassBorderStrong : theme.glassBorderSubtle

                    Behavior on color { ColorAnimation { duration: theme.animDurationFast } }

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: theme.spacingSm
                        anchors.rightMargin: theme.spacingSm
                        spacing: theme.spacingSm

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: ""
                            color: root.activeCategory === "wifi" ? theme.textStrong : theme.textMuted
                            font.pixelSize: theme.fontSizeMd
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Rede & Wi-Fi"
                            color: root.activeCategory === "wifi" ? theme.textStrong : theme.textMedium
                            font.pixelSize: theme.fontSizeSm
                            font.weight: root.activeCategory === "wifi" ? Font.DemiBold : Font.Normal
                        }
                    }

                    MouseArea {
                        id: catWifiMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.activeCategory = "wifi"
                    }
                }

                // 2. Bluetooth
                Rectangle {
                    width: parent.width
                    height: 40
                    radius: theme.radiusSmall
                    color: root.activeCategory === "bluetooth" ? theme.activeFill : (catBtMouse.containsMouse ? theme.hoverFill : theme.itemFill)
                    border.width: 1
                    border.color: root.activeCategory === "bluetooth" ? theme.glassBorderStrong : theme.glassBorderSubtle

                    Behavior on color { ColorAnimation { duration: theme.animDurationFast } }

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: theme.spacingSm
                        anchors.rightMargin: theme.spacingSm
                        spacing: theme.spacingSm

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: ""
                            color: root.activeCategory === "bluetooth" ? theme.textStrong : theme.textMuted
                            font.pixelSize: theme.fontSizeMd
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Bluetooth"
                            color: root.activeCategory === "bluetooth" ? theme.textStrong : theme.textMedium
                            font.pixelSize: theme.fontSizeSm
                            font.weight: root.activeCategory === "bluetooth" ? Font.DemiBold : Font.Normal
                        }
                    }

                    MouseArea {
                        id: catBtMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.activeCategory = "bluetooth"
                    }
                }

                // 3. Wallpaper Handler
                Rectangle {
                    width: parent.width
                    height: 40
                    radius: theme.radiusSmall
                    color: root.activeCategory === "wallpaper" ? theme.activeFill : (catWpMouse.containsMouse ? theme.hoverFill : theme.itemFill)
                    border.width: 1
                    border.color: root.activeCategory === "wallpaper" ? theme.glassBorderStrong : theme.glassBorderSubtle

                    Behavior on color { ColorAnimation { duration: theme.animDurationFast } }

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: theme.spacingSm
                        anchors.rightMargin: theme.spacingSm
                        spacing: theme.spacingSm

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: ""
                            color: root.activeCategory === "wallpaper" ? theme.textStrong : theme.textMuted
                            font.pixelSize: theme.fontSizeMd
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Wallpapers & Efeitos"
                            color: root.activeCategory === "wallpaper" ? theme.textStrong : theme.textMedium
                            font.pixelSize: theme.fontSizeSm
                            font.weight: root.activeCategory === "wallpaper" ? Font.DemiBold : Font.Normal
                        }
                    }

                    MouseArea {
                        id: catWpMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.activeCategory = "wallpaper"
                    }
                }

                // 4. Gaming Mode
                Rectangle {
                    width: parent.width
                    height: 40
                    radius: theme.radiusSmall
                    color: root.activeCategory === "gaming" ? theme.activeFill : (catGamingMouse.containsMouse ? theme.hoverFill : theme.itemFill)
                    border.width: 1
                    border.color: root.activeCategory === "gaming" ? theme.glassBorderStrong : theme.glassBorderSubtle

                    Behavior on color { ColorAnimation { duration: theme.animDurationFast } }

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: theme.spacingSm
                        anchors.rightMargin: theme.spacingSm
                        spacing: theme.spacingSm

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: ""
                            color: root.activeCategory === "gaming" ? theme.textStrong : theme.textMuted
                            font.pixelSize: theme.fontSizeMd
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Jogos & Performance"
                            color: root.activeCategory === "gaming" ? theme.textStrong : theme.textMedium
                            font.pixelSize: theme.fontSizeSm
                            font.weight: root.activeCategory === "gaming" ? Font.DemiBold : Font.Normal
                        }
                    }

                    MouseArea {
                        id: catGamingMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.activeCategory = "gaming"
                    }
                }
            }

            Rectangle {
                width: 1
                height: parent.height
                color: theme.separator
            }

            // CONTENT CONTAINER
            Item {
                width: parent.width - 190 - 1 - theme.spacingLg * 2
                height: parent.height

                // =============================================================
                // TAB CONTENT 1: WI-FI SETTINGS
                // =============================================================
                Column {
                    anchors.fill: parent
                    visible: root.activeCategory === "wifi"
                    spacing: theme.spacingMd

                    Rectangle {
                        width: parent.width
                        height: 52
                        radius: theme.radiusItem
                        color: theme.itemFill
                        border.width: 1
                        border.color: theme.glassBorderSubtle

                        Item {
                            anchors.fill: parent
                            anchors.leftMargin: theme.spacingMd
                            anchors.rightMargin: theme.spacingMd

                            Row {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: theme.spacingMd

                                Text {
                                    text: ""
                                    color: root.net && root.net.enabled ? theme.textStrong : theme.textMuted
                                    font.pixelSize: theme.iconSizeLg
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    width: 320
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 1

                                    Text {
                                        text: root.net && root.net.enabled ? "Wi-Fi Habilitado" : "Wi-Fi Desativado"
                                        color: theme.textStrong
                                        font.pixelSize: theme.fontSizeSm
                                        font.weight: Font.DemiBold
                                    }

                                    Text {
                                        text: root.net && root.net.available ? (root.net.ssid ? ("Conectado em " + root.net.ssid + (root.net.currentIp ? " (" + root.net.currentIp + ")" : "")) : "Procurando redes...") : "Sem conexão ativa"
                                        color: theme.textMuted
                                        font.pixelSize: theme.fontSizeXs
                                        elide: Text.ElideRight
                                    }
                                }
                            }

                            Row {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: theme.spacingSm

                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 32
                                    height: 32
                                    radius: theme.radiusSmall
                                    color: scanBtnMouse.containsMouse ? theme.hoverFill : "transparent"
                                    border.width: 1
                                    border.color: scanBtnMouse.containsMouse ? theme.glassBorderStrong : "transparent"
                                    visible: Boolean(root.net && root.net.enabled)

                                    Text {
                                        anchors.centerIn: parent
                                        text: ""
                                        color: root.net && root.net.isScanning ? theme.accent : theme.textMedium
                                        font.pixelSize: theme.iconSizeSm
                                    }

                                    MouseArea {
                                        id: scanBtnMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: if (root.net) root.net.scanNetworks(true)
                                    }
                                }

                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 38
                                    height: 22
                                    radius: 11
                                    color: root.net && root.net.enabled ? theme.textStrong : theme.glassFillDark
                                    border.width: 1
                                    border.color: theme.glassBorderSubtle

                                    Rectangle {
                                        anchors.verticalCenter: parent.verticalCenter
                                        x: root.net && root.net.enabled ? parent.width - width - 2 : 2
                                        width: 18
                                        height: 18
                                        radius: 9
                                        color: root.net && root.net.enabled ? theme.glassFillDark : theme.textMuted

                                        Behavior on x {
                                            NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic }
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: if (root.net) root.net.toggle()
                                    }
                                }
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        height: parent.height - 52 - theme.spacingMd
                        spacing: theme.spacingSm
                        visible: Boolean(root.net && root.net.enabled)

                        SectionHeader { title: "Redes Disponíveis" }

                        Flickable {
                            width: parent.width
                            height: parent.height - 22 - theme.spacingSm
                            contentWidth: width
                            contentHeight: wifiListCol.implicitHeight + 20
                            clip: true
                            boundsBehavior: Flickable.StopAtBounds

                            Column {
                                id: wifiListCol
                                width: parent.width
                                spacing: 6

                                Repeater {
                                    model: root.net ? root.net.availableNetworks : []

                                    delegate: Rectangle {
                                        required property var modelData
                                        width: wifiListCol.width
                                        implicitHeight: isPasswordExpanded ? 96 : 46
                                        radius: theme.radiusSmall
                                        color: modelData.inUse ? theme.activeFill : (wifiItemMouse.containsMouse ? theme.hoverFill : theme.itemFill)
                                        border.width: modelData.inUse ? 2 : 1
                                        border.color: modelData.inUse ? theme.glassBorderStrong : theme.glassBorderSubtle

                                        readonly property bool isPasswordExpanded: root.selectedWifiSsid === modelData.ssid

                                        Behavior on implicitHeight {
                                            NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic }
                                        }

                                        Column {
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            spacing: 6

                                            Item {
                                                width: parent.width
                                                height: 30

                                                Row {
                                                    anchors.left: parent.left
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    spacing: theme.spacingSm

                                                    Text {
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        text: ""
                                                        color: modelData.inUse ? theme.textStrong : theme.textMedium
                                                        font.pixelSize: theme.fontSizeSm
                                                    }

                                                    Column {
                                                        width: 320
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        spacing: 1

                                                        Row {
                                                            spacing: 6
                                                            Text {
                                                                text: modelData.ssid
                                                                color: theme.textStrong
                                                                font.pixelSize: theme.fontSizeSm
                                                                font.weight: modelData.inUse ? Font.Bold : Font.Medium
                                                                elide: Text.ElideRight
                                                            }
                                                            Text {
                                                                visible: modelData.security && !modelData.security.includes("open")
                                                                text: ""
                                                                color: theme.textSubtle
                                                                font.pixelSize: 10
                                                                anchors.verticalCenter: parent.verticalCenter
                                                            }
                                                        }

                                                        Text {
                                                            text: modelData.inUse ? "Conectado • Sinal: " + modelData.signal + "%" : "Sinal: " + modelData.signal + "% • " + (modelData.security || "Aberta")
                                                            color: theme.textMuted
                                                            font.pixelSize: theme.fontSizeXs
                                                        }
                                                    }
                                                }

                                                Rectangle {
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    anchors.right: parent.right
                                                    width: modelData.inUse ? 90 : 76
                                                    height: 28
                                                    radius: theme.radiusSmall
                                                    color: btnWifiMouse.containsMouse ? theme.hoverFill : theme.itemFill
                                                    border.width: 1
                                                    border.color: theme.glassBorderStrong

                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: modelData.inUse ? "Desconectar" : "Conectar"
                                                        color: theme.textStrong
                                                        font.pixelSize: theme.fontSizeXs
                                                        font.weight: Font.DemiBold
                                                    }

                                                    MouseArea {
                                                        id: btnWifiMouse
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: {
                                                            if (modelData.inUse) {
                                                                root.net.disconnectCurrent()
                                                            } else if (modelData.security && !modelData.security.toLowerCase().includes("open") && !modelData.security.includes("--")) {
                                                                if (root.selectedWifiSsid === modelData.ssid) {
                                                                    root.selectedWifiSsid = ""
                                                                } else {
                                                                    root.selectedWifiSsid = modelData.ssid
                                                                    root.wifiPasswordInput = ""
                                                                }
                                                            } else {
                                                                root.net.connectToNetwork(modelData.ssid, "")
                                                            }
                                                        }
                                                    }
                                                }
                                            }

                                            Row {
                                                width: parent.width
                                                height: 34
                                                visible: isPasswordExpanded
                                                spacing: theme.spacingSm

                                                Rectangle {
                                                    width: parent.width - 150
                                                    height: 32
                                                    radius: theme.radiusSmall
                                                    color: theme.glassFillDark
                                                    border.width: 1
                                                    border.color: pwdInput.activeFocus ? theme.glassBorderStrong : theme.glassBorderSubtle

                                                    Row {
                                                        anchors.fill: parent
                                                        anchors.leftMargin: 8
                                                        anchors.rightMargin: 8
                                                        spacing: 6

                                                        TextInput {
                                                            id: pwdInput
                                                            anchors.verticalCenter: parent.verticalCenter
                                                            width: parent.width - 28
                                                            color: theme.textStrong
                                                            font.pixelSize: theme.fontSizeSm
                                                            echoMode: root.showPasswordText ? TextInput.Normal : TextInput.Password
                                                            clip: true

                                                            Text {
                                                                anchors.fill: parent
                                                                text: "Senha da rede..."
                                                                color: theme.textSubtle
                                                                font.pixelSize: theme.fontSizeSm
                                                                visible: !pwdInput.text && !pwdInput.activeFocus
                                                            }

                                                            onTextChanged: root.wifiPasswordInput = text
                                                            onAccepted: {
                                                                root.net.connectToNetwork(modelData.ssid, pwdInput.text)
                                                                root.selectedWifiSsid = ""
                                                            }
                                                        }

                                                        Text {
                                                            anchors.verticalCenter: parent.verticalCenter
                                                            text: root.showPasswordText ? "" : ""
                                                            color: theme.textMuted
                                                            font.pixelSize: theme.fontSizeXs
                                                            MouseArea {
                                                                anchors.fill: parent
                                                                cursorShape: Qt.PointingHandCursor
                                                                onClicked: root.showPasswordText = !root.showPasswordText
                                                            }
                                                        }
                                                    }
                                                }

                                                Rectangle {
                                                    width: 64
                                                    height: 32
                                                    radius: theme.radiusSmall
                                                    color: submitPwdMouse.containsMouse ? theme.activeFill : theme.itemFill
                                                    border.width: 1
                                                    border.color: theme.glassBorderStrong

                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: "OK"
                                                        color: theme.textStrong
                                                        font.pixelSize: theme.fontSizeXs
                                                        font.weight: Font.Bold
                                                    }

                                                    MouseArea {
                                                        id: submitPwdMouse
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: {
                                                            root.net.connectToNetwork(modelData.ssid, pwdInput.text)
                                                            root.selectedWifiSsid = ""
                                                        }
                                                    }
                                                }

                                                Rectangle {
                                                    width: 64
                                                    height: 32
                                                    radius: theme.radiusSmall
                                                    color: theme.itemFill
                                                    border.width: 1
                                                    border.color: theme.glassBorderSubtle

                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: "Cancelar"
                                                        color: theme.textMuted
                                                        font.pixelSize: theme.fontSizeXs
                                                    }

                                                    MouseArea {
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: root.selectedWifiSsid = ""
                                                    }
                                                }
                                            }
                                        }

                                        MouseArea {
                                            id: wifiItemMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            z: -1
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // =============================================================
                // TAB CONTENT 2: BLUETOOTH SETTINGS
                // =============================================================
                Column {
                    anchors.fill: parent
                    visible: root.activeCategory === "bluetooth"
                    spacing: theme.spacingMd

                    Rectangle {
                        width: parent.width
                        height: 52
                        radius: theme.radiusItem
                        color: theme.itemFill
                        border.width: 1
                        border.color: theme.glassBorderSubtle

                        Item {
                            anchors.fill: parent
                            anchors.leftMargin: theme.spacingMd
                            anchors.rightMargin: theme.spacingMd

                            Row {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: theme.spacingMd

                                Text {
                                    text: ""
                                    color: root.bt && root.bt.enabled ? theme.textStrong : theme.textMuted
                                    font.pixelSize: theme.iconSizeLg
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    width: 320
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 1

                                    Text {
                                        text: root.bt && root.bt.enabled ? "Bluetooth Habilitado" : "Bluetooth Desativado"
                                        color: theme.textStrong
                                        font.pixelSize: theme.fontSizeSm
                                        font.weight: Font.DemiBold
                                    }

                                    Text {
                                        text: root.bt && root.bt.hasConnectedDevices ? (root.bt.connectedDevices.join(", ")) : (root.bt && root.bt.enabled ? "Pronto para parear novos dispositivos" : "Adaptador desligado")
                                        color: theme.textMuted
                                        font.pixelSize: theme.fontSizeXs
                                        elide: Text.ElideRight
                                    }
                                }
                            }

                            Row {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: theme.spacingSm

                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 32
                                    height: 32
                                    radius: theme.radiusSmall
                                    color: btScanBtnMouse.containsMouse ? theme.hoverFill : "transparent"
                                    border.width: 1
                                    border.color: btScanBtnMouse.containsMouse ? theme.glassBorderStrong : "transparent"
                                    visible: Boolean(root.bt && root.bt.enabled)

                                    Text {
                                        anchors.centerIn: parent
                                        text: ""
                                        color: root.bt && root.bt.isScanning ? theme.accent : theme.textMedium
                                        font.pixelSize: theme.iconSizeSm
                                    }

                                    MouseArea {
                                        id: btScanBtnMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (root.bt) {
                                                if (root.bt.isScanning) root.bt.stopScan()
                                                else root.bt.startScan()
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 38
                                    height: 22
                                    radius: 11
                                    color: root.bt && root.bt.enabled ? theme.textStrong : theme.glassFillDark
                                    border.width: 1
                                    border.color: theme.glassBorderSubtle

                                    Rectangle {
                                        anchors.verticalCenter: parent.verticalCenter
                                        x: root.bt && root.bt.enabled ? parent.width - width - 2 : 2
                                        width: 18
                                        height: 18
                                        radius: 9
                                        color: root.bt && root.bt.enabled ? theme.glassFillDark : theme.textMuted

                                        Behavior on x {
                                            NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic }
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: if (root.bt) root.bt.toggle()
                                    }
                                }
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        height: parent.height - 52 - theme.spacingMd
                        spacing: theme.spacingSm
                        visible: Boolean(root.bt && root.bt.enabled)

                        Flickable {
                            width: parent.width
                            height: parent.height
                            contentWidth: width
                            contentHeight: btContentCol.implicitHeight + 20
                            clip: true
                            boundsBehavior: Flickable.StopAtBounds

                            Column {
                                id: btContentCol
                                width: parent.width
                                spacing: theme.spacingSm

                                SectionHeader { title: "Dispositivos Pareados" }

                                Repeater {
                                    model: root.bt ? root.bt.pairedDevices : []

                                    delegate: Rectangle {
                                        required property var modelData
                                        width: btContentCol.width
                                        height: 46
                                        radius: theme.radiusSmall
                                        color: modelData.connected ? theme.activeFill : (btItemMouse.containsMouse ? theme.hoverFill : theme.itemFill)
                                        border.width: modelData.connected ? 2 : 1
                                        border.color: modelData.connected ? theme.glassBorderStrong : theme.glassBorderSubtle

                                        Item {
                                            anchors.fill: parent
                                            anchors.leftMargin: 12
                                            anchors.rightMargin: 12

                                            Row {
                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter
                                                spacing: theme.spacingSm

                                                Text {
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    text: modelData.icon || ""
                                                    color: modelData.connected ? theme.textStrong : theme.textMedium
                                                    font.pixelSize: theme.iconSizeMd
                                                }

                                                Column {
                                                    width: 320
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    spacing: 1

                                                    Text {
                                                        text: modelData.name || modelData.mac
                                                        color: theme.textStrong
                                                        font.pixelSize: theme.fontSizeSm
                                                        font.weight: modelData.connected ? Font.Bold : Font.Medium
                                                        elide: Text.ElideRight
                                                    }

                                                    Text {
                                                        text: modelData.connected ? "Conectado" : "Desconectado"
                                                        color: modelData.connected ? theme.textStrong : theme.textMuted
                                                        font.pixelSize: theme.fontSizeXs
                                                    }
                                                }
                                            }

                                            Row {
                                                anchors.right: parent.right
                                                anchors.verticalCenter: parent.verticalCenter
                                                spacing: 6

                                                Rectangle {
                                                    width: modelData.connected ? 90 : 76
                                                    height: 28
                                                    radius: theme.radiusSmall
                                                    color: connBtnMouse.containsMouse ? theme.hoverFill : theme.itemFill
                                                    border.width: 1
                                                    border.color: theme.glassBorderStrong

                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: modelData.connected ? "Desconectar" : "Conectar"
                                                        color: theme.textStrong
                                                        font.pixelSize: theme.fontSizeXs
                                                        font.weight: Font.DemiBold
                                                    }

                                                    MouseArea {
                                                        id: connBtnMouse
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: {
                                                            if (modelData.connected) root.bt.disconnectDevice(modelData.mac)
                                                            else root.bt.connectDevice(modelData.mac)
                                                        }
                                                    }
                                                }

                                                Rectangle {
                                                    width: 28
                                                    height: 28
                                                    radius: theme.radiusSmall
                                                    color: rmBtnMouse.containsMouse ? theme.hoverFill : "transparent"
                                                    border.width: 1
                                                    border.color: rmBtnMouse.containsMouse ? theme.glassBorderStrong : "transparent"

                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: ""
                                                        color: rmBtnMouse.containsMouse ? theme.textStrong : theme.textSubtle
                                                        font.pixelSize: theme.fontSizeXs
                                                    }

                                                    MouseArea {
                                                        id: rmBtnMouse
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: root.bt.removeDevice(modelData.mac)
                                                    }
                                                }
                                            }
                                        }

                                        MouseArea {
                                            id: btItemMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            z: -1
                                        }
                                    }
                                }

                                Text {
                                    visible: !root.bt || root.bt.pairedDevices.length === 0
                                    text: "Nenhum dispositivo Bluetooth pareado."
                                    color: theme.textMuted
                                    font.pixelSize: theme.fontSizeXs
                                    topPadding: 4
                                    bottomPadding: 4
                                }

                                Item { width: parent.width; height: 8 }

                                SectionHeader { title: "Dispositivos Disponíveis" }

                                Repeater {
                                    model: root.bt ? root.bt.discoveredDevices : []

                                    delegate: Rectangle {
                                        required property var modelData
                                        width: btContentCol.width
                                        height: 44
                                        radius: theme.radiusSmall
                                        color: discMouse.containsMouse ? theme.hoverFill : theme.itemFill
                                        border.width: 1
                                        border.color: theme.glassBorderSubtle

                                        Item {
                                            anchors.fill: parent
                                            anchors.leftMargin: 12
                                            anchors.rightMargin: 12

                                            Row {
                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter
                                                spacing: theme.spacingSm

                                                Text {
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    text: modelData.icon || ""
                                                    color: theme.textMedium
                                                    font.pixelSize: theme.iconSizeMd
                                                }

                                                Column {
                                                    width: 320
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    spacing: 1

                                                    Text {
                                                        text: modelData.name || modelData.mac
                                                        color: theme.textStrong
                                                        font.pixelSize: theme.fontSizeSm
                                                        font.weight: Font.Medium
                                                        elide: Text.ElideRight
                                                    }

                                                    Text {
                                                        text: modelData.mac
                                                        color: theme.textMuted
                                                        font.pixelSize: theme.fontSizeXs
                                                    }
                                                }
                                            }

                                            Rectangle {
                                                anchors.right: parent.right
                                                anchors.verticalCenter: parent.verticalCenter
                                                width: 72
                                                height: 28
                                                radius: theme.radiusSmall
                                                color: pairBtnMouse.containsMouse ? theme.activeFill : theme.itemFill
                                                border.width: 1
                                                border.color: theme.glassBorderStrong

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "Parear"
                                                    color: theme.textStrong
                                                    font.pixelSize: theme.fontSizeXs
                                                    font.weight: Font.DemiBold
                                                }

                                                MouseArea {
                                                    id: pairBtnMouse
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: root.bt.pairDevice(modelData.mac)
                                                }
                                            }
                                        }

                                        MouseArea {
                                            id: discMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            z: -1
                                        }
                                    }
                                }

                                Text {
                                    visible: Boolean(root.bt && root.bt.isScanning && root.bt.discoveredDevices.length === 0)
                                    text: "Escaneando dispositivos próximos..."
                                    color: theme.textMuted
                                    font.pixelSize: theme.fontSizeXs
                                    topPadding: 4
                                }
                            }
                        }
                    }
                }

                // =============================================================
                // TAB CONTENT 3: WALLPAPER HANDLER
                // =============================================================
                Row {
                    anchors.fill: parent
                    visible: root.activeCategory === "wallpaper"
                    spacing: theme.spacingMd

                    Column {
                        width: Math.round((parent.width - theme.spacingMd) * 0.52)
                        height: parent.height
                        spacing: theme.spacingSm

                        Rectangle {
                            width: parent.width
                            height: 34
                            radius: theme.radiusItem
                            color: theme.itemFill
                            border.width: 1
                            border.color: wpSearchField.activeFocus ? theme.glassBorderStrong : theme.glassBorderSubtle

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: theme.spacingMd
                                anchors.rightMargin: theme.spacingMd
                                spacing: theme.spacingSm

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: ""
                                    color: theme.textSubtle
                                    font.pixelSize: theme.fontSizeSm
                                }

                                TextInput {
                                    id: wpSearchField
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - 30
                                    color: theme.textStrong
                                    font.pixelSize: theme.fontSizeSm
                                    clip: true

                                    Text {
                                        anchors.fill: parent
                                        text: "Pesquisar wallpaper..."
                                        color: theme.textSubtle
                                        font.pixelSize: theme.fontSizeSm
                                        visible: !wpSearchField.text && !wpSearchField.activeFocus
                                    }

                                    Keys.onEscapePressed: if (root.goBack) root.goBack()
                                }
                            }
                        }

                        GridView {
                            id: wpGalleryGrid
                            width: parent.width
                            height: parent.height - 34 - theme.spacingSm
                            cellWidth: Math.floor(wpGalleryGrid.width / 2)
                            cellHeight: 140
                            clip: true
                            boundsBehavior: Flickable.StopAtBounds

                            model: {
                                if (!root.wp || !root.wp.wallpapers) return []
                                const q = wpSearchField.text.toLowerCase().trim()
                                if (!q) return root.wp.wallpapers
                                return root.wp.wallpapers.filter(w => {
                                    return (w.title && w.title.toLowerCase().includes(q)) ||
                                           (w.id && w.id.includes(q)) ||
                                           (w.tags && w.tags.some(t => t.toLowerCase().includes(q)))
                                })
                            }

                            delegate: Item {
                                width: wpGalleryGrid.cellWidth
                                height: wpGalleryGrid.cellHeight

                                readonly property var itemData: modelData
                                readonly property bool isSelected: root.wp && root.wp.selectedId === itemData.id
                                readonly property bool isActive: root.wp && root.wp.activeId === itemData.id

                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: 4
                                    radius: theme.radiusItem
                                    color: isSelected ? theme.activeFill : (wpCardMouse.containsMouse ? theme.hoverFill : theme.itemFill)
                                    border.width: isSelected ? 2 : 1
                                    border.color: isSelected ? theme.glassBorderStrong : theme.glassBorderSubtle

                                    Behavior on color { ColorAnimation { duration: theme.animDurationFast } }

                                    Column {
                                        anchors.fill: parent
                                        anchors.margins: 5
                                        spacing: 4

                                        Item {
                                            width: parent.width
                                            height: 84

                                            Image {
                                                id: thumbImg
                                                anchors.fill: parent
                                                fillMode: Image.PreserveAspectCrop
                                                source: itemData.preview ? ("file://" + itemData.preview) : ""
                                                asynchronous: true
                                                visible: status === Image.Ready
                                                layer.enabled: true
                                                layer.effect: MultiEffect {
                                                    maskEnabled: true
                                                    maskSource: thumbMask
                                                }
                                            }

                                            Rectangle {
                                                anchors.fill: parent
                                                radius: theme.radiusSmall
                                                color: theme.glassFillDark
                                                visible: !thumbImg.visible
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: ""
                                                    color: theme.textSubtle
                                                    font.pixelSize: 20
                                                }
                                            }

                                            Item {
                                                id: thumbMask
                                                anchors.fill: parent
                                                visible: false
                                                layer.enabled: true
                                                Rectangle {
                                                    anchors.fill: parent
                                                    radius: theme.radiusSmall
                                                    color: "black"
                                                }
                                            }

                                            Rectangle {
                                                visible: isActive
                                                anchors.top: parent.top
                                                anchors.left: parent.left
                                                anchors.margins: 3
                                                height: 16
                                                width: 54
                                                radius: 4
                                                color: theme.glassFillDark
                                                border.width: 1
                                                border.color: theme.glassBorderStrong

                                                Row {
                                                    anchors.centerIn: parent
                                                    spacing: 2
                                                    Text { text: ""; color: theme.textStrong; font.pixelSize: 8 }
                                                    Text { text: "ATIVO"; color: theme.textStrong; font.pixelSize: 8; font.weight: Font.Bold }
                                                }
                                            }
                                        }

                                        Text {
                                            width: parent.width
                                            text: itemData.title || itemData.id
                                            color: isSelected ? theme.textStrong : theme.textMedium
                                            font.pixelSize: theme.fontSizeXs
                                            font.weight: isSelected ? Font.DemiBold : Font.Medium
                                            elide: Text.ElideRight
                                        }
                                    }

                                    MouseArea {
                                        id: wpCardMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (root.wp) root.wp.selectWallpaper(itemData.id)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: Math.round((parent.width - theme.spacingMd) * 0.48)
                        height: parent.height
                        radius: theme.radiusItem
                        color: theme.itemFill
                        border.width: 1
                        border.color: theme.glassBorderSubtle

                        Column {
                            anchors.fill: parent
                            anchors.margins: theme.spacingMd
                            spacing: theme.spacingSm

                            Row {
                                width: parent.width
                                height: 44
                                spacing: theme.spacingSm

                                Item {
                                    width: 52
                                    height: 40
                                    anchors.verticalCenter: parent.verticalCenter

                                    Image {
                                        id: selPreview
                                        anchors.fill: parent
                                        fillMode: Image.PreserveAspectCrop
                                        source: (root.wp && root.wp.selectedWallpaper && root.wp.selectedWallpaper.preview) ? ("file://" + root.wp.selectedWallpaper.preview) : ""
                                        visible: status === Image.Ready
                                        layer.enabled: true
                                        layer.effect: MultiEffect {
                                            maskEnabled: true
                                            maskSource: selMask
                                        }
                                    }

                                    Item {
                                        id: selMask
                                        anchors.fill: parent
                                        visible: false
                                        layer.enabled: true
                                        Rectangle {
                                            anchors.fill: parent
                                            radius: theme.radiusSmall
                                            color: "black"
                                        }
                                    }
                                }

                                Column {
                                    width: parent.width - 60
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2

                                    Text {
                                        width: parent.width
                                        text: (root.wp && root.wp.selectedWallpaper) ? root.wp.selectedWallpaper.title : "Nenhum selecionado"
                                        color: theme.textStrong
                                        font.pixelSize: theme.fontSizeSm
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        width: parent.width
                                        text: (root.wp && root.wp.selectedWallpaper) ? ("ID: " + root.wp.selectedWallpaper.id) : ""
                                        color: theme.textMuted
                                        font.pixelSize: theme.fontSizeXs
                                        elide: Text.ElideRight
                                    }
                                }
                            }

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: theme.separator
                            }

                            Flickable {
                                width: parent.width
                                height: parent.height - 44 - 1 - 38 - theme.spacingSm * 3
                                contentWidth: width
                                contentHeight: wpSettingsCol.implicitHeight
                                clip: true
                                boundsBehavior: Flickable.StopAtBounds

                                Column {
                                    id: wpSettingsCol
                                    width: parent.width - 4
                                    spacing: theme.spacingMd

                                    Column {
                                        width: parent.width
                                        spacing: 4

                                        SectionHeader { title: "Proporção e Enquadramento" }

                                        Row {
                                            width: parent.width
                                            spacing: 6

                                            SettingPill {
                                                width: Math.floor((parent.width - 12) / 3)
                                                label: "Preencher (16:9)"
                                                active: root.wp && root.wp.scaling === "fill"
                                                onClicked: root.wp.setScalingMode("fill")
                                            }

                                            SettingPill {
                                                width: Math.floor((parent.width - 12) / 3)
                                                label: "Adaptar"
                                                active: root.wp && root.wp.scaling === "fit"
                                                onClicked: root.wp.setScalingMode("fit")
                                            }

                                            SettingPill {
                                                width: Math.floor((parent.width - 12) / 3)
                                                label: "Esticar"
                                                active: root.wp && root.wp.scaling === "stretch"
                                                onClicked: root.wp.setScalingMode("stretch")
                                            }
                                        }
                                    }

                                    Column {
                                        width: parent.width
                                        spacing: 4

                                        SectionHeader { title: "Camadas & Patrocínio" }

                                        SettingToggleRow {
                                            title: "Ocultar Patrocinador / Sponsor"
                                            subtitle: "Desativa QR Codes e marcas na tela"
                                            iconGlyph: ""
                                            checked: root.wp ? root.wp.hideSponsor : true
                                            onToggled: if (root.wp) root.wp.setHideSponsor(!root.wp.hideSponsor)
                                        }
                                    }

                                    Column {
                                        width: parent.width
                                        spacing: 4
                                        visible: wpDynamicPropsRepeater.count > 0

                                        SectionHeader { title: "Propriedades da Cena" }

                                        Repeater {
                                            id: wpDynamicPropsRepeater
                                            model: {
                                                if (!root.wp || !root.wp.selectedWallpaper || !root.wp.selectedWallpaper.properties) return []
                                                return root.wp.selectedWallpaper.properties.filter(p => {
                                                    const k = p.key.toLowerCase()
                                                    return k !== "schemecolor" && k !== "sponsorme" && k !== "sponsorinfo"
                                                })
                                            }

                                            delegate: Item {
                                                width: parent.width
                                                height: modelData.type === "bool" ? 38 : (modelData.type === "slider" ? 54 : 38)
                                                readonly property var propData: modelData

                                                Loader {
                                                    anchors.fill: parent
                                                    active: propData.type === "bool"
                                                    sourceComponent: SettingToggleRow {
                                                        title: propData.text || propData.key
                                                        subtitle: "Controle de shader da cena"
                                                        checked: {
                                                            const userVal = root.wp.getWallpaperPropertyValue(root.wp.selectedId, propData.key, propData.value)
                                                            return userVal === 1 || userVal === true || userVal === "1"
                                                        }
                                                        onToggled: {
                                                            const current = root.wp.getWallpaperPropertyValue(root.wp.selectedId, propData.key, propData.value)
                                                            const isChecked = (current === 1 || current === true || current === "1")
                                                            root.wp.setWallpaperProperty(root.wp.selectedId, propData.key, !isChecked ? 1 : 0)
                                                        }
                                                    }
                                                }

                                                Loader {
                                                    anchors.fill: parent
                                                    active: propData.type === "slider"
                                                    sourceComponent: Column {
                                                        anchors.fill: parent
                                                        spacing: 2

                                                        Item {
                                                            width: parent.width
                                                            height: 18
                                                            Text {
                                                                anchors.left: parent.left
                                                                anchors.verticalCenter: parent.verticalCenter
                                                                text: propData.text || propData.key
                                                                color: theme.textStrong
                                                                font.pixelSize: theme.fontSizeSm
                                                                font.weight: Font.Medium
                                                            }
                                                            Text {
                                                                anchors.right: parent.right
                                                                anchors.verticalCenter: parent.verticalCenter
                                                                text: Number(sliderMouse.currentVal).toFixed(2)
                                                                color: theme.textMuted
                                                                font.pixelSize: theme.fontSizeXs
                                                            }
                                                        }

                                                        Rectangle {
                                                            id: sliderTrack
                                                            width: parent.width
                                                            height: 20
                                                            radius: 10
                                                            color: theme.itemFill
                                                            border.width: 1
                                                            border.color: theme.glassBorderSubtle

                                                            readonly property real val: {
                                                                const uv = root.wp.getWallpaperPropertyValue(root.wp.selectedId, propData.key, propData.value)
                                                                return typeof uv === "number" ? uv : (parseFloat(uv) || propData.min)
                                                            }

                                                            Rectangle {
                                                                anchors.left: parent.left
                                                                anchors.top: parent.top
                                                                anchors.bottom: parent.bottom
                                                                width: Math.max(10, Math.min(parent.width, (sliderMouse.currentVal - propData.min) / (propData.max - propData.min || 1) * parent.width))
                                                                radius: 10
                                                                color: theme.activeFill
                                                            }

                                                            MouseArea {
                                                                id: sliderMouse
                                                                anchors.fill: parent
                                                                hoverEnabled: true
                                                                cursorShape: Qt.PointingHandCursor
                                                                property real currentVal: sliderTrack.val

                                                                function updateFromX(mx) {
                                                                    const ratio = Math.max(0, Math.min(1, mx / width))
                                                                    const newVal = propData.min + ratio * (propData.max - propData.min)
                                                                    currentVal = newVal
                                                                    root.wp.setWallpaperProperty(root.wp.selectedId, propData.key, newVal)
                                                                }

                                                                onPressed: mouse => updateFromX(mouse.x)
                                                                onPositionChanged: mouse => {
                                                                    if (pressed) updateFromX(mouse.x)
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    Column {
                                        width: parent.width
                                        spacing: 4

                                        SectionHeader { title: "Desempenho e Áudio" }

                                        Row {
                                            width: parent.width
                                            spacing: 6

                                            SettingPill {
                                                width: Math.floor((parent.width - 12) / 3)
                                                label: "60 FPS"
                                                active: root.wp && root.wp.fps === 60
                                                onClicked: root.wp.setFps(60)
                                            }

                                            SettingPill {
                                                width: Math.floor((parent.width - 12) / 3)
                                                label: "120 FPS"
                                                active: root.wp && root.wp.fps === 120
                                                onClicked: root.wp.setFps(120)
                                            }

                                            SettingPill {
                                                width: Math.floor((parent.width - 12) / 3)
                                                label: "240 FPS"
                                                active: root.wp && root.wp.fps === 240
                                                onClicked: root.wp.setFps(240)
                                            }
                                        }

                                        SettingToggleRow {
                                            title: "Pausar com Janelas no Workspace"
                                            subtitle: "Economiza GPU quando janelas estiverem visíveis"
                                            iconGlyph: "⏸"
                                            checked: root.wp && root.wp.pauseOnWindow
                                            onToggled: root.wp.setPauseOnWindow(!root.wp.pauseOnWindow)
                                        }

                                        SettingToggleRow {
                                            title: "Interatividade de Mouse"
                                            subtitle: "Permite efeitos dinâmicos ao passar o cursor"
                                            iconGlyph: ""
                                            checked: root.wp && root.wp.mouseEnabled
                                            onToggled: root.wp.setMouseEnabled(!root.wp.mouseEnabled)
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                width: parent.width
                                height: 38
                                radius: theme.radiusItem
                                color: applyBtnMouse.containsMouse ? theme.activeFill : theme.itemFill
                                border.width: 1
                                border.color: theme.glassBorderStrong

                                Behavior on color { ColorAnimation { duration: theme.animDurationFast } }

                                Row {
                                    anchors.centerIn: parent
                                    spacing: theme.spacingSm

                                    Text {
                                        text: ""
                                        color: theme.textStrong
                                        font.pixelSize: theme.fontSizeSm
                                    }

                                    Text {
                                        text: "Aplicar Wallpaper Agora"
                                        color: theme.textStrong
                                        font.pixelSize: theme.fontSizeSm
                                        font.weight: Font.DemiBold
                                    }
                                }

                                MouseArea {
                                    id: applyBtnMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (root.wp) root.wp.applySelectedWallpaper()
                                    }
                                }
                            }
                        }
                    }
                }

                // =============================================================
                // TAB CONTENT 4: GAMING SETTINGS
                // =============================================================
                Column {
                    anchors.fill: parent
                    visible: root.activeCategory === "gaming"
                    spacing: theme.spacingSm

                    Row {
                        width: parent.width
                        height: 32
                        spacing: theme.spacingSm

                        SettingPill {
                            label: "Bulldoptimizer"
                            active: root.activeGamingTab === "bulldoptimizer"
                            onClicked: root.activeGamingTab = "bulldoptimizer"
                        }

                        SettingPill {
                            label: "Gamescope"
                            active: root.activeGamingTab === "gamescope"
                            onClicked: root.activeGamingTab = "gamescope"
                        }

                        SettingPill {
                            label: "MangoHud"
                            active: root.activeGamingTab === "mangohud"
                            onClicked: root.activeGamingTab = "mangohud"
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: theme.separator
                    }

                    Flickable {
                        width: parent.width
                        height: parent.height - 32 - 1 - theme.spacingSm
                        contentWidth: width
                        contentHeight: gamingContentCol.implicitHeight + 20
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds

                        Column {
                            id: gamingContentCol
                            width: parent.width
                            spacing: theme.spacingSm

                            // Subtab 1: Bulldoptimizer
                            Column {
                                width: parent.width
                                visible: root.activeGamingTab === "bulldoptimizer"
                                spacing: theme.spacingSm

                                SectionHeader { title: "Shell & Sistema" }

                                SettingToggleRow {
                                    iconGlyph: ""
                                    title: "Wallpaper Estático (Zero-GPU)"
                                    subtitle: "Pausa o Wallpaper Engine e exibe imagem estática para liberar VRAM e GPU"
                                    checked: root.game ? root.game.boWallpaperStatic : true
                                    onToggled: {
                                        if (root.game) {
                                            root.game.boWallpaperStatic = !root.game.boWallpaperStatic
                                            root.game.saveConfig()
                                        }
                                    }
                                }

                                SettingToggleRow {
                                    iconGlyph: ""
                                    title: "Desativar Efeitos do Hyprland"
                                    subtitle: "Desativa blur, sombras e animações do compositor ao ativar o Bulldoptimizer"
                                    checked: root.game ? root.game.boHyprlandEffects : true
                                    onToggled: {
                                        if (root.game) {
                                            root.game.boHyprlandEffects = !root.game.boHyprlandEffects
                                            root.game.saveConfig()
                                            if (root.game.bulldoptimizerEnabled) {
                                                root.game.applyBulldoptimizer(true)
                                            }
                                        }
                                    }
                                }

                                SectionHeader { title: "Hardware & Driver GPU" }

                                SettingToggleRow {
                                    iconGlyph: ""
                                    title: "NVIDIA PowerMizer Performance"
                                    subtitle: "Trava a GPU em modo de desempenho máximo (Seguro: ignora em GPUs AMD/Intel)"
                                    checked: root.game ? root.game.boPowerMizer : false
                                    onToggled: {
                                        if (root.game) {
                                            root.game.boPowerMizer = !root.game.boPowerMizer
                                            root.game.saveConfig()
                                            if (root.game.bulldoptimizerEnabled) {
                                                root.game.applyBulldoptimizer(true)
                                            }
                                        }
                                    }
                                }
                            }

                            // Subtab 2: Gamescope
                            Column {
                                width: parent.width
                                visible: root.activeGamingTab === "gamescope"
                                spacing: theme.spacingSm

                                SectionHeader { title: "Visual & HDR" }

                                SettingToggleRow {
                                    iconGlyph: ""
                                    title: "HDR Nativo (--hdr-enabled)"
                                    subtitle: "Habilita suporte a High Dynamic Range no Gamescope"
                                    checked: root.game ? root.game.gsHdr : false
                                    onToggled: {
                                        if (root.game) {
                                            root.game.gsHdr = !root.game.gsHdr
                                            root.game.saveConfig()
                                        }
                                    }
                                }

                                SettingToggleRow {
                                    iconGlyph: ""
                                    title: "Mapeamento Inverso SDR -> HDR (--hdr-itm-enabled)"
                                    subtitle: "Auto-HDR para jogos clássicos em SDR"
                                    checked: root.game ? root.game.gsHdrItm : false
                                    onToggled: {
                                        if (root.game) {
                                            root.game.gsHdrItm = !root.game.gsHdrItm
                                            root.game.saveConfig()
                                        }
                                    }
                                }

                                Row {
                                    width: parent.width
                                    spacing: theme.spacingSm

                                    Text {
                                        text: "Brilho SDR no HDR:"
                                        color: theme.textMedium
                                        font.pixelSize: theme.fontSizeSm
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Repeater {
                                        model: [200, 300, 400, 600, 1000]
                                        delegate: SettingPill {
                                            required property int modelData
                                            width: 64
                                            label: modelData + " nits"
                                            active: root.game ? root.game.gsHdrSdrNits === modelData : false
                                            onClicked: {
                                                if (root.game) {
                                                    root.game.gsHdrSdrNits = modelData
                                                    root.game.saveConfig()
                                                }
                                            }
                                        }
                                    }
                                }

                                SectionHeader { title: "Exibição & Sincronização" }

                                SettingToggleRow {
                                    iconGlyph: ""
                                    title: "Modo Tela Cheia Exclusiva (--fullscreen)"
                                    subtitle: "Executa a sessão do jogo em tela cheia"
                                    checked: root.game ? root.game.gsFullscreen : true
                                    onToggled: {
                                        if (root.game) {
                                            root.game.gsFullscreen = !root.game.gsFullscreen
                                            root.game.saveConfig()
                                        }
                                    }
                                }

                                SettingToggleRow {
                                    iconGlyph: ""
                                    title: "Janela Sem Bordas (-b)"
                                    subtitle: "Executa em modo janela sem decorações"
                                    checked: root.game ? root.game.gsBorderless : false
                                    onToggled: {
                                        if (root.game) {
                                            root.game.gsBorderless = !root.game.gsBorderless
                                            root.game.saveConfig()
                                        }
                                    }
                                }

                                SettingToggleRow {
                                    iconGlyph: "⚡"
                                    title: "Adaptive Sync / VRR (--adaptive-sync)"
                                    subtitle: "Taxa de atualização variável para eliminar screen tearing"
                                    checked: root.game ? root.game.gsAdaptiveSync : false
                                    onToggled: {
                                        if (root.game) {
                                            root.game.gsAdaptiveSync = !root.game.gsAdaptiveSync
                                            root.game.saveConfig()
                                        }
                                    }
                                }

                                Row {
                                    width: parent.width
                                    spacing: theme.spacingSm

                                    Text {
                                        text: "Taxa de Atualização:"
                                        color: theme.textMedium
                                        font.pixelSize: theme.fontSizeSm
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Repeater {
                                        model: [240, 165, 144, 120, 60]
                                        delegate: SettingPill {
                                            required property int modelData
                                            width: 64
                                            label: modelData + "Hz"
                                            active: root.game ? root.game.gsRefreshRate === modelData : false
                                            onClicked: {
                                                if (root.game) root.game.setRefreshRate(modelData)
                                            }
                                        }
                                    }
                                }

                                Row {
                                    width: parent.width
                                    spacing: theme.spacingSm

                                    Text {
                                        text: "Resolução Nativa:"
                                        color: theme.textMedium
                                        font.pixelSize: theme.fontSizeSm
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    SettingPill {
                                        width: 72
                                        label: "1440p"
                                        active: root.game ? (root.game.gsWidth === 2560 && root.game.gsHeight === 1440) : false
                                        onClicked: if (root.game) root.game.setResolution(2560, 1440)
                                    }

                                    SettingPill {
                                        width: 72
                                        label: "1080p"
                                        active: root.game ? (root.game.gsWidth === 1920 && root.game.gsHeight === 1080) : false
                                        onClicked: if (root.game) root.game.setResolution(1920, 1080)
                                    }

                                    SettingPill {
                                        width: 72
                                        label: "4K UHD"
                                        active: root.game ? (root.game.gsWidth === 3840 && root.game.gsHeight === 2160) : false
                                        onClicked: if (root.game) root.game.setResolution(3840, 2160)
                                    }

                                    SettingPill {
                                        width: 84
                                        label: "UW 3440p"
                                        active: root.game ? (root.game.gsWidth === 3440 && root.game.gsHeight === 1440) : false
                                        onClicked: if (root.game) root.game.setResolution(3440, 1440)
                                    }
                                }

                                SectionHeader { title: "Upscaling & Filtros de Escala" }

                                SettingToggleRow {
                                    iconGlyph: "󰢮"
                                    title: "AMD FidelityFX FSR (-F fsr)"
                                    subtitle: "Reconstrução espacial de alta performance para ganhos de FPS"
                                    checked: root.game ? root.game.gsFsr : false
                                    onToggled: {
                                        if (root.game) {
                                            root.game.gsFsr = !root.game.gsFsr
                                            if (root.game.gsFsr) root.game.gsScalerFilter = "fsr"
                                            root.game.saveConfig()
                                        }
                                    }
                                }

                                Row {
                                    width: parent.width
                                    visible: root.game ? root.game.gsFsr : false
                                    spacing: theme.spacingSm

                                    Text {
                                        text: "Nitidez FSR:"
                                        color: theme.textMedium
                                        font.pixelSize: theme.fontSizeSm
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Repeater {
                                        model: [
                                            { label: "Suave (0)", val: 0 },
                                            { label: "Padrão (2)", val: 2 },
                                            { label: "Nítido (5)", val: 5 },
                                            { label: "Máximo (10)", val: 10 }
                                        ]
                                        delegate: SettingPill {
                                            required property var modelData
                                            width: 86
                                            label: modelData.label
                                            active: root.game ? root.game.gsFsrSharpness === modelData.val : false
                                            onClicked: {
                                                if (root.game) {
                                                    root.game.gsFsrSharpness = modelData.val
                                                    root.game.saveConfig()
                                                }
                                            }
                                        }
                                    }
                                }

                                SettingToggleRow {
                                    iconGlyph: "󰹑"
                                    title: "Integer Scaling (-S integer)"
                                    subtitle: "Escalonamento por números inteiros (Pixel Art perfeito)"
                                    checked: root.game ? root.game.gsIntegerScaling : false
                                    onToggled: {
                                        if (root.game) {
                                            root.game.gsIntegerScaling = !root.game.gsIntegerScaling
                                            root.game.saveConfig()
                                        }
                                    }
                                }

                                Row {
                                    width: parent.width
                                    spacing: theme.spacingSm

                                    Text {
                                        text: "Render Interno:"
                                        color: theme.textMedium
                                        font.pixelSize: theme.fontSizeSm
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    SettingPill {
                                        width: 72
                                        label: "Nativo"
                                        active: root.game ? root.game.gsRenderWidth === 0 : true
                                        onClicked: if (root.game) root.game.setRenderResolution(0, 0)
                                    }

                                    SettingPill {
                                        width: 72
                                        label: "1080p"
                                        active: root.game ? root.game.gsRenderWidth === 1920 : false
                                        onClicked: if (root.game) root.game.setRenderResolution(1920, 1080)
                                    }

                                    SettingPill {
                                        width: 72
                                        label: "720p"
                                        active: root.game ? root.game.gsRenderWidth === 1280 : false
                                        onClicked: if (root.game) root.game.setRenderResolution(1280, 720)
                                    }
                                }

                                Row {
                                    width: parent.width
                                    spacing: theme.spacingSm

                                    Text {
                                        text: "Limite de FPS:"
                                        color: theme.textMedium
                                        font.pixelSize: theme.fontSizeSm
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Repeater {
                                        model: [
                                            { label: "Sem Limite", val: 0 },
                                            { label: "240", val: 240 },
                                            { label: "165", val: 165 },
                                            { label: "144", val: 144 },
                                            { label: "120", val: 120 },
                                            { label: "60", val: 60 }
                                        ]
                                        delegate: SettingPill {
                                            required property var modelData
                                            width: 74
                                            label: modelData.label
                                            active: root.game ? root.game.gsFpsLimit === modelData.val : false
                                            onClicked: {
                                                if (root.game) {
                                                    root.game.gsFpsLimit = modelData.val
                                                    root.game.saveConfig()
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // Subtab 3: MangoHud
                            Column {
                                width: parent.width
                                visible: root.activeGamingTab === "mangohud"
                                spacing: theme.spacingSm

                                SectionHeader { title: "Presets do HUD" }

                                Row {
                                    width: parent.width
                                    spacing: theme.spacingSm

                                    SettingPill {
                                        width: 90
                                        label: "Completo"
                                        active: root.game ? (root.game.mhVram && root.game.mhGpuPower) : false
                                        onClicked: if (root.game) root.game.applyMangohudPreset("completo")
                                    }

                                    SettingPill {
                                        width: 90
                                        label: "Essencial"
                                        active: root.game ? (root.game.mhVram && !root.game.mhGpuPower) : false
                                        onClicked: if (root.game) root.game.applyMangohudPreset("essencial")
                                    }

                                    SettingPill {
                                        width: 90
                                        label: "Mínimo"
                                        active: root.game ? root.game.mhCompact : false
                                        onClicked: if (root.game) root.game.applyMangohudPreset("minimo")
                                    }
                                }

                                SectionHeader { title: "Métricas de Performance & GPU" }

                                SettingToggleRow {
                                    iconGlyph: ""
                                    title: "Exibir Taxa de Quadros (FPS)"
                                    subtitle: "Contador de quadros por segundo em tempo real"
                                    checked: root.game ? root.game.mhFps : true
                                    onToggled: {
                                        if (root.game) {
                                            root.game.mhFps = !root.game.mhFps
                                            root.game.saveConfig()
                                        }
                                    }
                                }

                                SettingToggleRow {
                                    iconGlyph: "󰓅"
                                    title: "Gráfico de Frametime"
                                    subtitle: "Exibe o gráfico de consistência dos quadros (ms)"
                                    checked: root.game ? root.game.mhFrametime : true
                                    onToggled: {
                                        if (root.game) {
                                            root.game.mhFrametime = !root.game.mhFrametime
                                            root.game.saveConfig()
                                        }
                                    }
                                }

                                SettingToggleRow {
                                    iconGlyph: "󰢮"
                                    title: "Uso e Temperatura da GPU"
                                    subtitle: "Percentual de carga e temperatura (°C) do chip gráfico"
                                    checked: root.game ? root.game.mhGpuStats : true
                                    onToggled: {
                                        if (root.game) {
                                            root.game.mhGpuStats = !root.game.mhGpuStats
                                            root.game.mhGpuTemp = root.game.mhGpuStats
                                            root.game.saveConfig()
                                        }
                                    }
                                }

                                SettingToggleRow {
                                    iconGlyph: "󰍛"
                                    title: "Memória VRAM da GPU"
                                    subtitle: "Exibe a alocação de memória de vídeo dedicada"
                                    checked: root.game ? root.game.mhVram : true
                                    onToggled: {
                                        if (root.game) {
                                            root.game.mhVram = !root.game.mhVram
                                            root.game.saveConfig()
                                        }
                                    }
                                }

                                SettingToggleRow {
                                    iconGlyph: "⚡"
                                    title: "Potência da GPU (Watts) & Clock (MHz)"
                                    subtitle: "Telemetria de energia e frequência do núcleo da GPU"
                                    checked: root.game ? root.game.mhGpuPower : false
                                    onToggled: {
                                        if (root.game) {
                                            root.game.mhGpuPower = !root.game.mhGpuPower
                                            root.game.mhGpuCoreClock = root.game.mhGpuPower
                                            root.game.saveConfig()
                                        }
                                    }
                                }

                                SectionHeader { title: "Métricas de CPU & Sistema" }

                                SettingToggleRow {
                                    iconGlyph: ""
                                    title: "Uso e Temperatura do Processador (CPU)"
                                    subtitle: "Carga percentual e temperatura (°C) dos núcleos"
                                    checked: root.game ? root.game.mhCpuStats : true
                                    onToggled: {
                                        if (root.game) {
                                            root.game.mhCpuStats = !root.game.mhCpuStats
                                            root.game.mhCpuTemp = root.game.mhCpuStats
                                            root.game.saveConfig()
                                        }
                                    }
                                }

                                SettingToggleRow {
                                    iconGlyph: ""
                                    title: "Memória RAM do Sistema"
                                    subtitle: "Alocação e consumo de memória principal do PC"
                                    checked: root.game ? root.game.mhRam : true
                                    onToggled: {
                                        if (root.game) {
                                            root.game.mhRam = !root.game.mhRam
                                            root.game.saveConfig()
                                        }
                                    }
                                }

                                SettingToggleRow {
                                    iconGlyph: "⚡"
                                    title: "Potência da CPU (Watts) & Frequência (MHz)"
                                    subtitle: "Telemetria de consumo energético e clock da CPU"
                                    checked: root.game ? root.game.mhCpuPower : false
                                    onToggled: {
                                        if (root.game) {
                                            root.game.mhCpuPower = !root.game.mhCpuPower
                                            root.game.mhCpuMhz = root.game.mhCpuPower
                                            root.game.saveConfig()
                                        }
                                    }
                                }

                                SectionHeader { title: "Layout & Posição na Tela" }

                                Row {
                                    width: parent.width
                                    spacing: theme.spacingSm

                                    SettingPill {
                                        width: 96
                                        label: "Topo-Esquerda"
                                        active: root.game ? root.game.mhPosition === "top-left" : true
                                        onClicked: if (root.game) root.game.setPosition("top-left")
                                    }

                                    SettingPill {
                                        width: 96
                                        label: "Topo-Direita"
                                        active: root.game ? root.game.mhPosition === "top-right" : false
                                        onClicked: if (root.game) root.game.setPosition("top-right")
                                    }

                                    SettingPill {
                                        width: 96
                                        label: "Base-Esquerda"
                                        active: root.game ? root.game.mhPosition === "bottom-left" : false
                                        onClicked: if (root.game) root.game.setPosition("bottom-left")
                                    }

                                    SettingPill {
                                        width: 96
                                        label: "Base-Direita"
                                        active: root.game ? root.game.mhPosition === "bottom-right" : false
                                        onClicked: if (root.game) root.game.setPosition("bottom-right")
                                    }
                                }

                                SettingToggleRow {
                                    iconGlyph: "󰒲"
                                    title: "Modo Linha Compacta (hud_compact)"
                                    subtitle: "Exibe todas as métricas em uma única linha no topo"
                                    checked: root.game ? root.game.mhCompact : false
                                    onToggled: {
                                        if (root.game) {
                                            root.game.mhCompact = !root.game.mhCompact
                                            root.game.saveConfig()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

            }
        }
    }
}
