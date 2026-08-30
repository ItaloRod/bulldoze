import QtQuick
import Quickshell.Bluetooth
import Quickshell.Io

QtObject {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: available && adapter.enabled
    property var connectedDevices: []
    property var knownDevices: ({})
    property bool initialScanDone: false
    readonly property bool hasConnectedDevices: connectedDevices.length > 0
    readonly property string label: !available ? "Bluetooth indisponível" : (!enabled ? "Bluetooth desligado" : (hasConnectedDevices ? connectedDevices.join(", ") : "Sem dispositivos"))

    function toggle() {
        if (available) {
            adapter.enabled = !adapter.enabled
            refresh()
        }
    }

    function pairNew() {
        settingsProc.running = true
    }

    function openSettings() {
        settingsProc.running = true
    }

    function sendConnectNotification(deviceName) {
        notifProc.exec(["notify-send", "-a", "Bluetooth", "-i", "bluetooth", "Bluetooth", "Dispositivo [" + deviceName + "] foi conectado"])
    }

    function refresh() {
        if (enabled && !btProc.running) {
            btProc.running = true
        } else if (!enabled) {
            connectedDevices = []
            knownDevices = {}
        }
    }

    property var notifProc: Process {
        id: notifProc
    }

    property var timer: Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    property var proc: Process {
        id: btProc
        command: ["bluetoothctl", "devices", "Connected"]
        
        property string buffer: ""

        stdout: SplitParser {
            onRead: data => {
                btProc.buffer += data + "\n"
            }
        }

        onExited: (code, status) => {
            if (code !== 0) return
            
            const raw = btProc.buffer.trim()
            btProc.buffer = ""
            
            const lines = raw !== "" ? raw.split("\n") : []
            const currentMap = {}
            const currentNames = []

            for (let i = 0; i < lines.length; i++) {
                const line = lines[i].trim()
                if (line.startsWith("Device ")) {
                    // Format: "Device F4:6A:D7:97:22:FF Xbox Wireless Controller"
                    const parts = line.split(" ")
                    if (parts.length >= 3) {
                        const mac = parts[1]
                        const name = parts.slice(2).join(" ").trim()
                        if (mac && name) {
                            currentMap[mac] = name
                            if (!currentNames.includes(name)) {
                                currentNames.push(name)
                            }
                        }
                    }
                }
            }

            // Only notify for newly connected devices that were not in knownDevices
            if (root.initialScanDone) {
                for (const mac in currentMap) {
                    if (!root.knownDevices[mac]) {
                        root.sendConnectNotification(currentMap[mac])
                    }
                }
            } else {
                root.initialScanDone = true
            }

            root.knownDevices = currentMap
            root.connectedDevices = currentNames
        }
    }

    property var setProc: Process {
        id: settingsProc
        command: ["blueman-manager"]
    }
}
