import QtQuick
import Quickshell.Networking
import Quickshell.Io

QtObject {
    id: root

    readonly property bool enabled: Networking.wifiEnabled
    readonly property bool hardwareEnabled: Networking.wifiHardwareEnabled
    readonly property bool available: hardwareEnabled && enabled
    property string ssid: ""
    readonly property string label: available ? (ssid !== "" ? ssid : "Conectado") : "Desconectado"

    function toggle() {
        Networking.wifiEnabled = !Networking.wifiEnabled
        refresh()
    }

    function openSettings() {
        settingsProc.running = true
    }

    function refresh() {
        if (!wifiProc.running) {
            wifiProc.running = true
        }
    }

    property var timer: Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    property var proc: Process {
        id: wifiProc
        command: ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show", "--active"]
        stdout: SplitParser {
            onRead: data => {
                const lines = data.split("\n")
                let foundSsid = ""
                for (let line of lines) {
                    if (line.includes(":802-11-wireless") || line.includes(":wifi")) {
                        foundSsid = line.split(":")[0].trim()
                        break
                    }
                }
                root.ssid = foundSsid
            }
        }
    }

    property var setProc: Process {
        id: settingsProc
        command: ["nm-connection-editor"]
    }
}
