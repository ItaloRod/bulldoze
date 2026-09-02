import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
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

    onVisibleChanged: {
        if (visible) {
            searchField.text = ""
            if (root.wp) {
                root.wp.loadWallpapers()
                root.wp.loadConfig()
            }
            searchField.forceActiveFocus()
        }
    }

    // Component: Setting Pill Button
    component SettingPill: Rectangle {
        id: pill
        property string label: ""
        property bool active: false
        signal clicked()

        height: 28
        radius: theme.radiusSmall
        color: active ? theme.activeFill : (pMouse.containsMouse ? theme.hoverFill : theme.itemFill)
        border.width: 1
        border.color: active ? theme.glassBorderStrong : theme.glassBorderSubtle

        Behavior on color {
            ColorAnimation { duration: theme.animDurationFast }
        }

        Text {
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

    // Component: Toggle Row
    component SettingToggleRow: Rectangle {
        id: toggleRow
        property string iconGlyph: ""
        property string title: ""
        property string subtitle: ""
        property bool checked: false
        signal toggled()

        width: parent ? parent.width : 340
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

    // Component: Section Header
    component SectionHeader: Item {
        property string title: ""
        width: parent ? parent.width : 340
        height: 20

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

        // 1. Header (Title, Subtitle, Close Button)
        Row {
            width: parent.width
            height: 40
            spacing: theme.spacingMd

            // Icon & Title
            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 44
                spacing: 2

                Row {
                    spacing: theme.spacingSm
                    Text {
                        text: ""
                        color: theme.textStrong
                        font.pixelSize: theme.fontSizeTitle
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "Gerenciador de Wallpapers"
                        color: theme.textStrong
                        font.pixelSize: theme.fontSizeTitle
                        font.weight: Font.DemiBold
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Text {
                    text: "Wallpaper Engine Workshop • Shaders e Interatividade de Mouse"
                    color: theme.textMuted
                    font.pixelSize: theme.fontSizeXs
                }
            }

            // Close Button
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 32
                height: 32
                radius: theme.radiusSmall
                color: closeBtnMouse.containsMouse ? theme.hoverFill : "transparent"
                border.width: 1
                border.color: closeBtnMouse.containsMouse ? theme.glassBorderStrong : "transparent"

                Text {
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
            // Left Column: Gallery & Search (54% Width)
            // ==========================================
            Column {
                width: Math.round((parent.width - theme.spacingLg) * 0.54)
                height: parent.height
                spacing: theme.spacingSm

                // Search Header
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
                            anchors.verticalCenter: parent.verticalCenter
                            text: ""
                            color: theme.textSubtle
                            font.pixelSize: theme.fontSizeSm
                        }

                        TextInput {
                            id: searchField
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 30
                            color: theme.textStrong
                            font.pixelSize: theme.fontSizeSm
                            clip: true

                            Text {
                                anchors.fill: parent
                                text: "Pesquisar por nome ou tag..."
                                color: theme.textSubtle
                                font.pixelSize: theme.fontSizeSm
                                visible: !searchField.text && !searchField.activeFocus
                            }

                            Keys.onEscapePressed: if (root.goBack) root.goBack()
                        }
                    }
                }

                // Gallery GridView directly
                GridView {
                    id: galleryGrid
                    width: parent.width
                    height: parent.height - 36 - theme.spacingSm
                    cellWidth: Math.floor(galleryGrid.width / 2)
                    cellHeight: 154
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
                        readonly property bool isSelected: root.wp && root.wp.selectedId === itemData.id
                        readonly property bool isActive: root.wp && root.wp.activeId === itemData.id

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 4
                            radius: theme.radiusItem
                            color: isSelected ? theme.activeFill : (cardMouse.containsMouse ? theme.hoverFill : theme.itemFill)
                            border.width: isSelected ? 2 : 1
                            border.color: isSelected ? theme.glassBorderStrong : theme.glassBorderSubtle

                            Behavior on color {
                                ColorAnimation { duration: theme.animDurationFast }
                            }

                            Column {
                                anchors.fill: parent
                                anchors.margins: 6
                                spacing: 6

                                // Thumbnail Container
                                Item {
                                    width: parent.width
                                    height: 94

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

                                    // Fallback rectangle if no image
                                    Rectangle {
                                        anchors.fill: parent
                                        radius: theme.radiusSmall
                                        color: theme.glassFillDark
                                        visible: !thumbImg.visible
                                        Text {
                                            anchors.centerIn: parent
                                            text: ""
                                            color: theme.textSubtle
                                            font.pixelSize: 24
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

                                    // Active Badge (Currently displayed)
                                    Rectangle {
                                        visible: isActive
                                        anchors.top: parent.top
                                        anchors.left: parent.left
                                        anchors.margins: 4
                                        height: 18
                                        width: 60
                                        radius: 4
                                        color: theme.glassFillDark
                                        border.width: 1
                                        border.color: theme.glassBorderStrong

                                        Row {
                                            anchors.centerIn: parent
                                            spacing: 3
                                            Text {
                                                text: ""
                                                color: theme.textStrong
                                                font.pixelSize: 9
                                            }
                                            Text {
                                                text: "ATIVO"
                                                color: theme.textStrong
                                                font.pixelSize: 9
                                                font.weight: Font.Bold
                                            }
                                        }
                                    }

                                    // Type Badge
                                    Rectangle {
                                        anchors.top: parent.top
                                        anchors.right: parent.right
                                        anchors.margins: 4
                                        height: 18
                                        width: itemData.type === "video" ? 42 : 46
                                        radius: 4
                                        color: theme.glassFillDark

                                        Text {
                                            anchors.centerIn: parent
                                            text: itemData.type === "video" ? "VÍDEO" : "CENA"
                                            color: theme.textMuted
                                            font.pixelSize: 9
                                            font.weight: Font.DemiBold
                                        }
                                    }
                                }

                                // Title Label
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
                                id: cardMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (root.wp) {
                                        root.wp.selectWallpaper(itemData.id)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ==========================================
            // Right Column: Configuration Panel (46% Width)
            // ==========================================
            Rectangle {
                width: Math.round((parent.width - theme.spacingLg) * 0.46)
                height: parent.height
                radius: theme.radiusItem
                color: theme.itemFill
                border.width: 1
                border.color: theme.glassBorderSubtle

                Column {
                    anchors.fill: parent
                    anchors.margins: theme.spacingMd
                    spacing: theme.spacingSm

                    // Selected Wallpaper Info Header
                    Row {
                        width: parent.width
                        height: 48
                        spacing: theme.spacingSm

                        // Mini preview
                        Item {
                            width: 56
                            height: 44
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
                            width: parent.width - 64
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
                                text: (root.wp && root.wp.selectedWallpaper) ? ("ID: " + root.wp.selectedWallpaper.id + " • " + (root.wp.selectedWallpaper.tags ? root.wp.selectedWallpaper.tags.join(", ") : "Workshop")) : ""
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

                    // Scrollable Settings Sections via Flickable
                    Flickable {
                        width: parent.width
                        height: parent.height - 48 - 1 - 42 - theme.spacingSm * 3
                        contentWidth: width
                        contentHeight: settingsCol.implicitHeight
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds

                        Column {
                            id: settingsCol
                            width: parent.width - 4
                            spacing: theme.spacingMd

                            // Section: Aspect Ratio & Scaling
                            Column {
                                width: parent.width
                                spacing: 6

                                SectionHeader {
                                    title: "Proporção e Enquadramento"
                                }

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
                                        label: "Adaptar (Inteiro)"
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

                                Text {
                                    width: parent.width
                                    text: root.wp && root.wp.scaling === "fit" 
                                        ? "Modo Adaptar: exibe o wallpaper 100% sem cortes, com bordas neutras."
                                        : "Modo Preencher: ajusta suavemente ao monitor 16:9 sem distorção."
                                    color: theme.textMuted
                                    font.pixelSize: theme.fontSizeXs
                                    wrapMode: Text.WordWrap
                                }
                            }

                            // Section: Sponsor & Watermark Toggles
                            Column {
                                width: parent.width
                                spacing: 6

                                SectionHeader {
                                    title: "Camadas e Patrocínio"
                                }

                                SettingToggleRow {
                                    title: "Ocultar Patrocinador / Sponsor"
                                    subtitle: "Desativa automaticamente QR Codes e camadas de doação"
                                    iconGlyph: ""
                                    checked: root.wp ? root.wp.hideSponsor : true
                                    onToggled: {
                                        if (root.wp) {
                                            root.wp.setHideSponsor(!root.wp.hideSponsor)
                                        }
                                    }
                                }
                            }

                            // Section: Dynamic Shader Properties (e.g. X-Ray, Reveal, Sliders)
                            Column {
                                width: parent.width
                                spacing: 6
                                visible: dynamicPropertiesRepeater.count > 0

                                SectionHeader {
                                    title: "Propriedades da Cena"
                                }

                                Repeater {
                                    id: dynamicPropertiesRepeater
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

                                        // Boolean Property Toggle
                                        Loader {
                                            anchors.fill: parent
                                            active: propData.type === "bool"
                                            sourceComponent: SettingToggleRow {
                                                title: propData.text || propData.key
                                                subtitle: "Controle nativo de shader / camada"
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

                                        // Slider Property
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

                                                // Interactive Slider Track
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

                            // Section: Performance & Audio
                            Column {
                                width: parent.width
                                spacing: 6

                                SectionHeader {
                                    title: "Desempenho"
                                }

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
                                        label: "240 FPS (Nativo)"
                                        active: root.wp && root.wp.fps === 240
                                        onClicked: root.wp.setFps(240)
                                    }
                                }

                                SettingToggleRow {
                                    title: "Pausar com Janelas no Workspace"
                                    subtitle: "Economiza GPU pausando a animação quando houver janelas abertas"
                                    iconGlyph: "⏸"
                                    checked: root.wp && root.wp.pauseOnWindow
                                    onToggled: root.wp.setPauseOnWindow(!root.wp.pauseOnWindow)
                                }

                                SettingToggleRow {
                                    title: "Interatividade e Efeitos de Mouse"
                                    subtitle: "Permite hover, iluminação, revelação e parallax"
                                    iconGlyph: ""
                                    checked: root.wp && root.wp.mouseEnabled
                                    onToggled: root.wp.setMouseEnabled(!root.wp.mouseEnabled)
                                }
                            }
                        }
                    }

                    // Bottom Action Button
                    Rectangle {
                        width: parent.width
                        height: 42
                        radius: theme.radiusItem
                        color: applyBtnMouse.containsMouse ? theme.activeFill : theme.itemFill
                        border.width: 1
                        border.color: theme.glassBorderStrong

                        Behavior on color {
                            ColorAnimation { duration: theme.animDurationFast }
                        }

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
                                if (root.wp) {
                                    root.wp.applySelectedWallpaper()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
