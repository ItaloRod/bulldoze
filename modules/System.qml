import QtQuick
import Quickshell.Io

Item {
    id: root
    visible: false

    property int cpuUsage: 0
    property int memoryUsage: 0
    property real previousIdle: 0
    property real previousTotal: 0

    FileView {
        id: statFile
        path: "/proc/stat"
        blockLoading: true
        blockAllReads: true
    }

    FileView {
        id: memoryFile
        path: "/proc/meminfo"
        blockLoading: true
        blockAllReads: true
    }

    function refresh() {
        const fields = statFile.text().split("\n")[0].trim().split(/\s+/)
        const values = fields.slice(1).map(Number)
        const idle = values[3] + values[4]
        const total = values.reduce((sum, value) => sum + value, 0)

        if (previousTotal > 0 && total > previousTotal)
            cpuUsage = Math.round(100 * (1 - (idle - previousIdle) / (total - previousTotal)))

        previousIdle = idle
        previousTotal = total

        const text = memoryFile.text()
        const totalMatch = /MemTotal:\s+(\d+)/.exec(text)
        const availableMatch = /MemAvailable:\s+(\d+)/.exec(text)
        if (totalMatch && availableMatch)
            memoryUsage = Math.round(100 * (1 - Number(availableMatch[1]) / Number(totalMatch[1])))
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
