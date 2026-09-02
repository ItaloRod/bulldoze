import QtQuick
import Quickshell.Bluetooth
import Quickshell.Io

QtObject {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: available && adapter.enabled
    property var connectedDevices: []
    property var pairedDevices: []
    property var discoveredDevices: []
    property var knownDevices: ({})
    property bool initialScanDone: false
    property bool isScanning: false
    property bool isConnecting: false
    property string lastError: ""

    readonly property bool hasConnectedDevices: connectedDevices.length > 0
    readonly property string label: !available ? "Bluetooth indisponível" : (!enabled ? "Bluetooth desligado" : (hasConnectedDevices ? connectedDevices.join(", ") : "Sem dispositivos"))

    function getDeviceIcon(name) {
        if (!name) return ""
        const n = name.toLowerCase()
        if (n.includes("controller") || n.includes("xbox") || n.includes("dualshock") || n.includes("gamepad") || n.includes("dualsense") || n.includes("switch")) {
            return ""
        }
        if (n.includes("headphone") || n.includes("headset") || n.includes("earphone") || n.includes("buds") || n.includes("airpods") || n.includes("earbuds") || n.includes("fone")) {
            return ""
        }
        if (n.includes("sound") || n.includes("speaker") || n.includes("jbl") || n.includes("caixa") || n.includes("audio") || n.includes("boombox")) {
            return ""
        }
        if (n.includes("mouse")) return ""
        if (n.includes("keyboard") || n.includes("teclado")) return ""
        if (n.includes("phone") || n.includes("iphone") || n.includes("galaxy") || n.includes("android")) return ""
        return ""
    }

    function toggle() {
        if (available) {
            adapter.enabled = !adapter.enabled
            refresh()
        }
    }

    function connectDevice(mac) {
        if (!mac || root.isConnecting) return
        root.isConnecting = true
        root.lastError = ""
        actionProc.command = ["bluetoothctl", "connect", mac]
        actionProc.running = true
    }

    function disconnectDevice(mac) {
        if (!mac || root.isConnecting) return
        root.isConnecting = true
        root.lastError = ""
        actionProc.command = ["bluetoothctl", "disconnect", mac]
        actionProc.running = true
    }

    function pairDevice(mac) {
        if (!mac || root.isConnecting) return
        root.isConnecting = true
        root.lastError = ""
        actionProc.command = ["sh", "-c", "bluetoothctl pair " + mac + " && bluetoothctl trust " + mac + " && bluetoothctl connect " + mac]
        actionProc.running = true
    }

    function removeDevice(mac) {
        if (!mac) return
        actionProc.command = ["bluetoothctl", "remove", mac]
        actionProc.running = true
    }

    function startScan() {
        if (root.isScanning) return
        root.isScanning = true
        root.discoveredDevices = []
        scanProc.buffer = ""
        scanProc.running = true
    }

    function stopScan() {
        if (scanProc.running) {
            scanProc.running = false
        }
        root.isScanning = false
    }

    function sendConnectNotification(deviceName) {
        notifProc.exec(["notify-send", "-a", "Bluetooth", "-i", "bluetooth", "Bluetooth", "Dispositivo [" + deviceName + "] foi conectado"])
    }

    function refresh() {
        if (enabled && !btProc.running) {
            btProc.running = true
        } else if (!enabled) {
            connectedDevices = []
            pairedDevices = []
            knownDevices = {}
            root.stopScan()
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

    // Refresh paired and connected devices
    property var proc: Process {
        id: btProc
        command: ["sh", "-c", "bluetoothctl devices Paired; echo '---CONNECTED---'; bluetoothctl devices Connected"]
        
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
            if (!raw) return
            
            const sections = raw.split("---CONNECTED---")
            const pairedRaw = (sections[0] || "").trim().split("\n")
            const connRaw = (sections[1] || "").trim().split("\n")

            const connMacs = new Set()
            const currentMap = {}
            const currentNames = []

            for (let line of connRaw) {
                const l = line.trim()
                if (l.startsWith("Device ")) {
                    const parts = l.split(" ")
                    if (parts.length >= 2) {
                        const mac = parts[1]
                        connMacs.add(mac)
                    }
                }
            }

            const pList = []
            for (let line of pairedRaw) {
                const l = line.trim()
                if (l.startsWith("Device ")) {
                    const parts = l.split(" ")
                    if (parts.length >= 3) {
                        const mac = parts[1]
                        const name = parts.slice(2).join(" ").trim()
                        const isConn = connMacs.has(mac)
                        pList.push({
                            mac: mac,
                            name: name,
                            connected: isConn,
                            icon: root.getDeviceIcon(name)
                        })
                        if (isConn) {
                            currentMap[mac] = name
                            if (!currentNames.includes(name)) {
                                currentNames.push(name)
                            }
                        }
                    }
                }
            }

            // Notification check
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
            root.pairedDevices = pList
        }
    }

    // Device Action Process
    property var actionProc: Process {
        id: actionProc
        property string buffer: ""
        stdout: SplitParser { onRead: data => { actionProc.buffer += data + "\n" } }
        stderr: SplitParser { onRead: data => { actionProc.buffer += data + "\n" } }
        onExited: (code, status) => {
            root.isConnecting = false
            if (code !== 0) {
                root.lastError = actionProc.buffer.trim()
            } else {
                root.lastError = ""
            }
            actionProc.buffer = ""
            root.refresh()
        }
    }

    // Active Discovery Scanner Process
    property var scanProcess: Process {
        id: scanProc
        command: ["bluetoothctl", "--timeout", "15", "scan", "on"]
        property string buffer: ""

        stdout: SplitParser {
            onRead: data => {
                const lines = data.split("\n")
                const currentDiscovered = Object.assign([], root.discoveredDevices)
                const existingMacs = new Set(root.pairedDevices.map(d => d.mac))
                
                for (let line of lines) {
                    const l = line.trim()
                    if (l.includes("[NEW] Device ") || l.includes("[CHG] Device ") || l.startsWith("Device ")) {
                        const match = l.match(/Device\s+([0-9A-Fa-f:]{17})\s+(.+)/)
                        if (match) {
                            const mac = match[1]
                            const name = match[2].replace(/\[.*?\]/g, "").trim()
                            if (name && !name.startsWith("RSSI:") && !name.startsWith("TxPower:") && !name.startsWith("ManufacturerData:") && !existingMacs.has(mac)) {
                                const idx = currentDiscovered.findIndex(d => d.mac === mac)
                                const devObj = {
                                    mac: mac,
                                    name: name,
                                    icon: root.getDeviceIcon(name)
                                }
                                if (idx >= 0) {
                                    currentDiscovered[idx] = devObj
                                } else {
                                    currentDiscovered.push(devObj)
                                }
                            }
                        }
                    }
                }
                root.discoveredDevices = currentDiscovered
            }
        }

        onExited: (code, status) => {
            root.isScanning = false
        }
    }
}
