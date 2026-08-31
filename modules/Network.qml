import QtQuick
import Quickshell.Networking
import Quickshell.Io

QtObject {
    id: root

    readonly property bool enabled: Networking.wifiEnabled
    readonly property bool hardwareEnabled: Networking.wifiHardwareEnabled
    readonly property bool available: hardwareEnabled && enabled
    property string ssid: ""
    property int currentSignal: 0
    property string currentSecurity: ""
    property string currentIp: ""
    property var availableNetworks: []
    property bool isScanning: false
    property bool isConnecting: false
    property string lastError: ""

    readonly property string label: available ? (ssid !== "" ? ssid : "Conectado") : "Desconectado"

    function toggle() {
        Networking.wifiEnabled = !Networking.wifiEnabled
        refresh()
        if (Networking.wifiEnabled) {
            scanNetworks(true)
        }
    }

    function refresh() {
        if (!wifiActiveProc.running) {
            wifiActiveProc.running = true
        }
    }

    function scanNetworks(force) {
        if (root.isScanning) return
        root.isScanning = true
        scanProc.buffer = ""
        scanProc.command = force ? ["nmcli", "-t", "-f", "IN-USE,BSSID,SSID,SIGNAL,SECURITY", "dev", "wifi", "list", "--rescan", "yes"]
                                 : ["nmcli", "-t", "-f", "IN-USE,BSSID,SSID,SIGNAL,SECURITY", "dev", "wifi", "list"]
        scanProc.running = true
    }

    function connectToNetwork(targetSsid, password) {
        if (!targetSsid || root.isConnecting) return
        root.isConnecting = true
        root.lastError = ""
        
        let args = ["nmcli", "dev", "wifi", "connect", targetSsid]
        if (password && password.trim() !== "") {
            args.push("password", password.trim())
        }
        
        connectProc.targetSsid = targetSsid
        connectProc.command = args
        connectProc.buffer = ""
        connectProc.running = true
    }

    function disconnectCurrent() {
        if (!root.ssid) return
        disconnProc.command = ["nmcli", "con", "down", "id", root.ssid]
        disconnProc.running = true
    }

    function forgetNetwork(targetSsid) {
        if (!targetSsid) return
        forgetProc.command = ["nmcli", "con", "delete", "id", targetSsid]
        forgetProc.running = true
    }

    property var timer: Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.refresh()
        }
    }

    // Active Wi-Fi connection parser
    property var activeProc: Process {
        id: wifiActiveProc
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
                if (foundSsid !== "") {
                    ipProc.running = true
                } else {
                    root.currentIp = ""
                    root.currentSignal = 0
                }
            }
        }
    }

    // IP address fetcher
    property var ipProcess: Process {
        id: ipProc
        command: ["ip", "-4", "addr", "show", "up"]
        property string buffer: ""
        stdout: SplitParser {
            onRead: data => {
                ipProc.buffer += data + "\n"
            }
        }
        onExited: (code, status) => {
            if (code === 0) {
                const lines = ipProc.buffer.split("\n")
                ipProc.buffer = ""
                for (let line of lines) {
                    const l = line.trim()
                    if (l.startsWith("inet ") && !l.startsWith("inet 127.")) {
                        const parts = l.split(" ")
                        if (parts.length >= 2) {
                            root.currentIp = parts[1].split("/")[0]
                            break
                        }
                    }
                }
            }
        }
    }

    // Network Scanner Process
    property var scanProcess: Process {
        id: scanProc
        property string buffer: ""
        stdout: SplitParser {
            onRead: data => {
                scanProc.buffer += data + "\n"
            }
        }
        onExited: (code, status) => {
            root.isScanning = false
            if (code !== 0) return
            
            const raw = scanProc.buffer.trim()
            scanProc.buffer = ""
            if (!raw) return

            const lines = raw.split("\n")
            const netMap = {}

            for (let line of lines) {
                if (!line.trim()) continue
                const safe = line.replace(/\\:/g, "__COLON__")
                const parts = safe.split(":")
                if (parts.length >= 5) {
                    const inUse = parts[0].trim() === "*"
                    const bssid = parts[1].replace(/__COLON__/g, ":").trim()
                    const ssidName = parts[2].replace(/__COLON__/g, ":").trim()
                    const signal = parseInt(parts[3]) || 0
                    const security = parts.slice(4).join(":").replace(/__COLON__/g, ":").trim()

                    if (!ssidName) continue // skip unnamed/hidden SSID

                    if (!netMap[ssidName] || inUse || signal > netMap[ssidName].signal) {
                        netMap[ssidName] = {
                            inUse: inUse,
                            bssid: bssid,
                            ssid: ssidName,
                            signal: signal,
                            security: security
                        }
                    }
                    if (inUse) {
                        root.currentSignal = signal
                        root.currentSecurity = security
                    }
                }
            }

            const list = Object.values(netMap)
            list.sort((a, b) => {
                if (a.inUse && !b.inUse) return -1
                if (!a.inUse && b.inUse) return 1
                return b.signal - a.signal
            })
            root.availableNetworks = list
        }
    }

    // Connect Process
    property var connectProcess: Process {
        id: connectProc
        property string targetSsid: ""
        property string buffer: ""
        stdout: SplitParser {
            onRead: data => { connectProc.buffer += data + "\n" }
        }
        stderr: SplitParser {
            onRead: data => { connectProc.buffer += data + "\n" }
        }
        onExited: (code, status) => {
            root.isConnecting = false
            if (code === 0) {
                root.lastError = ""
                root.refresh()
                root.scanNetworks(false)
            } else {
                root.lastError = connectProc.buffer.trim() || "Falha ao conectar na rede"
            }
            connectProc.buffer = ""
        }
    }

    // Disconnect Process
    property var disconnProcess: Process {
        id: disconnProc
        onExited: (code, status) => {
            root.refresh()
            root.scanNetworks(false)
        }
    }

    // Forget Process
    property var forgetProcess: Process {
        id: forgetProc
        onExited: (code, status) => {
            root.refresh()
            root.scanNetworks(false)
        }
    }
}
