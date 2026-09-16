import "../modules"
import QtQuick
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
                } catch (e) {}
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
                    }
                } catch (e) {}
            }
        }
    }

    Process {
        id: loginProc
        stdout: SplitParser {
            onRead: data => {
                root.authenticating = false
                try {
                    const res = JSON.parse(data)
                    if (res.success) {
                        root.loginSuccess = true
                        root.errorMessage = ""
                        exitAnim.start()
                    } else {
                        root.errorMessage = res.error || "Senha incorreta"
                        pwdInput.text = ""
                        shakeAnim.start()
                        pwdInput.forceActiveFocus()
                    }
                } catch (e) {
                    root.errorMessage = "Erro no serviço de autenticação"
                    pwdInput.text = ""
                    shakeAnim.start()
                    pwdInput.forceActiveFocus()
                }
            }
        }
    }

    // -------------------------------------------------------------------------
    // 1. FULLSCREEN PRISTINE WALLPAPER (Sem blur, 100% nítido)
    // -------------------------------------------------------------------------
    Image {
        id: bgImage
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        source: "file:///var/lib/greetd/Wallpaper_greeter.png"
        asynchronous: true
        cache: false
    }

    Rectangle {
        anchors.fill: parent
        color: "#20000000"
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            sessionDropdownOpen = false
            userDropdownOpen = false
            pwdInput.forceActiveFocus()
        }
    }

    // Shake animation on incorrect password
    SequentialAnimation {
        id: shakeAnim

        NumberAnimation { target: loginContentTranslate; property: "x"; to: -14; duration: 45; easing.type: Easing.OutQuad }
        NumberAnimation { target: loginContentTranslate; property: "x"; to: 14; duration: 45; easing.type: Easing.OutQuad }
        NumberAnimation { target: loginContentTranslate; property: "x"; to: -10; duration: 45; easing.type: Easing.OutQuad }
        NumberAnimation { target: loginContentTranslate; property: "x"; to: 10; duration: 45; easing.type: Easing.OutQuad }
        NumberAnimation { target: loginContentTranslate; property: "x"; to: 0; duration: 45; easing.type: Easing.OutQuad }
    }

    ParallelAnimation {
        id: introAnim
        NumberAnimation { target: clockCol; property: "opacity"; from: 0; to: 1; duration: 300; easing.type: Easing.OutCubic }
        NumberAnimation { target: bottomControlsCol; property: "opacity"; from: 0; to: 1; duration: 300; easing.type: Easing.OutCubic }
    }

    ParallelAnimation {
        id: exitAnim
        NumberAnimation { target: clockCol; property: "opacity"; to: 0; duration: 150; easing.type: Easing.InCubic }
        NumberAnimation { target: bottomControlsCol; property: "opacity"; to: 0; duration: 150; easing.type: Easing.InCubic }
    }

    // =========================================================================
    // POSIÇÃO 2/5 (CENTRO SUPERIOR): DATA ACIMA (MÉDIA), HORA ABAIXO (GRANDE)
    // =========================================================================
    Column {
        id: clockCol
        anchors.horizontalCenter: parent.horizontalCenter
        y: Math.round(parent.height * 0.18)
        spacing: 2

        Text {
            renderType: Text.NativeRendering
            anchors.horizontalCenter: parent.horizontalCenter
            text: {
                const dateStr = sysClock.date.toLocaleDateString(Qt.locale("pt_BR"), "dddd, dd 'de' MMMM")
                return dateStr ? (dateStr.charAt(0).toUpperCase() + dateStr.slice(1)) : ""
            }
            color: "#F2FFFFFF"
            font.pixelSize: 22
            font.weight: Font.Medium
        }

        Text {
            renderType: Text.NativeRendering
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(sysClock.date, "HH:mm")
            color: "#FFFFFF"
            font.pixelSize: 84
            font.weight: Font.Bold
        }
    }

    // =========================================================================
    // POSIÇÃO 5/5 (CENTRO INFERIOR): AVATAR, USUÁRIO E INPUT DE SENHA
    // =========================================================================
    Column {
        id: bottomControlsCol
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 16
        }
        spacing: 12

        transform: Translate {
            id: loginContentTranslate
            x: 0
            y: 0
        }

        // Avatar Circular (64x64)
        Item {
            id: avatarContainer
            width: 64
            height: 64
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
                id: avatarImg
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                source: root.currentUser.avatar ? ("file://" + root.currentUser.avatar) : ""
                visible: source !== "" && status === Image.Ready
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
                    radius: 32
                    color: "black"
                }
            }

            Rectangle {
                anchors.fill: parent
                radius: 32
                color: "#33000000"
                visible: !avatarImg.visible || avatarImg.status !== Image.Ready
                border.width: 1
                border.color: "#33FFFFFF"

                Text {
                    renderType: Text.NativeRendering
                    anchors.centerIn: parent
                    text: root.currentUser.displayName ? root.currentUser.displayName[0].toUpperCase() : "U"
                    color: theme.textStrong
                    font.pixelSize: 24
                    font.weight: Font.Bold
                }
            }

            Rectangle {
                anchors.fill: parent
                radius: 32
                color: "transparent"
                border.width: 1.5
                border.color: "#40FFFFFF"
            }
        }

        // Nome de Exibição
        Text {
            renderType: Text.NativeRendering
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.currentUser.displayName || root.currentUser.username
            color: theme.textStrong
            font.pixelSize: 16
            font.weight: Font.DemiBold
        }

        // Pílula de Entrada de Senha (Estilo macOS: 280x38, radius 19)
        Rectangle {
            id: pwdContainer
            anchors.horizontalCenter: parent.horizontalCenter
            width: 280
            height: 38
            radius: 19
            color: "#4D000000"
            border.width: 1
            border.color: root.authenticating ? theme.accent : (pwdInput.activeFocus ? "#80FFFFFF" : "#33FFFFFF")
            clip: true

            Row {
                anchors {
                    fill: parent
                    leftMargin: 12
                    rightMargin: 8
                }
                spacing: 8

                TextInput {
                    id: pwdInput
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - (revealBtn.visible ? 28 : 0) - 32
                    echoMode: root.showPassword ? TextInput.Normal : TextInput.Password
                    color: theme.textStrong
                    font.pixelSize: 13
                    focus: true
                    clip: true
                    readOnly: root.authenticating
                    renderType: TextInput.NativeRendering

                    onAccepted: root.doLogin()

                    Component.onCompleted: {
                        forceActiveFocus()
                    }

                    Text {
                        anchors.fill: parent
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.authenticating ? "Autenticando..." : "Digite sua senha"
                        color: "#80FFFFFF"
                        font.pixelSize: 13
                        visible: !pwdInput.text && !pwdInput.activeFocus
                        renderType: Text.NativeRendering
                    }
                }

                // Reveal Password Eye Button
                Rectangle {
                    id: revealBtn
                    width: 24
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 12
                    color: revealMouse.containsMouse ? theme.hoverFill : "transparent"
                    visible: pwdInput.text.length > 0 && !root.authenticating

                    Text {
                        renderType: Text.NativeRendering
                        anchors.centerIn: parent
                        text: root.showPassword ? "" : ""
                        color: revealMouse.containsMouse ? theme.textStrong : theme.textMuted
                        font.pixelSize: 12
                    }

                    MouseArea {
                        id: revealMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.showPassword = !root.showPassword
                    }
                }

                // Submit Button (Seta para direita)
                Rectangle {
                    width: 26
                    height: 26
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 13
                    color: (!root.authenticating && submitMouse.containsMouse) ? "#4DFFFFFF" : "#26FFFFFF"
                    scale: submitMouse.pressed ? 0.90 : 1.0

                    Text {
                        renderType: Text.NativeRendering
                        anchors.centerIn: parent
                        text: root.authenticating ? "" : ""
                        color: theme.textStrong
                        font.pixelSize: 12

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
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.doLogin()
                    }
                }
            }
        }

        // Mensagem de Erro
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.errorMessage.length > 0
            text: root.errorMessage
            color: "#FF6B6B"
            font.pixelSize: 12
            font.weight: Font.Medium
            renderType: Text.NativeRendering
        }
    }

    // =========================================================================
    // CANTO INFERIOR ESQUERDO: SELETOR DE SESSÃO (HYPRLAND)
    // =========================================================================
    Row {
        anchors {
            left: parent.left
            leftMargin: 16
            bottom: parent.bottom
            bottomMargin: 16
        }
        spacing: 8

        Rectangle {
            height: 32
            width: sessRow.implicitWidth + 20
            radius: 16
            color: sessMouse.containsMouse || root.sessionDropdownOpen ? "#40000000" : "#26000000"
            border.width: 1
            border.color: sessMouse.containsMouse || root.sessionDropdownOpen ? "#4DFFFFFF" : "#26FFFFFF"

            Row {
                id: sessRow
                anchors.centerIn: parent
                spacing: 6

                Text {
                    renderType: Text.NativeRendering
                    text: currentSession.icon || ""
                    color: "#FFFFFF"
                    font.pixelSize: 13
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    renderType: Text.NativeRendering
                    text: currentSession.name
                    color: "#FFFFFF"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: sessMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.sessionDropdownOpen = !root.sessionDropdownOpen
            }
        }
    }

    // =========================================================================
    // CANTO INFERIOR DIREITO: BOTÕES DE ENERGIA (SUSPENDER, REINICIAR, DESLIGAR)
    // =========================================================================
    Row {
        anchors {
            right: parent.right
            rightMargin: 16
            bottom: parent.bottom
            bottomMargin: 16
        }
        spacing: 8

        Repeater {
            model: [
                { "icon": "", "label": "Suspender", "action": "systemctl suspend" },
                { "icon": "", "label": "Reiniciar", "action": "systemctl reboot" },
                { "icon": "", "label": "Desligar", "action": "systemctl poweroff" }
            ]

            delegate: Rectangle {
                id: pwrBtn
                required property var modelData

                width: 32
                height: 32
                radius: 16
                color: pwrBtnMouse.containsMouse ? "#40000000" : "#26000000"
                border.width: 1
                border.color: pwrBtnMouse.containsMouse ? "#4DFFFFFF" : "#26FFFFFF"

                Text {
                    renderType: Text.NativeRendering
                    anchors.centerIn: parent
                    text: pwrBtn.modelData.icon
                    color: pwrBtnMouse.containsMouse ? "#FFFFFF" : "#BFFFFFFF"
                    font.pixelSize: 13
                }

                MouseArea {
                    id: pwrBtnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.runPowerCommand(pwrBtn.modelData.action)
                }
            }
        }
    }
}
