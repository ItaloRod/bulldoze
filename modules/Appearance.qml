import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property string configPath: Quickshell.env("HOME") + "/.config/bulldoze/appearance.json"
    property string topBarIconColor: "white" // "white" | "black"
    readonly property color topBarColor: (topBarIconColor === "black") ? "#000000" : "#FFFFFF"

    function setTopBarIconColor(colorName) {
        if (colorName === "black" || colorName === "white") {
            topBarIconColor = colorName
            saveConfig()
        }
    }

    function toggleTopBarIconColor() {
        topBarIconColor = (topBarIconColor === "black") ? "white" : "black"
        saveConfig()
    }

    function loadConfig() {
        if (!readProc.running) {
            readProc.running = true
        }
    }

    function saveConfig() {
        const payload = JSON.stringify({ topBarIconColor: root.topBarIconColor })
        writeProc.exec(["bash", "-c", "mkdir -p ~/.config/bulldoze && echo '" + payload + "' > '" + configPath + "'"])
    }

    property var readProc: Process {
        id: readProc
        command: ["sh", "-c", "cat '" + root.configPath + "' 2>/dev/null || echo '{\"topBarIconColor\":\"white\"}'"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    const parsed = JSON.parse(data.trim())
                    if (parsed && (parsed.topBarIconColor === "black" || parsed.topBarIconColor === "white")) {
                        root.topBarIconColor = parsed.topBarIconColor
                    }
                } catch(e) {}
            }
        }
    }

    property var writeProc: Process {
        id: writeProc
    }

    Component.onCompleted: loadConfig()
}
