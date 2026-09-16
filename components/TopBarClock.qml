import QtQuick
import Quickshell
import "."

Item {
    id: root

    property color textColor: "#FFFFFF"
    signal clicked()

    implicitHeight: 32
    implicitWidth: clockText.implicitWidth + 16

    Theme {
        id: theme
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    function formatDateTime(date) {
        if (!date) return ""
        const locale = Qt.locale("pt_BR")
        
        let weekDay = date.toLocaleDateString(locale, "ddd")
        if (weekDay) {
            weekDay = weekDay.charAt(0).toUpperCase() + weekDay.slice(1)
            if (!weekDay.endsWith(".")) weekDay += "."
        } else {
            weekDay = ""
        }

        const day = date.getDate()

        let month = date.toLocaleDateString(locale, "MMM")
        if (month) {
            month = month.charAt(0).toUpperCase() + month.slice(1)
            if (month.endsWith(".")) month = month.slice(0, -1)
        } else {
            month = ""
        }

        const time = Qt.formatDateTime(date, "HH:mm")

        return `${weekDay} ${day} de ${month}. ${time}`
    }

    Rectangle {
        id: clickHighlight
        anchors.fill: parent
        radius: 4
        color: clickArea.containsMouse ? (root.textColor === "#000000" ? "#14000000" : "#14FFFFFF") : "transparent"

        Text {
            id: clockText
            anchors.centerIn: parent
            text: root.formatDateTime(clock.date)
            color: root.textColor
            font.pixelSize: 13
            font.weight: Font.Bold
            renderType: Text.NativeRendering
        }

        MouseArea {
            id: clickArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.clicked()
        }
    }
}
