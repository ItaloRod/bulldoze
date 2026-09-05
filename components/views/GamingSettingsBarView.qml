import QtQuick
import "../../modules"
import ".."

Item {
    id: root

    property var goBack
    property var gaming
    property string activeTab: "bulldoptimizer" // "bulldoptimizer" | "gamescope" | "mangohud"

    readonly property var game: gaming

    Theme {
        id: theme
    }

    onVisibleChanged: {
        if (visible && root.game) {
            root.game.loadConfig()
        }
    }

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
            font.pixelSize: 11
            font.weight: Font.DemiBold
            font.capitalization: Font.AllUppercase
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: theme.spacingXxl
        spacing: theme.spacingMd

        // 1. Header with Title, Back Button and Tab Switcher
        Item {
            width: parent.width
            height: 36

            // Left: Back button + Title column
            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: theme.spacingMd

                // Close / Back Button
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
                        renderType: Text.NativeRendering
                        anchors.centerIn: parent
                        text: ""
                        color: theme.textStrong
                        font.pixelSize: theme.fontSizeMd
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
                    spacing: 1

                    Text {
                        renderType: Text.NativeRendering
                        text: "Configurações de Jogos"
                        color: theme.textStrong
                        font.pixelSize: theme.fontSizeLg
                        font.weight: Font.DemiBold
                    }

                    Text {
                        renderType: Text.NativeRendering
                        text: "Bulldoptimizer, Gamescope HDR & MangoHud"
                        color: theme.textMuted
                        font.pixelSize: theme.fontSizeXs
                    }
                }
            }

            // Right: Tab Switcher Pills anchored cleanly to the right
            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: theme.spacingSm

                SettingPill {
                    label: "Bulldoptimizer"
                    active: root.activeTab === "bulldoptimizer"
                    onClicked: root.activeTab = "bulldoptimizer"
                }

                SettingPill {
                    label: "Gamescope"
                    active: root.activeTab === "gamescope"
                    onClicked: root.activeTab = "gamescope"
                }

                SettingPill {
                    label: "MangoHud"
                    active: root.activeTab === "mangohud"
                    onClicked: root.activeTab = "mangohud"
                }
            }
        }

        // Separator
        Rectangle {
            width: parent.width
            height: 1
            color: theme.separator
        }

        // Scrollable Content Area
        Flickable {
            width: parent.width
            height: parent.height - 70
            contentWidth: width
            contentHeight: contentCol.implicitHeight + 20
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: contentCol
                width: parent.width
                spacing: theme.spacingSm

                // =========================================================
                // TAB 0: BULLDOPTIMIZER (SYSTEM, HYPRLAND & GPU OPTIMIZATION)
                // =========================================================
                Column {
                    width: parent.width
                    visible: root.activeTab === "bulldoptimizer"
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

                    SectionHeader { title: "Hardware & Driver GPU (AMD Radeon)" }

                    SettingToggleRow {
                        iconGlyph: ""
                        title: "AMD DPM Performance (Max Clocks)"
                        subtitle: "Trava GPU Core e VRAM em clocks de alto desempenho para eliminar oscilações e micro-stutters"
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

                // =========================================================
                // TAB 1: GAMESCOPE (COMPREHENSIVE)
                // =========================================================
                Column {
                    width: parent.width
                    visible: root.activeTab === "gamescope"
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

                    // HDR SDR Nits Selector
                    Row {
                        width: parent.width
                        spacing: theme.spacingSm

                        Text {
                            renderType: Text.NativeRendering
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
                                width: 64
                                label: modelData + "Hz"
                                active: root.game ? root.game.gsRefreshRate === modelData : false
                                onClicked: {
                                    if (root.game) root.game.setRefreshRate(modelData)
                                }
                            }
                        }
                    }

                    // Native Resolution Selector
                    Row {
                        width: parent.width
                        spacing: theme.spacingSm

                        Text {
                            renderType: Text.NativeRendering
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

                    // Render Resolution (Upscaling Source)
                    Row {
                        width: parent.width
                        spacing: theme.spacingSm

                        Text {
                            renderType: Text.NativeRendering
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

                // =========================================================
                // TAB 2: MANGOHUD (COMPREHENSIVE)
                // =========================================================
                Column {
                    width: parent.width
                    visible: root.activeTab === "mangohud"
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

                    // HUD Position Selector
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
