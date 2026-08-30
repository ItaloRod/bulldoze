import QtQuick
import Quickshell.Services.UPower

QtObject {
    readonly property var device: UPower.displayDevice
    readonly property bool available: device !== null && device.isPresent
    readonly property int percentage: available ? Math.round(device.percentage) : 0
    readonly property bool charging: available && !UPower.onBattery
    readonly property string label: available ? percentage + "%" : "sem bateria"
}
