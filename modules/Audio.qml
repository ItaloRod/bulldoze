import QtQuick
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
}
