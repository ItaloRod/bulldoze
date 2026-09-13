import QtQuick
import "../../modules"
import ".."

Item {
    id: root

    property var goBack
    property var gaming

    readonly property var game: gaming

    Theme {
        id: theme
    }

    // State for preset editor
    property bool isEditingPreset: false
    property string editId: ""
    property string editName: ""
    property string editGame: ""
    property int editWidth: 1920
    property int editHeight: 1080
    property int editRenderWidth: 0
    property int editRenderHeight: 0
    property bool editGrabCursor: true
    property bool editFsr: false
    property int editSharpness: 2

    onVisibleChanged: {
        if (visible && root.game) {
            root.game.loadConfig()
            isEditingPreset = false
        }
    }

    // --- REUSABLE COMPONENTS ---

    // 1. Mini Top Quick Toggle Button (Matches Home style, compact size)
    component MiniHomeToggle: Rectangle {
        id: miniBtn
        property string iconGlyph: ""
        property string label: ""
        property bool active: false
        signal clicked()

        height: 26
        implicitWidth: miniRow.implicitWidth + 14
        radius: theme.radiusSmall
        color: active ? theme.activeFill : (miniMouse.containsMouse ? theme.hoverFill : theme.itemFill)
        border.width: 1
        border.color: active ? theme.glassBorderStrong : (miniMouse.containsMouse ? theme.glassBorderSubtle : "transparent")
        scale: miniMouse.pressed ? 0.94 : (miniMouse.containsMouse ? 1.04 : 1.0)
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

        Row {
            id: miniRow
            anchors.centerIn: parent
            spacing: 5

            Text {
                renderType: Text.NativeRendering
                text: miniBtn.iconGlyph
                color: miniBtn.active ? theme.textStrong : (miniMouse.containsMouse ? theme.textStrong : theme.textMuted)
                font.pixelSize: 11
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                renderType: Text.NativeRendering
                text: miniBtn.label + (miniBtn.active ? " (ON)" : "")
                color: miniBtn.active ? theme.textStrong : (miniMouse.containsMouse ? theme.textStrong : theme.textMedium)
                font.pixelSize: 10
                font.weight: miniBtn.active ? Font.Bold : Font.Medium
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            id: miniMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: miniBtn.clicked()
        }
    }

    // 2. Setting Toggle Row
    component SettingToggleRow: Rectangle {
        id: toggleRow
        property string iconGlyph: ""
        property string title: ""
        property string subtitle: ""
        property bool checked: false
        signal toggled()

        width: parent ? parent.width : 540
        implicitHeight: Math.max(38, contentCol.implicitHeight + 8)
        radius: theme.radiusSmall
        color: rowMouse.containsMouse ? theme.hoverFill : "transparent"

        Behavior on color {
            ColorAnimation { duration: theme.animDurationFast }
        }

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

    // 3. Setting Pill Selector
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

        Behavior on color {
            ColorAnimation { duration: theme.animDurationFast }
        }

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

    // 4. Section Jump Pill (Quick anchor navigation)
    component JumpPill: Rectangle {
        id: jPill
        property string label: ""
        signal clicked()

        implicitWidth: jText.implicitWidth + 16
        height: 22
        radius: 4
        color: jMouse.containsMouse ? theme.hoverFill : theme.itemFill
        border.width: 1
        border.color: jMouse.containsMouse ? theme.glassBorderStrong : theme.glassBorderSubtle

        Text {
            renderType: Text.NativeRendering
            id: jText
            anchors.centerIn: parent
            text: jPill.label
            color: jMouse.containsMouse ? theme.textStrong : theme.textMuted
            font.pixelSize: 10
            font.weight: Font.Medium
        }

        MouseArea {
            id: jMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: jPill.clicked()
        }
    }

    // 5. Section Group Header / Banner
    component GroupBanner: Rectangle {
        property string iconGlyph: ""
        property string title: ""
        property string subtitle: ""

        width: parent ? parent.width : 540
        height: 38
        radius: theme.radiusSmall
        color: theme.itemFill
        border.width: 1
        border.color: theme.glassBorderSubtle

        Row {
            anchors.fill: parent
            anchors.leftMargin: theme.spacingSm
            anchors.rightMargin: theme.spacingSm
            spacing: theme.spacingSm

            Text {
                renderType: Text.NativeRendering
                anchors.verticalCenter: parent.verticalCenter
                text: iconGlyph
                color: theme.textStrong
                font.pixelSize: 14
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1

                Text {
                    renderType: Text.NativeRendering
                    text: title
                    color: theme.textStrong
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                }

                Text {
                    renderType: Text.NativeRendering
                    text: subtitle
                    color: theme.textMuted
                    font.pixelSize: 10
                }
            }
        }
    }

    // 6. Section Subtitle Header
    component SectionHeader: Item {
        property string title: ""
        width: parent ? parent.width : 540
        height: 22

        Text {
            renderType: Text.NativeRendering
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: parent.title
            color: theme.textSubtle
            font.pixelSize: 10
            font.weight: Font.DemiBold
            font.capitalization: Font.AllUppercase
        }
    }

    // --- MAIN LAYOUT ---
    Column {
        anchors.fill: parent
        anchors.margins: theme.spacingLg
        spacing: theme.spacingSm

        // TOP HEADER: Title, Back Button & Home Quick Toggles (Reduced Size)
        Item {
            width: parent.width
            height: 34

            // Left: Back button + Title
            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: theme.spacingSm

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 28
                    height: 28
                    radius: theme.radiusSmall
                    color: closeMouse.containsMouse ? theme.hoverFill : theme.itemFill
                    border.width: 1
                    border.color: closeMouse.containsMouse ? theme.glassBorderStrong : theme.glassBorderSubtle
                    scale: closeMouse.pressed ? 0.92 : 1.0

                    Behavior on color { ColorAnimation { duration: theme.animDurationFast } }
                    Behavior on scale { NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic } }

                    Text {
                        renderType: Text.NativeRendering
                        anchors.centerIn: parent
                        text: ""
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

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 0

                    Text {
                        renderType: Text.NativeRendering
                        text: "Configurações de Jogos"
                        color: theme.textStrong
                        font.pixelSize: theme.fontSizeMd
                        font.weight: Font.DemiBold
                    }

                    Text {
                        renderType: Text.NativeRendering
                        text: "Gaming Mode • Tela Única com Rolagem"
                        color: theme.textMuted
                        font.pixelSize: 10
                    }
                }
            }

            // Right: Same Quick Toggles from Home (Compact Size)
            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                MiniHomeToggle {
                    iconGlyph: ""
                    label: "GameMode"
                    active: root.game ? root.game.gamemodeEnabled : false
                    onClicked: if (root.game) root.game.toggleGamemode()
                }

                MiniHomeToggle {
                    iconGlyph: ""
                    label: "Bulldoptimizer"
                    active: root.game ? root.game.bulldoptimizerEnabled : false
                    onClicked: if (root.game) root.game.toggleBulldoptimizer()
                }

                MiniHomeToggle {
                    iconGlyph: ""
                    label: "MangoHud"
                    active: root.game ? root.game.mangohudEnabled : false
                    onClicked: if (root.game) root.game.toggleMangohud()
                }

                MiniHomeToggle {
                    iconGlyph: ""
                    label: "Gamescope"
                    active: root.game ? root.game.gamescopeEnabled : false
                    onClicked: if (root.game) root.game.toggleGamescope()
                }
            }
        }

        // NAVIGATION JUMP BAR (Allows direct anchor jumping while keeping all content on the same scrollable screen)
        Row {
            width: parent.width
            spacing: 6

            Text {
                renderType: Text.NativeRendering
                text: "Ir para:"
                color: theme.textSubtle
                font.pixelSize: 10
                anchors.verticalCenter: parent.verticalCenter
            }

            JumpPill {
                label: " 1. Gamescope"
                onClicked: mainFlick.contentY = sectionGs.y
            }

            JumpPill {
                label: "🎯 2. Presets por Jogo"
                onClicked: mainFlick.contentY = sectionPresets.y
            }

            JumpPill {
                label: " 3. MangoHud"
                onClicked: mainFlick.contentY = sectionMh.y
            }

            JumpPill {
                label: " 4. Bulldoptimizer"
                onClicked: mainFlick.contentY = sectionBo.y
            }
        }

        // Separator
        Rectangle {
            width: parent.width
            height: 1
            color: theme.separator
        }

        // UNIFIED SCROLLABLE VIEW (Everything is on this single screen!)
        Flickable {
            id: mainFlick
            width: parent.width
            height: parent.height - 80
            contentWidth: width
            contentHeight: contentCol.implicitHeight + 40
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: contentCol
                width: parent.width
                spacing: theme.spacingMd

                // =========================================================
                // SEÇÃO 1: GAMESCOPE (RESOLUÇÃO, FSR & CORREÇÃO DE MOUSE)
                // =========================================================
                Column {
                    id: sectionGs
                    width: parent.width
                    spacing: theme.spacingSm

                    GroupBanner {
                        iconGlyph: ""
                        title: "1. Gamescope — Resolução Virtual, FSR & Entrada"
                        subtitle: "Ajuste resoluções (-w / -W), taxa de atualização e correção de clique do mouse"
                    }

                    SectionHeader { title: "Monitor & Tela de Saída (-W / -H)" }

                    // Native Resolution Selector
                    Row {
                        width: parent.width
                        spacing: theme.spacingSm

                        Text {
                            renderType: Text.NativeRendering
                            text: "Resolução do Monitor:"
                            color: theme.textMedium
                            font.pixelSize: theme.fontSizeSm
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        SettingPill {
                            width: 76
                            label: "1080p"
                            active: root.game ? (root.game.gsWidth === 1920 && root.game.gsHeight === 1080) : false
                            onClicked: if (root.game) root.game.setResolution(1920, 1080)
                        }

                        SettingPill {
                            width: 76
                            label: "1440p"
                            active: root.game ? (root.game.gsWidth === 2560 && root.game.gsHeight === 1440) : false
                            onClicked: if (root.game) root.game.setResolution(2560, 1440)
                        }

                        SettingPill {
                            width: 76
                            label: "4K UHD"
                            active: root.game ? (root.game.gsWidth === 3840 && root.game.gsHeight === 2160) : false
                            onClicked: if (root.game) root.game.setResolution(3840, 2160)
                        }

                        SettingPill {
                            width: 86
                            label: "UW 3440p"
                            active: root.game ? (root.game.gsWidth === 3440 && root.game.gsHeight === 1440) : false
                            onClicked: if (root.game) root.game.setResolution(3440, 1440)
                        }
                    }

                    // Refresh Rate Selector
                    Row {
                        width: parent.width
                        spacing: theme.spacingSm

                        Text {
                            renderType: Text.NativeRendering
                            text: "Taxa de Atualização:"
                            color: theme.textMedium
                            font.pixelSize: theme.fontSizeSm
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Repeater {
                            model: [240, 165, 144, 120, 60]
                            delegate: SettingPill {
                                required property int modelData
                                width: 62
                                label: modelData + "Hz"
                                active: root.game ? root.game.gsRefreshRate === modelData : false
                                onClicked: if (root.game) root.game.setRefreshRate(modelData)
                            }
                        }
                    }

                    SettingToggleRow {
                        iconGlyph: ""
                        title: "Modo Tela Cheia Exclusiva (--fullscreen)"
                        subtitle: "Executa a sessão do jogo cobrindo a tela inteira (-f)"
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

                    SectionHeader { title: "Resolução do Jogo (-w / -h) & Super Resolução (FSR)" }

                    // Render Resolution (Upscaling Source)
                    Row {
                        width: parent.width
                        spacing: theme.spacingSm

                        Text {
                            renderType: Text.NativeRendering
                            text: "Renderização do Jogo:"
                            color: theme.textMedium
                            font.pixelSize: theme.fontSizeSm
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        SettingPill {
                            width: 76
                            label: "Nativo"
                            active: root.game ? root.game.gsRenderWidth === 0 : true
                            onClicked: if (root.game) root.game.setRenderResolution(0, 0)
                        }

                        SettingPill {
                            width: 76
                            label: "1080p"
                            active: root.game ? root.game.gsRenderWidth === 1920 : false
                            onClicked: if (root.game) root.game.setRenderResolution(1920, 1080)
                        }

                        SettingPill {
                            width: 76
                            label: "720p"
                            active: root.game ? root.game.gsRenderWidth === 1280 : false
                            onClicked: if (root.game) root.game.setRenderResolution(1280, 720)
                        }
                    }

                    SettingToggleRow {
                        iconGlyph: "󰢮"
                        title: "AMD FidelityFX FSR (-F fsr)"
                        subtitle: "Upscaling inteligente com ganho de FPS a partir de resolução mais leve"
                        checked: root.game ? root.game.gsFsr : false
                        onToggled: {
                            if (root.game) {
                                root.game.gsFsr = !root.game.gsFsr
                                if (root.game.gsFsr) root.game.gsScalerFilter = "fsr"
                                root.game.saveConfig()
                            }
                        }
                    }

                    // FSR Sharpness Selector
                    Row {
                        width: parent.width
                        visible: root.game ? root.game.gsFsr : false
                        spacing: theme.spacingSm

                        Text {
                            renderType: Text.NativeRendering
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

                    // FPS Limiter
                    Row {
                        width: parent.width
                        spacing: theme.spacingSm

                        Text {
                            renderType: Text.NativeRendering
                            text: "Limite de FPS:"
                            color: theme.textMedium
                            font.pixelSize: theme.fontSizeSm
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Repeater {
                            model: [
                                { label: "Livre", val: 0 },
                                { label: "240", val: 240 },
                                { label: "165", val: 165 },
                                { label: "144", val: 144 },
                                { label: "120", val: 120 },
                                { label: "60", val: 60 }
                            ]
                            delegate: SettingPill {
                                required property var modelData
                                width: 62
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

                    SectionHeader { title: "Controles & Correções de Entrada (Mouse)" }

                    // MOUSE OFFSET FIX: Travar Cursor na Janela (--force-grab-cursor)
                    SettingToggleRow {
                        iconGlyph: "󰍽"
                        title: "Travar Cursor na Janela (--force-grab-cursor)"
                        subtitle: "Corrige desalinhamento do clique e botões fora de posição em jogos Unity/Wine (ex: Cities: Skylines II)"
                        checked: root.game ? root.game.gsForceGrabCursor : false
                        onToggled: {
                            if (root.game) {
                                root.game.gsForceGrabCursor = !root.game.gsForceGrabCursor
                                root.game.saveConfig()
                            }
                        }
                    }

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
                }

                // Separator
                Rectangle {
                    width: parent.width
                    height: 1
                    color: theme.separator
                }

                // =========================================================
                // SEÇÃO 2: PRESETS ESPECÍFICOS POR JOGO DO GAMESCOPE
                // =========================================================
                Column {
                    id: sectionPresets
                    width: parent.width
                    spacing: theme.spacingSm

                    GroupBanner {
                        iconGlyph: "🎯"
                        title: "2. Perfis e Presets do Gamescope por Jogo"
                        subtitle: "Alterne, crie, edite ou exclua perfis otimizados para jogos específicos"
                    }

                    // Action Bar: Salvar Novo Preset
                    Row {
                        width: parent.width
                        spacing: theme.spacingSm

                        Text {
                            renderType: Text.NativeRendering
                            text: "Presets Salvos:"
                            color: theme.textStrong
                            font.pixelSize: theme.fontSizeSm
                            font.weight: Font.DemiBold
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Item { width: 1; height: 1; anchors.leftMargin: 1 }

                        Rectangle {
                            height: 26
                            implicitWidth: newBtnText.implicitWidth + 20
                            radius: theme.radiusSmall
                            color: newBtnMouse.containsMouse ? theme.hoverFill : theme.itemFill
                            border.width: 1
                            border.color: newBtnMouse.containsMouse ? theme.glassBorderStrong : theme.glassBorderSubtle

                            Text {
                                id: newBtnText
                                renderType: Text.NativeRendering
                                anchors.centerIn: parent
                                text: "➕ Salvar Configuração Atual como Novo Preset"
                                color: theme.textStrong
                                font.pixelSize: 11
                                font.weight: Font.Medium
                            }

                            MouseArea {
                                id: newBtnMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.editId = ""
                                    root.editName = "Meu Preset Personalizado"
                                    root.editGame = "Cities: Skylines II"
                                    root.editWidth = root.game ? root.game.gsWidth : 1920
                                    root.editHeight = root.game ? root.game.gsHeight : 1080
                                    root.editRenderWidth = root.game ? root.game.gsRenderWidth : 0
                                    root.editRenderHeight = root.game ? root.game.gsRenderHeight : 0
                                    root.editGrabCursor = root.game ? root.game.gsForceGrabCursor : true
                                    root.editFsr = root.game ? root.game.gsFsr : false
                                    root.editSharpness = root.game ? root.game.gsFsrSharpness : 2
                                    root.isEditingPreset = true
                                }
                            }
                        }
                    }

                    // INLINE PRESET EDITOR CARD (Visible when editing or creating)
                    Rectangle {
                        width: parent.width
                        visible: root.isEditingPreset
                        implicitHeight: editFormCol.implicitHeight + 20
                        radius: theme.radiusSmall
                        color: theme.glassFillDark
                        border.width: 1
                        border.color: theme.glassBorderStrong

                        Column {
                            id: editFormCol
                            anchors.fill: parent
                            anchors.margins: theme.spacingMd
                            spacing: theme.spacingSm

                            Text {
                                renderType: Text.NativeRendering
                                text: root.editId === "" ? "Criar Novo Preset de Jogo" : "Editar Preset: " + root.editName
                                color: theme.textStrong
                                font.pixelSize: theme.fontSizeSm
                                font.weight: Font.Bold
                            }

                            // Inputs Row (Nome do Preset + Jogo)
                            Row {
                                width: parent.width
                                spacing: theme.spacingMd

                                Column {
                                    width: (parent.width - theme.spacingMd) / 2
                                    spacing: 3

                                    Text {
                                        renderType: Text.NativeRendering
                                        text: "Nome do Preset:"
                                        color: theme.textMuted
                                        font.pixelSize: 10
                                    }

                                    Rectangle {
                                        width: parent.width
                                        height: 28
                                        radius: 4
                                        color: theme.itemFill
                                        border.width: 1
                                        border.color: nameInput.activeFocus ? theme.accent : theme.glassBorderSubtle

                                        TextInput {
                                            id: nameInput
                                            anchors.fill: parent
                                            anchors.leftMargin: 8
                                            anchors.rightMargin: 8
                                            verticalAlignment: TextInput.AlignVCenter
                                            color: theme.textStrong
                                            font.pixelSize: 11
                                            text: root.editName
                                            onTextChanged: root.editName = text
                                        }
                                    }
                                }

                                Column {
                                    width: (parent.width - theme.spacingMd) / 2
                                    spacing: 3

                                    Text {
                                        renderType: Text.NativeRendering
                                        text: "Jogo Associado:"
                                        color: theme.textMuted
                                        font.pixelSize: 10
                                    }

                                    Rectangle {
                                        width: parent.width
                                        height: 28
                                        radius: 4
                                        color: theme.itemFill
                                        border.width: 1
                                        border.color: gameInput.activeFocus ? theme.accent : theme.glassBorderSubtle

                                        TextInput {
                                            id: gameInput
                                            anchors.fill: parent
                                            anchors.leftMargin: 8
                                            anchors.rightMargin: 8
                                            verticalAlignment: TextInput.AlignVCenter
                                            color: theme.textStrong
                                            font.pixelSize: 11
                                            text: root.editGame
                                            onTextChanged: root.editGame = text
                                        }
                                    }
                                }
                            }

                            // Toggles in Editor
                            Row {
                                width: parent.width
                                spacing: theme.spacingLg

                                SettingPill {
                                    label: root.editGrabCursor ? "󰍽 Trava de Cursor: ATIVA" : "󰍽 Trava de Cursor: OFF"
                                    active: root.editGrabCursor
                                    onClicked: root.editGrabCursor = !root.editGrabCursor
                                }

                                SettingPill {
                                    label: root.editFsr ? "󰢮 AMD FSR: ATIVO" : "󰢮 AMD FSR: OFF"
                                    active: root.editFsr
                                    onClicked: root.editFsr = !root.editFsr
                                }
                            }

                            // Action buttons: Salvar e Cancelar
                            Row {
                                anchors.right: parent.right
                                spacing: theme.spacingSm

                                Rectangle {
                                    height: 26
                                    implicitWidth: cancelText.implicitWidth + 16
                                    radius: 4
                                    color: cancelMouse.containsMouse ? theme.hoverFill : "transparent"
                                    border.width: 1
                                    border.color: theme.glassBorderSubtle

                                    Text {
                                        id: cancelText
                                        renderType: Text.NativeRendering
                                        anchors.centerIn: parent
                                        text: "Cancelar"
                                        color: theme.textMuted
                                        font.pixelSize: 11
                                    }

                                    MouseArea {
                                        id: cancelMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.isEditingPreset = false
                                    }
                                }

                                Rectangle {
                                    height: 26
                                    implicitWidth: saveText.implicitWidth + 18
                                    radius: 4
                                    color: theme.textStrong
                                    border.width: 1
                                    border.color: theme.glassBorderStrong

                                    Text {
                                        id: saveText
                                        renderType: Text.NativeRendering
                                        anchors.centerIn: parent
                                        text: "💾 Salvar Preset"
                                        color: theme.glassFillDark
                                        font.pixelSize: 11
                                        font.weight: Font.Bold
                                    }

                                    MouseArea {
                                        id: saveMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (root.editId === "") {
                                                if (root.game) root.game.savePreset(root.editName, root.editGame)
                                            } else {
                                                if (root.game) {
                                                    root.game.updatePreset(root.editId, {
                                                        "name": root.editName,
                                                        "game": root.editGame,
                                                        "width": root.editWidth,
                                                        "height": root.editHeight,
                                                        "render_width": root.editRenderWidth,
                                                        "render_height": root.editRenderHeight,
                                                        "force_grab_cursor": root.editGrabCursor,
                                                        "fsr": root.editFsr,
                                                        "fsr_sharpness": root.editSharpness
                                                    })
                                                }
                                            }
                                            root.isEditingPreset = false
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // PRESET CARDS LIST
                    Repeater {
                        model: root.game ? root.game.gamescopePresets : []
                        delegate: Rectangle {
                            id: presetCard
                            required property var modelData
                            width: parent.width
                            implicitHeight: pCardCol.implicitHeight + 16
                            radius: theme.radiusSmall
                            color: theme.itemFill
                            border.width: 1
                            border.color: theme.glassBorderSubtle

                            Column {
                                id: pCardCol
                                anchors.fill: parent
                                anchors.margins: theme.spacingSm
                                spacing: 4

                                Item {
                                    width: parent.width
                                    height: 24

                                    Row {
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: theme.spacingSm

                                        Text {
                                            renderType: Text.NativeRendering
                                            text: presetCard.modelData.name || "Preset"
                                            color: theme.textStrong
                                            font.pixelSize: 12
                                            font.weight: Font.DemiBold
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        Rectangle {
                                            height: 18
                                            implicitWidth: gameTagText.implicitWidth + 10
                                            radius: 3
                                            color: theme.hoverFill
                                            anchors.verticalCenter: parent.verticalCenter

                                            Text {
                                                id: gameTagText
                                                renderType: Text.NativeRendering
                                                anchors.centerIn: parent
                                                text: presetCard.modelData.game || "Global"
                                                color: theme.textMedium
                                                font.pixelSize: 9
                                                font.weight: Font.Medium
                                            }
                                        }
                                    }

                                    // Action Buttons: Aplicar, Editar, Excluir
                                    Row {
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 6

                                        // Aplicar Button
                                        Rectangle {
                                            height: 22
                                            implicitWidth: applyText.implicitWidth + 12
                                            radius: 4
                                            color: applyMouse.containsMouse ? theme.hoverFill : theme.itemFill
                                            border.width: 1
                                            border.color: theme.glassBorderSubtle

                                            Text {
                                                id: applyText
                                                renderType: Text.NativeRendering
                                                anchors.centerIn: parent
                                                text: "▶ Aplicar"
                                                color: theme.textStrong
                                                font.pixelSize: 10
                                                font.weight: Font.DemiBold
                                            }

                                            MouseArea {
                                                id: applyMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    if (root.game) root.game.applyGamescopePreset(presetCard.modelData)
                                                }
                                            }
                                        }

                                        // Editar Button
                                        Rectangle {
                                            height: 22
                                            implicitWidth: editText.implicitWidth + 12
                                            radius: 4
                                            color: editMouse.containsMouse ? theme.hoverFill : theme.itemFill
                                            border.width: 1
                                            border.color: theme.glassBorderSubtle

                                            Text {
                                                id: editText
                                                renderType: Text.NativeRendering
                                                anchors.centerIn: parent
                                                text: "✏️ Editar"
                                                color: theme.textMedium
                                                font.pixelSize: 10
                                            }

                                            MouseArea {
                                                id: editMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    root.editId = presetCard.modelData.id
                                                    root.editName = presetCard.modelData.name || ""
                                                    root.editGame = presetCard.modelData.game || ""
                                                    root.editWidth = presetCard.modelData.width || 1920
                                                    root.editHeight = presetCard.modelData.height || 1080
                                                    root.editRenderWidth = presetCard.modelData.render_width || 0
                                                    root.editRenderHeight = presetCard.modelData.render_height || 0
                                                    root.editGrabCursor = !!presetCard.modelData.force_grab_cursor
                                                    root.editFsr = !!presetCard.modelData.fsr
                                                    root.editSharpness = presetCard.modelData.fsr_sharpness !== undefined ? presetCard.modelData.fsr_sharpness : 2
                                                    root.isEditingPreset = true
                                                }
                                            }
                                        }

                                        // Excluir Button (only for custom presets)
                                        Rectangle {
                                            height: 22
                                            implicitWidth: delText.implicitWidth + 10
                                            radius: 4
                                            visible: presetCard.modelData.id !== "global_default"
                                            color: delMouse.containsMouse ? "#44FF3333" : "transparent"
                                            border.width: 1
                                            border.color: theme.glassBorderSubtle

                                            Text {
                                                id: delText
                                                renderType: Text.NativeRendering
                                                anchors.centerIn: parent
                                                text: "🗑️"
                                                color: theme.textMuted
                                                font.pixelSize: 10
                                            }

                                            MouseArea {
                                                id: delMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    if (root.game) root.game.deletePreset(presetCard.modelData.id)
                                                }
                                            }
                                        }
                                    }
                                }

                                // Specs row
                                Row {
                                    width: parent.width
                                    spacing: theme.spacingMd

                                    Text {
                                        renderType: Text.NativeRendering
                                        text: "Saída: " + (presetCard.modelData.width || 1920) + "x" + (presetCard.modelData.height || 1080) + " @" + (presetCard.modelData.refresh_rate || 144) + "Hz"
                                        color: theme.textMuted
                                        font.pixelSize: 10
                                    }

                                    Text {
                                        renderType: Text.NativeRendering
                                        text: "Render: " + (presetCard.modelData.render_width ? (presetCard.modelData.render_width + "x" + presetCard.modelData.render_height) : "Nativo")
                                        color: theme.textMuted
                                        font.pixelSize: 10
                                    }

                                    Text {
                                        renderType: Text.NativeRendering
                                        text: "FSR: " + (presetCard.modelData.fsr ? "Ativo" : "Off")
                                        color: theme.textMuted
                                        font.pixelSize: 10
                                    }

                                    Text {
                                        renderType: Text.NativeRendering
                                        text: "Trava Mouse: " + (presetCard.modelData.force_grab_cursor ? "Ativo (Fix Cities II)" : "Off")
                                        color: presetCard.modelData.force_grab_cursor ? theme.textStrong : theme.textMuted
                                        font.pixelSize: 10
                                        font.weight: presetCard.modelData.force_grab_cursor ? Font.Bold : Font.Normal
                                    }
                                }
                            }
                        }
                    }
                }

                // Separator
                Rectangle {
                    width: parent.width
                    height: 1
                    color: theme.separator
                }

                // =========================================================
                // SEÇÃO 3: MANGOHUD (TELEMETRIA E MONITORAMENTO)
                // =========================================================
                Column {
                    id: sectionMh
                    width: parent.width
                    spacing: theme.spacingSm

                    GroupBanner {
                        iconGlyph: ""
                        title: "3. MangoHud — Telemetria e Monitoramento de Hardware"
                        subtitle: "Métricas de FPS, carga de placa de vídeo, processador e consumo de memória"
                    }

                    SectionHeader { title: "Presets Rápidos do HUD" }

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
                        subtitle: "Exibe o gráfico de consistência e tempo de entrega dos quadros (ms)"
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

                // Separator
                Rectangle {
                    width: parent.width
                    height: 1
                    color: theme.separator
                }

                // =========================================================
                // SEÇÃO 4: BULLDOPTIMIZER (OTIMIZADOR DE SISTEMA & AMD)
                // =========================================================
                Column {
                    id: sectionBo
                    width: parent.width
                    spacing: theme.spacingSm

                    GroupBanner {
                        iconGlyph: ""
                        title: "4. Bulldoptimizer — Otimizações de Sistema & Driver"
                        subtitle: "Suspende efeitos gráficos do Hyprland e força frequências máximas na GPU AMD"
                    }

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

                    SectionHeader { title: "Hardware & Driver GPU (AMD Radeon)" }

                    SettingToggleRow {
                        iconGlyph: ""
                        title: "AMD DPM Performance (Max Clocks)"
                        subtitle: "Trava GPU Core e VRAM em clocks de alto desempenho para eliminar micro-stutters"
                        checked: root.game ? root.game.boAmdDpm : true
                        onToggled: {
                            if (root.game) {
                                root.game.boAmdDpm = !root.game.boAmdDpm
                                root.game.saveConfig()
                                if (root.game.bulldoptimizerEnabled) {
                                    root.game.applyBulldoptimizer(true)
                                }
                            }
                        }
                    }

                    SettingToggleRow {
                        iconGlyph: "⚡"
                        title: "AMD RADV Anti-Lag & Shader Boost"
                        subtitle: "Ativa compilador ACO, AMD Anti-Lag, cache de shaders de 50GB e XWayland sem esperas"
                        checked: root.game ? root.game.boRadvOptimizations : true
                        onToggled: {
                            if (root.game) {
                                root.game.boRadvOptimizations = !root.game.boRadvOptimizations
                                root.game.saveConfig()
                            }
                        }
                    }
                }
            }
        }
    }
}
