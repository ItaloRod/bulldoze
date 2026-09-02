import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import "../modules"

PanelWindow {
    id: root

    WlrLayershell.namespace: "bulldoze-control-center"

    Theme {
        id: theme
    }

    property bool open: false
    property var showOsd
    property bool showGamingSettings: false
    property string activeGamingTab: "gamescope" // "gamescope" or "mangohud"

    visible: open || card.opacity > 0.001
    color: "transparent"
    focusable: true
    exclusiveZone: 0

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    Network { id: network }
    Bluetooth { id: bluetooth }
    Audio { id: audio }
    Gaming { id: gaming }
    UserProfile { id: userProfile }

    onOpenChanged: {
        if (open) {
            userProfile.refresh()
            gaming.loadConfig()
        } else {
            root.showGamingSettings = false
        }
    }

    function toggleAudio() {
        audio.toggleMute()
        if (showOsd) {
            showOsd(audio.muted ? "Áudio silenciado" : "Áudio " + audio.volume + "%", audio.muted ? 0 : audio.volumeRatio)
        }
    }

    function changeVolume(ratio) {
        audio.setVolume(ratio)
        if (showOsd) {
            showOsd("Áudio " + audio.volume + "%", ratio)
        }
    }

    // Reusable UI Components
    component SwitchButton: Rectangle {
        id: sw
        property bool checked: false
        signal toggled()

        width: 38
        height: 24
        radius: 12
        color: checked ? theme.textStrong : theme.itemFill
        border.width: 1
        border.color: theme.glassBorderSubtle

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            x: sw.checked ? parent.width - width - 2 : 2
            width: 20
            height: 20
            radius: 10
            color: sw.checked ? theme.glassFillDark : theme.textMuted

            Behavior on x {
                NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: sw.toggled()
        }
    }

    component SettingToggleRow: Rectangle {
        id: toggleRow
        property string iconGlyph: ""
        property string title: ""
        property string subtitle: ""
        property bool checked: false
        signal toggled()

        width: parent ? parent.width : 300
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

        SwitchButton {
            id: rowSwitch
            anchors {
                right: parent.right
                rightMargin: theme.spacingSm
                verticalCenter: parent.verticalCenter
            }
            checked: toggleRow.checked
            onToggled: toggleRow.toggled()
        }

        MouseArea {
            id: rowMouse
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
                right: rowSwitch.left
            }
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: toggleRow.toggled()
        }
    }

    component SettingPillButton: Rectangle {
        id: pillBtn
        property string label: ""
        property bool active: false
        signal clicked()

        height: 28
        radius: theme.radiusSmall
        color: active ? theme.activeFill : (pillMouse.containsMouse ? theme.hoverFill : theme.itemFill)
        border.width: 1
        border.color: active ? theme.glassBorderStrong : theme.glassBorderSubtle

        Behavior on color {
            ColorAnimation { duration: theme.animDurationFast }
        }

        Text {
            anchors.centerIn: parent
            text: pillBtn.label
            color: pillBtn.active ? theme.textStrong : theme.textMedium
            font.pixelSize: theme.fontSizeXs
            font.weight: pillBtn.active ? Font.DemiBold : Font.Medium
        }

        MouseArea {
            id: pillMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: pillBtn.clicked()
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.open = false
    }

    Item {
        id: card
        width: 412
        height: root.showGamingSettings 
            ? Math.min(680, gamingSettingsCol.implicitHeight + (theme.spacingLg + theme.notchTopRadius) * 2)
            : mainCol.implicitHeight + (theme.spacingLg + theme.notchTopRadius) * 2

        anchors {
            top: parent.top
            topMargin: theme.notchHeight + 110
            right: parent.right
        }

        transformOrigin: Item.Right
        scale: root.open ? 1.0 : 0.92
        opacity: root.open ? 1.0 : 0.0

        Behavior on height {
            NumberAnimation {
                duration: theme.animDurationFast
                easing.type: Easing.OutCubic
            }
        }

        transform: Translate {
            x: root.open ? 0 : 28
            Behavior on x {
                NumberAnimation {
                    duration: root.open ? theme.animDurationSticky : theme.animDurationExit
                    easing.type: root.open ? Easing.OutBack : Easing.InCubic
                    easing.overshoot: theme.stickyOvershoot
                }
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: root.open ? theme.animDurationSticky : theme.animDurationExit
                easing.type: root.open ? Easing.OutBack : Easing.InCubic
                easing.overshoot: theme.stickyOvershoot
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: root.open ? theme.animDurationSticky : theme.animDurationExit
                easing.type: Easing.OutCubic
            }
        }

        SideGlassPanel {
            anchors.fill: parent
        }

        MouseArea {
            anchors.fill: parent
            onClicked: mouse => mouse.accepted = true
        }

        // =====================================================================
        // VIEW 1: MAIN CONTROL CENTER VIEW
        // =====================================================================
        Item {
            id: mainView
            anchors.fill: parent
            opacity: !root.showGamingSettings ? 1.0 : 0.0
            visible: opacity > 0.001

            transform: Translate {
                x: root.showGamingSettings ? -20 : 0
                Behavior on x {
                    NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic }
                }
            }

            Behavior on opacity {
                NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic }
            }

            Column {
                id: mainCol
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    leftMargin: theme.spacingLg
                    rightMargin: theme.spacingLg + theme.notchTopRadius
                    topMargin: theme.spacingLg + theme.notchTopRadius
                }
                spacing: theme.spacingMd

                // 0. User Profile Header Section with Privacy Eye Blur Toggle
                Rectangle {
                    width: parent.width
                    height: 60
                    radius: theme.radiusItem
                    color: theme.itemFill
                    border.width: 1
                    border.color: theme.glassBorderSubtle

                    Row {
                        anchors {
                            left: parent.left
                            leftMargin: theme.spacingMd
                            right: parent.right
                            rightMargin: theme.spacingMd
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: theme.spacingMd

                        // Avatar Container
                        Item {
                            id: avatarContainer
                            width: 42
                            height: 42
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                anchors.fill: parent
                                radius: theme.radiusItem
                                color: theme.glassFillDark
                            }

                            Image {
                                id: avatarImg
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectCrop
                                source: userProfile.hasAvatar && userProfile.avatarPath !== "" ? ("file://" + userProfile.avatarPath) : ""
                                visible: userProfile.hasAvatar && status === Image.Ready
                                asynchronous: true
                                cache: false
                                layer.enabled: true
                                layer.effect: MultiEffect {
                                    maskEnabled: true
                                    maskSource: avatarMask
                                }
                            }

                            Item {
                                id: avatarMask
                                width: avatarContainer.width
                                height: avatarContainer.height
                                visible: false
                                layer.enabled: true

                                Rectangle {
                                    anchors.fill: parent
                                    radius: theme.radiusItem
                                    color: "black"
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: !avatarImg.visible
                                text: userProfile.initial
                                color: theme.textStrong
                                font.pixelSize: theme.fontSizeXl
                                font.weight: Font.DemiBold
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: theme.radiusItem
                                color: "transparent"
                                border.width: 1
                                border.color: theme.glassBorder
                            }
                        }

                        // User Info with Privacy Blur Effect (Blurs display name and hostname only)
                        Item {
                            id: userInfoContainer
                            width: parent.width - avatarContainer.width - privacyEyeBtn.width - (theme.spacingMd * 2)
                            height: 42
                            anchors.verticalCenter: parent.verticalCenter

                            Column {
                                id: userInfoCol
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                }
                                spacing: 2

                                layer.enabled: true
                                layer.effect: MultiEffect {
                                    blurEnabled: userProfile.privacyBlur > 0.001
                                    blur: userProfile.privacyBlur
                                    blurMax: 64
                                    blurMultiplier: 3.0
                                }

                                Text {
                                    width: parent.width
                                    text: userProfile.displayName
                                    color: theme.textStrong
                                    opacity: 1.0 - (userProfile.privacyBlur * 0.7)
                                    font.pixelSize: theme.fontSizeLg
                                    font.weight: Font.DemiBold
                                    elide: Text.ElideRight
                                }

                                Row {
                                    spacing: theme.spacingXs
                                    opacity: 1.0 - (userProfile.privacyBlur * 0.7)

                                    Text {
                                        text: ""
                                        color: theme.textMuted
                                        font.pixelSize: theme.fontSizeXs
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        text: userProfile.hostName
                                        color: theme.textMuted
                                        font.pixelSize: theme.fontSizeXs
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }

                            // Frosted Privacy Placeholder Pill Bars (When blurred)
                            Column {
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                }
                                spacing: 6
                                opacity: userProfile.privacyBlur
                                visible: opacity > 0.001

                                Rectangle {
                                    width: Math.min(130, parent.width * 0.65)
                                    height: 14
                                    radius: 7
                                    color: theme.glassFillDark
                                    border.width: 1
                                    border.color: theme.glassBorderSubtle
                                }

                                Rectangle {
                                    width: Math.min(85, parent.width * 0.4)
                                    height: 10
                                    radius: 5
                                    color: theme.glassFillDark
                                    border.width: 1
                                    border.color: theme.glassBorderSubtle
                                }
                            }
                        }

                        // Privacy Eye Button (Toggle blur for screenshots/streams)
                        Rectangle {
                            id: privacyEyeBtn
                            width: 32
                            height: 32
                            radius: theme.radiusSmall
                            anchors.verticalCenter: parent.verticalCenter
                            color: eyeMouse.containsMouse ? theme.hoverFill : (userProfile.privacyMode ? theme.activeFill : "transparent")
                            border.width: 1
                            border.color: userProfile.privacyMode ? theme.glassBorderStrong : theme.glassBorderSubtle

                            Behavior on color {
                                ColorAnimation { duration: theme.animDurationFast }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: userProfile.privacyMode ? "" : ""
                                color: userProfile.privacyMode ? theme.textStrong : theme.textMuted
                                font.pixelSize: theme.fontSizeMd
                            }

                            MouseArea {
                                id: eyeMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: userProfile.togglePrivacy()
                            }
                        }
                    }
                }

                // 1. Wi-Fi Section (Horizontal Full-Width)
                Rectangle {
                    width: parent.width
                    height: 52
                    radius: theme.radiusItem
                    color: network.available ? theme.activeFill : theme.itemFill
                    border.width: 1
                    border.color: network.available ? theme.glassBorderStrong : theme.glassBorderSubtle

                    Row {
                        anchors {
                            left: parent.left
                            leftMargin: theme.spacingMd
                            right: wifiToggleBtn.left
                            rightMargin: theme.spacingSm
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: theme.spacingMd

                        Text {
                            text: ""
                            color: network.available ? theme.textStrong : theme.textMuted
                            font.pixelSize: theme.fontSizeLg
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: "Wi-Fi"
                                color: theme.textStrong
                                font.pixelSize: theme.fontSizeMd
                                font.weight: Font.DemiBold
                            }

                            Text {
                                text: network.available ? (network.ssid !== "" ? "Conectado a: " + network.ssid : "Conectado") : "Desconectado"
                                color: network.available ? theme.textMedium : theme.textMuted
                                font.pixelSize: theme.fontSizeXs
                                elide: Text.ElideRight
                            }
                        }
                    }

                    Rectangle {
                        id: wifiToggleBtn
                        anchors {
                            right: parent.right
                            rightMargin: theme.spacingMd
                            verticalCenter: parent.verticalCenter
                        }
                        width: 38
                        height: 24
                        radius: 12
                        color: network.enabled ? theme.textStrong : theme.itemFill
                        border.width: 1
                        border.color: theme.glassBorderSubtle

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            x: network.enabled ? parent.width - width - 2 : 2
                            width: 20
                            height: 20
                            radius: 10
                            color: network.enabled ? theme.glassFillDark : theme.textMuted

                            Behavior on x {
                                NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: network.toggle()
                        }
                    }
                }

                // 2. Bluetooth Section (Horizontal Full-Width)
                Rectangle {
                    width: parent.width
                    implicitHeight: btCol.implicitHeight + (theme.spacingMd * 2)
                    radius: theme.radiusItem
                    color: bluetooth.enabled ? theme.activeFill : theme.itemFill
                    border.width: 1
                    border.color: bluetooth.enabled ? theme.glassBorderStrong : theme.glassBorderSubtle

                    Column {
                        id: btCol
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins: theme.spacingMd
                        }
                        spacing: theme.spacingSm

                        Item {
                            width: parent.width
                            height: 32

                            Row {
                                anchors {
                                    left: parent.left
                                    right: btToggleBtn.left
                                    rightMargin: theme.spacingSm
                                    verticalCenter: parent.verticalCenter
                                }
                                spacing: theme.spacingMd

                                Text {
                                    text: ""
                                    color: bluetooth.enabled ? theme.textStrong : theme.textMuted
                                    font.pixelSize: theme.fontSizeLg
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2

                                    Text {
                                        text: "Bluetooth"
                                        color: theme.textStrong
                                        font.pixelSize: theme.fontSizeMd
                                        font.weight: Font.DemiBold
                                    }

                                    Text {
                                        text: !bluetooth.enabled ? "Desligado" : (bluetooth.hasConnectedDevices ? bluetooth.connectedDevices.join(", ") : "Nenhum dispositivo")
                                        color: bluetooth.hasConnectedDevices ? theme.textMedium : theme.textMuted
                                        font.pixelSize: theme.fontSizeXs
                                        elide: Text.ElideRight
                                    }
                                }
                            }

                            Rectangle {
                                id: btToggleBtn
                                anchors {
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                }
                                width: 38
                                height: 24
                                radius: 12
                                color: bluetooth.enabled ? theme.textStrong : theme.itemFill
                                border.width: 1
                                border.color: theme.glassBorderSubtle

                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    x: bluetooth.enabled ? parent.width - width - 2 : 2
                                    width: 20
                                    height: 20
                                    radius: 10
                                    color: bluetooth.enabled ? theme.glassFillDark : theme.textMuted

                                    Behavior on x {
                                        NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: bluetooth.toggle()
                                }
                            }
                        }

                        Repeater {
                            model: bluetooth.connectedDevices

                            delegate: Rectangle {
                                required property var modelData
                                width: parent.width
                                height: 28
                                radius: theme.radiusSmall
                                color: theme.hoverFill

                                Row {
                                    anchors {
                                        left: parent.left
                                        leftMargin: theme.spacingSm
                                        verticalCenter: parent.verticalCenter
                                    }
                                    spacing: theme.spacingSm

                                    Text {
                                        text: ""
                                        color: theme.textStrong
                                        font.pixelSize: theme.fontSizeSm
                                    }

                                    Text {
                                        text: modelData
                                        color: theme.textStrong
                                        font.pixelSize: theme.fontSizeSm
                                        font.weight: Font.Medium
                                    }
                                }

                                Text {
                                    anchors {
                                        right: parent.right
                                        rightMargin: theme.spacingSm
                                        verticalCenter: parent.verticalCenter
                                    }
                                    text: "conectado"
                                    color: theme.textMuted
                                    font.pixelSize: theme.fontSizeXs
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 30
                            radius: theme.radiusSmall
                            color: pairMouse.containsMouse ? theme.hoverFill : "transparent"
                            border.width: 1
                            border.color: theme.glassBorderSubtle

                            Behavior on color {
                                ColorAnimation { duration: theme.animDurationFast }
                            }

                            Row {
                                anchors.centerIn: parent
                                spacing: theme.spacingSm

                                Text {
                                    text: ""
                                    color: theme.textStrong
                                    font.pixelSize: theme.fontSizeSm
                                }

                                Text {
                                    text: "Parear novo dispositivo"
                                    color: theme.textMedium
                                    font.pixelSize: theme.fontSizeSm
                                    font.weight: Font.Medium
                                }
                            }

                            MouseArea {
                                id: pairMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: bluetooth.pairNew()
                            }
                        }
                    }
                }

                // 3. Audio Section (Horizontal Full-Width with Volume Slider)
                Rectangle {
                    width: parent.width
                    implicitHeight: audioCol.implicitHeight + (theme.spacingMd * 2)
                    radius: theme.radiusItem
                    color: theme.itemFill
                    border.width: 1
                    border.color: theme.glassBorderSubtle

                    Column {
                        id: audioCol
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins: theme.spacingMd
                        }
                        spacing: theme.spacingSm

                        Item {
                            width: parent.width
                            height: 32

                            Row {
                                anchors {
                                    left: parent.left
                                    verticalCenter: parent.verticalCenter
                                }
                                spacing: theme.spacingMd

                                Text {
                                    text: audio.icon
                                    color: audio.muted ? theme.textMuted : theme.textStrong
                                    font.pixelSize: theme.fontSizeLg
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2

                                    Text {
                                        text: "Áudio"
                                        color: theme.textStrong
                                        font.pixelSize: theme.fontSizeMd
                                        font.weight: Font.DemiBold
                                    }

                                    Text {
                                        text: audio.label
                                        color: theme.textMuted
                                        font.pixelSize: theme.fontSizeXs
                                    }
                                }
                            }

                            Rectangle {
                                anchors {
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                }
                                width: 72
                                height: 28
                                radius: theme.radiusSmall
                                color: muteMouse.containsMouse ? theme.hoverFill : (audio.muted ? theme.activeFill : "transparent")
                                border.width: 1
                                border.color: theme.glassBorderSubtle

                                Text {
                                    anchors.centerIn: parent
                                    text: audio.muted ? "Mutado" : "Silenciar"
                                    color: audio.muted ? theme.textStrong : theme.textMedium
                                    font.pixelSize: theme.fontSizeXs
                                    font.weight: Font.Medium
                                }

                                MouseArea {
                                    id: muteMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: root.toggleAudio()
                                }
                            }
                        }

                        Row {
                            width: parent.width
                            height: 26
                            spacing: theme.spacingSm

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: ""
                                color: theme.textMuted
                                font.pixelSize: theme.fontSizeSm
                            }

                            Item {
                                id: sliderTrack
                                width: parent.width - 44
                                height: parent.height
                                anchors.verticalCenter: parent.verticalCenter

                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width
                                    height: 8
                                    radius: 4
                                    color: theme.glassFillDark
                                    border.width: 1
                                    border.color: theme.glassBorderSubtle

                                    Rectangle {
                                        anchors {
                                            left: parent.left
                                            top: parent.top
                                            bottom: parent.bottom
                                        }
                                        width: Math.max(0, Math.min(parent.width, parent.width * audio.volumeRatio))
                                        radius: 4
                                        color: audio.muted ? theme.indicatorInactive : theme.textStrong

                                        Behavior on width {
                                            NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic }
                                        }
                                    }
                                }

                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    x: Math.max(0, Math.min(sliderTrack.width - width, (sliderTrack.width - width) * audio.volumeRatio))
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

                                    function updatePos(mouseX) {
                                        const ratio = Math.max(0, Math.min(1, mouseX / sliderTrack.width))
                                        root.changeVolume(ratio)
                                    }

                                    onClicked: mouse => updatePos(mouse.x)
                                    onPositionChanged: mouse => {
                                        if (pressed) {
                                            updatePos(mouse.x)
                                        }
                                    }
                                }
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: ""
                                color: theme.textStrong
                                font.pixelSize: theme.fontSizeSm
                            }
                        }
                    }
                }

                // 4. Gaming Profile Section (with Gear Settings Icon)
                Rectangle {
                    width: parent.width
                    implicitHeight: gamingCol.implicitHeight + (theme.spacingMd * 2)
                    radius: theme.radiusItem
                    color: gaming.anyActive ? theme.activeFill : theme.itemFill
                    border.width: 1
                    border.color: gaming.anyActive ? theme.glassBorderStrong : theme.glassBorderSubtle

                    Column {
                        id: gamingCol
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins: theme.spacingMd
                        }
                        spacing: theme.spacingMd

                        // Header with Title and Gear Settings Button
                        Item {
                            width: parent.width
                            height: 28

                            Row {
                                anchors {
                                    left: parent.left
                                    verticalCenter: parent.verticalCenter
                                }
                                spacing: theme.spacingMd

                                Text {
                                    text: ""
                                    color: gaming.anyActive ? theme.textStrong : theme.textMuted
                                    font.pixelSize: theme.fontSizeLg
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2

                                    Text {
                                        text: "Perfil de Jogos"
                                        color: theme.textStrong
                                        font.pixelSize: theme.fontSizeMd
                                        font.weight: Font.DemiBold
                                    }

                                    Text {
                                        text: gaming.anyActive ? "Otimizações gráficas ativas para jogos" : "Ferramentas e wrappers desativados"
                                        color: gaming.anyActive ? theme.textMedium : theme.textMuted
                                        font.pixelSize: theme.fontSizeXs
                                    }
                                }
                            }

                            // Gear Settings Button (Opens Gaming Settings View)
                            Rectangle {
                                id: gearBtn
                                width: 28
                                height: 28
                                radius: theme.radiusSmall
                                anchors {
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                }
                                color: gearMouse.containsMouse ? theme.hoverFill : "transparent"
                                border.width: 1
                                border.color: theme.glassBorderSubtle

                                Behavior on color {
                                    ColorAnimation { duration: theme.animDurationFast }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: ""
                                    color: gearMouse.containsMouse ? theme.textStrong : theme.textMedium
                                    font.pixelSize: theme.fontSizeMd
                                }

                                MouseArea {
                                    id: gearMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.showGamingSettings = true
                                }
                            }
                        }

                        // 4 Interactive Quick Tiles in 2x2 Grid
                        Grid {
                            width: parent.width
                            columns: 2
                            spacing: theme.spacingMd

                            // Tile 1: GameMode
                            Rectangle {
                                width: (parent.width - theme.spacingMd) / 2
                                height: 54
                                radius: theme.radiusItem
                                color: gaming.gamemodeEnabled ? theme.activeFill : (gmMouse.containsMouse ? theme.hoverFill : "transparent")
                                border.width: 1
                                border.color: gaming.gamemodeEnabled ? theme.glassBorderStrong : theme.glassBorderSubtle

                                Behavior on color {
                                    ColorAnimation { duration: theme.animDurationFast }
                                }

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 4

                                    Row {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        spacing: 7

                                        Text {
                                            text: ""
                                            color: gaming.gamemodeEnabled ? theme.textStrong : theme.textMedium
                                            font.pixelSize: theme.fontSizeSm
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        Text {
                                            text: "GameMode"
                                            color: gaming.gamemodeEnabled ? theme.textStrong : theme.textMedium
                                            font.pixelSize: theme.fontSizeSm
                                            font.weight: Font.DemiBold
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: gaming.gamemodeEnabled ? "Ativo" : "Desligado"
                                        color: gaming.gamemodeEnabled ? theme.textStrong : theme.textSubtle
                                        font.pixelSize: theme.fontSizeXs
                                    }
                                }

                                MouseArea {
                                    id: gmMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: gaming.toggleGamemode()
                                }
                            }

                            // Tile 2: Bulldoptimizer
                            Rectangle {
                                width: (parent.width - theme.spacingMd) / 2
                                height: 54
                                radius: theme.radiusItem
                                color: gaming.bulldoptimizerEnabled ? theme.activeFill : (boMouse.containsMouse ? theme.hoverFill : "transparent")
                                border.width: 1
                                border.color: gaming.bulldoptimizerEnabled ? theme.glassBorderStrong : theme.glassBorderSubtle

                                Behavior on color {
                                    ColorAnimation { duration: theme.animDurationFast }
                                }

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 4

                                    Row {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        spacing: 7

                                        Text {
                                            text: ""
                                            color: gaming.bulldoptimizerEnabled ? theme.textStrong : theme.textMedium
                                            font.pixelSize: theme.fontSizeSm
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        Text {
                                            text: "Bulldoptimizer"
                                            color: gaming.bulldoptimizerEnabled ? theme.textStrong : theme.textMedium
                                            font.pixelSize: theme.fontSizeSm
                                            font.weight: Font.DemiBold
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: gaming.bulldoptimizerEnabled ? "Otimizado" : "Desligado"
                                        color: gaming.bulldoptimizerEnabled ? theme.textStrong : theme.textSubtle
                                        font.pixelSize: theme.fontSizeXs
                                    }
                                }

                                MouseArea {
                                    id: boMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: gaming.toggleBulldoptimizer()
                                }
                            }

                            // Tile 3: MangoHud
                            Rectangle {
                                width: (parent.width - theme.spacingMd) / 2
                                height: 54
                                radius: theme.radiusItem
                                color: gaming.mangohudEnabled ? theme.activeFill : (mhMouse.containsMouse ? theme.hoverFill : "transparent")
                                border.width: 1
                                border.color: gaming.mangohudEnabled ? theme.glassBorderStrong : theme.glassBorderSubtle

                                Behavior on color {
                                    ColorAnimation { duration: theme.animDurationFast }
                                }

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 4

                                    Row {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        spacing: 7

                                        Text {
                                            text: "󰓅"
                                            color: gaming.mangohudEnabled ? theme.textStrong : theme.textMedium
                                            font.pixelSize: theme.fontSizeSm
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        Text {
                                            text: "MangoHud"
                                            color: gaming.mangohudEnabled ? theme.textStrong : theme.textMedium
                                            font.pixelSize: theme.fontSizeSm
                                            font.weight: Font.DemiBold
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: gaming.mangohudEnabled ? (gaming.mhVram ? "Overlay + VRAM" : "Overlay") : "Desligado"
                                        color: gaming.mangohudEnabled ? theme.textStrong : theme.textSubtle
                                        font.pixelSize: theme.fontSizeXs
                                    }
                                }

                                MouseArea {
                                    id: mhMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: gaming.toggleMangohud()
                                }
                            }

                            // Tile 4: Gamescope
                            Rectangle {
                                width: (parent.width - theme.spacingMd) / 2
                                height: 54
                                radius: theme.radiusItem
                                color: gaming.gamescopeEnabled ? theme.activeFill : (gsMouse.containsMouse ? theme.hoverFill : "transparent")
                                border.width: 1
                                border.color: gaming.gamescopeEnabled ? theme.glassBorderStrong : theme.glassBorderSubtle

                                Behavior on color {
                                    ColorAnimation { duration: theme.animDurationFast }
                                }

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 4

                                    Row {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        spacing: 7

                                        Text {
                                            text: "󰹑"
                                            color: gaming.gamescopeEnabled ? theme.textStrong : theme.textMedium
                                            font.pixelSize: theme.fontSizeSm
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        Text {
                                            text: "Gamescope"
                                            color: gaming.gamescopeEnabled ? theme.textStrong : theme.textMedium
                                            font.pixelSize: theme.fontSizeSm
                                            font.weight: Font.DemiBold
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: gaming.gamescopeEnabled ? (gaming.gsHdr ? "HDR " + gaming.gsRefreshRate + "Hz" : gaming.gsRefreshRate + "Hz") : "Desligado"
                                        color: gaming.gamescopeEnabled ? theme.textStrong : theme.textSubtle
                                        font.pixelSize: theme.fontSizeXs
                                    }
                                }

                                MouseArea {
                                    id: gsMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: gaming.toggleGamescope()
                                }
                            }
                        }
                    }
                }
            }
        }

        // =====================================================================
        // VIEW 2: GAMING ADVANCED SETTINGS OVERLAY / VIEW
        // =====================================================================
        Item {
            id: gamingSettingsView
            anchors.fill: parent
            opacity: root.showGamingSettings ? 1.0 : 0.0
            visible: opacity > 0.001

            transform: Translate {
                x: root.showGamingSettings ? 0 : 20
                Behavior on x {
                    NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic }
                }
            }

            Behavior on opacity {
                NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic }
            }

            Column {
                id: gamingSettingsCol
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    leftMargin: theme.spacingLg
                    rightMargin: theme.spacingLg + theme.notchTopRadius
                    topMargin: theme.spacingLg + theme.notchTopRadius
                }
                spacing: theme.spacingMd

                // 1. Settings Navigation Header Bar
                Item {
                    width: parent.width
                    height: 36

                    Row {
                        anchors {
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: theme.spacingSm

                        // Back Button
                        Rectangle {
                            width: 32
                            height: 32
                            radius: theme.radiusSmall
                            anchors.verticalCenter: parent.verticalCenter
                            color: backMouse.containsMouse ? theme.hoverFill : theme.itemFill
                            border.width: 1
                            border.color: theme.glassBorderSubtle

                            Behavior on color {
                                ColorAnimation { duration: theme.animDurationFast }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: ""
                                color: theme.textStrong
                                font.pixelSize: theme.fontSizeMd
                            }

                            MouseArea {
                                id: backMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.showGamingSettings = false
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1

                            Text {
                                text: "Ajustes de Jogos"
                                color: theme.textStrong
                                font.pixelSize: theme.fontSizeLg
                                font.weight: Font.DemiBold
                            }

                            Text {
                                text: "Gamescope HDR & Métricas MangoHud"
                                color: theme.textMuted
                                font.pixelSize: theme.fontSizeXs
                            }
                        }
                    }

                    // Saved Status Indicator
                    Rectangle {
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                        height: 24
                        radius: theme.radiusSmall
                        color: "transparent"

                        Row {
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                text: ""
                                color: theme.textSubtle
                                font.pixelSize: theme.fontSizeXs
                            }

                            Text {
                                text: "Salvo"
                                color: theme.textSubtle
                                font.pixelSize: theme.fontSizeXs
                            }
                        }
                    }
                }

                // 2. Segmented Tab Switcher (Gamescope vs MangoHud)
                Rectangle {
                    width: parent.width
                    height: 38
                    radius: theme.radiusItem
                    color: theme.glassFillDark
                    border.width: 1
                    border.color: theme.glassBorderSubtle

                    Row {
                        anchors.fill: parent
                        anchors.margins: 4
                        spacing: 4

                        // Tab 1: Gamescope
                        Rectangle {
                            width: (parent.width - 4) / 2
                            height: parent.height
                            radius: Math.max(2, theme.radiusItem - 4)
                            color: root.activeGamingTab === "gamescope" ? theme.activeFill : (tabGsMouse.containsMouse ? theme.hoverFill : "transparent")
                            border.width: 1
                            border.color: root.activeGamingTab === "gamescope" ? theme.glassBorderStrong : "transparent"

                            Behavior on color {
                                ColorAnimation { duration: theme.animDurationFast }
                            }

                            Row {
                                anchors.centerIn: parent
                                spacing: 6

                                Text {
                                    text: "󰹑"
                                    color: root.activeGamingTab === "gamescope" ? theme.textStrong : theme.textMuted
                                    font.pixelSize: theme.fontSizeSm
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: "Gamescope"
                                    color: root.activeGamingTab === "gamescope" ? theme.textStrong : theme.textMedium
                                    font.pixelSize: theme.fontSizeSm
                                    font.weight: root.activeGamingTab === "gamescope" ? Font.DemiBold : Font.Normal
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: tabGsMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.activeGamingTab = "gamescope"
                            }
                        }

                        // Tab 2: MangoHud
                        Rectangle {
                            width: (parent.width - 4) / 2
                            height: parent.height
                            radius: Math.max(2, theme.radiusItem - 4)
                            color: root.activeGamingTab === "mangohud" ? theme.activeFill : (tabMhMouse.containsMouse ? theme.hoverFill : "transparent")
                            border.width: 1
                            border.color: root.activeGamingTab === "mangohud" ? theme.glassBorderStrong : "transparent"

                            Behavior on color {
                                ColorAnimation { duration: theme.animDurationFast }
                            }

                            Row {
                                anchors.centerIn: parent
                                spacing: 6

                                Text {
                                    text: "󰓅"
                                    color: root.activeGamingTab === "mangohud" ? theme.textStrong : theme.textMuted
                                    font.pixelSize: theme.fontSizeSm
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: "MangoHud"
                                    color: root.activeGamingTab === "mangohud" ? theme.textStrong : theme.textMedium
                                    font.pixelSize: theme.fontSizeSm
                                    font.weight: root.activeGamingTab === "mangohud" ? Font.DemiBold : Font.Normal
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: tabMhMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.activeGamingTab = "mangohud"
                            }
                        }
                    }
                }

                // 3. Scrollable Settings Content Area
                Flickable {
                    id: flickSettings
                    width: parent.width
                    height: 500
                    contentWidth: width
                    contentHeight: root.activeGamingTab === "gamescope" ? gsSettingsCol.implicitHeight + 20 : mhSettingsCol.implicitHeight + 20
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    // =========================================================
                    // TAB CONTENT A: GAMESCOPE SETTINGS
                    // =========================================================
                    Column {
                        id: gsSettingsCol
                        visible: root.activeGamingTab === "gamescope"
                        width: parent.width
                        spacing: theme.spacingMd

                        // Card A1: Master Toggle Gamescope
                        Rectangle {
                            width: parent.width
                            implicitHeight: gsMasterCol.implicitHeight + (theme.spacingMd * 2)
                            radius: theme.radiusItem
                            color: gaming.gamescopeEnabled ? theme.activeFill : theme.itemFill
                            border.width: 1
                            border.color: gaming.gamescopeEnabled ? theme.glassBorderStrong : theme.glassBorderSubtle

                            Column {
                                id: gsMasterCol
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    top: parent.top
                                    margins: theme.spacingMd
                                }
                                spacing: theme.spacingSm

                                SettingToggleRow {
                                    iconGlyph: "󰹑"
                                    title: "Micro-compositor Gamescope"
                                    subtitle: "Isolamento gráfico Wayland, upscaling e controle de FPS"
                                    checked: gaming.gamescopeEnabled
                                    onToggled: gaming.toggleGamescope()
                                }
                            }
                        }

                        // Card A2: Resolução de Renderização Interna (Entrada / In-Game)
                        Rectangle {
                            width: parent.width
                            implicitHeight: renderResCol.implicitHeight + (theme.spacingMd * 2)
                            radius: theme.radiusItem
                            color: theme.itemFill
                            border.width: 1
                            border.color: theme.glassBorderSubtle

                            Column {
                                id: renderResCol
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    top: parent.top
                                    margins: theme.spacingMd
                                }
                                spacing: theme.spacingSm

                                Row {
                                    width: parent.width
                                    spacing: theme.spacingSm

                                    Text {
                                        text: "󰑋"
                                        color: theme.textStrong
                                        font.pixelSize: theme.fontSizeMd
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: "Resolução de Renderização (Entrada)"
                                        color: theme.textStrong
                                        font.pixelSize: theme.fontSizeSm
                                        font.weight: Font.DemiBold
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                Row {
                                    width: parent.width
                                    spacing: theme.spacingSm

                                    SettingPillButton {
                                        width: (parent.width - (theme.spacingSm * 3)) / 4
                                        label: "Nativa"
                                        active: gaming.gsRenderWidth === 0 || (gaming.gsRenderWidth === gaming.gsWidth && gaming.gsRenderHeight === gaming.gsHeight)
                                        onClicked: gaming.setRenderResolution(0, 0)
                                    }
                                    SettingPillButton {
                                        width: (parent.width - (theme.spacingSm * 3)) / 4
                                        label: "1080p (75%)"
                                        active: gaming.gsRenderWidth === 1920 && gaming.gsRenderHeight === 1080
                                        onClicked: gaming.setRenderResolution(1920, 1080)
                                    }
                                    SettingPillButton {
                                        width: (parent.width - (theme.spacingSm * 3)) / 4
                                        label: "960p (66%)"
                                        active: gaming.gsRenderWidth === 1706 && gaming.gsRenderHeight === 960
                                        onClicked: gaming.setRenderResolution(1706, 960)
                                    }
                                    SettingPillButton {
                                        width: (parent.width - (theme.spacingSm * 3)) / 4
                                        label: "720p (50%)"
                                        active: gaming.gsRenderWidth === 1280 && gaming.gsRenderHeight === 720
                                        onClicked: gaming.setRenderResolution(1280, 720)
                                    }
                                }

                                Text {
                                    width: parent.width
                                    text: (gaming.gsRenderWidth > 0 && gaming.gsRenderHeight > 0)
                                        ? ("Renderizando internamente em " + gaming.gsRenderWidth + "x" + gaming.gsRenderHeight + " ➔ Upscaling para " + gaming.gsWidth + "x" + gaming.gsHeight)
                                        : ("Renderização nativa 1:1 em " + gaming.gsWidth + "x" + gaming.gsHeight + " (sem redução)")
                                    color: theme.textMuted
                                    font.pixelSize: theme.fontSizeXs
                                    elide: Text.ElideRight
                                }
                            }
                        }

                        // Card A3: Resolução de Saída (Display Físico)
                        Rectangle {
                            width: parent.width
                            implicitHeight: resCol.implicitHeight + (theme.spacingMd * 2)
                            radius: theme.radiusItem
                            color: theme.itemFill
                            border.width: 1
                            border.color: theme.glassBorderSubtle

                            Column {
                                id: resCol
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    top: parent.top
                                    margins: theme.spacingMd
                                }
                                spacing: theme.spacingSm

                                Row {
                                    width: parent.width
                                    spacing: theme.spacingSm

                                    Text {
                                        text: "󰍹"
                                        color: theme.textStrong
                                        font.pixelSize: theme.fontSizeMd
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: "Resolução de Saída (Tela)"
                                        color: theme.textStrong
                                        font.pixelSize: theme.fontSizeSm
                                        font.weight: Font.DemiBold
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                Row {
                                    width: parent.width
                                    spacing: theme.spacingSm

                                    SettingPillButton {
                                        width: (parent.width - (theme.spacingSm * 3)) / 4
                                        label: "1440p"
                                        active: gaming.gsWidth === 2560 && gaming.gsHeight === 1440
                                        onClicked: gaming.setResolution(2560, 1440)
                                    }
                                    SettingPillButton {
                                        width: (parent.width - (theme.spacingSm * 3)) / 4
                                        label: "1080p"
                                        active: gaming.gsWidth === 1920 && gaming.gsHeight === 1080
                                        onClicked: gaming.setResolution(1920, 1080)
                                    }
                                    SettingPillButton {
                                        width: (parent.width - (theme.spacingSm * 3)) / 4
                                        label: "4K"
                                        active: gaming.gsWidth === 3840 && gaming.gsHeight === 2160
                                        onClicked: gaming.setResolution(3840, 2160)
                                    }
                                    SettingPillButton {
                                        width: (parent.width - (theme.spacingSm * 3)) / 4
                                        label: "720p"
                                        active: gaming.gsWidth === 1280 && gaming.gsHeight === 720
                                        onClicked: gaming.setResolution(1280, 720)
                                    }
                                }
                            }
                        }

                        // Card A4: Upscaling & Filtros de Escala
                        Rectangle {
                            width: parent.width
                            implicitHeight: fsrCol.implicitHeight + (theme.spacingMd * 2)
                            radius: theme.radiusItem
                            color: theme.itemFill
                            border.width: 1
                            border.color: theme.glassBorderSubtle

                            Column {
                                id: fsrCol
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    top: parent.top
                                    margins: theme.spacingMd
                                }
                                spacing: theme.spacingSm

                                Row {
                                    width: parent.width
                                    spacing: theme.spacingSm

                                    Text {
                                        text: "󰹑"
                                        color: theme.textStrong
                                        font.pixelSize: theme.fontSizeMd
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: "Upscaling & Filtros de Escala"
                                        color: theme.textStrong
                                        font.pixelSize: theme.fontSizeSm
                                        font.weight: Font.DemiBold
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                SettingToggleRow {
                                    iconGlyph: "󰹑"
                                    title: "Upscaling Espacial (FSR / NIS)"
                                    subtitle: "Reconstrução com nitidez aprimorada (-F fsr/nis)"
                                    checked: gaming.gsFsr
                                    onToggled: {
                                        gaming.gsFsr = !gaming.gsFsr
                                        gaming.saveConfig()
                                    }
                                }

                                Column {
                                    width: parent.width
                                    spacing: theme.spacingSm
                                    visible: gaming.gsFsr

                                    Rectangle {
                                        width: parent.width
                                        height: 1
                                        color: theme.separator
                                    }

                                    // Algoritmo Selector
                                    Row {
                                        width: parent.width
                                        spacing: theme.spacingSm

                                        Text {
                                            text: "Algoritmo de Escala"
                                            color: theme.textMedium
                                            font.pixelSize: theme.fontSizeXs
                                            font.weight: Font.Medium
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }

                                    Row {
                                        width: parent.width
                                        spacing: theme.spacingSm

                                        SettingPillButton {
                                            width: (parent.width - (theme.spacingSm * 3)) / 4
                                            label: "FSR (AMD)"
                                            active: gaming.gsScalerFilter === "fsr"
                                            onClicked: gaming.setScalerFilter("fsr")
                                        }
                                        SettingPillButton {
                                            width: (parent.width - (theme.spacingSm * 3)) / 4
                                            label: "NIS (NV)"
                                            active: gaming.gsScalerFilter === "nis"
                                            onClicked: gaming.setScalerFilter("nis")
                                        }
                                        SettingPillButton {
                                            width: (parent.width - (theme.spacingSm * 3)) / 4
                                            label: "Linear"
                                            active: gaming.gsScalerFilter === "linear"
                                            onClicked: gaming.setScalerFilter("linear")
                                        }
                                        SettingPillButton {
                                            width: (parent.width - (theme.spacingSm * 3)) / 4
                                            label: "Nearest"
                                            active: gaming.gsScalerFilter === "nearest"
                                            onClicked: gaming.setScalerFilter("nearest")
                                        }
                                    }

                                    // Sharpness Slider
                                    Column {
                                        width: parent.width
                                        spacing: 4

                                        Item {
                                            width: parent.width
                                            height: 16

                                            Text {
                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: "Nitidez do Filtro"
                                                color: theme.textMedium
                                                font.pixelSize: theme.fontSizeXs
                                                font.weight: Font.Medium
                                            }

                                            Text {
                                                anchors.right: parent.right
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: "Nível " + gaming.gsFsrSharpness
                                                color: theme.textStrong
                                                font.pixelSize: theme.fontSizeXs
                                                font.weight: Font.DemiBold
                                            }
                                        }

                                        Item {
                                            width: parent.width
                                            height: 22

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
                                                    width: Math.max(0, Math.min(parent.width, parent.width * (gaming.gsFsrSharpness / 20)))
                                                    radius: 3
                                                    color: theme.textStrong
                                                }
                                            }

                                            Rectangle {
                                                anchors.verticalCenter: parent.verticalCenter
                                                x: Math.max(0, Math.min(parent.width - width, (parent.width - width) * (gaming.gsFsrSharpness / 20)))
                                                width: 14
                                                height: 14
                                                radius: 7
                                                color: theme.textStrong
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                hoverEnabled: true

                                                function updateSharpness(mouseX) {
                                                    const ratio = Math.max(0, Math.min(1, mouseX / parent.width))
                                                    gaming.gsFsrSharpness = Math.round(ratio * 20)
                                                    gaming.saveConfig()
                                                }

                                                onClicked: mouse => updateSharpness(mouse.x)
                                                onPositionChanged: mouse => { if (pressed) updateSharpness(mouse.x) }
                                            }
                                        }
                                    }
                                }

                                SettingToggleRow {
                                    iconGlyph: "󰄲"
                                    title: "Escalonamento Inteiro"
                                    subtitle: "Multiplicação exata de pixels (-S integer)"
                                    checked: gaming.gsIntegerScaling
                                    onToggled: {
                                        gaming.gsIntegerScaling = !gaming.gsIntegerScaling
                                        gaming.saveConfig()
                                    }
                                }
                            }
                        }

                        // Card A5: Taxa de Atualização (Hz)
                        Rectangle {
                            width: parent.width
                            implicitHeight: hzCol.implicitHeight + (theme.spacingMd * 2)
                            radius: theme.radiusItem
                            color: theme.itemFill
                            border.width: 1
                            border.color: theme.glassBorderSubtle

                            Column {
                                id: hzCol
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    top: parent.top
                                    margins: theme.spacingMd
                                }
                                spacing: theme.spacingSm

                                Row {
                                    width: parent.width
                                    spacing: theme.spacingSm

                                    Text {
                                        text: "󰓅"
                                        color: theme.textStrong
                                        font.pixelSize: theme.fontSizeMd
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: "Taxa de Atualização"
                                        color: theme.textStrong
                                        font.pixelSize: theme.fontSizeSm
                                        font.weight: Font.DemiBold
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                Row {
                                    width: parent.width
                                    spacing: 4

                                    SettingPillButton {
                                        width: (parent.width - 16) / 5
                                        label: "240Hz"
                                        active: gaming.gsRefreshRate === 240
                                        onClicked: gaming.setRefreshRate(240)
                                    }
                                    SettingPillButton {
                                        width: (parent.width - 16) / 5
                                        label: "165Hz"
                                        active: gaming.gsRefreshRate === 165
                                        onClicked: gaming.setRefreshRate(165)
                                    }
                                    SettingPillButton {
                                        width: (parent.width - 16) / 5
                                        label: "144Hz"
                                        active: gaming.gsRefreshRate === 144
                                        onClicked: gaming.setRefreshRate(144)
                                    }
                                    SettingPillButton {
                                        width: (parent.width - 16) / 5
                                        label: "120Hz"
                                        active: gaming.gsRefreshRate === 120
                                        onClicked: gaming.setRefreshRate(120)
                                    }
                                    SettingPillButton {
                                        width: (parent.width - 16) / 5
                                        label: "60Hz"
                                        active: gaming.gsRefreshRate === 60
                                        onClicked: gaming.setRefreshRate(60)
                                    }
                                }
                            }
                        }

                        // Card A6: Modo de Janela & Sincronização
                        Rectangle {
                            width: parent.width
                            implicitHeight: winCol.implicitHeight + (theme.spacingMd * 2)
                            radius: theme.radiusItem
                            color: theme.itemFill
                            border.width: 1
                            border.color: theme.glassBorderSubtle

                            Column {
                                id: winCol
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    top: parent.top
                                    margins: theme.spacingMd
                                }
                                spacing: theme.spacingSm

                                SettingToggleRow {
                                    iconGlyph: ""
                                    title: "Tela Cheia Nativa"
                                    subtitle: "Executa em modo fullscreen (--fullscreen)"
                                    checked: gaming.gsFullscreen
                                    onToggled: {
                                        gaming.gsFullscreen = !gaming.gsFullscreen
                                        gaming.saveConfig()
                                    }
                                }

                                SettingToggleRow {
                                    iconGlyph: ""
                                    title: "Janela Sem Bordas"
                                    subtitle: "Modo borderless (-b)"
                                    checked: gaming.gsBorderless
                                    onToggled: {
                                        gaming.gsBorderless = !gaming.gsBorderless
                                        gaming.saveConfig()
                                    }
                                }

                                SettingToggleRow {
                                    iconGlyph: "󰡍"
                                    title: "Taxa Variável / VRR"
                                    subtitle: "Sincronização Adaptativa (--adaptive-sync)"
                                    checked: gaming.gsAdaptiveSync
                                    onToggled: {
                                        gaming.gsAdaptiveSync = !gaming.gsAdaptiveSync
                                        gaming.saveConfig()
                                    }
                                }
                            }
                        }

                        // Card A7: HDR (High Dynamic Range)
                        Rectangle {
                            width: parent.width
                            implicitHeight: hdrCol.implicitHeight + (theme.spacingMd * 2)
                            radius: theme.radiusItem
                            color: gaming.gsHdr ? theme.activeFill : theme.itemFill
                            border.width: 1
                            border.color: gaming.gsHdr ? theme.glassBorderStrong : theme.glassBorderSubtle

                            Column {
                                id: hdrCol
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    top: parent.top
                                    margins: theme.spacingMd
                                }
                                spacing: theme.spacingSm

                                SettingToggleRow {
                                    iconGlyph: "󰄛"
                                    title: "Habilitar Saída HDR"
                                    subtitle: "Cores de 10-bit e alto alcance dinâmico (--hdr-enabled)"
                                    checked: gaming.gsHdr
                                    onToggled: {
                                        gaming.gsHdr = !gaming.gsHdr
                                        gaming.saveConfig()
                                    }
                                }

                                Column {
                                    width: parent.width
                                    spacing: theme.spacingSm
                                    visible: gaming.gsHdr

                                    Rectangle {
                                        width: parent.width
                                        height: 1
                                        color: theme.separator
                                    }

                                    SettingToggleRow {
                                        iconGlyph: "󰃠"
                                        title: "Mapeamento Inverso SDR ➔ HDR"
                                        subtitle: "Gera efeito HDR em jogos SDR (--hdr-itm-enabled)"
                                        checked: gaming.gsHdrItm
                                        onToggled: {
                                            gaming.gsHdrItm = !gaming.gsHdrItm
                                            gaming.saveConfig()
                                        }
                                    }

                                    // SDR Content Nits Slider
                                    Column {
                                        width: parent.width
                                        spacing: 4

                                        Item {
                                            width: parent.width
                                            height: 16

                                            Text {
                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: "Luminância de Conteúdo SDR"
                                                color: theme.textMedium
                                                font.pixelSize: theme.fontSizeXs
                                                font.weight: Font.Medium
                                            }

                                            Text {
                                                anchors.right: parent.right
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: gaming.gsHdrSdrNits + " nits"
                                                color: theme.textStrong
                                                font.pixelSize: theme.fontSizeXs
                                                font.weight: Font.DemiBold
                                            }
                                        }

                                        Item {
                                            width: parent.width
                                            height: 22

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
                                                    width: Math.max(0, Math.min(parent.width, parent.width * ((gaming.gsHdrSdrNits - 100) / 700)))
                                                    radius: 3
                                                    color: theme.textStrong
                                                }
                                            }

                                            Rectangle {
                                                anchors.verticalCenter: parent.verticalCenter
                                                x: Math.max(0, Math.min(parent.width - width, (parent.width - width) * ((gaming.gsHdrSdrNits - 100) / 700)))
                                                width: 14
                                                height: 14
                                                radius: 7
                                                color: theme.textStrong
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                hoverEnabled: true

                                                function updateNits(mouseX) {
                                                    const ratio = Math.max(0, Math.min(1, mouseX / parent.width))
                                                    gaming.gsHdrSdrNits = Math.round(100 + ratio * 700)
                                                    gaming.saveConfig()
                                                }

                                                onClicked: mouse => updateNits(mouse.x)
                                                onPositionChanged: mouse => { if (pressed) updateNits(mouse.x) }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // =========================================================
                    // TAB CONTENT B: MANGOHUD SETTINGS (VRAM, RAM, CPU, GPU)
                    // =========================================================
                    Column {
                        id: mhSettingsCol
                        visible: root.activeGamingTab === "mangohud"
                        width: parent.width
                        spacing: theme.spacingMd

                        // Card B1: Master Toggle MangoHud & Presets
                        Rectangle {
                            width: parent.width
                            implicitHeight: mhMasterCol.implicitHeight + (theme.spacingMd * 2)
                            radius: theme.radiusItem
                            color: gaming.mangohudEnabled ? theme.activeFill : theme.itemFill
                            border.width: 1
                            border.color: gaming.mangohudEnabled ? theme.glassBorderStrong : theme.glassBorderSubtle

                            Column {
                                id: mhMasterCol
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    top: parent.top
                                    margins: theme.spacingMd
                                }
                                spacing: theme.spacingSm

                                SettingToggleRow {
                                    iconGlyph: "󰓅"
                                    title: "Overlay MangoHud"
                                    subtitle: "Telemetria de desempenho em tempo real no jogo"
                                    checked: gaming.mangohudEnabled
                                    onToggled: gaming.toggleMangohud()
                                }

                                Rectangle {
                                    width: parent.width
                                    height: 1
                                    color: theme.separator
                                }

                                Row {
                                    width: parent.width
                                    spacing: theme.spacingSm

                                    SettingPillButton {
                                        width: (parent.width - (theme.spacingSm * 2)) / 3
                                        label: "Essencial"
                                        active: gaming.mhFps && gaming.mhVram && gaming.mhRam && !gaming.mhGpuCoreClock
                                        onClicked: gaming.applyMangohudPreset("essencial")
                                    }
                                    SettingPillButton {
                                        width: (parent.width - (theme.spacingSm * 2)) / 3
                                        label: "Completo"
                                        active: gaming.mhGpuCoreClock && gaming.mhCpuMhz
                                        onClicked: gaming.applyMangohudPreset("completo")
                                    }
                                    SettingPillButton {
                                        width: (parent.width - (theme.spacingSm * 2)) / 3
                                        label: "Mínimo"
                                        active: gaming.mhCompact
                                        onClicked: gaming.applyMangohudPreset("minimo")
                                    }
                                }
                            }
                        }

                        // Card B2: Consumo de Memória (VRAM e RAM)
                        Rectangle {
                            width: parent.width
                            implicitHeight: memCol.implicitHeight + (theme.spacingMd * 2)
                            radius: theme.radiusItem
                            color: (gaming.mhVram || gaming.mhRam) ? theme.activeFill : theme.itemFill
                            border.width: 1
                            border.color: (gaming.mhVram || gaming.mhRam) ? theme.glassBorderStrong : theme.glassBorderSubtle

                            Column {
                                id: memCol
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    top: parent.top
                                    margins: theme.spacingMd
                                }
                                spacing: theme.spacingSm

                                Row {
                                    width: parent.width
                                    spacing: theme.spacingSm

                                    Text {
                                        text: "󰘚"
                                        color: theme.textStrong
                                        font.pixelSize: theme.fontSizeMd
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: "Consumo de Memória"
                                        color: theme.textStrong
                                        font.pixelSize: theme.fontSizeSm
                                        font.weight: Font.DemiBold
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                SettingToggleRow {
                                    iconGlyph: "󰢮"
                                    title: "Consumo de VRAM"
                                    subtitle: "Exibe uso da memória da placa de vídeo (vram)"
                                    checked: gaming.mhVram
                                    onToggled: {
                                        gaming.mhVram = !gaming.mhVram
                                        gaming.saveConfig()
                                    }
                                }

                                SettingToggleRow {
                                    iconGlyph: "󰍛"
                                    title: "Consumo de RAM"
                                    subtitle: "Exibe uso da memória RAM do sistema (ram)"
                                    checked: gaming.mhRam
                                    onToggled: {
                                        gaming.mhRam = !gaming.mhRam
                                        gaming.saveConfig()
                                    }
                                }
                            }
                        }

                        // Card B3: Placa de Vídeo (GPU)
                        Rectangle {
                            width: parent.width
                            implicitHeight: gpuCol.implicitHeight + (theme.spacingMd * 2)
                            radius: theme.radiusItem
                            color: theme.itemFill
                            border.width: 1
                            border.color: theme.glassBorderSubtle

                            Column {
                                id: gpuCol
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    top: parent.top
                                    margins: theme.spacingMd
                                }
                                spacing: theme.spacingSm

                                Row {
                                    width: parent.width
                                    spacing: theme.spacingSm

                                    Text {
                                        text: "󰢮"
                                        color: theme.textStrong
                                        font.pixelSize: theme.fontSizeMd
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: "Placa de Vídeo (GPU)"
                                        color: theme.textStrong
                                        font.pixelSize: theme.fontSizeSm
                                        font.weight: Font.DemiBold
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                SettingToggleRow {
                                    title: "Uso da GPU (%)"
                                    subtitle: "Carga de processamento gráfico (gpu_stats)"
                                    checked: gaming.mhGpuStats
                                    onToggled: {
                                        gaming.mhGpuStats = !gaming.mhGpuStats
                                        gaming.saveConfig()
                                    }
                                }

                                SettingToggleRow {
                                    title: "Temperatura da GPU (°C)"
                                    subtitle: "Temperatura em tempo real (gpu_temp)"
                                    checked: gaming.mhGpuTemp
                                    onToggled: {
                                        gaming.mhGpuTemp = !gaming.mhGpuTemp
                                        gaming.saveConfig()
                                    }
                                }

                                SettingToggleRow {
                                    title: "Clock da GPU (Core & Mem)"
                                    subtitle: "Frequência em MHz (gpu_core_clock)"
                                    checked: gaming.mhGpuCoreClock
                                    onToggled: {
                                        gaming.mhGpuCoreClock = !gaming.mhGpuCoreClock
                                        gaming.saveConfig()
                                    }
                                }

                                SettingToggleRow {
                                    title: "Potência da GPU (Watts)"
                                    subtitle: "Consumo elétrico da placa (gpu_power)"
                                    checked: gaming.mhGpuPower
                                    onToggled: {
                                        gaming.mhGpuPower = !gaming.mhGpuPower
                                        gaming.saveConfig()
                                    }
                                }
                            }
                        }

                        // Card B4: Processador (CPU)
                        Rectangle {
                            width: parent.width
                            implicitHeight: cpuCol.implicitHeight + (theme.spacingMd * 2)
                            radius: theme.radiusItem
                            color: theme.itemFill
                            border.width: 1
                            border.color: theme.glassBorderSubtle

                            Column {
                                id: cpuCol
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    top: parent.top
                                    margins: theme.spacingMd
                                }
                                spacing: theme.spacingSm

                                Row {
                                    width: parent.width
                                    spacing: theme.spacingSm

                                    Text {
                                        text: "󰍛"
                                        color: theme.textStrong
                                        font.pixelSize: theme.fontSizeMd
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: "Processador (CPU)"
                                        color: theme.textStrong
                                        font.pixelSize: theme.fontSizeSm
                                        font.weight: Font.DemiBold
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                SettingToggleRow {
                                    title: "Uso da CPU (%)"
                                    subtitle: "Carga total dos núcleos (cpu_stats)"
                                    checked: gaming.mhCpuStats
                                    onToggled: {
                                        gaming.mhCpuStats = !gaming.mhCpuStats
                                        gaming.saveConfig()
                                    }
                                }

                                SettingToggleRow {
                                    title: "Temperatura da CPU (°C)"
                                    subtitle: "Temperatura do encapsulamento (cpu_temp)"
                                    checked: gaming.mhCpuTemp
                                    onToggled: {
                                        gaming.mhCpuTemp = !gaming.mhCpuTemp
                                        gaming.saveConfig()
                                    }
                                }

                                SettingToggleRow {
                                    title: "Frequência dos Núcleos (MHz)"
                                    subtitle: "Clock da CPU (cpu_mhz)"
                                    checked: gaming.mhCpuMhz
                                    onToggled: {
                                        gaming.mhCpuMhz = !gaming.mhCpuMhz
                                        gaming.saveConfig()
                                    }
                                }

                                SettingToggleRow {
                                    title: "Potência da CPU (Watts)"
                                    subtitle: "Consumo de energia do processador (cpu_power)"
                                    checked: gaming.mhCpuPower
                                    onToggled: {
                                        gaming.mhCpuPower = !gaming.mhCpuPower
                                        gaming.saveConfig()
                                    }
                                }
                            }
                        }

                        // Card B5: Taxa de Quadros & Frametimes
                        Rectangle {
                            width: parent.width
                            implicitHeight: fpsCol.implicitHeight + (theme.spacingMd * 2)
                            radius: theme.radiusItem
                            color: theme.itemFill
                            border.width: 1
                            border.color: theme.glassBorderSubtle

                            Column {
                                id: fpsCol
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    top: parent.top
                                    margins: theme.spacingMd
                                }
                                spacing: theme.spacingSm

                                SettingToggleRow {
                                    iconGlyph: "󰓅"
                                    title: "Taxa de Quadros (FPS)"
                                    subtitle: "Contador numérico de FPS (fps)"
                                    checked: gaming.mhFps
                                    onToggled: {
                                        gaming.mhFps = !gaming.mhFps
                                        gaming.saveConfig()
                                    }
                                }

                                SettingToggleRow {
                                    iconGlyph: "󰄲"
                                    title: "Gráfico de Frametimes"
                                    subtitle: "Gráfico de consistência de quadros (frametime)"
                                    checked: gaming.mhFrametime
                                    onToggled: {
                                        gaming.mhFrametime = !gaming.mhFrametime
                                        gaming.saveConfig()
                                    }
                                }
                            }
                        }

                        // Card B6: Posição do HUD na Tela
                        Rectangle {
                            width: parent.width
                            implicitHeight: posCol.implicitHeight + (theme.spacingMd * 2)
                            radius: theme.radiusItem
                            color: theme.itemFill
                            border.width: 1
                            border.color: theme.glassBorderSubtle

                            Column {
                                id: posCol
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    top: parent.top
                                    margins: theme.spacingMd
                                }
                                spacing: theme.spacingSm

                                Row {
                                    width: parent.width
                                    spacing: theme.spacingSm

                                    Text {
                                        text: ""
                                        color: theme.textStrong
                                        font.pixelSize: theme.fontSizeMd
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: "Posição do Overlay na Tela"
                                        color: theme.textStrong
                                        font.pixelSize: theme.fontSizeSm
                                        font.weight: Font.DemiBold
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                Row {
                                    width: parent.width
                                    spacing: 4

                                    SettingPillButton {
                                        width: (parent.width - 12) / 4
                                        label: "Sup. Esq."
                                        active: gaming.mhPosition === "top-left"
                                        onClicked: gaming.setPosition("top-left")
                                    }
                                    SettingPillButton {
                                        width: (parent.width - 12) / 4
                                        label: "Sup. Dir."
                                        active: gaming.mhPosition === "top-right"
                                        onClicked: gaming.setPosition("top-right")
                                    }
                                    SettingPillButton {
                                        width: (parent.width - 12) / 4
                                        label: "Inf. Esq."
                                        active: gaming.mhPosition === "bottom-left"
                                        onClicked: gaming.setPosition("bottom-left")
                                    }
                                    SettingPillButton {
                                        width: (parent.width - 12) / 4
                                        label: "Inf. Dir."
                                        active: gaming.mhPosition === "bottom-right"
                                        onClicked: gaming.setPosition("bottom-right")
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

