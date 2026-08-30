import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property string configPath: Quickshell.env("HOME") + "/.config/bulldoze/privacy.json"

    property string displayName: "Usuário"
    property string loginUser: "usuario"
    property string hostName: "bulldoze"
    property string avatarPath: ""
    property bool hasAvatar: false
    property string initial: "U"
    property string avatarUrl: ""

    // Privacy / Streamer Mode for screenshots (blurs display name and hostname)
    property bool privacyMode: false
    property real privacyBlur: privacyMode ? 1.0 : 0.0

    Behavior on privacyBlur {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    function togglePrivacy() {
        privacyMode = !privacyMode
        savePrivacy()
    }

    function loadPrivacy() {
        if (!privacyReadProc.running) {
            privacyReadProc.running = true
        }
    }

    function savePrivacy() {
        privacyWriteProc.exec(["bash", "-c", "mkdir -p ~/.config/bulldoze && echo '{\"privacy\": " + (privacyMode ? "true" : "false") + "}' > '" + configPath + "'"])
    }

    property var privacyReadProc: Process {
        id: privacyReadProc
        command: ["cat", root.configPath]
        stdout: SplitParser {
            onRead: data => {
                try {
                    const parsed = JSON.parse(data.trim())
                    root.privacyMode = !!parsed.privacy
                } catch (e) {}
            }
        }
    }

    property var privacyWriteProc: Process {
        id: privacyWriteProc
    }

    function refresh() {
        if (!syncProc.running) {
            syncProc.running = true
        }
        loadPrivacy()
    }

    property var timer: Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    property var proc: Process {
        id: syncProc
        command: ["python3", "/home/paulo/.config/quickshell/bulldoze/scripts/sync-profile.py"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    const parsed = JSON.parse(data.trim())
                    if (parsed.displayName) root.displayName = parsed.displayName
                    if (parsed.loginUser) root.loginUser = parsed.loginUser
                    if (parsed.hostName) root.hostName = parsed.hostName
                    root.avatarPath = parsed.avatarPath || ""
                    root.hasAvatar = parsed.hasAvatar || false
                    root.initial = parsed.initial || (root.displayName ? root.displayName[0].toUpperCase() : "U")
                    root.avatarUrl = parsed.avatarUrl || ""
                } catch (e) {
                    // Ignore parse errors on partial stream
                }
            }
        }
    }

    Component.onCompleted: loadPrivacy()
}
