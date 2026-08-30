import Quickshell
import Quickshell.Wayland
import QtQuick
import "components"

ShellRoot {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: greeterWindow
            required property var modelData

            screen: modelData

            WlrLayershell.namespace: "bulldoze-greeter"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            color: "transparent"
            focusable: true
            exclusiveZone: -1

            Greeter {
                anchors.fill: parent
            }
        }
    }
}
