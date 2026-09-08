import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import "../../modules"
import ".."

Item {
    id: root

    property var goBack
    property var network
    property var bluetooth
    property var audio
    property var gaming
    property var wallpaperEngine
    property var userProfile
    property var lockScreen

    focus: true
    Keys.onEscapePressed: if (root.goBack) root.goBack()

    // Sidebar Category: "home" | "wifi" | "bluetooth" | "sound" | "wallpaper" | "gaming" | "grub"
    property string activeCategory: "home"
    property string activeGamingTab: "bulldoptimizer"

    Theme {
        id: theme
    }

    readonly property var net: network
    readonly property var bt: bluetooth
    readonly property var aud: audio
    readonly property var game: gaming
    readonly property var wp: wallpaperEngine
    readonly property var prof: userProfile

    Process {
        id: proc
    }

    property string selectedWifiSsid: ""
    property string wifiPasswordInput: ""
    property bool showPasswordText: false

    property real bannerCropOffset: 0.0
    property bool isCropAdjustOpen: false
    property string cropConfigPath: Quickshell.env("HOME") + "/.config/bulldoze/banner_crop.json"
    property real wpVersion: 0

    Connections {
        target: root.wp
        function onSnapshotVersionChanged() {
            root.wpVersion = Date.now()
        }
        function onActiveIdChanged() {
            root.wpVersion = Date.now()
        }
    }

    Process {
        id: cropReadProc
        command: ["sh", "-c", "cat " + root.cropConfigPath + " 2>/dev/null || echo '{\"crop\":0.0}'"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    const parsed = JSON.parse(data.trim())
                    if (typeof parsed.crop === "number") {
                        root.bannerCropOffset = Math.max(0.0, Math.min(1.0, parsed.crop))
                    }
                } catch(e) {}
            }
        }
    }

    Process {
        id: cropWriteProc
    }

    function loadCropConfig() {
        if (!cropReadProc.running) cropReadProc.running = true
    }

    function saveCropConfig() {
        const jsonStr = JSON.stringify({ crop: root.bannerCropOffset })
        cropWriteProc.exec(["sh", "-c", "mkdir -p ~/.config/bulldoze && echo '" + jsonStr + "' > " + root.cropConfigPath])
    }

    Component.onCompleted: root.loadCropConfig()

    onVisibleChanged: {
        if (visible) {
            root.selectedWifiSsid = ""
            root.wifiPasswordInput = ""
            root.wpVersion = Date.now()
            root.loadCropConfig()
            if (root.prof) root.prof.refresh()
            if (root.net && root.net.enabled) root.net.scanNetworks(true)
            if (root.bt && root.bt.enabled) root.bt.refresh()
            if (root.aud) root.aud.refreshSinks()
            if (root.game) root.game.loadConfig()
            if (root.wp) {
                root.wp.loadWallpapers()
                root.wp.loadConfig()
            }
        } else {
            root.isCropAdjustOpen = false
            if (root.bt) root.bt.stopScan()
        }
    }

    onActiveCategoryChanged: {
        root.selectedWifiSsid = ""
        root.wifiPasswordInput = ""
        if (activeCategory === "home") {
            if (root.prof) root.prof.refresh()
            if (root.game) root.game.loadConfig()
        } else if (activeCategory === "wifi" && root.net && root.net.enabled) {
            root.net.scanNetworks(true)
        } else if (activeCategory === "bluetooth" && root.bt && root.bt.enabled) {
            root.bt.refresh()
        } else if (activeCategory === "sound" && root.aud) {
            root.aud.refreshSinks()
        } else if (activeCategory === "wallpaper" && root.wp) {
            root.wp.loadWallpapers()
            root.wp.loadConfig()
        } else if (activeCategory === "gaming" && root.game) {
            root.game.loadConfig()
        } else if (activeCategory === "grub" && root.wp) {
            root.wp.loadWallpapers()
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
            renderType: Text.NativeRendering
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
                renderType: Text.NativeRendering
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
                    renderType: Text.NativeRendering
                    width: parent.width
                    text: toggleRow.title
                    color: theme.textStrong
                    font.pixelSize: theme.fontSizeSm
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                }

                Text {
                    renderType: Text.NativeRendering
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
            renderType: Text.NativeRendering
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

        // 1. TOP HORIZONTAL CATEGORY BAR (Centralizada e independente do scroll)
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            height: 42
            spacing: theme.spacingMd

            // 0. Home
            Rectangle {
                width: 42
                height: 42
                radius: theme.radiusSmall
                color: root.activeCategory === "home" ? theme.activeFill : (catHomeMouse.containsMouse ? theme.hoverFill : "transparent")
                border.width: 1
                border.color: root.activeCategory === "home" ? theme.glassBorderStrong : (catHomeMouse.containsMouse ? theme.glassBorderSubtle : "transparent")
                scale: catHomeMouse.pressed ? 0.90 : (catHomeMouse.containsMouse ? 1.10 : 1.0)
                transformOrigin: Item.Center

                Behavior on color { ColorAnimation { duration: theme.animDurationFast } }
                Behavior on border.color { ColorAnimation { duration: theme.animDurationFast } }
                Behavior on scale { NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutBack; easing.overshoot: theme.buttonOvershoot } }

                Text {
                    anchors.centerIn: parent
                    text: ""
                    color: root.activeCategory === "home" ? theme.textStrong : (catHomeMouse.containsMouse ? theme.textStrong : theme.textMuted)
                    font.pixelSize: theme.fontSizeXl
                    renderType: Text.NativeRendering
                }

                MouseArea {
                    id: catHomeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.activeCategory = "home"
                }
            }

            // 1. Wi-Fi
            Rectangle {
                width: 42
                height: 42
                radius: theme.radiusSmall
                color: root.activeCategory === "wifi" ? theme.activeFill : (catWifiMouse.containsMouse ? theme.hoverFill : "transparent")
                border.width: 1
                border.color: root.activeCategory === "wifi" ? theme.glassBorderStrong : (catWifiMouse.containsMouse ? theme.glassBorderSubtle : "transparent")
                scale: catWifiMouse.pressed ? 0.90 : (catWifiMouse.containsMouse ? 1.10 : 1.0)
                transformOrigin: Item.Center

                Behavior on color { ColorAnimation { duration: theme.animDurationFast } }
                Behavior on border.color { ColorAnimation { duration: theme.animDurationFast } }
                Behavior on scale { NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutBack; easing.overshoot: theme.buttonOvershoot } }

                Text {
                    anchors.centerIn: parent
                    text: ""
                    color: root.activeCategory === "wifi" ? theme.textStrong : (catWifiMouse.containsMouse ? theme.textStrong : theme.textMuted)
                    font.pixelSize: theme.fontSizeXl
                    renderType: Text.NativeRendering
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
                width: 42
                height: 42
                radius: theme.radiusSmall
                color: root.activeCategory === "bluetooth" ? theme.activeFill : (catBtMouse.containsMouse ? theme.hoverFill : "transparent")
                border.width: 1
                border.color: root.activeCategory === "bluetooth" ? theme.glassBorderStrong : (catBtMouse.containsMouse ? theme.glassBorderSubtle : "transparent")
                scale: catBtMouse.pressed ? 0.90 : (catBtMouse.containsMouse ? 1.10 : 1.0)
                transformOrigin: Item.Center

                Behavior on color { ColorAnimation { duration: theme.animDurationFast } }
                Behavior on border.color { ColorAnimation { duration: theme.animDurationFast } }
                Behavior on scale { NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutBack; easing.overshoot: theme.buttonOvershoot } }

                Text {
                    anchors.centerIn: parent
                    text: ""
                    color: root.activeCategory === "bluetooth" ? theme.textStrong : (catBtMouse.containsMouse ? theme.textStrong : theme.textMuted)
                    font.pixelSize: theme.fontSizeXl
                    renderType: Text.NativeRendering
                }

                MouseArea {
                    id: catBtMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.activeCategory = "bluetooth"
                }
            }

            // 3. Som
            Rectangle {
                width: 42
                height: 42
                radius: theme.radiusSmall
                color: root.activeCategory === "sound" ? theme.activeFill : (catSoundMouse.containsMouse ? theme.hoverFill : "transparent")
                border.width: 1
                border.color: root.activeCategory === "sound" ? theme.glassBorderStrong : (catSoundMouse.containsMouse ? theme.glassBorderSubtle : "transparent")
                scale: catSoundMouse.pressed ? 0.90 : (catSoundMouse.containsMouse ? 1.10 : 1.0)
                transformOrigin: Item.Center

                Behavior on color { ColorAnimation { duration: theme.animDurationFast } }
                Behavior on border.color { ColorAnimation { duration: theme.animDurationFast } }
                Behavior on scale { NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutBack; easing.overshoot: theme.buttonOvershoot } }

                Text {
                    anchors.centerIn: parent
                    text: ""
                    color: root.activeCategory === "sound" ? theme.textStrong : (catSoundMouse.containsMouse ? theme.textStrong : theme.textMuted)
                    font.pixelSize: theme.fontSizeXl
                    renderType: Text.NativeRendering
                }

                MouseArea {
                    id: catSoundMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.activeCategory = "sound"
                }
            }

            // 4. Wallpaper
            Rectangle {
                width: 42
                height: 42
                radius: theme.radiusSmall
                color: root.activeCategory === "wallpaper" ? theme.activeFill : (catWpMouse.containsMouse ? theme.hoverFill : "transparent")
                border.width: 1
                border.color: root.activeCategory === "wallpaper" ? theme.glassBorderStrong : (catWpMouse.containsMouse ? theme.glassBorderSubtle : "transparent")
                scale: catWpMouse.pressed ? 0.90 : (catWpMouse.containsMouse ? 1.10 : 1.0)
                transformOrigin: Item.Center

                Behavior on color { ColorAnimation { duration: theme.animDurationFast } }
                Behavior on border.color { ColorAnimation { duration: theme.animDurationFast } }
                Behavior on scale { NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutBack; easing.overshoot: theme.buttonOvershoot } }

                Text {
                    anchors.centerIn: parent
                    text: ""
                    color: root.activeCategory === "wallpaper" ? theme.textStrong : (catWpMouse.containsMouse ? theme.textStrong : theme.textMuted)
                    font.pixelSize: theme.fontSizeXl
                    renderType: Text.NativeRendering
                }

                MouseArea {
                    id: catWpMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.activeCategory = "wallpaper"
                }
            }

            // 5. Gaming
            Rectangle {
                width: 42
                height: 42
                radius: theme.radiusSmall
                color: root.activeCategory === "gaming" ? theme.activeFill : (catGamingMouse.containsMouse ? theme.hoverFill : "transparent")
                border.width: 1
                border.color: root.activeCategory === "gaming" ? theme.glassBorderStrong : (catGamingMouse.containsMouse ? theme.glassBorderSubtle : "transparent")
                scale: catGamingMouse.pressed ? 0.90 : (catGamingMouse.containsMouse ? 1.10 : 1.0)
                transformOrigin: Item.Center

                Behavior on color { ColorAnimation { duration: theme.animDurationFast } }
                Behavior on border.color { ColorAnimation { duration: theme.animDurationFast } }
                Behavior on scale { NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutBack; easing.overshoot: theme.buttonOvershoot } }

                Text {
                    anchors.centerIn: parent
                    text: ""
                    color: root.activeCategory === "gaming" ? theme.textStrong : (catGamingMouse.containsMouse ? theme.textStrong : theme.textMuted)
                    font.pixelSize: theme.fontSizeXl
                    renderType: Text.NativeRendering
                }

                MouseArea {
                    id: catGamingMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.activeCategory = "gaming"
                }
            }

            // 6. GRUB Bootloader
            Rectangle {
                width: 42
                height: 42
                radius: theme.radiusSmall
                color: root.activeCategory === "grub" ? theme.activeFill : (catGrubMouse.containsMouse ? theme.hoverFill : "transparent")
                border.width: 1
                border.color: root.activeCategory === "grub" ? theme.glassBorderStrong : (catGrubMouse.containsMouse ? theme.glassBorderSubtle : "transparent")
                scale: catGrubMouse.pressed ? 0.90 : (catGrubMouse.containsMouse ? 1.10 : 1.0)
                transformOrigin: Item.Center

                Behavior on color { ColorAnimation { duration: theme.animDurationFast } }
                Behavior on border.color { ColorAnimation { duration: theme.animDurationFast } }
                Behavior on scale { NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutBack; easing.overshoot: theme.buttonOvershoot } }

                Text {
                    anchors.centerIn: parent
                    text: ""
                    color: root.activeCategory === "grub" ? theme.textStrong : (catGrubMouse.containsMouse ? theme.textStrong : theme.textMuted)
                    font.pixelSize: theme.fontSizeXl
                    renderType: Text.NativeRendering
                }

                MouseArea {
                    id: catGrubMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.activeCategory = "grub"
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: theme.separator
        }

        // 2. CONTENT CONTAINER (Largura total)
        Item {
            width: parent.width
            height: parent.height - 42 - 1 - theme.spacingMd * 2

                // =============================================================
                // TAB CONTENT 0: HOME SETTINGS
                // =============================================================
                Item {
                    id: homeTabContent
                    anchors.fill: parent
                    visible: root.activeCategory === "home"

                    property var currentTime: new Date()
                    property int currentDay: currentTime.getDate()
                    property string uptimeStr: "0m"
                    property string kernelStr: ""
                    property string pendingAction: ""
                    property string confirmTitle: ""
                    property string confirmDesc: ""

                    Timer {
                        interval: 1000
                        running: homeTabContent.visible
                        repeat: true
                        onTriggered: homeTabContent.currentTime = new Date()
                    }

                    Process {
                        id: uptimeProc
                        command: ["sh", "-c", "cat /proc/uptime | awk '{print int($1)}'"]
                        stdout: SplitParser {
                            onRead: data => {
                                const sec = parseInt(data.trim())
                                if (!isNaN(sec)) {
                                    const h = Math.floor(sec / 3600)
                                    const m = Math.floor((sec % 3600) / 60)
                                    if (h > 0) homeTabContent.uptimeStr = h + "h " + m + "m"
                                    else homeTabContent.uptimeStr = m + "m"
                                }
                            }
                        }
                    }

                    Process {
                        id: kernelProc
                        command: ["sh", "-c", "cat /proc/sys/kernel/osrelease 2>/dev/null || uname -r"]
                        running: true
                        stdout: SplitParser {
                            onRead: data => {
                                const k = data.trim()
                                if (k) homeTabContent.kernelStr = k
                            }
                        }
                    }

                    Timer {
                        interval: 30000
                        running: homeTabContent.visible
                        repeat: true
                        triggeredOnStart: true
                        onTriggered: if (!uptimeProc.running) uptimeProc.running = true
                    }

                    function getCalendarDays(d) {
                        if (!d) return []
                        const year = d.getFullYear()
                        const month = d.getMonth()
                        const todayDate = d.getDate()
                        const firstDay = new Date(year, month, 1).getDay()
                        const daysInMonth = new Date(year, month + 1, 0).getDate()
                        const daysInPrevMonth = new Date(year, month, 0).getDate()

                        let days = []
                        for (let i = firstDay - 1; i >= 0; i--) {
                            days.push({ day: daysInPrevMonth - i, isCurrent: false, isToday: false })
                        }
                        for (let i = 1; i <= daysInMonth; i++) {
                            days.push({ day: i, isCurrent: true, isToday: (i === todayDate) })
                        }
                        const totalCells = days.length > 35 ? 42 : 35
                        const remaining = totalCells - days.length
                        for (let i = 1; i <= remaining; i++) {
                            days.push({ day: i, isCurrent: false, isToday: false })
                        }
                        return days
                    }

                    property var calendarDays: getCalendarDays(currentTime)
                    onCurrentDayChanged: calendarDays = getCalendarDays(currentTime)

                    readonly property string greetingPrefix: {
                        const h = homeTabContent.currentTime.getHours()
                        if (h >= 6 && h < 12) {
                            return "Bom dia,"
                        } else if (h >= 12 && h < 18) {
                            return "Boa tarde,"
                        } else if (h >= 18 && h <= 23) {
                            return "Boa noite,"
                        } else {
                            return "Vai dormir,"
                        }
                    }

                    readonly property string greetingSuffix: {
                        const h = homeTabContent.currentTime.getHours()
                        if (h >= 6 && h < 12) {
                            return "! ☀️"
                        } else if (h >= 12 && h < 18) {
                            return "! 🌇"
                        } else if (h >= 18 && h <= 23) {
                            return "! 🌙"
                        } else {
                            return "! 💤"
                        }
                    }

                    // 1. Scrollable Home Area (Flickable)
                    Flickable {
                        id: homeFlickable
                        anchors {
                            top: parent.top
                            bottom: homeBottomBar.top
                            bottomMargin: theme.spacingSm
                            left: parent.left
                            right: parent.right
                        }
                        clip: true
                        contentWidth: width
                        contentHeight: homeScrollCol.implicitHeight

                        Column {
                            id: homeScrollCol
                            width: parent.width
                            spacing: theme.spacingMd

                            // =========================================================
                            // TOP: WELCOME CARD COM BANNER EM UMA LINHA SÓ
                            // =========================================================
                            Rectangle {
                                id: welcomeCard
                                width: parent.width
                                implicitHeight: welcomeContentCol.implicitHeight + 16
                                radius: theme.radiusItem
                                color: theme.itemFill
                                border.width: 1
                                border.color: theme.glassBorderSubtle

                                Column {
                                    id: welcomeContentCol
                                    width: parent.width
                                    spacing: 0

                                    // Banner com Avatar Sobreposto
                                    Item {
                                        id: bannerContainer
                                        width: parent.width
                                        height: bannerBox.height + 40

                                        // Banner com cantos superiores arredondados e blur pré-aplicado
                                        Item {
                                            id: bannerBox
                                            anchors {
                                                top: parent.top
                                                left: parent.left
                                                right: parent.right
                                            }
                                            height: 180
                                            layer.enabled: true
                                            layer.effect: MultiEffect {
                                                maskEnabled: true
                                                maskSource: bannerMask
                                            }

                                            Rectangle {
                                                anchors.fill: parent
                                                color: theme.glassFillDark
                                            }

                                            Item {
                                                anchors.fill: parent
                                                clip: true

                                                Image {
                                                    id: bannerImg
                                                    source: "file://" + Quickshell.env("HOME") + "/.cache/bulldoze/Wallpaper_greeter.png?v=" + root.wpVersion
                                                    asynchronous: true
                                                    cache: false
                                                    readonly property real scaleRatio: (implicitWidth > 0 && implicitHeight > 0)
                                                        ? Math.max(parent.width / implicitWidth, parent.height / implicitHeight)
                                                        : 1.0
                                                    width: implicitWidth > 0 ? implicitWidth * scaleRatio : parent.width
                                                    height: implicitHeight > 0 ? implicitHeight * scaleRatio : parent.height
                                                    x: (parent.width - width) / 2
                                                    y: -(height - parent.height) * root.bannerCropOffset

                                                    onStatusChanged: {
                                                        if (status === Image.Error) {
                                                            source = "file:///var/lib/greetd/Wallpaper_greeter.png?v=" + root.wpVersion
                                                        }
                                                    }
                                                }
                                            }

                                            // Fallback se imagem indisponível
                                            Rectangle {
                                                anchors.fill: parent
                                                color: "#25000000"
                                                visible: !bannerImg.visible
                                            }
                                        }

                                        // Máscara com cantos superiores arredondados
                                        Item {
                                            id: bannerMask
                                            anchors.fill: bannerBox
                                            visible: false
                                            layer.enabled: true

                                            Rectangle {
                                                width: parent.width
                                                height: parent.height + theme.radiusItem
                                                radius: theme.radiusItem
                                                color: "black"
                                            }
                                        }

                                        // Avatar 80x80 Centralizado Horizontalmente e Sobreposto na Borda Inferior
                                        Item {
                                            id: avatarOverBanner
                                            width: 80
                                            height: 80
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            y: bannerBox.height - 40

                                            Rectangle {
                                                anchors.fill: parent
                                                radius: 40
                                                color: theme.glassFillDark
                                                border.width: 3
                                                border.color: theme.glassBorderStrong
                                            }

                                            Image {
                                                id: bigAvatarImg
                                                anchors.fill: parent
                                                anchors.margins: 3
                                                fillMode: Image.PreserveAspectCrop
                                                source: (root.prof && root.prof.hasAvatar && root.prof.avatarPath !== "") ? ("file://" + root.prof.avatarPath) : ""
                                                visible: Boolean(root.prof && root.prof.hasAvatar && status === Image.Ready)
                                                asynchronous: true
                                                cache: false

                                                layer.enabled: true
                                                layer.effect: MultiEffect {
                                                    maskEnabled: true
                                                    maskSource: bigAvatarMask
                                                }
                                            }

                                            Item {
                                                id: bigAvatarMask
                                                anchors.fill: parent
                                                visible: false
                                                layer.enabled: true

                                                Rectangle {
                                                    anchors.fill: parent
                                                    radius: 40
                                                    color: "black"
                                                }
                                            }

                                            Text {
                                                renderType: Text.NativeRendering
                                                anchors.centerIn: parent
                                                visible: !bigAvatarImg.visible
                                                text: (root.prof && root.prof.initial) ? root.prof.initial : "U"
                                                color: theme.textStrong
                                                font.pixelSize: 28
                                                font.weight: Font.Bold
                                            }
                                        }

                                        // Botão de Ajuste do Enquadramento (Canetinha/Pincel) no canto superior esquerdo do banner
                                        Rectangle {
                                            id: homeCropBtn
                                            anchors {
                                                top: bannerBox.top
                                                topMargin: 10
                                                left: bannerBox.left
                                                leftMargin: 10
                                            }
                                            width: 28
                                            height: 28
                                            radius: theme.radiusSmall
                                            color: hcMouse.containsMouse ? theme.hoverFill : (root.isCropAdjustOpen ? theme.activeFill : theme.glassFillDark)
                                            border.width: 1
                                            border.color: root.isCropAdjustOpen ? theme.glassBorderStrong : (hcMouse.containsMouse ? theme.glassBorderStrong : theme.glassBorderSubtle)
                                            scale: hcMouse.pressed ? 0.90 : (hcMouse.containsMouse ? 1.10 : 1.0)
                                            transformOrigin: Item.Center
                                            z: 25

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
                                                text: ""
                                                color: root.isCropAdjustOpen ? theme.textStrong : (hcMouse.containsMouse ? theme.textStrong : theme.textMuted)
                                                font.pixelSize: theme.iconSizeSm
                                            }

                                            MouseArea {
                                                id: hcMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: root.isCropAdjustOpen = !root.isCropAdjustOpen
                                            }
                                        }

                                        // Popup do Slider Vertical de Enquadramento
                                        Rectangle {
                                            id: cropAdjustPopup
                                            anchors {
                                                top: homeCropBtn.bottom
                                                topMargin: 6
                                                left: homeCropBtn.left
                                            }
                                            width: 140
                                            height: 180
                                            radius: theme.radiusItem
                                            color: theme.glassFillDark
                                            border.width: 1
                                            border.color: theme.glassBorderStrong
                                            visible: root.isCropAdjustOpen
                                            z: 30

                                            Column {
                                                anchors.fill: parent
                                                anchors.margins: theme.spacingSm
                                                spacing: 6

                                                Text {
                                                    renderType: Text.NativeRendering
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                    text: "Enquadramento"
                                                    color: theme.textStrong
                                                    font.pixelSize: 10
                                                    font.weight: Font.DemiBold
                                                }

                                                // Slider Vertical
                                                Item {
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                    width: 32
                                                    height: 96

                                                    Rectangle {
                                                        anchors.centerIn: parent
                                                        width: 6
                                                        height: parent.height
                                                        radius: 3
                                                        color: theme.itemFill
                                                        border.width: 1
                                                        border.color: theme.glassBorderSubtle
                                                    }

                                                    Rectangle {
                                                        id: sliderThumb
                                                        width: 18
                                                        height: 18
                                                        radius: 9
                                                        color: theme.textStrong
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                        y: root.bannerCropOffset * (parent.height - height)

                                                        Behavior on y {
                                                            enabled: !sliderMouse.drag.active
                                                            NumberAnimation { duration: theme.animDurationFast }
                                                        }
                                                    }

                                                    MouseArea {
                                                        id: sliderMouse
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor
                                                        preventStealing: true

                                                        function updateFromPos(mouseY) {
                                                            const clampedY = Math.max(0, Math.min(mouseY - 9, parent.height - 18))
                                                            const val = clampedY / (parent.height - 18)
                                                            root.bannerCropOffset = Math.max(0.0, Math.min(1.0, val))
                                                            root.saveCropConfig()
                                                        }

                                                        onPositionChanged: mouse => {
                                                            if (pressed) updateFromPos(mouse.y)
                                                        }
                                                        onPressed: mouse => updateFromPos(mouse.y)
                                                    }
                                                }

                                                Text {
                                                    renderType: Text.NativeRendering
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                    text: Math.round(root.bannerCropOffset * 100) + "%"
                                                    color: theme.textMuted
                                                    font.pixelSize: 10
                                                    font.weight: Font.Medium
                                                }

                                                Rectangle {
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                    width: parent.width - 8
                                                    height: 20
                                                    radius: theme.radiusSmall
                                                    color: topResetMouse.containsMouse ? theme.hoverFill : theme.itemFill
                                                    border.width: 1
                                                    border.color: theme.glassBorderSubtle

                                                    Text {
                                                        renderType: Text.NativeRendering
                                                        anchors.centerIn: parent
                                                        text: "Início (0%)"
                                                        color: theme.textStrong
                                                        font.pixelSize: 9
                                                        font.weight: Font.Medium
                                                    }

                                                    MouseArea {
                                                        id: topResetMouse
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: {
                                                            root.bannerCropOffset = 0.0
                                                            root.saveCropConfig()
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        // Botão de Privacidade (Olho) no canto superior direito do banner
                                        Rectangle {
                                            id: homePrivacyBtn
                                            anchors {
                                                top: bannerBox.top
                                                topMargin: 10
                                                right: bannerBox.right
                                                rightMargin: 10
                                            }
                                            width: 28
                                            height: 28
                                            radius: theme.radiusSmall
                                            color: hpMouse.containsMouse ? theme.hoverFill : ((root.prof && root.prof.privacyMode) ? theme.activeFill : theme.glassFillDark)
                                            border.width: 1
                                            border.color: (root.prof && root.prof.privacyMode) ? theme.glassBorderStrong : (hpMouse.containsMouse ? theme.glassBorderStrong : theme.glassBorderSubtle)
                                            scale: hpMouse.pressed ? 0.90 : (hpMouse.containsMouse ? 1.10 : 1.0)
                                            transformOrigin: Item.Center
                                            z: 20

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
                                                text: (root.prof && root.prof.privacyMode) ? "" : ""
                                                color: (root.prof && root.prof.privacyMode) ? theme.textStrong : (hpMouse.containsMouse ? theme.textStrong : theme.textMuted)
                                                font.pixelSize: theme.iconSizeSm
                                            }

                                            MouseArea {
                                                id: hpMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: if (root.prof) root.prof.togglePrivacy()
                                            }
                                        }
                                    }

                                    // Espaçamento abaixo do avatar
                                    Item { width: 1; height: 12 }

                                    // Saudação em uma linha só + Blur no displayName
                                    Column {
                                        width: parent.width
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        spacing: 4

                                        Row {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            spacing: 6

                                            Text {
                                                renderType: Text.NativeRendering
                                                text: homeTabContent.greetingPrefix
                                                color: theme.textStrong
                                                font.pixelSize: 22
                                                font.weight: Font.Bold
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            Item {
                                                width: nameText.implicitWidth
                                                height: nameText.implicitHeight
                                                anchors.verticalCenter: parent.verticalCenter

                                                layer.enabled: true
                                                layer.effect: MultiEffect {
                                                    blurEnabled: root.prof && root.prof.privacyBlur > 0.001
                                                    blur: root.prof ? root.prof.privacyBlur : 0.0
                                                    blurMax: 48
                                                    blurMultiplier: 2.5
                                                }

                                                Text {
                                                    renderType: Text.NativeRendering
                                                    id: nameText
                                                    anchors.centerIn: parent
                                                    text: (root.prof && root.prof.displayName) ? root.prof.displayName : "Usuário"
                                                    color: theme.textStrong
                                                    font.pixelSize: 22
                                                    font.weight: Font.Bold
                                                }
                                            }

                                            Text {
                                                renderType: Text.NativeRendering
                                                text: homeTabContent.greetingSuffix
                                                color: theme.textStrong
                                                font.pixelSize: 22
                                                font.weight: Font.Bold
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }

                                        // Hostname com privacy blur
                                        Item {
                                            width: hostRow.implicitWidth
                                            height: 20
                                            anchors.horizontalCenter: parent.horizontalCenter

                                            layer.enabled: true
                                            layer.effect: MultiEffect {
                                                blurEnabled: root.prof && root.prof.privacyBlur > 0.001
                                                blur: root.prof ? root.prof.privacyBlur : 0.0
                                                blurMax: 48
                                                blurMultiplier: 2.5
                                            }

                                            Row {
                                                id: hostRow
                                                anchors.centerIn: parent
                                                spacing: 4

                                                Text {
                                                    renderType: Text.NativeRendering
                                                    text: ""
                                                    color: theme.textMuted
                                                    font.pixelSize: 11
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }

                                                Text {
                                                    renderType: Text.NativeRendering
                                                    text: "@" + (root.prof ? root.prof.hostName : "bulldoze")
                                                    color: theme.textMuted
                                                    font.pixelSize: theme.fontSizeSm
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }
                                            }
                                        }
                                    }

                                    Item { width: 1; height: 14 }
                                }
                            }

                            // =========================================================
                            // DATA, HORA E CALENDÁRIO (100% DA LARGURA)
                            // =========================================================
                            Rectangle {
                                id: dateTimeCalendarCard
                                width: parent.width
                                implicitHeight: dtCalCol.implicitHeight + theme.spacingLg * 2
                                radius: theme.radiusItem
                                color: theme.itemFill
                                border.width: 1
                                border.color: theme.glassBorderSubtle

                                Column {
                                    id: dtCalCol
                                    anchors {
                                        top: parent.top
                                        left: parent.left
                                        right: parent.right
                                        margins: theme.spacingLg
                                    }
                                    spacing: theme.spacingMd

                                    // Top Row: Big Clock (48px) + Day of Week Highlight + Full Date
                                    Row {
                                        width: parent.width
                                        spacing: theme.spacingLg

                                        // Big Clock (Aumentado para 48px)
                                        Text {
                                            renderType: Text.NativeRendering
                                            text: Qt.formatTime(homeTabContent.currentTime, "hh:mm")
                                            color: theme.textStrong
                                            font.pixelSize: 48
                                            font.weight: Font.Bold
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        Rectangle {
                                            width: 1
                                            height: 46
                                            color: theme.separator
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        // Day of Week & Date
                                        Row {
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: theme.spacingSm

                                            Rectangle {
                                                height: 24
                                                implicitWidth: dayBadgeText.implicitWidth + 16
                                                radius: theme.radiusSmall
                                                color: theme.activeFill
                                                border.width: 1
                                                border.color: theme.glassBorderStrong
                                                anchors.verticalCenter: parent.verticalCenter

                                                Text {
                                                    renderType: Text.NativeRendering
                                                    id: dayBadgeText
                                                    anchors.centerIn: parent
                                                    text: {
                                                        const d = homeTabContent.currentTime
                                                        const str = d.toLocaleDateString(Qt.locale("pt_BR"), "dddd")
                                                        return str.toUpperCase()
                                                    }
                                                    color: theme.textStrong
                                                    font.pixelSize: theme.fontSizeSm
                                                    font.weight: Font.Bold
                                                }
                                            }

                                            Text {
                                                renderType: Text.NativeRendering
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: {
                                                    const d = homeTabContent.currentTime
                                                    return d.toLocaleDateString(Qt.locale("pt_BR"), "dd 'de' MMMM 'de' yyyy")
                                                }
                                                color: theme.textMedium
                                                font.pixelSize: theme.fontSizeMd
                                                font.weight: Font.Medium
                                            }
                                        }
                                    }

                                    // Divisor
                                    Rectangle {
                                        width: parent.width
                                        height: 1
                                        color: theme.separator
                                    }

                                    // Calendário em Largura Total
                                    Column {
                                        width: parent.width
                                        spacing: 8

                                        // Título do Mês
                                        Text {
                                            renderType: Text.NativeRendering
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: {
                                                const m = homeTabContent.currentTime.toLocaleDateString(Qt.locale("pt_BR"), "MMMM yyyy")
                                                return m.charAt(0).toUpperCase() + m.slice(1)
                                            }
                                            color: theme.textStrong
                                            font.pixelSize: theme.fontSizeSm
                                            font.weight: Font.Bold
                                        }

                                        // Cabeçalho dos Dias da Semana
                                        Row {
                                            width: parent.width
                                            Repeater {
                                                model: ["DOM", "SEG", "TER", "QUA", "QUI", "SEX", "SÁB"]
                                                Item {
                                                    width: parent.width / 7
                                                    height: 18
                                                    Text {
                                                        renderType: Text.NativeRendering
                                                        anchors.centerIn: parent
                                                        text: modelData
                                                        color: theme.textSubtle
                                                        font.pixelSize: 10
                                                        font.weight: Font.DemiBold
                                                    }
                                                }
                                            }
                                        }

                                        // Divisor
                                        Rectangle {
                                            width: parent.width
                                            height: 1
                                            color: theme.separator
                                        }

                                        // Grade de Dias
                                        Grid {
                                            id: calGrid
                                            width: parent.width
                                            columns: 7
                                            rowSpacing: 2
                                            columnSpacing: 0

                                            Repeater {
                                                model: homeTabContent.calendarDays

                                                Item {
                                                    width: calGrid.width / 7
                                                    height: 26

                                                    Rectangle {
                                                        anchors.centerIn: parent
                                                        width: 24
                                                        height: 24
                                                        radius: 12
                                                        color: modelData.isToday ? theme.textStrong : "transparent"

                                                        Text {
                                                            renderType: Text.NativeRendering
                                                            anchors.centerIn: parent
                                                            text: modelData.day
                                                            color: modelData.isToday
                                                                ? theme.glassFillDark
                                                                : (modelData.isCurrent ? theme.textStrong : theme.textSubtle)
                                                            font.pixelSize: 11
                                                            font.weight: modelData.isToday ? Font.Bold : (modelData.isCurrent ? Font.Medium : Font.Normal)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // =========================================================
                            // CENTRAL DE JOGOS & OTIMIZAÇÃO (100% DA LARGURA EM UMA LINHA)
                            // =========================================================
                            Rectangle {
                                id: gamingRowCard
                                width: parent.width
                                implicitHeight: homeGamingRowCol.implicitHeight + theme.spacingMd * 2
                                radius: theme.radiusItem
                                color: theme.itemFill
                                border.width: 1
                                border.color: theme.glassBorderSubtle

                                Column {
                                    id: homeGamingRowCol
                                    anchors {
                                        top: parent.top
                                        left: parent.left
                                        right: parent.right
                                        margins: theme.spacingMd
                                    }
                                    spacing: theme.spacingSm

                                    Row {
                                        width: parent.width
                                        spacing: theme.spacingSm

                                        Text {
                                            renderType: Text.NativeRendering
                                            text: ""
                                            color: theme.textMuted
                                            font.pixelSize: theme.fontSizeXs
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        Text {
                                            renderType: Text.NativeRendering
                                            text: "Central de Jogos & Performance"
                                            color: theme.textSubtle
                                            font.pixelSize: 11
                                            font.weight: Font.DemiBold
                                            font.capitalization: Font.AllUppercase
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }

                                    // 4 Toggles em Linha Horizontal ocupando a largura total
                                    Row {
                                        id: gamingControlsRow
                                        width: parent.width
                                        spacing: theme.spacingSm

                                        readonly property real itemWidth: (width - (theme.spacingSm * 3)) / 4

                                        // 1. GameMode
                                        Rectangle {
                                            width: gamingControlsRow.itemWidth
                                            height: 44
                                            radius: theme.radiusSmall
                                            color: (root.game && root.game.gamemodeEnabled) ? theme.activeFill : (gmMouse.containsMouse ? theme.hoverFill : theme.itemFill)
                                            border.width: 1
                                            border.color: (root.game && root.game.gamemodeEnabled) ? theme.glassBorderStrong : (gmMouse.containsMouse ? theme.glassBorderSubtle : "transparent")
                                            scale: gmMouse.pressed ? 0.94 : (gmMouse.containsMouse ? 1.02 : 1.0)
                                            transformOrigin: Item.Center

                                            Behavior on color { ColorAnimation { duration: theme.animDurationFast } }
                                            Behavior on border.color { ColorAnimation { duration: theme.animDurationFast } }
                                            Behavior on scale { NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutBack; easing.overshoot: theme.buttonOvershoot } }

                                            Row {
                                                anchors.centerIn: parent
                                                spacing: 8

                                                Text {
                                                    renderType: Text.NativeRendering
                                                    text: ""
                                                    color: (root.game && root.game.gamemodeEnabled) ? theme.textStrong : (gmMouse.containsMouse ? theme.textStrong : theme.textMedium)
                                                    font.pixelSize: theme.iconSizeSm
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }

                                                Text {
                                                    renderType: Text.NativeRendering
                                                    text: "GameMode"
                                                    color: (root.game && root.game.gamemodeEnabled) ? theme.textStrong : (gmMouse.containsMouse ? theme.textStrong : theme.textMedium)
                                                    font.pixelSize: theme.fontSizeSm
                                                    font.weight: (root.game && root.game.gamemodeEnabled) ? Font.Bold : Font.Normal
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }
                                            }

                                            Rectangle {
                                                anchors {
                                                    right: parent.right
                                                    rightMargin: 8
                                                    verticalCenter: parent.verticalCenter
                                                }
                                                width: 6
                                                height: 6
                                                radius: 3
                                                color: (root.game && root.game.gamemodeEnabled) ? theme.textStrong : theme.itemFill
                                                border.width: 1
                                                border.color: (root.game && root.game.gamemodeEnabled) ? theme.textStrong : theme.glassBorderSubtle
                                            }

                                            MouseArea {
                                                id: gmMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: if (root.game) root.game.toggleGamemode()
                                            }
                                        }

                                        // 2. Bulldoptimizer
                                        Rectangle {
                                            width: gamingControlsRow.itemWidth
                                            height: 44
                                            radius: theme.radiusSmall
                                            color: (root.game && root.game.bulldoptimizerEnabled) ? theme.activeFill : (boMouse.containsMouse ? theme.hoverFill : theme.itemFill)
                                            border.width: 1
                                            border.color: (root.game && root.game.bulldoptimizerEnabled) ? theme.glassBorderStrong : (boMouse.containsMouse ? theme.glassBorderSubtle : "transparent")
                                            scale: boMouse.pressed ? 0.94 : (boMouse.containsMouse ? 1.02 : 1.0)
                                            transformOrigin: Item.Center

                                            Behavior on color { ColorAnimation { duration: theme.animDurationFast } }
                                            Behavior on border.color { ColorAnimation { duration: theme.animDurationFast } }
                                            Behavior on scale { NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutBack; easing.overshoot: theme.buttonOvershoot } }

                                            Row {
                                                anchors.centerIn: parent
                                                spacing: 8

                                                Text {
                                                    renderType: Text.NativeRendering
                                                    text: ""
                                                    color: (root.game && root.game.bulldoptimizerEnabled) ? theme.textStrong : (boMouse.containsMouse ? theme.textStrong : theme.textMedium)
                                                    font.pixelSize: theme.iconSizeSm
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }

                                                Text {
                                                    renderType: Text.NativeRendering
                                                    text: "Bulldoptimizer"
                                                    color: (root.game && root.game.bulldoptimizerEnabled) ? theme.textStrong : (boMouse.containsMouse ? theme.textStrong : theme.textMedium)
                                                    font.pixelSize: theme.fontSizeSm
                                                    font.weight: (root.game && root.game.bulldoptimizerEnabled) ? Font.Bold : Font.Normal
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }
                                            }

                                            Rectangle {
                                                anchors {
                                                    right: parent.right
                                                    rightMargin: 8
                                                    verticalCenter: parent.verticalCenter
                                                }
                                                width: 6
                                                height: 6
                                                radius: 3
                                                color: (root.game && root.game.bulldoptimizerEnabled) ? theme.textStrong : theme.itemFill
                                                border.width: 1
                                                border.color: (root.game && root.game.bulldoptimizerEnabled) ? theme.textStrong : theme.glassBorderSubtle
                                            }

                                            MouseArea {
                                                id: boMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: if (root.game) root.game.toggleBulldoptimizer()
                                            }
                                        }

                                        // 3. MangoHud
                                        Rectangle {
                                            width: gamingControlsRow.itemWidth
                                            height: 44
                                            radius: theme.radiusSmall
                                            color: (root.game && root.game.mangohudEnabled) ? theme.activeFill : (mhMouse.containsMouse ? theme.hoverFill : theme.itemFill)
                                            border.width: 1
                                            border.color: (root.game && root.game.mangohudEnabled) ? theme.glassBorderStrong : (mhMouse.containsMouse ? theme.glassBorderSubtle : "transparent")
                                            scale: mhMouse.pressed ? 0.94 : (mhMouse.containsMouse ? 1.02 : 1.0)
                                            transformOrigin: Item.Center

                                            Behavior on color { ColorAnimation { duration: theme.animDurationFast } }
                                            Behavior on border.color { ColorAnimation { duration: theme.animDurationFast } }
                                            Behavior on scale { NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutBack; easing.overshoot: theme.buttonOvershoot } }

                                            Row {
                                                anchors.centerIn: parent
                                                spacing: 8

                                                Text {
                                                    renderType: Text.NativeRendering
                                                    text: ""
                                                    color: (root.game && root.game.mangohudEnabled) ? theme.textStrong : (mhMouse.containsMouse ? theme.textStrong : theme.textMedium)
                                                    font.pixelSize: theme.iconSizeSm
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }

                                                Text {
                                                    renderType: Text.NativeRendering
                                                    text: "MangoHud"
                                                    color: (root.game && root.game.mangohudEnabled) ? theme.textStrong : (mhMouse.containsMouse ? theme.textStrong : theme.textMedium)
                                                    font.pixelSize: theme.fontSizeSm
                                                    font.weight: (root.game && root.game.mangohudEnabled) ? Font.Bold : Font.Normal
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }
                                            }

                                            Rectangle {
                                                anchors {
                                                    right: parent.right
                                                    rightMargin: 8
                                                    verticalCenter: parent.verticalCenter
                                                }
                                                width: 6
                                                height: 6
                                                radius: 3
                                                color: (root.game && root.game.mangohudEnabled) ? theme.textStrong : theme.itemFill
                                                border.width: 1
                                                border.color: (root.game && root.game.mangohudEnabled) ? theme.textStrong : theme.glassBorderSubtle
                                            }

                                            MouseArea {
                                                id: mhMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: if (root.game) root.game.toggleMangohud()
                                            }
                                        }

                                        // 4. Gamescope
                                        Rectangle {
                                            width: gamingControlsRow.itemWidth
                                            height: 44
                                            radius: theme.radiusSmall
                                            color: (root.game && root.game.gamescopeEnabled) ? theme.activeFill : (gsMouse.containsMouse ? theme.hoverFill : theme.itemFill)
                                            border.width: 1
                                            border.color: (root.game && root.game.gamescopeEnabled) ? theme.glassBorderStrong : (gsMouse.containsMouse ? theme.glassBorderSubtle : "transparent")
                                            scale: gsMouse.pressed ? 0.94 : (gsMouse.containsMouse ? 1.02 : 1.0)
                                            transformOrigin: Item.Center

                                            Behavior on color { ColorAnimation { duration: theme.animDurationFast } }
                                            Behavior on border.color { ColorAnimation { duration: theme.animDurationFast } }
                                            Behavior on scale { NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutBack; easing.overshoot: theme.buttonOvershoot } }

                                            Row {
                                                anchors.centerIn: parent
                                                spacing: 8

                                                Text {
                                                    renderType: Text.NativeRendering
                                                    text: ""
                                                    color: (root.game && root.game.gamescopeEnabled) ? theme.textStrong : (gsMouse.containsMouse ? theme.textStrong : theme.textMedium)
                                                    font.pixelSize: theme.iconSizeSm
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }

                                                Text {
                                                    renderType: Text.NativeRendering
                                                    text: "Gamescope"
                                                    color: (root.game && root.game.gamescopeEnabled) ? theme.textStrong : (gsMouse.containsMouse ? theme.textStrong : theme.textMedium)
                                                    font.pixelSize: theme.fontSizeSm
                                                    font.weight: (root.game && root.game.gamescopeEnabled) ? Font.Bold : Font.Normal
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }
                                            }

                                            Rectangle {
                                                anchors {
                                                    right: parent.right
                                                    rightMargin: 8
                                                    verticalCenter: parent.verticalCenter
                                                }
                                                width: 6
                                                height: 6
                                                radius: 3
                                                color: (root.game && root.game.gamescopeEnabled) ? theme.textStrong : theme.itemFill
                                                border.width: 1
                                                border.color: (root.game && root.game.gamescopeEnabled) ? theme.textStrong : theme.glassBorderSubtle
                                            }

                                            MouseArea {
                                                id: gsMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: if (root.game) root.game.toggleGamescope()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // 3. Fixed Bottom Bar (Energy + System Info + Kernel)
                    Item {
                        id: homeBottomBar
                        anchors {
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                        }
                        height: 40
                        z: 20

                        Rectangle {
                            anchors {
                                top: parent.top
                                left: parent.left
                                right: parent.right
                            }
                            height: 1
                            color: theme.separator
                        }

                        // Left: OS Info + Kernel Info + Uptime
                        Row {
                            anchors {
                                left: parent.left
                                verticalCenter: parent.verticalCenter
                            }
                            spacing: theme.spacingSm

                            // OS Name (Arch Linux)
                            Row {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 5

                                Text {
                                    renderType: Text.NativeRendering
                                    text: ""
                                    color: theme.textStrong
                                    font.pixelSize: theme.fontSizeSm
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    renderType: Text.NativeRendering
                                    text: "Arch Linux"
                                    color: theme.textStrong
                                    font.pixelSize: theme.fontSizeXs
                                    font.weight: Font.DemiBold
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 1
                                height: 14
                                color: theme.separator
                            }

                            // Kernel Linux
                            Row {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 4
                                visible: homeTabContent.kernelStr !== ""

                                Text {
                                    renderType: Text.NativeRendering
                                    text: ""
                                    color: theme.textMuted
                                    font.pixelSize: theme.fontSizeXs
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    renderType: Text.NativeRendering
                                    text: "Kernel " + homeTabContent.kernelStr
                                    color: theme.textMuted
                                    font.pixelSize: theme.fontSizeXs
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 1
                                height: 14
                                color: theme.separator
                                visible: homeTabContent.kernelStr !== ""
                            }

                            // Uptime
                            Row {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 4

                                Text {
                                    renderType: Text.NativeRendering
                                    text: ""
                                    color: theme.textMuted
                                    font.pixelSize: theme.fontSizeXs
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    renderType: Text.NativeRendering
                                    text: "Atividade: " + homeTabContent.uptimeStr
                                    color: theme.textMuted
                                    font.pixelSize: theme.fontSizeXs
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }

                        // Right: Power Action Buttons (Bloquear, Encerrar sessão, Reiniciar, Desligar)
                        Row {
                            anchors {
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                            }
                            spacing: theme.spacingSm

                            // 1. Bloquear
                            Rectangle {
                                width: 32
                                height: 32
                                radius: theme.radiusSmall
                                color: lockBtnMouse.containsMouse ? theme.hoverFill : "transparent"
                                border.width: 1
                                border.color: lockBtnMouse.containsMouse ? theme.glassBorderStrong : "transparent"
                                scale: lockBtnMouse.pressed ? 0.90 : (lockBtnMouse.containsMouse ? 1.15 : 1.0)
                                transformOrigin: Item.Center

                                Behavior on color { ColorAnimation { duration: theme.animDurationFast } }
                                Behavior on border.color { ColorAnimation { duration: theme.animDurationFast } }
                                Behavior on scale { NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutBack; easing.overshoot: theme.buttonOvershoot } }

                                Text {
                                    renderType: Text.NativeRendering
                                    anchors.centerIn: parent
                                    text: ""
                                    color: lockBtnMouse.containsMouse ? theme.textStrong : theme.textMedium
                                    font.pixelSize: theme.iconSizeMd
                                }

                                MouseArea {
                                    id: lockBtnMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (root.lockScreen) root.lockScreen()
                                    }
                                }
                            }

                            // 2. Encerrar Sessão
                            Rectangle {
                                width: 32
                                height: 32
                                radius: theme.radiusSmall
                                color: logoutBtnMouse.containsMouse ? theme.hoverFill : "transparent"
                                border.width: 1
                                border.color: logoutBtnMouse.containsMouse ? theme.glassBorderStrong : "transparent"
                                scale: logoutBtnMouse.pressed ? 0.90 : (logoutBtnMouse.containsMouse ? 1.15 : 1.0)
                                transformOrigin: Item.Center

                                Behavior on color { ColorAnimation { duration: theme.animDurationFast } }
                                Behavior on border.color { ColorAnimation { duration: theme.animDurationFast } }
                                Behavior on scale { NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutBack; easing.overshoot: theme.buttonOvershoot } }

                                Text {
                                    renderType: Text.NativeRendering
                                    anchors.centerIn: parent
                                    text: ""
                                    color: logoutBtnMouse.containsMouse ? theme.textStrong : theme.textMedium
                                    font.pixelSize: theme.iconSizeMd
                                }

                                MouseArea {
                                    id: logoutBtnMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        homeTabContent.confirmTitle = "Encerrar Sessão"
                                        homeTabContent.confirmDesc = "Deseja realmente encerrar a sessão do usuário?"
                                        homeTabContent.pendingAction = "hyprctl dispatch exit || loginctl terminate-user $USER"
                                    }
                                }
                            }

                            // 3. Reiniciar
                            Rectangle {
                                width: 32
                                height: 32
                                radius: theme.radiusSmall
                                color: rebootBtnMouse.containsMouse ? theme.hoverFill : "transparent"
                                border.width: 1
                                border.color: rebootBtnMouse.containsMouse ? theme.glassBorderStrong : "transparent"
                                scale: rebootBtnMouse.pressed ? 0.90 : (rebootBtnMouse.containsMouse ? 1.15 : 1.0)
                                transformOrigin: Item.Center

                                Behavior on color { ColorAnimation { duration: theme.animDurationFast } }
                                Behavior on border.color { ColorAnimation { duration: theme.animDurationFast } }
                                Behavior on scale { NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutBack; easing.overshoot: theme.buttonOvershoot } }

                                Text {
                                    renderType: Text.NativeRendering
                                    anchors.centerIn: parent
                                    text: ""
                                    color: rebootBtnMouse.containsMouse ? theme.textStrong : theme.textMedium
                                    font.pixelSize: theme.iconSizeMd
                                }

                                MouseArea {
                                    id: rebootBtnMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        homeTabContent.confirmTitle = "Reiniciar Sistema"
                                        homeTabContent.confirmDesc = "Deseja realmente reiniciar o computador?"
                                        homeTabContent.pendingAction = "systemctl reboot"
                                    }
                                }
                            }

                            // 4. Desligar
                            Rectangle {
                                width: 32
                                height: 32
                                radius: theme.radiusSmall
                                color: poweroffBtnMouse.containsMouse ? theme.hoverFill : "transparent"
                                border.width: 1
                                border.color: poweroffBtnMouse.containsMouse ? theme.glassBorderStrong : "transparent"
                                scale: poweroffBtnMouse.pressed ? 0.90 : (poweroffBtnMouse.containsMouse ? 1.15 : 1.0)
                                transformOrigin: Item.Center

                                Behavior on color { ColorAnimation { duration: theme.animDurationFast } }
                                Behavior on border.color { ColorAnimation { duration: theme.animDurationFast } }
                                Behavior on scale { NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutBack; easing.overshoot: theme.buttonOvershoot } }

                                Text {
                                    renderType: Text.NativeRendering
                                    anchors.centerIn: parent
                                    text: ""
                                    color: poweroffBtnMouse.containsMouse ? theme.textStrong : theme.textMedium
                                    font.pixelSize: theme.iconSizeMd
                                }

                                MouseArea {
                                    id: poweroffBtnMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        homeTabContent.confirmTitle = "Desligar Sistema"
                                        homeTabContent.confirmDesc = "Deseja realmente desligar o computador agora?"
                                        homeTabContent.pendingAction = "systemctl poweroff"
                                    }
                                }
                            }
                        }
                    }

                    // 4. Confirmation Dialog Modal
                    Rectangle {
                        id: confirmOverlay
                        anchors.fill: parent
                        color: "#90000000"
                        visible: homeTabContent.pendingAction !== ""
                        z: 50

                        MouseArea {
                            anchors.fill: parent
                            onClicked: homeTabContent.pendingAction = ""
                        }

                        Rectangle {
                            anchors.centerIn: parent
                            width: 380
                            height: 170
                            radius: theme.radiusItem
                            color: theme.glassFillDark
                            border.width: 1
                            border.color: theme.glassBorderStrong

                            Column {
                                anchors.fill: parent
                                anchors.margins: theme.spacingLg
                                spacing: theme.spacingMd

                                Row {
                                    spacing: theme.spacingSm
                                    Text {
                                        renderType: Text.NativeRendering
                                        text: ""
                                        color: theme.textStrong
                                        font.pixelSize: theme.fontSizeXl
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        renderType: Text.NativeRendering
                                        text: homeTabContent.confirmTitle
                                        color: theme.textStrong
                                        font.pixelSize: theme.fontSizeLg
                                        font.weight: Font.Bold
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                Text {
                                    renderType: Text.NativeRendering
                                    width: parent.width
                                    text: homeTabContent.confirmDesc
                                    color: theme.textMedium
                                    font.pixelSize: theme.fontSizeSm
                                    wrapMode: Text.WordWrap
                                }

                                Item { width: 1; height: 1 }

                                Row {
                                    anchors.right: parent.right
                                    spacing: theme.spacingSm

                                    // Cancelar
                                    Rectangle {
                                        width: 90
                                        height: 32
                                        radius: theme.radiusSmall
                                        color: cancelMouse.containsMouse ? theme.hoverFill : theme.itemFill
                                        border.width: 1
                                        border.color: theme.glassBorderSubtle

                                        Text {
                                            renderType: Text.NativeRendering
                                            anchors.centerIn: parent
                                            text: "Cancelar"
                                            color: theme.textMedium
                                            font.pixelSize: theme.fontSizeXs
                                            font.weight: Font.Medium
                                        }

                                        MouseArea {
                                            id: cancelMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: homeTabContent.pendingAction = ""
                                        }
                                    }

                                    // Confirmar
                                    Rectangle {
                                        width: 90
                                        height: 32
                                        radius: theme.radiusSmall
                                        color: confirmMouse.containsMouse ? theme.hoverFill : theme.activeFill
                                        border.width: 1
                                        border.color: theme.glassBorderStrong

                                        Text {
                                            renderType: Text.NativeRendering
                                            anchors.centerIn: parent
                                            text: "Confirmar"
                                            color: theme.textStrong
                                            font.pixelSize: theme.fontSizeXs
                                            font.weight: Font.Bold
                                        }

                                        MouseArea {
                                            id: confirmMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                const act = homeTabContent.pendingAction
                                                homeTabContent.pendingAction = ""
                                                if (root.goBack) root.goBack()
                                                proc.exec(["sh", "-c", act])
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

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
                                    renderType: Text.NativeRendering
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
                                        renderType: Text.NativeRendering
                                        text: root.net && root.net.enabled ? "Wi-Fi Habilitado" : "Wi-Fi Desativado"
                                        color: theme.textStrong
                                        font.pixelSize: theme.fontSizeSm
                                        font.weight: Font.DemiBold
                                    }

                                    Text {
                                        renderType: Text.NativeRendering
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
                                        renderType: Text.NativeRendering
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
                                                        renderType: Text.NativeRendering
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
                                                                renderType: Text.NativeRendering
                                                                text: modelData.ssid
                                                                color: theme.textStrong
                                                                font.pixelSize: theme.fontSizeSm
                                                                font.weight: modelData.inUse ? Font.Bold : Font.Medium
                                                                elide: Text.ElideRight
                                                            }
                                                            Text {
                                                                renderType: Text.NativeRendering
                                                                visible: modelData.security && !modelData.security.includes("open")
                                                                text: ""
                                                                color: theme.textSubtle
                                                                font.pixelSize: 10
                                                                anchors.verticalCenter: parent.verticalCenter
                                                            }
                                                        }

                                                        Text {
                                                            renderType: Text.NativeRendering
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
                                                        renderType: Text.NativeRendering
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
                                                            renderType: TextInput.NativeRendering
                                                            id: pwdInput
                                                            anchors.verticalCenter: parent.verticalCenter
                                                            width: parent.width - 28
                                                            color: theme.textStrong
                                                            font.pixelSize: theme.fontSizeSm
                                                            echoMode: root.showPasswordText ? TextInput.Normal : TextInput.Password
                                                            clip: true

                                                            Text {
                                                                renderType: Text.NativeRendering
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
                                                            renderType: Text.NativeRendering
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
                                                        renderType: Text.NativeRendering
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
                                                        renderType: Text.NativeRendering
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
                                    renderType: Text.NativeRendering
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
                                        renderType: Text.NativeRendering
                                        text: root.bt && root.bt.enabled ? "Bluetooth Habilitado" : "Bluetooth Desativado"
                                        color: theme.textStrong
                                        font.pixelSize: theme.fontSizeSm
                                        font.weight: Font.DemiBold
                                    }

                                    Text {
                                        renderType: Text.NativeRendering
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
                                        renderType: Text.NativeRendering
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
                                                    renderType: Text.NativeRendering
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
                                                        renderType: Text.NativeRendering
                                                        text: modelData.name || modelData.mac
                                                        color: theme.textStrong
                                                        font.pixelSize: theme.fontSizeSm
                                                        font.weight: modelData.connected ? Font.Bold : Font.Medium
                                                        elide: Text.ElideRight
                                                    }

                                                    Text {
                                                        renderType: Text.NativeRendering
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
                                                        renderType: Text.NativeRendering
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
                                                        renderType: Text.NativeRendering
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
                                    renderType: Text.NativeRendering
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
                                                    renderType: Text.NativeRendering
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
                                                        renderType: Text.NativeRendering
                                                        text: modelData.name || modelData.mac
                                                        color: theme.textStrong
                                                        font.pixelSize: theme.fontSizeSm
                                                        font.weight: Font.Medium
                                                        elide: Text.ElideRight
                                                    }

                                                    Text {
                                                        renderType: Text.NativeRendering
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
                                                    renderType: Text.NativeRendering
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
                                    renderType: Text.NativeRendering
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
                // TAB CONTENT: SOUND SETTINGS
                // =============================================================
                Column {
                    anchors.fill: parent
                    visible: root.activeCategory === "sound"
                    spacing: theme.spacingMd

                    // Card 1: Master Volume Slider
                    Rectangle {
                        width: parent.width
                        height: 72
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
                                spacing: theme.spacingSm

                                Rectangle {
                                    width: 26
                                    height: 26
                                    radius: theme.radiusSmall
                                    color: soundMuteBtnMouse.containsMouse ? theme.hoverFill : "transparent"
                                    border.width: 1
                                    border.color: soundMuteBtnMouse.containsMouse ? theme.glassBorderStrong : "transparent"
                                    scale: soundMuteBtnMouse.pressed ? 0.90 : 1.0

                                    Behavior on color { ColorAnimation { duration: theme.animDurationFast } }
                                    Behavior on scale { NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutBack } }

                                    Text {
                                        renderType: Text.NativeRendering
                                        anchors.centerIn: parent
                                        text: root.aud ? root.aud.icon : ""
                                        color: root.aud && root.aud.muted ? theme.indicatorInactive : theme.textStrong
                                        font.pixelSize: theme.fontSizeMd
                                    }

                                    MouseArea {
                                        id: soundMuteBtnMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: if (root.aud) root.aud.toggleMute()
                                    }
                                }

                                Text {
                                    renderType: Text.NativeRendering
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Volume de Saída"
                                    color: theme.textStrong
                                    font.pixelSize: theme.fontSizeSm
                                    font.weight: Font.DemiBold
                                }

                                Item {
                                    width: Math.max(10, parent.width - 26 - 120 - 50 - (theme.spacingSm * 3))
                                    height: 1
                                }

                                Text {
                                    renderType: Text.NativeRendering
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 50
                                    horizontalAlignment: Text.AlignRight
                                    text: (root.aud ? root.aud.volume : 0) + "%"
                                    color: root.aud && root.aud.muted ? theme.textMuted : theme.textStrong
                                    font.pixelSize: theme.fontSizeSubmenuTitle
                                    font.weight: Font.Bold
                                }
                            }

                            // Slider Bar
                            Item {
                                id: mainVolumeSlider
                                width: parent.width
                                height: 20

                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width
                                    height: 6
                                    radius: 3
                                    color: theme.glassFillDark
                                    border.width: 1
                                    border.color: theme.glassBorderSubtle

                                    Rectangle {
                                        anchors {
                                            left: parent.left
                                            top: parent.top
                                            bottom: parent.bottom
                                        }
                                        width: Math.max(0, Math.min(parent.width, parent.width * (root.aud ? root.aud.volumeRatio : 0)))
                                        radius: 3
                                        color: root.aud && root.aud.muted ? theme.indicatorInactive : theme.textStrong

                                        Behavior on width {
                                            NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic }
                                        }
                                    }
                                }

                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    x: Math.max(0, Math.min(mainVolumeSlider.width - width, (mainVolumeSlider.width - width) * (root.aud ? root.aud.volumeRatio : 0)))
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: theme.textStrong
                                    border.width: 1
                                    border.color: theme.glassFillDark

                                    Behavior on x {
                                        NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor

                                    function updateVolume(mouseX) {
                                        const ratio = Math.max(0, Math.min(1.0, mouseX / mainVolumeSlider.width))
                                        if (root.aud) root.aud.setVolume(ratio)
                                    }

                                    onClicked: mouse => updateVolume(mouse.x)
                                    onPositionChanged: mouse => {
                                        if (pressed) updateVolume(mouse.x)
                                    }
                                }
                            }
                        }
                    }

                    // Section 2: Output Devices
                    SectionHeader { title: "Dispositivos de Saída" }

                    Flickable {
                        width: parent.width
                        height: parent.height - 72 - 22 - (theme.spacingMd * 2)
                        contentWidth: width
                        contentHeight: soundDevicesCol.implicitHeight + 20
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds

                        Column {
                            id: soundDevicesCol
                            width: parent.width
                            spacing: 6

                            Repeater {
                                model: root.aud ? root.aud.availableSinks : []

                                delegate: Rectangle {
                                    required property var modelData
                                    width: soundDevicesCol.width
                                    height: 52
                                    radius: theme.radiusSmall
                                    color: modelData.isDefault ? theme.activeFill : (sinkItemMouse.containsMouse ? theme.hoverFill : theme.itemFill)
                                    border.width: modelData.isDefault ? 2 : 1
                                    border.color: modelData.isDefault ? theme.glassBorderStrong : theme.glassBorderSubtle

                                    Behavior on color { ColorAnimation { duration: theme.animDurationFast } }

                                    Item {
                                        anchors.fill: parent
                                        anchors.leftMargin: theme.spacingMd
                                        anchors.rightMargin: theme.spacingMd

                                        Row {
                                            anchors.left: parent.left
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: theme.spacingMd

                                            Text {
                                                renderType: Text.NativeRendering
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: modelData.icon || ""
                                                color: modelData.isDefault ? theme.textStrong : theme.textMedium
                                                font.pixelSize: theme.fontSizeLg
                                            }

                                            Column {
                                                width: 380
                                                anchors.verticalCenter: parent.verticalCenter
                                                spacing: 2

                                                Text {
                                                    renderType: Text.NativeRendering
                                                    width: parent.width
                                                    text: modelData.name
                                                    color: theme.textStrong
                                                    font.pixelSize: theme.fontSizeSm
                                                    font.weight: modelData.isDefault ? Font.Bold : Font.Medium
                                                    elide: Text.ElideRight
                                                }

                                                Text {
                                                    renderType: Text.NativeRendering
                                                    text: modelData.isDefault ? "Saída de áudio padrão ativa" : "Disponível para reprodução"
                                                    color: theme.textMuted
                                                    font.pixelSize: theme.fontSizeXs
                                                }
                                            }
                                        }

                                        Rectangle {
                                            anchors.right: parent.right
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: modelData.isDefault ? 94 : 80
                                            height: 28
                                            radius: theme.radiusSmall
                                            color: modelData.isDefault ? theme.activeFill : (sinkItemMouse.containsMouse ? theme.hoverFill : theme.itemFill)
                                            border.width: 1
                                            border.color: modelData.isDefault ? theme.glassBorderStrong : theme.glassBorderSubtle

                                            Row {
                                                anchors.centerIn: parent
                                                spacing: 4

                                                Text {
                                                    renderType: Text.NativeRendering
                                                    visible: modelData.isDefault
                                                    text: ""
                                                    color: theme.textStrong
                                                    font.pixelSize: 10
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }

                                                Text {
                                                    renderType: Text.NativeRendering
                                                    text: modelData.isDefault ? "Padrão" : "Selecionar"
                                                    color: theme.textStrong
                                                    font.pixelSize: theme.fontSizeXs
                                                    font.weight: Font.DemiBold
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }
                                            }
                                        }
                                    }

                                    MouseArea {
                                        id: sinkItemMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (root.aud) root.aud.setDefaultSink(modelData.id)
                                        }
                                    }
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
                                    renderType: Text.NativeRendering
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: ""
                                    color: theme.textSubtle
                                    font.pixelSize: theme.fontSizeSm
                                }

                                TextInput {
                                    renderType: TextInput.NativeRendering
                                    id: wpSearchField
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - 30
                                    color: theme.textStrong
                                    font.pixelSize: theme.fontSizeSm
                                    clip: true

                                    Text {
                                        renderType: Text.NativeRendering
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
                                                    renderType: Text.NativeRendering
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
                                                    Text { renderType: Text.NativeRendering; text: ""; color: theme.textStrong; font.pixelSize: 8 }
                                                    Text { renderType: Text.NativeRendering; text: "ATIVO"; color: theme.textStrong; font.pixelSize: 8; font.weight: Font.Bold }
                                                }
                                            }
                                        }

                                        Text {
                                            renderType: Text.NativeRendering
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
                                        renderType: Text.NativeRendering
                                        width: parent.width
                                        text: (root.wp && root.wp.selectedWallpaper) ? root.wp.selectedWallpaper.title : "Nenhum selecionado"
                                        color: theme.textStrong
                                        font.pixelSize: theme.fontSizeSm
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        renderType: Text.NativeRendering
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
                                                                renderType: Text.NativeRendering
                                                                anchors.left: parent.left
                                                                anchors.verticalCenter: parent.verticalCenter
                                                                text: propData.text || propData.key
                                                                color: theme.textStrong
                                                                font.pixelSize: theme.fontSizeSm
                                                                font.weight: Font.Medium
                                                            }
                                                            Text {
                                                                renderType: Text.NativeRendering
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
                                        renderType: Text.NativeRendering
                                        text: ""
                                        color: theme.textStrong
                                        font.pixelSize: theme.fontSizeSm
                                    }

                                    Text {
                                        renderType: Text.NativeRendering
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
                // TAB CONTENT 4: GAMING SETTINGS (UNIFIED SCROLL & PRESETS)
                // =============================================================
                Item {
                    anchors.fill: parent
                    visible: root.activeCategory === "gaming"

                    GamingSettingsBarView {
                        anchors.fill: parent
                        gaming: root.game
                        goBack: () => root.activeCategory = "home"
                    }
                }

                // =============================================================
                // TAB CONTENT 5: GRUB BOOTLOADER SETTINGS & WALLPAPER
                // =============================================================
                Item {
                    anchors.fill: parent
                    visible: root.activeCategory === "grub"

                    GrubSettingsBarView {
                        anchors.fill: parent
                        wallpaperEngine: root.wp
                        goBack: () => root.activeCategory = "home"
                    }
                }
            }
        }
    }
