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
    property var wallpaperEngine

    Theme {
        id: theme
    }

    readonly property var wp: wallpaperEngine

    property string selectedWallpaperPath: ""
    property string selectedWallpaperTitle: ""
    property string selectedWallpaperId: ""
    property string activeGrubId: ""
    property string activeGrubTitle: ""
    property string activeGrubPath: ""
    property string configPath: Quickshell.env("HOME") + "/.config/bulldoze/grub_wallpaper.json"
    property string statusMessage: ""
    property bool isApplying: false
    property bool isPreviewing: false

    Component.onCompleted: {
        if (root.wp) {
            root.wp.loadWallpapers()
        }
        loadGrubConfig()
    }

    onVisibleChanged: {
        if (visible) {
            searchField.text = ""
            if (root.wp) {
                root.wp.loadWallpapers()
            }
            loadGrubConfig()
        }
    }

    function loadGrubConfig() {
        if (!readConfigProc.running) {
            readConfigProc.running = true
        }
    }

    Process {
        id: readConfigProc
        command: ["sh", "-c", "cat '" + root.configPath + "' 2>/dev/null | tr '\\n' ' '"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    const parsed = JSON.parse(data.trim())
                    if (parsed && parsed.path) {
                        root.activeGrubPath = parsed.path
                        root.activeGrubId = parsed.id || ""
                        root.activeGrubTitle = parsed.title || ""

                        // Auto-select active GRUB wallpaper if nothing selected or on initial load
                        if (!root.selectedWallpaperPath) {
                            root.selectedWallpaperPath = root.activeGrubPath
                            root.selectedWallpaperId = root.activeGrubId
                            root.selectedWallpaperTitle = root.activeGrubTitle
                        }
                    } else {
                        initFallbackSelection()
                    }
                } catch (e) {
                    initFallbackSelection()
                }
            }
        }
    }

    function initFallbackSelection() {
        if (!root.selectedWallpaperPath && root.wp && root.wp.wallpapers && root.wp.wallpapers.length > 0) {
            const current = root.wp.selectedWallpaper || root.wp.activeWallpaper || root.wp.wallpapers[0]
            if (current) {
                root.selectedWallpaperId = current.id || ""
                root.selectedWallpaperTitle = current.title || "Wallpaper Selecionado"
                root.selectedWallpaperPath = current.preview || ""
            }
        }
    }

    Process {
        id: applyProc
        command: [
            "python3",
            Quickshell.env("HOME") + "/.config/quickshell/bulldoze/scripts/bulldoze-grub-wallpaper.py",
            "--image", root.selectedWallpaperPath,
            "--id", root.selectedWallpaperId,
            "--title", root.selectedWallpaperTitle
        ]
        onExited: (exitCode, exitStatus) => {
            root.isApplying = false
            if (exitCode === 0) {
                root.activeGrubId = root.selectedWallpaperId
                root.activeGrubTitle = root.selectedWallpaperTitle
                root.activeGrubPath = root.selectedWallpaperPath
                root.statusMessage = "Wallpaper do GRUB salvo e sincronizado com sucesso!"
                statusTimer.restart()
            } else {
                root.statusMessage = "Erro ao aplicar wallpaper no GRUB."
                statusTimer.restart()
            }
        }
    }

    Process {
        id: previewProc
        command: ["sh", "-c", Quickshell.env("HOME") + "/.config/quickshell/bulldoze/scripts/preview-grub.sh"]
        onExited: (exitCode, exitStatus) => {
            root.isPreviewing = false
        }
    }

    Timer {
        id: statusTimer
        interval: 4000
        onTriggered: root.statusMessage = ""
    }

    Column {
        anchors.fill: parent
        anchors.margins: theme.spacingLg
        spacing: theme.spacingMd

        // 1. Header (Icon, Title, Subtitle, Close Button)
        Row {
            width: parent.width
            height: 40
            spacing: theme.spacingMd

            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 44
                spacing: 2

                Row {
                    spacing: theme.spacingSm
                    Text {
                        renderType: Text.NativeRendering
                        text: ""
                        color: theme.textStrong
                        font.pixelSize: theme.fontSizeTitle
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        renderType: Text.NativeRendering
                        text: "GRUB Bootloader & Wallpaper"
                        color: theme.textStrong
                        font.pixelSize: theme.fontSizeTitle
                        font.weight: Font.DemiBold
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Text {
                    renderType: Text.NativeRendering
                    text: "Personalização visual do seletor de boot, imagem de fundo e card de vidro flutuante"
                    color: theme.textMuted
                    font.pixelSize: theme.fontSizeXs
                }
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 32
                height: 32
                radius: theme.radiusSmall
                color: closeBtnMouse.containsMouse ? theme.hoverFill : "transparent"
                border.width: 1
                border.color: closeBtnMouse.containsMouse ? theme.glassBorderStrong : "transparent"

                Text {
                    renderType: Text.NativeRendering
                    anchors.centerIn: parent
                    text: ""
                    color: theme.textMuted
                    font.pixelSize: theme.fontSizeSm
                }

                MouseArea {
                    id: closeBtnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (root.goBack) root.goBack()
                }
            }
        }

        // Separator
        Rectangle {
            width: parent.width
            height: 1
            color: theme.separator
        }

        // 2. Main Two-Column Layout
        Row {
            width: parent.width
            height: parent.height - 40 - 1 - theme.spacingMd * 2
            spacing: theme.spacingLg

            // ==========================================
            // Left Column: Wallpaper Gallery (52% Width)
            // ==========================================
            Column {
                width: Math.round((parent.width - theme.spacingLg) * 0.52)
                height: parent.height
                spacing: theme.spacingSm

                // Search Box
                Rectangle {
                    width: parent.width
                    height: 36
                    radius: theme.radiusItem
                    color: theme.itemFill
                    border.width: 1
                    border.color: searchField.activeFocus ? theme.glassBorderStrong : theme.glassBorderSubtle

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
                            id: searchField
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 30
                            color: theme.textStrong
                            font.pixelSize: theme.fontSizeSm
                            clip: true

                            Text {
                                renderType: Text.NativeRendering
                                anchors.fill: parent
                                text: "Pesquisar wallpaper para o GRUB..."
                                color: theme.textSubtle
                                font.pixelSize: theme.fontSizeSm
                                visible: !searchField.text && !searchField.activeFocus
                            }

                            Keys.onEscapePressed: if (root.goBack) root.goBack()
                        }
                    }
                }

                // Gallery GridView
                GridView {
                    id: galleryGrid
                    width: parent.width
                    height: parent.height - 36 - theme.spacingSm
                    cellWidth: Math.floor(galleryGrid.width / 2)
                    cellHeight: 140
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    model: {
                        if (!root.wp || !root.wp.wallpapers) return []
                        const q = searchField.text.toLowerCase().trim()
                        if (!q) return root.wp.wallpapers
                        return root.wp.wallpapers.filter(w => {
                            return (w.title && w.title.toLowerCase().includes(q)) ||
                                   (w.id && w.id.includes(q)) ||
                                   (w.tags && w.tags.some(t => t.toLowerCase().includes(q)))
                        })
                    }

                    delegate: Item {
                        width: galleryGrid.cellWidth
                        height: galleryGrid.cellHeight

                        readonly property var itemData: modelData
                        readonly property bool isSelected: root.selectedWallpaperId === itemData.id
                        readonly property bool isGrubActive: (root.activeGrubId !== "" && root.activeGrubId === itemData.id) ||
                                                             (root.activeGrubPath !== "" && itemData.preview && root.activeGrubPath === itemData.preview)

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 4
                            radius: theme.radiusItem
                            color: isSelected ? theme.activeFill : (cardMouse.containsMouse ? theme.hoverFill : theme.itemFill)
                            border.width: isSelected ? 2 : 1
                            border.color: isSelected ? theme.glassBorderStrong : theme.glassBorderSubtle

                            Behavior on color { ColorAnimation { duration: theme.animDurationFast } }

                            Column {
                                anchors.fill: parent
                                anchors.margins: 6
                                spacing: 5

                                Item {
                                    width: parent.width
                                    height: 84

                                    Image {
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
                                        anchors.fill: parent
                                        radius: theme.radiusSmall
                                        color: "transparent"
                                        border.width: 1
                                        border.color: theme.glassBorderSubtle
                                    }

                                    // Active in GRUB badge (top-left)
                                    Rectangle {
                                        visible: isGrubActive
                                        anchors.top: parent.top
                                        anchors.left: parent.left
                                        anchors.margins: 4
                                        height: 18
                                        width: grubBadgeRow.implicitWidth + 10
                                        radius: 4
                                        color: "#D9101014"
                                        border.width: 1
                                        border.color: theme.glassBorderStrong

                                        Row {
                                            id: grubBadgeRow
                                            anchors.centerIn: parent
                                            spacing: 3

                                            Text {
                                                renderType: Text.NativeRendering
                                                text: ""
                                                color: theme.textStrong
                                                font.pixelSize: 9
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            Text {
                                                renderType: Text.NativeRendering
                                                text: "GRUB"
                                                color: theme.textStrong
                                                font.pixelSize: 9
                                                font.weight: Font.Bold
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }
                                    }

                                    // Selection badge (top-right)
                                    Rectangle {
                                        visible: isSelected
                                        anchors.top: parent.top
                                        anchors.right: parent.right
                                        anchors.margins: 4
                                        width: 20
                                        height: 20
                                        radius: 10
                                        color: theme.activeFill
                                        border.width: 1
                                        border.color: theme.glassBorderStrong

                                        Text {
                                            renderType: Text.NativeRendering
                                            anchors.centerIn: parent
                                            text: ""
                                            color: theme.textStrong
                                            font.pixelSize: 10
                                        }
                                    }
                                }

                                Text {
                                    renderType: Text.NativeRendering
                                    width: parent.width
                                    text: itemData.title || "Sem título"
                                    color: isSelected ? theme.textStrong : theme.textMedium
                                    font.pixelSize: theme.fontSizeXs
                                    font.weight: isSelected ? Font.DemiBold : Font.Normal
                                    elide: Text.ElideRight
                                }
                            }

                            MouseArea {
                                id: cardMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.selectedWallpaperId = itemData.id || ""
                                    root.selectedWallpaperTitle = itemData.title || "Wallpaper Selecionado"
                                    root.selectedWallpaperPath = itemData.preview || ""
                                }
                            }
                        }
                    }
                }
            }

            // ==========================================
            // ==========================================
            // Right Column: Preview & Apply (48% Width)
            // ==========================================
            Rectangle {
                width: Math.round((parent.width - theme.spacingLg) * 0.48)
                height: parent.height
                radius: theme.radiusItem
                color: theme.itemFill
                border.width: 1
                border.color: theme.glassBorderSubtle
                clip: true

                // Top Preview Section
                Column {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: actionsCol.top
                    anchors.margins: theme.spacingLg
                    spacing: theme.spacingSm
                    clip: true

                    // Section Title & Persistence Status
                    Row {
                        width: parent.width
                        spacing: theme.spacingSm

                        Text {
                            renderType: Text.NativeRendering
                            text: "Pré-visualização do GRUB"
                            color: theme.textStrong
                            font.pixelSize: theme.fontSizeMd
                            font.weight: Font.DemiBold
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            height: 20
                            width: stateBadgeText.implicitWidth + 12
                            radius: 10
                            readonly property bool isCurrent: (root.selectedWallpaperId !== "" && root.selectedWallpaperId === root.activeGrubId) ||
                                                              (root.selectedWallpaperPath !== "" && root.selectedWallpaperPath === root.activeGrubPath)
                            color: isCurrent ? theme.activeFill : theme.hoverFill
                            border.width: 1
                            border.color: isCurrent ? theme.glassBorderStrong : theme.glassBorderSubtle

                            Text {
                                id: stateBadgeText
                                anchors.centerIn: parent
                                renderType: Text.NativeRendering
                                text: parent.isCurrent ? "● Salvo no GRUB" : "● Não Aplicado"
                                color: parent.isCurrent ? theme.textStrong : theme.textMuted
                                font.pixelSize: theme.fontSizeXs
                                font.weight: Font.Medium
                            }
                        }
                    }

                    Text {
                        renderType: Text.NativeRendering
                        width: parent.width
                        text: root.selectedWallpaperTitle || "Nenhum wallpaper selecionado"
                        color: theme.textMedium
                        font.pixelSize: theme.fontSizeXs
                        elide: Text.ElideRight
                    }

                    // 16:9 Screen Mockup with Floating Glass Card
                    Item {
                        width: parent.width
                        height: Math.min(Math.round(width * 9 / 16), parent.height - 30)
                        anchors.horizontalCenter: parent.horizontalCenter

                        Rectangle {
                            anchors.fill: parent
                            radius: theme.radiusItem
                            color: "#0E0E10"
                            clip: true

                            // Wallpaper preview
                            Image {
                                id: fullWpPreview
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectCrop
                                source: root.selectedWallpaperPath ? ("file://" + root.selectedWallpaperPath) : ""
                                asynchronous: true
                            }

                            // Dark overlay to simulate screen boot ambiance
                            Rectangle {
                                anchors.fill: parent
                                color: "#10000000"
                            }

                            // Simulated Floating Glass Card (matching the exact x=60, y=520, w=560, h=620 on 2560x1440)
                            Rectangle {
                                id: previewCard
                                x: Math.round(parent.width * (60 / 2560))
                                y: Math.round(parent.height * (520 / 1440))
                                width: Math.round(parent.width * (560 / 2560))
                                height: Math.round(parent.height * (620 / 1440))
                                radius: Math.max(4, Math.round(20 * (parent.width / 2560)))
                                color: "#26000000"
                                border.width: 0
                                clip: true

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: Math.max(4, Math.round(12 * (parent.width / 2560)))
                                    spacing: 3

                                    Text {
                                        renderType: Text.NativeRendering
                                        text: "BULLDOZE 3.0"
                                        color: "#FFFFFF"
                                        font.pixelSize: Math.max(7, Math.round(11 * (parent.width / 2560)))
                                        font.weight: Font.Bold
                                        font.family: "Roboto Mono"
                                    }

                                    Text {
                                        renderType: Text.NativeRendering
                                        text: "SELETOR DE BOOT"
                                        color: "#BFFFFFFF"
                                        font.pixelSize: Math.max(5, Math.round(7 * (parent.width / 2560)))
                                        font.family: "Roboto Mono"
                                    }

                                    Item { width: 1; height: 3 }

                                    // Active pill item
                                    Rectangle {
                                        width: parent.width
                                        height: Math.max(12, Math.round(20 * (parent.width / 2560)))
                                        radius: 3
                                        color: "#33FFFFFF"

                                        Row {
                                            anchors.fill: parent
                                            anchors.leftMargin: 4
                                            spacing: 4
                                            Text {
                                                renderType: Text.NativeRendering
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: ""
                                                color: "#FFFFFF"
                                                font.pixelSize: Math.max(5, Math.round(7 * (parent.width / 2560)))
                                            }
                                            Text {
                                                renderType: Text.NativeRendering
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: "Arch Linux"
                                                color: "#FFFFFF"
                                                font.pixelSize: Math.max(5, Math.round(7 * (parent.width / 2560)))
                                                font.weight: Font.Bold
                                                font.family: "Roboto Mono"
                                            }
                                        }
                                    }

                                    // Second item
                                    Rectangle {
                                        width: parent.width
                                        height: Math.max(10, Math.round(16 * (parent.width / 2560)))
                                        radius: 3
                                        color: "transparent"

                                        Row {
                                            anchors.fill: parent
                                            anchors.leftMargin: 4
                                            spacing: 4
                                            Text {
                                                renderType: Text.NativeRendering
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: ""
                                                color: "#C0FFFFFF"
                                                font.pixelSize: Math.max(5, Math.round(7 * (parent.width / 2560)))
                                            }
                                            Text {
                                                renderType: Text.NativeRendering
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: "Linux CachyOS"
                                                color: "#C0FFFFFF"
                                                font.pixelSize: Math.max(5, Math.round(7 * (parent.width / 2560)))
                                                font.family: "Roboto Mono"
                                            }
                                        }
                                    }

                                    // Third item
                                    Rectangle {
                                        width: parent.width
                                        height: Math.max(10, Math.round(16 * (parent.width / 2560)))
                                        radius: 3
                                        color: "transparent"

                                        Row {
                                            anchors.fill: parent
                                            anchors.leftMargin: 4
                                            spacing: 4
                                            Text {
                                                renderType: Text.NativeRendering
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: ""
                                                color: "#C0FFFFFF"
                                                font.pixelSize: Math.max(5, Math.round(7 * (parent.width / 2560)))
                                            }
                                            Text {
                                                renderType: Text.NativeRendering
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: "Windows Boot Manager"
                                                color: "#C0FFFFFF"
                                                font.pixelSize: Math.max(5, Math.round(7 * (parent.width / 2560)))
                                                font.family: "Roboto Mono"
                                            }
                                        }
                                    }
                                }
                            }

                            // Outer frame border
                            Rectangle {
                                anchors.fill: parent
                                radius: theme.radiusItem
                                color: "transparent"
                                border.width: 1
                                border.color: theme.glassBorderSubtle
                            }
                        }
                    }
                }

                // Bottom Action Buttons (Anchored inside the box)
                Column {
                    id: actionsCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: theme.spacingLg
                    spacing: theme.spacingSm

                    // Status Message Banner (if any)
                    Rectangle {
                        visible: root.statusMessage !== ""
                        width: parent.width
                        height: 30
                        radius: theme.radiusSmall
                        color: theme.activeFill
                        border.width: 1
                        border.color: theme.glassBorderStrong

                        Row {
                            anchors.centerIn: parent
                            spacing: theme.spacingSm
                            Text {
                                renderType: Text.NativeRendering
                                text: ""
                                color: theme.textStrong
                                font.pixelSize: theme.fontSizeXs
                            }
                            Text {
                                renderType: Text.NativeRendering
                                text: root.statusMessage
                                color: theme.textStrong
                                font.pixelSize: theme.fontSizeXs
                                font.weight: Font.Medium
                            }
                        }
                    }

                    // Action Button: Apply to GRUB
                    Rectangle {
                        width: parent.width
                        height: 38
                        radius: theme.radiusItem
                        color: root.isApplying ? theme.hoverFill : (applyBtnMouse.containsMouse ? theme.activeFill : theme.itemFill)
                        border.width: 1
                        border.color: theme.glassBorderStrong

                        Behavior on color { ColorAnimation { duration: theme.animDurationFast } }

                        Row {
                            anchors.centerIn: parent
                            spacing: theme.spacingSm

                            Text {
                                renderType: Text.NativeRendering
                                text: root.isApplying ? "" : ""
                                color: theme.textStrong
                                font.pixelSize: theme.fontSizeSm
                            }

                            Text {
                                renderType: Text.NativeRendering
                                readonly property bool isCurrent: (root.selectedWallpaperId !== "" && root.selectedWallpaperId === root.activeGrubId) ||
                                                                  (root.selectedWallpaperPath !== "" && root.selectedWallpaperPath === root.activeGrubPath)
                                text: root.isApplying ? "Processando e Sincronizando..." :
                                      (isCurrent ? "Reaplicar Wallpaper no GRUB" : "Salvar e Aplicar Wallpaper no GRUB")
                                color: theme.textStrong
                                font.pixelSize: theme.fontSizeSm
                                font.weight: Font.DemiBold
                            }
                        }

                        MouseArea {
                            id: applyBtnMouse
                            anchors.fill: parent
                            enabled: !root.isApplying && root.selectedWallpaperPath !== ""
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.isApplying = true
                                root.statusMessage = "Renderizando card com blur e salvando no GRUB..."
                                applyProc.running = true
                            }
                        }
                    }

                    // Secondary Action: Test GRUB Live
                    Rectangle {
                        width: parent.width
                        height: 34
                        radius: theme.radiusItem
                        color: testBtnMouse.containsMouse ? theme.hoverFill : "transparent"
                        border.width: 1
                        border.color: testBtnMouse.containsMouse ? theme.glassBorderStrong : theme.glassBorderSubtle

                        Behavior on color { ColorAnimation { duration: theme.animDurationFast } }

                        Row {
                            anchors.centerIn: parent
                            spacing: theme.spacingSm

                            Text {
                                renderType: Text.NativeRendering
                                text: ""
                                color: theme.textMedium
                                font.pixelSize: theme.fontSizeSm
                            }

                            Text {
                                renderType: Text.NativeRendering
                                text: "Visualizar GRUB em Janela (Sem Reiniciar)"
                                color: theme.textMedium
                                font.pixelSize: theme.fontSizeSm
                                font.weight: Font.Medium
                            }
                        }

                        MouseArea {
                            id: testBtnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                previewProc.running = true
                            }
                        }
                    }
                }
            }
        }
    }
}
