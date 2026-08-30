import "../modules"
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import Quickshell.Wayland

WlSessionLock {
    id: root

    property bool authenticating: false
    property string errorMessage: ""
    property bool showPassword: false

    function lock() {
        root.locked = true
    }

    function unlock() {
        root.locked = false
    }

    onLockedChanged: {
        if (locked) {
            errorMessage = ""
            authenticating = false
            showPassword = false
            bgImage.source = ""
            bgImage.source = "file://" + Quickshell.env("HOME") + "/.cache/bulldoze/Wallpaper_greeter.png"
            introAnim.restart()
            if (pwdInput) {
                pwdInput.text = ""
                pwdInput.forceActiveFocus()
            }
        }
    }

    WlSessionLockSurface {
        id: surface

        function runCommand(cmd) {
            powerProc.exec(["sh", "-c", cmd])
        }

        color: "transparent"

        Component.onCompleted: {
            introAnim.start()
        }

        Theme {
            id: theme
        }

        UserProfile {
            id: userProfile
        }

        SystemClock {
            id: sysClock
            precision: SystemClock.Minutes
        }

        Process {
            id: powerProc
        }

        PamContext {
            id: pam
            config: "login"

            onPamMessage: {
                if (messageIsError && message) {
                    root.errorMessage = message
                }
            }

            onCompleted: result => {
                root.authenticating = false
                if (result === PamResult.Success) {
                    root.errorMessage = ""
                    pwdInput.text = ""
                    exitAnim.start()
                } else {
                    root.errorMessage = "Senha incorreta"
                    pwdInput.text = ""
                    shakeAnim.start()
                    pwdInput.forceActiveFocus()
                    pam.start()
                }
            }

            onError: error => {
                root.authenticating = false
                root.errorMessage = "Erro na autenticação"
                pwdInput.text = ""
                shakeAnim.start()
                pwdInput.forceActiveFocus()
                pam.start()
            }
        }

        // Background Image / Wallpaper (Sharp Fullscreen Wallpaper)
        Image {
            id: bgImage
            anchors.fill: parent
            source: "file://" + Quickshell.env("HOME") + "/.cache/bulldoze/Wallpaper_greeter.png"
            fillMode: Image.PreserveAspectCrop
            visible: status === Image.Ready
            cache: false
            onStatusChanged: {
                if (status === Image.Error) {
                    source = "file:///var/lib/greetd/Wallpaper_greeter.png"
                }
            }
        }

        // Fallback dark gradient if wallpaper is missing
        Rectangle {
            anchors.fill: parent
            visible: !bgImage.visible

            gradient: Gradient {
                GradientStop { position: 0; color: "#141418" }
                GradientStop { position: 1; color: "#0A0A0C" }
            }
        }

        // Catch clicks to refocus password input
        MouseArea {
            anchors.fill: parent
            onClicked: pwdInput.forceActiveFocus()
        }

        property bool isExpanded: false
        readonly property int collapsedWidth: (restingClock && restingClock.implicitWidth > 0) ? Math.round(restingClock.implicitWidth + ((theme.contentInset + theme.notchConcaveWidth) * 2) + 16) : theme.notchCollapsedWidth

        // =====================================================================
        // INTRO & EXIT ANIMATIONS (Deterministic & Smooth)
        // =====================================================================
        ParallelAnimation {
            id: introAnim

            onStarted: {
                surface.isExpanded = true
            }

            NumberAnimation {
                target: topNotchCard
                property: "width"
                from: surface.collapsedWidth
                to: theme.notchExpandedWidth
                duration: 380
                easing.type: Easing.OutBack
                easing.overshoot: 1.25
            }

            NumberAnimation {
                target: topNotchCard
                property: "height"
                from: theme.notchHeight
                to: 380
                duration: 380
                easing.type: Easing.OutBack
                easing.overshoot: 1.25
            }

            NumberAnimation {
                target: notchContent
                property: "opacity"
                from: 0
                to: 1
                duration: 280
                easing.type: Easing.OutCubic
            }

            NumberAnimation {
                target: notchContent
                property: "scale"
                from: 0.90
                to: 1.0
                duration: 380
                easing.type: Easing.OutBack
                easing.overshoot: 1.25
            }

            NumberAnimation {
                target: restingClock
                property: "opacity"
                from: 1
                to: 0
                duration: 160
                easing.type: Easing.OutCubic
            }
        }

        ParallelAnimation {
            id: exitAnim

            onStarted: {
                surface.isExpanded = false
            }

            NumberAnimation {
                target: notchContent
                property: "opacity"
                to: 0
                duration: 120
                easing.type: Easing.InCubic
            }

            NumberAnimation {
                target: restingClock
                property: "opacity"
                to: 1
                duration: 160
                easing.type: Easing.InCubic
            }

            NumberAnimation {
                target: topNotchCard
                property: "width"
                to: surface.collapsedWidth
                duration: 260
                easing.type: Easing.InOutCubic
            }

            NumberAnimation {
                target: topNotchCard
                property: "height"
                to: theme.notchHeight
                duration: 260
                easing.type: Easing.InOutCubic
            }

            onFinished: {
                root.unlock()
            }
        }

        // =====================================================================
        // MORPHING DYNAMIC NOTCH LOCK CARD (Top-bezel Docked)
        // =====================================================================
        Item {
            id: topNotchCard

            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }

            width: surface.isExpanded ? theme.notchExpandedWidth : surface.collapsedWidth
            height: surface.isExpanded ? 380 : theme.notchHeight

            // Top Notch Concave Glass Panel with Scoped Component Blur
            GlassPanel {
                anchors.fill: parent
                blurSource: bgImage
            }

            // Shake Animation on wrong password
            SequentialAnimation {
                id: shakeAnim

                NumberAnimation { target: notchContentTranslate; property: "x"; to: -14; duration: 45; easing.type: Easing.OutQuad }
                NumberAnimation { target: notchContentTranslate; property: "x"; to: 14; duration: 45; easing.type: Easing.OutQuad }
                NumberAnimation { target: notchContentTranslate; property: "x"; to: -10; duration: 45; easing.type: Easing.OutQuad }
                NumberAnimation { target: notchContentTranslate; property: "x"; to: 10; duration: 45; easing.type: Easing.OutQuad }
                NumberAnimation { target: notchContentTranslate; property: "x"; to: 0; duration: 45; easing.type: Easing.OutQuad }
            }

            // -----------------------------------------------------------------
            // Resting / Collapsed State View (Minimal Clock)
            // -----------------------------------------------------------------
            Clock {
                id: restingClock
                anchors.centerIn: parent
                opacity: 1.0
                visible: opacity > 0.001
            }

            // -----------------------------------------------------------------
            // Expanded Lock Screen Content (Morphs into view)
            // -----------------------------------------------------------------
            Item {
                id: notchContent
                anchors.fill: parent
                opacity: 0.0
                scale: 0.90
                transformOrigin: Item.Top
                visible: opacity > 0.001

                transform: Translate {
                    id: notchContentTranslate
                    x: 0
                    y: 0
                }

                Column {
                    anchors {
                        top: parent.top
                        topMargin: theme.notchConcaveHeight + theme.spacingSm
                        horizontalCenter: parent.horizontalCenter
                    }
                    width: parent.width - (theme.contentInset * 2) - (theme.notchConcaveWidth * 2)
                    spacing: theme.spacingMd

                    // 1. Large Header: Digital Clock & Date
                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 2

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: Qt.formatDateTime(sysClock.date, "HH:mm")
                            color: theme.textStrong
                            font.pixelSize: 54
                            font.weight: Font.Bold
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: {
                                const dateStr = sysClock.date.toLocaleDateString(Qt.locale("pt_BR"), "dddd, dd 'de' MMMM")
                                return dateStr ? (dateStr.charAt(0).toUpperCase() + dateStr.slice(1)) : ""
                            }
                            color: theme.textMedium
                            font.pixelSize: 14
                            font.weight: Font.Medium
                        }
                    }

                    // 2. User Info & Avatar Row
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: theme.spacingMd

                        // Avatar Container with Mask
                        Item {
                            id: avatarContainer
                            width: 44
                            height: 44
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                id: avatarImg
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectCrop
                                source: userProfile.hasAvatar ? ("file://" + userProfile.avatarPath) : ""
                                visible: userProfile.hasAvatar && status === Image.Ready
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

                            // Fallback Initial Letter
                            Rectangle {
                                anchors.fill: parent
                                radius: theme.radiusItem
                                color: theme.itemFill
                                visible: !userProfile.hasAvatar || avatarImg.status !== Image.Ready
                                border.width: 1
                                border.color: theme.glassBorderSubtle

                                Text {
                                    anchors.centerIn: parent
                                    text: userProfile.initial
                                    color: theme.textStrong
                                    font.pixelSize: theme.fontSizeLg
                                    font.weight: Font.Bold
                                }
                            }

                            // Outer Glass Ring
                            Rectangle {
                                anchors.fill: parent
                                radius: theme.radiusItem
                                color: "transparent"
                                border.width: 1
                                border.color: theme.glassBorder
                            }
                        }

                        // User Text
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1

                            Text {
                                text: userProfile.displayName
                                color: theme.textStrong
                                font.pixelSize: theme.fontSizeSubmenuTitle
                                font.weight: Font.Bold
                            }

                            Text {
                                text: userProfile.hostName
                                color: theme.textMuted
                                font.pixelSize: theme.fontSizeSubmenuBody
                            }
                        }
                    }

                    // 3. Password Input Box
                    Rectangle {
                        id: pwdContainer
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: Math.min(420, parent.width)
                        height: 44
                        radius: theme.radiusItem
                        color: theme.itemFill
                        border.width: 1
                        border.color: root.authenticating ? theme.accent : (pwdInput.activeFocus ? theme.glassBorderStrong : theme.glassBorderSubtle)
                        clip: true

                        Row {
                            anchors {
                                fill: parent
                                leftMargin: theme.spacingMd
                                rightMargin: theme.spacingSm
                            }
                            spacing: theme.spacingSm

                            // Lock Icon / Loading Spinner
                            Item {
                                width: 20
                                height: 20
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    anchors.centerIn: parent
                                    text: ""
                                    visible: !root.authenticating
                                    color: pwdInput.activeFocus ? theme.textStrong : theme.textSubtle
                                    font.pixelSize: theme.iconSizeSm
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: ""
                                    visible: root.authenticating
                                    color: theme.accent
                                    font.pixelSize: theme.iconSizeSm

                                    NumberAnimation on rotation {
                                        running: root.authenticating
                                        from: 0
                                        to: 360
                                        loops: Animation.Infinite
                                        duration: 900
                                    }
                                }
                            }

                            TextInput {
                                id: pwdInput
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - 20 - (revealBtn.visible ? 30 : 0) - 34 - (theme.spacingSm * 3)
                                echoMode: root.showPassword ? TextInput.Normal : TextInput.Password
                                color: theme.textStrong
                                font.pixelSize: theme.fontSizeMd
                                focus: true
                                clip: true
                                readOnly: root.authenticating
                                opacity: root.authenticating ? 0.6 : 1

                                onAccepted: {
                                    if (text.length > 0 && !root.authenticating) {
                                        root.authenticating = true
                                        root.errorMessage = ""
                                        if (!pam.active) pam.start()
                                        if (pam.responseRequired) pam.respond(text)
                                    }
                                }

                                Component.onCompleted: {
                                    forceActiveFocus()
                                    if (!pam.active) pam.start()
                                }

                                Text {
                                    anchors.fill: parent
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: root.authenticating ? "Autenticando..." : "Digite sua senha..."
                                    color: theme.textSubtle
                                    font.pixelSize: theme.fontSizeMd
                                    visible: !pwdInput.text && !pwdInput.activeFocus
                                }
                            }

                            // Reveal Password Eye Button
                            Rectangle {
                                id: revealBtn
                                width: 28
                                height: 28
                                anchors.verticalCenter: parent.verticalCenter
                                radius: theme.radiusSmall
                                color: revealMouse.containsMouse ? theme.hoverFill : "transparent"
                                visible: pwdInput.text.length > 0 && !root.authenticating

                                Text {
                                    anchors.centerIn: parent
                                    text: root.showPassword ? "" : ""
                                    color: revealMouse.containsMouse ? theme.textStrong : theme.textMuted
                                    font.pixelSize: theme.iconSizeSm
                                }

                                MouseArea {
                                    id: revealMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.showPassword = !root.showPassword
                                }
                            }

                            // Submit Button
                            Rectangle {
                                width: 32
                                height: 32
                                anchors.verticalCenter: parent.verticalCenter
                                radius: theme.radiusSmall
                                color: (!root.authenticating && submitMouse.containsMouse) ? theme.hoverFill : "transparent"
                                border.width: 1
                                border.color: (!root.authenticating && submitMouse.containsMouse) ? theme.glassBorderStrong : "transparent"
                                scale: submitMouse.pressed ? 0.90 : (submitMouse.containsMouse ? 1.12 : 1.0)
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

                                Text {
                                    anchors.centerIn: parent
                                    text: ""
                                    visible: !root.authenticating
                                    color: pwdInput.text.length > 0 ? theme.textStrong : theme.textSubtle
                                    font.pixelSize: theme.iconSizeSm
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: ""
                                    visible: root.authenticating
                                    color: theme.accent
                                    font.pixelSize: theme.iconSizeSm

                                    NumberAnimation on rotation {
                                        running: root.authenticating
                                        from: 0
                                        to: 360
                                        loops: Animation.Infinite
                                        duration: 900
                                    }
                                }

                                MouseArea {
                                    id: submitMouse
                                    anchors.fill: parent
                                    enabled: !root.authenticating && pwdInput.text.length > 0
                                    hoverEnabled: true
                                    cursorShape: (!root.authenticating && pwdInput.text.length > 0) ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    onClicked: pwdInput.accepted()
                                }
                            }
                        }

                        // Indeterminate Loading Bar across bottom edge
                        Rectangle {
                            anchors.bottom: parent.bottom
                            height: 2
                            width: parent.width * 0.4
                            radius: 1
                            color: theme.accent
                            visible: root.authenticating

                            SequentialAnimation on x {
                                running: root.authenticating
                                loops: Animation.Infinite

                                NumberAnimation {
                                    from: -pwdContainer.width * 0.4
                                    to: pwdContainer.width
                                    duration: 1000
                                    easing.type: Easing.InOutQuad
                                }
                            }
                        }
                    }

                    // 4. Status / Error Message
                    Item {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width
                        height: 18

                        Row {
                            anchors.centerIn: parent
                            spacing: 6
                            visible: root.authenticating || root.errorMessage.length > 0

                            Text {
                                visible: root.authenticating
                                text: ""
                                color: theme.accent
                                font.pixelSize: theme.fontSizeSm
                                anchors.verticalCenter: parent.verticalCenter

                                NumberAnimation on rotation {
                                    running: root.authenticating
                                    from: 0
                                    to: 360
                                    loops: Animation.Infinite
                                    duration: 900
                                }
                            }

                            Text {
                                visible: !root.authenticating && root.errorMessage.length > 0
                                text: ""
                                color: "#FF6B6B"
                                font.pixelSize: theme.fontSizeSm
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: root.authenticating ? "Autenticando..." : root.errorMessage
                                color: root.errorMessage ? "#FF6B6B" : theme.textMedium
                                font.pixelSize: theme.fontSizeSm
                                font.weight: Font.Medium
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    // 5. Integrated Power Actions Row
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: theme.spacingLg

                        Repeater {
                            model: [
                                { "icon": "", "label": "Suspender", "action": "systemctl suspend" },
                                { "icon": "", "label": "Reiniciar", "action": "systemctl reboot" },
                                { "icon": "", "label": "Desligar", "action": "systemctl poweroff" }
                            ]

                            delegate: Rectangle {
                                id: pwrBtn
                                required property var modelData

                                width: 36
                                height: 36
                                radius: theme.radiusSmall
                                color: pwrBtnMouse.containsMouse ? theme.hoverFill : "transparent"
                                border.width: 1
                                border.color: pwrBtnMouse.containsMouse ? theme.glassBorderStrong : "transparent"
                                scale: pwrBtnMouse.pressed ? 0.90 : (pwrBtnMouse.containsMouse ? 1.15 : 1.0)
                                transformOrigin: Item.Center

                                Text {
                                    anchors.centerIn: parent
                                    text: pwrBtn.modelData.icon
                                    color: pwrBtnMouse.containsMouse ? theme.textStrong : theme.textMedium
                                    font.pixelSize: theme.iconSizeMd
                                }

                                // Hover Tooltip Pill (reveals above button)
                                Rectangle {
                                    id: tooltip
                                    width: tipText.implicitWidth + (theme.spacingMd * 2)
                                    height: 26
                                    radius: theme.radiusSmall
                                    color: theme.glassFillDark
                                    border.width: 1
                                    border.color: theme.glassBorderStrong
                                    opacity: pwrBtnMouse.containsMouse ? 1.0 : 0.0
                                    scale: pwrBtnMouse.containsMouse ? 1.0 : 0.85
                                    visible: opacity > 0.001

                                    anchors {
                                        bottom: parent.top
                                        bottomMargin: theme.spacingSm
                                        horizontalCenter: parent.horizontalCenter
                                    }

                                    Text {
                                        id: tipText
                                        anchors.centerIn: parent
                                        text: pwrBtn.modelData.label
                                        color: theme.textStrong
                                        font.pixelSize: theme.fontSizeSm
                                        font.weight: Font.Medium
                                    }

                                    Behavior on opacity {
                                        NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic }
                                    }
                                    Behavior on scale {
                                        NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutBack; easing.overshoot: theme.stickyOvershoot }
                                    }
                                }

                                MouseArea {
                                    id: pwrBtnMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: surface.runCommand(pwrBtn.modelData.action)
                                }

                                Behavior on color { ColorAnimation { duration: theme.animDurationFast } }
                                Behavior on border.color { ColorAnimation { duration: theme.animDurationFast } }
                                Behavior on scale {
                                    NumberAnimation {
                                        duration: theme.animDurationFast
                                        easing.type: Easing.OutBack
                                        easing.overshoot: theme.buttonOvershoot
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
