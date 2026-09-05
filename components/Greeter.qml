import "../modules"
import QtQuick
import QtQuick.Shapes
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Item {
    id: root

    property bool authenticating: false
    property bool loginSuccess: false
    property string errorMessage: ""
    property bool showPassword: false
    property var usersList: []
    property int selectedUserIndex: 0
    property var sessionsList: []
    property int selectedSessionIndex: 0
    property bool sessionDropdownOpen: false
    property bool userDropdownOpen: false

    readonly property var currentUser: (usersList && usersList.length > selectedUserIndex && usersList[selectedUserIndex]) ? usersList[selectedUserIndex] : {
        "username": userProfile.loginUser || "paulo",
        "displayName": userProfile.displayName || "Paulo Italo",
        "hostName": userProfile.hostName || "bulldoze",
        "avatar": userProfile.avatarPath || "/var/lib/AccountsService/icons/paulo"
    }

    readonly property var currentSession: (sessionsList && sessionsList.length > selectedSessionIndex && sessionsList[selectedSessionIndex]) ? sessionsList[selectedSessionIndex] : {
        "name": "Hyprland",
        "exec": "/usr/bin/start-hyprland",
        "icon": ""
    }

    readonly property string helperPath: {
        const localScript = Qt.resolvedUrl("../scripts/greetd-client.py").toString().replace("file://", "")
        return localScript
    }

    function runPowerCommand(cmd) {
        powerProc.exec(["sh", "-c", cmd])
    }

    function doLogin() {
        if (pwdInput.text.length === 0 || authenticating || loginSuccess) return

        authenticating = true
        errorMessage = ""
        sessionDropdownOpen = false
        userDropdownOpen = false
        loginProc.exec(["python3", helperPath, "login", "--user", currentUser.username, "--password", pwdInput.text, "--cmd", currentSession.exec])
    }

    anchors.fill: parent

    Component.onCompleted: {
        usersProc.exec(["python3", helperPath, "users"])
        sessionsProc.exec(["python3", helperPath, "sessions"])
        introAnim.start()
        pwdInput.forceActiveFocus()
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

    Process {
        id: usersProc
        stdout: SplitParser {
            onRead: data => {
                try {
                    const parsed = JSON.parse(data)
                    if (Array.isArray(parsed) && parsed.length > 0) {
                        root.usersList = parsed
                    }
                } catch (e) {
                    console.log("Error parsing users:", e)
                }
            }
        }
    }

    Process {
        id: sessionsProc
        stdout: SplitParser {
            onRead: data => {
                try {
                    const parsed = JSON.parse(data)
                    if (Array.isArray(parsed) && parsed.length > 0) {
                        root.sessionsList = parsed
                        const hyprIndex = parsed.findIndex(s => s.name === "Hyprland" || s.name.toLowerCase() === "hyprland")
                        if (hyprIndex >= 0) {
                            root.selectedSessionIndex = hyprIndex
                        } else {
                            root.selectedSessionIndex = 0
                        }
                    }
                } catch (e) {
                    console.log("Error parsing sessions:", e)
                }
            }
        }
    }

    Process {
        id: loginProc
        onExited: exitCode => {
            if (exitCode !== 0 && !root.loginSuccess) {
                root.authenticating = false
                root.errorMessage = "Falha no processo de login"
                pwdInput.text = ""
                shakeAnim.start()
                pwdInput.forceActiveFocus()
            }
        }

        stdout: SplitParser {
            onRead: data => {
                try {
                    const res = JSON.parse(data)
                    if (res.success) {
                        root.loginSuccess = true
                        root.authenticating = false
                        root.errorMessage = ""
                        pwdInput.text = ""
                        pwdInput.focus = false
                        exitAnim.start()
                    } else {
                        root.authenticating = false
                        root.errorMessage = res.error || "Senha incorreta"
                        pwdInput.text = ""
                        shakeAnim.start()
                        pwdInput.forceActiveFocus()
                    }
                } catch (e) {
                    root.authenticating = false
                    root.errorMessage = "Erro ao processar resposta"
                    pwdInput.text = ""
                    shakeAnim.start()
                    pwdInput.forceActiveFocus()
                }
            }
        }
    }

    // Background Image / Wallpaper (Sharp Fullscreen Wallpaper)
    Image {
        id: bgImage
        anchors.fill: parent
        source: "file:///var/lib/greetd/Wallpaper_greeter.png"
        fillMode: Image.PreserveAspectCrop
        visible: status === Image.Ready
        cache: false
    }

    // Fallback dark gradient
    Rectangle {
        anchors.fill: parent
        visible: !bgImage.visible

        gradient: Gradient {
            GradientStop { position: 0; color: "#141418" }
            GradientStop { position: 1; color: "#0A0A0C" }
        }
    }

    property bool isExpanded: false
    readonly property int collapsedWidth: (restingClock && restingClock.implicitWidth > 0) ? Math.round(restingClock.implicitWidth + ((theme.contentInset + theme.notchConcaveWidth) * 2) + 16) : theme.notchCollapsedWidth

    property real animNotchWidth: isExpanded ? theme.notchExpandedWidth : collapsedWidth
    property real animNotchHeight: isExpanded ? 400 : theme.notchHeight

    Behavior on animNotchWidth {
        NumberAnimation {
            duration: 380
            easing.type: root.isExpanded ? Easing.OutBack : Easing.InOutCubic
            easing.overshoot: 1.25
        }
    }

    Behavior on animNotchHeight {
        NumberAnimation {
            duration: 380
            easing.type: root.isExpanded ? Easing.OutBack : Easing.InOutCubic
            easing.overshoot: 1.25
        }
    }

    readonly property real notchLeft: Math.round((root.width - animNotchWidth) / 2)
    readonly property real notchRight: notchLeft + animNotchWidth

    readonly property real borderThickness: theme.borderThickness
    readonly property real innerRadius: theme.innerRadius
    readonly property real concaveWidth: theme.notchConcaveWidth
    readonly property real concaveHeight: theme.notchConcaveHeight
    readonly property real bottomRadius: theme.notchBottomRadius

    // =========================================================================
    // UNIFIED FROSTED GLASS BLUR LAYER (Masked by Unified Shape)
    // =========================================================================
    Item {
        id: frameBlurContainer
        anchors.fill: parent
        visible: bgImage.status === Image.Ready && parent.width > 0 && parent.height > 0
        layer.enabled: true
        layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: unifiedShapeMask
        }

        ShaderEffectSource {
            id: bgSample
            anchors.fill: parent
            sourceItem: bgImage
            live: false
        }

        MultiEffect {
            anchors.fill: parent
            source: bgSample
            blurEnabled: true
            blur: 0.85
            blurMax: 48
        }
    }

    // Mask Item for Frosted Blur
    Item {
        id: unifiedShapeMask
        anchors.fill: parent
        visible: false
        layer.enabled: true

        Shape {
            anchors.fill: parent
            antialiasing: true

            ShapePath {
                fillRule: ShapePath.OddEvenFill
                fillColor: "black"
                strokeColor: "transparent"
                strokeWidth: 0

                startX: 0
                startY: 0

                PathLine { x: root.width; y: 0 }
                PathLine { x: root.width; y: root.height }
                PathLine { x: 0; y: root.height }
                PathLine { x: 0; y: 0 }

                PathMove {
                    x: root.notchLeft
                    y: root.borderThickness
                }

                PathCubic {
                    x: root.notchLeft + root.concaveWidth
                    y: root.borderThickness + root.concaveHeight
                    control1X: root.notchLeft + (root.concaveWidth * 0.5)
                    control1Y: root.borderThickness
                    control2X: root.notchLeft + root.concaveWidth
                    control2Y: root.borderThickness + (root.concaveHeight * 0.5)
                }

                PathLine {
                    x: root.notchLeft + root.concaveWidth
                    y: root.animNotchHeight - root.bottomRadius
                }

                PathCubic {
                    x: root.notchLeft + root.concaveWidth + root.bottomRadius
                    y: root.animNotchHeight
                    control1X: root.notchLeft + root.concaveWidth
                    control1Y: root.animNotchHeight - (root.bottomRadius * 0.5)
                    control2X: root.notchLeft + root.concaveWidth + (root.bottomRadius * 0.5)
                    control2Y: root.animNotchHeight
                }

                PathLine {
                    x: root.notchRight - root.concaveWidth - root.bottomRadius
                    y: root.animNotchHeight
                }

                PathCubic {
                    x: root.notchRight - root.concaveWidth
                    y: root.animNotchHeight - root.bottomRadius
                    control1X: root.notchRight - root.concaveWidth - (root.bottomRadius * 0.5)
                    control1Y: root.animNotchHeight
                    control2X: root.notchRight - root.concaveWidth
                    control2Y: root.animNotchHeight - (root.bottomRadius * 0.5)
                }

                PathLine {
                    x: root.notchRight - root.concaveWidth
                    y: root.borderThickness + root.concaveHeight
                }

                PathCubic {
                    x: root.notchRight
                    y: root.borderThickness
                    control1X: root.notchRight - root.concaveWidth
                    control1Y: root.borderThickness + (root.concaveHeight * 0.5)
                    control2X: root.notchRight - (root.concaveWidth * 0.5)
                    control2Y: root.borderThickness
                }

                PathLine {
                    x: root.width - root.borderThickness - root.innerRadius
                    y: root.borderThickness
                }

                PathCubic {
                    x: root.width - root.borderThickness
                    y: root.borderThickness + root.innerRadius
                    control1X: root.width - root.borderThickness - (root.innerRadius * 0.5)
                    control1Y: root.borderThickness
                    control2X: root.width - root.borderThickness
                    control2Y: root.borderThickness + (root.innerRadius * 0.5)
                }

                PathLine {
                    x: root.width - root.borderThickness
                    y: root.height - root.borderThickness - root.innerRadius
                }

                PathCubic {
                    x: root.width - root.borderThickness - root.innerRadius
                    y: root.height - root.borderThickness
                    control1X: root.width - root.borderThickness
                    control1Y: root.height - root.borderThickness - (root.innerRadius * 0.5)
                    control2X: root.width - root.borderThickness - (root.innerRadius * 0.5)
                    control2Y: root.height - root.borderThickness
                }

                PathLine {
                    x: root.borderThickness + root.innerRadius
                    y: root.height - root.borderThickness
                }

                PathCubic {
                    x: root.borderThickness
                    y: root.height - root.borderThickness - root.innerRadius
                    control1X: root.borderThickness + (root.innerRadius * 0.5)
                    control1Y: root.height - root.borderThickness
                    control2X: root.borderThickness
                    control2Y: root.height - root.borderThickness - (root.innerRadius * 0.5)
                }

                PathLine {
                    x: root.borderThickness
                    y: root.borderThickness + root.innerRadius
                }

                PathCubic {
                    x: root.borderThickness + root.innerRadius
                    y: root.borderThickness
                    control1X: root.borderThickness
                    control1Y: root.borderThickness + (root.innerRadius * 0.5)
                    control2X: root.borderThickness + (root.innerRadius * 0.5)
                    control2Y: root.borderThickness
                }

                PathLine {
                    x: root.notchLeft
                    y: root.borderThickness
                }
            }
        }
    }

    // =========================================================================
    // UNIFIED CONTINUOUS VECTOR SHAPE (Perimeter Frame + Morphing Notch)
    // =========================================================================
    Shape {
        id: unifiedShape
        anchors.fill: parent
        antialiasing: true
        visible: parent.width > 0 && parent.height > 0

        // 1. Unified Glass Fill
        ShapePath {
            fillRule: ShapePath.OddEvenFill
            fillColor: theme.glassFill
            strokeColor: "transparent"
            strokeWidth: 0

            startX: 0
            startY: 0

            PathLine { x: root.width; y: 0 }
            PathLine { x: root.width; y: root.height }
            PathLine { x: 0; y: root.height }
            PathLine { x: 0; y: 0 }

            PathMove {
                x: root.notchLeft
                y: root.borderThickness
            }

            PathCubic {
                x: root.notchLeft + root.concaveWidth
                y: root.borderThickness + root.concaveHeight
                control1X: root.notchLeft + (root.concaveWidth * 0.5)
                control1Y: root.borderThickness
                control2X: root.notchLeft + root.concaveWidth
                control2Y: root.borderThickness + (root.concaveHeight * 0.5)
            }

            PathLine {
                x: root.notchLeft + root.concaveWidth
                y: root.animNotchHeight - root.bottomRadius
            }

            PathCubic {
                x: root.notchLeft + root.concaveWidth + root.bottomRadius
                y: root.animNotchHeight
                control1X: root.notchLeft + root.concaveWidth
                control1Y: root.animNotchHeight - (root.bottomRadius * 0.5)
                control2X: root.notchLeft + root.concaveWidth + (root.bottomRadius * 0.5)
                control2Y: root.animNotchHeight
            }

            PathLine {
                x: root.notchRight - root.concaveWidth - root.bottomRadius
                y: root.animNotchHeight
            }

            PathCubic {
                x: root.notchRight - root.concaveWidth
                y: root.animNotchHeight - root.bottomRadius
                control1X: root.notchRight - root.concaveWidth - (root.bottomRadius * 0.5)
                control1Y: root.animNotchHeight
                control2X: root.notchRight - root.concaveWidth
                control2Y: root.animNotchHeight - (root.bottomRadius * 0.5)
            }

            PathLine {
                x: root.notchRight - root.concaveWidth
                y: root.borderThickness + root.concaveHeight
            }

            PathCubic {
                x: root.notchRight
                y: root.borderThickness
                control1X: root.notchRight - root.concaveWidth
                control1Y: root.borderThickness + (root.concaveHeight * 0.5)
                control2X: root.notchRight - (root.concaveWidth * 0.5)
                control2Y: root.borderThickness
            }

            PathLine {
                x: root.width - root.borderThickness - root.innerRadius
                y: root.borderThickness
            }

            PathCubic {
                x: root.width - root.borderThickness
                y: root.borderThickness + root.innerRadius
                control1X: root.width - root.borderThickness - (root.innerRadius * 0.5)
                control1Y: root.borderThickness
                control2X: root.width - root.borderThickness
                control2Y: root.borderThickness + (root.innerRadius * 0.5)
            }

            PathLine {
                x: root.width - root.borderThickness
                y: root.height - root.borderThickness - root.innerRadius
            }

            PathCubic {
                x: root.width - root.borderThickness - root.innerRadius
                y: root.height - root.borderThickness
                control1X: root.width - root.borderThickness
                control1Y: root.height - root.borderThickness - (root.innerRadius * 0.5)
                control2X: root.width - root.borderThickness - (root.innerRadius * 0.5)
                control2Y: root.height - root.borderThickness
            }

            PathLine {
                x: root.borderThickness + root.innerRadius
                y: root.height - root.borderThickness
            }

            PathCubic {
                x: root.borderThickness
                y: root.height - root.borderThickness - root.innerRadius
                control1X: root.borderThickness + (root.innerRadius * 0.5)
                control1Y: root.height - root.borderThickness
                control2X: root.borderThickness
                control2Y: root.height - root.borderThickness - (root.innerRadius * 0.5)
            }

            PathLine {
                x: root.borderThickness
                y: root.borderThickness + root.innerRadius
            }

            PathCubic {
                x: root.borderThickness + root.innerRadius
                y: root.borderThickness
                control1X: root.borderThickness
                control1Y: root.borderThickness + (root.innerRadius * 0.5)
                control2X: root.borderThickness + (root.innerRadius * 0.5)
                control2Y: root.borderThickness
            }

            PathLine {
                x: root.notchLeft
                y: root.borderThickness
            }
        }

        // 2. Continuous 1px Inner Stroke
        ShapePath {
            fillColor: "transparent"
            strokeColor: theme.glassBorderSubtle
            strokeWidth: 1
            capStyle: ShapePath.RoundCap

            startX: root.notchLeft
            startY: root.borderThickness + 0.5

            PathCubic {
                x: root.notchLeft + root.concaveWidth + 0.5
                y: root.borderThickness + root.concaveHeight
                control1X: root.notchLeft + (root.concaveWidth * 0.5)
                control1Y: root.borderThickness + 0.5
                control2X: root.notchLeft + root.concaveWidth + 0.5
                control2Y: root.borderThickness + (root.concaveHeight * 0.5)
            }

            PathLine {
                x: root.notchLeft + root.concaveWidth + 0.5
                y: root.animNotchHeight - root.bottomRadius
            }

            PathCubic {
                x: root.notchLeft + root.concaveWidth + root.bottomRadius
                y: root.animNotchHeight - 0.5
                control1X: root.notchLeft + root.concaveWidth + 0.5
                control1Y: root.animNotchHeight - (root.bottomRadius * 0.5)
                control2X: root.notchLeft + root.concaveWidth + (root.bottomRadius * 0.5)
                control2Y: root.animNotchHeight - 0.5
            }

            PathLine {
                x: root.notchRight - root.concaveWidth - root.bottomRadius
                y: root.animNotchHeight - 0.5
            }

            PathCubic {
                x: root.notchRight - root.concaveWidth - 0.5
                y: root.animNotchHeight - root.bottomRadius
                control1X: root.notchRight - root.concaveWidth - (root.bottomRadius * 0.5)
                control1Y: root.animNotchHeight - 0.5
                control2X: root.notchRight - root.concaveWidth - 0.5
                control2Y: root.animNotchHeight - (root.bottomRadius * 0.5)
            }

            PathLine {
                x: root.notchRight - root.concaveWidth - 0.5
                y: root.borderThickness + root.concaveHeight
            }

            PathCubic {
                x: root.notchRight
                y: root.borderThickness + 0.5
                control1X: root.notchRight - root.concaveWidth - 0.5
                control1Y: root.borderThickness + (root.concaveHeight * 0.5)
                control2X: root.notchRight - (root.concaveWidth * 0.5)
                control2Y: root.borderThickness + 0.5
            }

            PathLine {
                x: root.width - root.borderThickness - root.innerRadius
                y: root.borderThickness + 0.5
            }

            PathCubic {
                x: root.width - root.borderThickness - 0.5
                y: root.borderThickness + root.innerRadius + 0.5
                control1X: root.width - root.borderThickness - (root.innerRadius * 0.5)
                control1Y: root.borderThickness + 0.5
                control2X: root.width - root.borderThickness - 0.5
                control2Y: root.borderThickness + (root.innerRadius * 0.5)
            }

            PathLine {
                x: root.width - root.borderThickness - 0.5
                y: root.height - root.borderThickness - root.innerRadius - 0.5
            }

            PathCubic {
                x: root.width - root.borderThickness - root.innerRadius - 0.5
                y: root.height - root.borderThickness - 0.5
                control1X: root.width - root.borderThickness - 0.5
                control1Y: root.height - root.borderThickness - (root.innerRadius * 0.5)
                control2X: root.width - root.borderThickness - (root.innerRadius * 0.5)
                control2Y: root.height - root.borderThickness - 0.5
            }

            PathLine {
                x: root.borderThickness + root.innerRadius + 0.5
                y: root.height - root.borderThickness - 0.5
            }

            PathCubic {
                x: root.borderThickness + 0.5
                y: root.height - root.borderThickness - root.innerRadius - 0.5
                control1X: root.borderThickness + (root.innerRadius * 0.5)
                control1Y: root.height - root.borderThickness - 0.5
                control2X: root.borderThickness + 0.5
                control2Y: root.height - root.borderThickness - (root.innerRadius * 0.5)
            }

            PathLine {
                x: root.borderThickness + 0.5
                y: root.borderThickness + root.innerRadius + 0.5
            }

            PathCubic {
                x: root.borderThickness + root.innerRadius + 0.5
                y: root.borderThickness + 0.5
                control1X: root.borderThickness + 0.5
                control1Y: root.borderThickness + (root.innerRadius * 0.5)
                control2X: root.borderThickness + (root.innerRadius * 0.5)
                control2Y: root.borderThickness + 0.5
            }

            PathLine {
                x: root.notchLeft
                y: root.borderThickness + 0.5
            }
        }
    }

    // Catch clicks outside to dismiss dropdowns and refocus password
    MouseArea {
        anchors.fill: parent
        onClicked: {
            sessionDropdownOpen = false
            userDropdownOpen = false
            pwdInput.forceActiveFocus()
        }
    }

    // =========================================================================
    // INTRO & EXIT ANIMATIONS (Deterministic & Smooth)
    // =========================================================================
    ParallelAnimation {
        id: introAnim

        onStarted: {
            root.isExpanded = true
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
            root.isExpanded = false
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
    }

    // =========================================================================
    // MORPHING DYNAMIC NOTCH GREETER CONTAINER (Fused seamlessly with top border)
    // =========================================================================
    Item {
        id: topNotchCard

        x: root.notchLeft
        y: 0
        width: root.animNotchWidth
        height: root.animNotchHeight

        // Shake Animation for wrong password
        SequentialAnimation {
            id: shakeAnim

            NumberAnimation { target: notchContentTranslate; property: "x"; to: -14; duration: 45; easing.type: Easing.OutQuad }
            NumberAnimation { target: notchContentTranslate; property: "x"; to: 14; duration: 45; easing.type: Easing.OutQuad }
            NumberAnimation { target: notchContentTranslate; property: "x"; to: -10; duration: 45; easing.type: Easing.OutQuad }
            NumberAnimation { target: notchContentTranslate; property: "x"; to: 10; duration: 45; easing.type: Easing.OutQuad }
            NumberAnimation { target: notchContentTranslate; property: "x"; to: 0; duration: 45; easing.type: Easing.OutQuad }
        }

        // ---------------------------------------------------------------------
        // Resting / Collapsed State View (Minimal Clock)
        // ---------------------------------------------------------------------
        Clock {
            id: restingClock
            anchors.centerIn: parent
            opacity: root.isExpanded ? 0.0 : 1.0
            visible: opacity > 0.001
        }

        // ---------------------------------------------------------------------
        // Expanded Greeter Content (Morphs into view)
        // ---------------------------------------------------------------------
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
                        renderType: Text.NativeRendering
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Qt.formatDateTime(sysClock.date, "HH:mm")
                        color: theme.textStrong
                        font.pixelSize: 54
                        font.weight: Font.Bold
                    }

                    Text {
                        renderType: Text.NativeRendering
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

                // 2. User Info & Session Row
                Item {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.min(440, parent.width)
                    height: 46
                    z: 50

                    // Left: User Info
                    Row {
                        anchors {
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: theme.spacingMd

                        // Avatar Container with Mask
                        Item {
                            id: avatarContainer
                            width: 42
                            height: 42
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                id: avatarImg
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectCrop
                                source: (currentUser.avatar && currentUser.avatar.length > 0) ? ("file://" + currentUser.avatar) : ""
                                visible: currentUser.avatar && currentUser.avatar.length > 0 && status === Image.Ready
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
                                visible: !currentUser.avatar || avatarImg.status !== Image.Ready
                                border.width: 1
                                border.color: theme.glassBorderSubtle

                                Text {
                                    renderType: Text.NativeRendering
                                    anchors.centerIn: parent
                                    text: (currentUser.displayName || currentUser.username || "U").charAt(0).toUpperCase()
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
                                renderType: Text.NativeRendering
                                text: currentUser.displayName || currentUser.username
                                color: theme.textStrong
                                font.pixelSize: theme.fontSizeSubmenuTitle
                                font.weight: Font.Bold
                            }

                            Text {
                                renderType: Text.NativeRendering
                                text: currentUser.hostName || "bulldoze"
                                color: theme.textMuted
                                font.pixelSize: theme.fontSizeSubmenuBody
                            }
                        }
                    }

                    // Right: Session Selector Button
                    Rectangle {
                        id: sessionBtn
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                        height: 32
                        width: sessionRow.implicitWidth + (theme.spacingSm * 2)
                        radius: theme.radiusSmall
                        color: sessionMouse.containsMouse || root.sessionDropdownOpen ? theme.hoverFill : theme.itemFill
                        border.width: 1
                        border.color: sessionMouse.containsMouse || root.sessionDropdownOpen ? theme.glassBorderStrong : theme.glassBorderSubtle
                        scale: sessionMouse.pressed ? 0.94 : 1.0

                        Behavior on color { ColorAnimation { duration: theme.animDurationFast } }
                        Behavior on border.color { ColorAnimation { duration: theme.animDurationFast } }

                        Row {
                            id: sessionRow
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                renderType: Text.NativeRendering
                                text: currentSession.icon || ""
                                color: theme.textStrong
                                font.pixelSize: theme.iconSizeSm
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                renderType: Text.NativeRendering
                                text: currentSession.name
                                color: theme.textStrong
                                font.pixelSize: theme.fontSizeXs
                                font.weight: Font.DemiBold
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                renderType: Text.NativeRendering
                                text: root.sessionDropdownOpen ? "▴" : "▾"
                                color: theme.textMuted
                                font.pixelSize: 10
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            id: sessionMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.sessionDropdownOpen = !root.sessionDropdownOpen
                                root.userDropdownOpen = false
                            }
                        }
                    }

                    // Session Dropdown Popup Menu
                    Rectangle {
                        id: sessionDropdown
                        anchors {
                            top: sessionBtn.bottom
                            topMargin: 4
                            right: sessionBtn.right
                        }
                        width: 160
                        height: Math.min(180, (sessionsCol.implicitHeight + (theme.spacingSm * 2)))
                        radius: theme.radiusItem
                        color: theme.glassFillDark
                        border.width: 1
                        border.color: theme.glassBorderStrong
                        visible: root.sessionDropdownOpen && opacity > 0.001
                        opacity: root.sessionDropdownOpen ? 1.0 : 0.0
                        scale: root.sessionDropdownOpen ? 1.0 : 0.90
                        transformOrigin: Item.TopRight
                        clip: true
                        z: 100

                        Behavior on opacity { NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic } }
                        Behavior on scale { NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutBack; easing.overshoot: theme.stickyOvershoot } }

                        Flickable {
                            anchors.fill: parent
                            anchors.margins: theme.spacingSm
                            contentHeight: sessionsCol.implicitHeight
                            clip: true

                            Column {
                                id: sessionsCol
                                width: parent.width
                                spacing: 2

                                Repeater {
                                    model: root.sessionsList

                                    delegate: Rectangle {
                                        id: sessItem
                                        required property var modelData
                                        required property int index

                                        width: sessionsCol.width
                                        height: 30
                                        radius: theme.radiusSmall
                                        color: sessMouse.containsMouse ? theme.hoverFill : (root.selectedSessionIndex === sessItem.index ? theme.itemFill : "transparent")

                                        Row {
                                            anchors {
                                                fill: parent
                                                leftMargin: theme.spacingSm
                                                rightMargin: theme.spacingSm
                                            }
                                            spacing: theme.spacingSm

                                            Text {
                                                renderType: Text.NativeRendering
                                                text: sessItem.modelData.icon || ""
                                                color: theme.textStrong
                                                font.pixelSize: theme.iconSizeSm
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            Text {
                                                renderType: Text.NativeRendering
                                                text: sessItem.modelData.name
                                                color: theme.textStrong
                                                font.pixelSize: theme.fontSizeSm
                                                font.weight: root.selectedSessionIndex === sessItem.index ? Font.Bold : Font.Normal
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }

                                        MouseArea {
                                            id: sessMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                root.selectedSessionIndex = sessItem.index
                                                root.sessionDropdownOpen = false
                                                pwdInput.forceActiveFocus()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // 3. Password Input Box
                Rectangle {
                    id: pwdContainer
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.min(440, parent.width)
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
                                renderType: Text.NativeRendering
                                anchors.centerIn: parent
                                text: ""
                                visible: !root.authenticating
                                color: pwdInput.activeFocus ? theme.textStrong : theme.textSubtle
                                font.pixelSize: theme.iconSizeSm
                            }

                            Text {
                                renderType: Text.NativeRendering
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
                            renderType: TextInput.NativeRendering
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

                            onAccepted: root.doLogin()

                            Component.onCompleted: forceActiveFocus()

                            Text {
                                renderType: Text.NativeRendering
                                anchors.fill: parent
                                anchors.verticalCenter: parent.verticalCenter
                                text: root.authenticating ? "Iniciando sessão..." : "Digite sua senha..."
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
                                renderType: Text.NativeRendering
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
                                renderType: Text.NativeRendering
                                anchors.centerIn: parent
                                text: ""
                                visible: !root.authenticating
                                color: pwdInput.text.length > 0 ? theme.textStrong : theme.textSubtle
                                font.pixelSize: theme.iconSizeSm
                            }

                            Text {
                                renderType: Text.NativeRendering
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
                                onClicked: root.doLogin()
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
                            renderType: Text.NativeRendering
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
                            renderType: Text.NativeRendering
                            visible: !root.authenticating && root.errorMessage.length > 0
                            text: ""
                            color: "#FF6B6B"
                            font.pixelSize: theme.fontSizeSm
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            renderType: Text.NativeRendering
                            text: root.authenticating ? "Iniciando sessão..." : root.errorMessage
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
                                renderType: Text.NativeRendering
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
                                    renderType: Text.NativeRendering
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
                                onClicked: root.runPowerCommand(pwrBtn.modelData.action)
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
