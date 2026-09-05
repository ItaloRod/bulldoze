import Quickshell
import QtQuick

Row {
    id: root

    property bool isExpanded: false

    Theme {
        id: theme
    }

    spacing: 8

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter

        text: Qt.formatDateTime(clock.date, "HH:mm")
        color: theme.textStrong

        font.pixelSize: theme.fontSizeMd
        font.weight: Font.Bold
        renderType: Text.NativeRendering
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter

        text: {
            const str = clock.date.toLocaleDateString(Qt.locale("pt_BR"), "ddd, dd MMM")
            return str ? (str.charAt(0).toUpperCase() + str.slice(1)) : ""
        }
        color: root.isExpanded ? theme.textMedium : theme.textMuted

        font.pixelSize: theme.fontSizeXs
        font.weight: Font.Medium
        renderType: Text.NativeRendering
    }
}

