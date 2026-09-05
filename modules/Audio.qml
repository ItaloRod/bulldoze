import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

QtObject {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool available: sink !== null && sink.audio !== null
    readonly property bool muted: available && sink.audio.muted
    readonly property int volume: available ? Math.round(sink.audio.volume * 100) : 0
    readonly property real volumeRatio: available ? Math.max(0, Math.min(1, sink.audio.volume)) : 0
    readonly property string icon: !available ? "󰖁" : (muted ? "󰖁" : (volume === 0 ? "" : (volume < 50 ? "" : "")))
    readonly property string label: !available ? "áudio indisponível" : (muted ? "Mudo" : volume + "%")

    property PwObjectTracker tracker: PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    property var availableSinks: []

    function toggleMute() {
        if (available)
            sink.audio.muted = !sink.audio.muted
    }

    function setVolume(vol) {
        if (available) {
            sink.audio.volume = Math.max(0, Math.min(1.0, vol))
            if (sink.audio.muted && vol > 0) {
                sink.audio.muted = false
            }
        }
    }

    function stepVolume(delta) {
        if (available) {
            setVolume(sink.audio.volume + delta)
        }
    }

    function setDefaultSink(id) {
        if (!id) return
        setSinkProc.command = [Quickshell.env("HOME") + "/.config/quickshell/bulldoze/scripts/bulldoze-audio.py", "set-sink", id.toString()]
        setSinkProc.running = true
    }

    function refreshSinks() {
        if (!sinksProc.running) {
            sinksProc.buffer = ""
            sinksProc.running = true
        }
    }

    property var sinksTimer: Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshSinks()
    }

    property var sinksProc: Process {
        id: sinksProc
        command: [Quickshell.env("HOME") + "/.config/quickshell/bulldoze/scripts/bulldoze-audio.py", "sinks"]
        property string buffer: ""

        stdout: SplitParser {
            onRead: data => {
                sinksProc.buffer += data
            }
        }

        onExited: (code, status) => {
            if (code === 0) {
                try {
                    const parsed = JSON.parse(sinksProc.buffer.trim())
                    root.availableSinks = parsed
                } catch (e) {
                }
            }
            sinksProc.buffer = ""
        }
    }

    property var setSinkProc: Process {
        id: setSinkProc
        onExited: (code, status) => {
            root.refreshSinks()
        }
    }
}
