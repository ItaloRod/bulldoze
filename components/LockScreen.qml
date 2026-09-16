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

        // ---------------------------------------------------------------------
        // 1. FULLSCREEN PRISTINE WALLPAPER (Sem blur, 100% nítido)
        // ---------------------------------------------------------------------
        Image {
            id: bgImage
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            source: "file://" + Quickshell.env("HOME") + "/.cache/bulldoze/Wallpaper_greeter.png"
            asynchronous: true
            cache: false
            onStatusChanged: {
                if (status === Image.Error) {
                    source = "file:///var/lib/greetd/Wallpaper_greeter.png"
                }
            }
        }

        // Leve vinheta sutil para garantir legibilidade perfeita
        Rectangle {
            anchors.fill: parent
            color: "#20000000"
        }

        // Dismiss shake animation on wrong password
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
            onFinished: root.unlock()
        }

        // =====================================================================
        // POSIÇÃO 2/5 (CENTRO SUPERIOR): DATA ACIMA (MÉDIA), HORA ABAIXO (GRANDE)
        // =====================================================================
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

        // =====================================================================
        // POSIÇÃO 5/5 (CENTRO INFERIOR): AVATAR, USUÁRIO E INPUT DE SENHA
        // =====================================================================
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
                        radius: 32
                        color: "black"
                    }
                }

                // Fallback Initial Letter
                Rectangle {
                    anchors.fill: parent
                    radius: 32
                    color: "#33000000"
                    visible: !userProfile.hasAvatar || avatarImg.status !== Image.Ready
                    border.width: 1
                    border.color: "#33FFFFFF"

                    Text {
                        renderType: Text.NativeRendering
                        anchors.centerIn: parent
                        text: userProfile.initial
                        color: theme.textStrong
                        font.pixelSize: 24
                        font.weight: Font.Bold
                    }
                }

                // Outer Ring
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
                text: userProfile.displayName
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
                            onClicked: pwdInput.accepted()
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

        // =====================================================================
        // CANTO INFERIOR DIREITO: BOTÕES DE ENERGIA (SUSPENDER, REINICIAR, DESLIGAR)
        // =====================================================================
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
                        onClicked: surface.runCommand(pwrBtn.modelData.action)
                    }
                }
            }
        }
    }
}
