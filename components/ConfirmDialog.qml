import QtQuick
import QtQuick.Effects
import "."

Item {
    id: root

    property bool open: false
    property string title: "Confirmação"
    property string description: "Deseja realmente prosseguir?"
    property string icon: ""
    property var onConfirm
    property var onCancel

    Theme {
        id: theme
    }

    visible: open || card.opacity > 0.001
    focus: open

    // 1. Dim Backdrop Overlay covering the entire screen
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: theme.glassFill
        opacity: root.open ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation {
                duration: root.open ? theme.animDurationFast : theme.animDurationExit
                easing.type: Easing.OutCubic
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (root.onCancel) root.onCancel()
            }
        }
    }

    // 2. Centered Confirmation Dialog Card
    Item {
        id: card
        anchors.centerIn: parent
        width: 400
        height: contentCol.implicitHeight + (theme.spacingLg * 2)

        scale: root.open ? 1.0 : 0.90
        opacity: root.open ? 1.0 : 0.0

        Behavior on scale {
            NumberAnimation {
                duration: root.open ? theme.animDurationSticky : theme.animDurationExit
                easing.type: root.open ? Easing.OutBack : Easing.InCubic
                easing.overshoot: theme.stickyOvershoot
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: root.open ? theme.animDurationNormal : theme.animDurationExit
                easing.type: Easing.OutCubic
            }
        }

        // Prevent clicks inside the card from propagating to the dim backdrop
        MouseArea {
            anchors.fill: parent
            onClicked: mouse => mouse.accepted = true
        }

        // Liquid Glass Surface with specular highlight and soft shadow
        LiquidGlass {
            anchors.fill: parent
            radius: theme.radiusCard
            fillColor: theme.glassFillDark
            shadowEnabled: true
        }

        Column {
            id: contentCol
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: theme.spacingLg
            }
            spacing: theme.spacingMd

            // Header row: Icon + Title
            Row {
                spacing: theme.spacingSm
                anchors.left: parent.left
                anchors.right: parent.right

                Text {
                    renderType: Text.NativeRendering
                    text: root.icon
                    color: theme.textStrong
                    font.pixelSize: theme.fontSizeXl
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    renderType: Text.NativeRendering
                    text: root.title
                    color: theme.textStrong
                    font.pixelSize: theme.fontSizeLg
                    font.weight: Font.Bold
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Description text
            Text {
                renderType: Text.NativeRendering
                width: parent.width
                text: root.description
                color: theme.textMedium
                font.pixelSize: theme.fontSizeSm
                wrapMode: Text.WordWrap
                lineHeight: 1.25
            }

            Item {
                width: 1
                height: theme.spacingXs
            }

            // Buttons row: Cancelar / Confirmar
            Row {
                anchors.right: parent.right
                spacing: theme.spacingSm

                // Cancel button
                Rectangle {
                    width: 100
                    height: 34
                    radius: theme.radiusSmall
                    color: cancelMouse.containsMouse ? theme.hoverFill : theme.itemFill
                    border.width: 1
                    border.color: cancelMouse.containsMouse ? theme.glassBorderStrong : theme.glassBorderSubtle
                    scale: cancelMouse.pressed ? 0.92 : (cancelMouse.containsMouse ? 1.05 : 1.0)
                    transformOrigin: Item.Center

                    Behavior on color { ColorAnimation { duration: theme.animDurationFast } }
                    Behavior on border.color { ColorAnimation { duration: theme.animDurationFast } }
                    Behavior on scale {
                        NumberAnimation {
                            duration: theme.animDurationFast
                            easing.type: Easing.OutBack
                            easing.overshoot: theme.buttonOvershoot
                        }
                    }

                    Text {
                        renderType: Text.NativeRendering
                        anchors.centerIn: parent
                        text: "Cancelar"
                        color: cancelMouse.containsMouse ? theme.textStrong : theme.textMedium
                        font.pixelSize: theme.fontSizeXs
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        id: cancelMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.onCancel) root.onCancel()
                        }
                    }
                }

                // Confirm button
                Rectangle {
                    width: 100
                    height: 34
                    radius: theme.radiusSmall
                    color: confirmMouse.containsMouse ? theme.hoverFill : theme.activeFill
                    border.width: 1
                    border.color: theme.glassBorderStrong
                    scale: confirmMouse.pressed ? 0.92 : (confirmMouse.containsMouse ? 1.05 : 1.0)
                    transformOrigin: Item.Center

                    Behavior on color { ColorAnimation { duration: theme.animDurationFast } }
                    Behavior on border.color { ColorAnimation { duration: theme.animDurationFast } }
                    Behavior on scale {
                        NumberAnimation {
                            duration: theme.animDurationFast
                            easing.type: Easing.OutBack
                            easing.overshoot: theme.buttonOvershoot
                        }
                    }

                    Text {
                        renderType: Text.NativeRendering
                        anchors.centerIn: parent
                        text: "Confirmar"
                        color: theme.textStrong
                        font.pixelSize: theme.fontSizeXs
                        font.weight: Font.Bold
                    }

                    MouseArea {
                        id: confirmMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.onConfirm) root.onConfirm()
                        }
                    }
                }
            }
        }
    }

    // Keyboard support: Escape cancels, Return/Enter confirms
    Keys.onEscapePressed: event => {
        event.accepted = true
        if (root.onCancel) root.onCancel()
    }
    Keys.onReturnPressed: event => {
        event.accepted = true
        if (root.onConfirm) root.onConfirm()
    }
    Keys.onEnterPressed: event => {
        event.accepted = true
        if (root.onConfirm) root.onConfirm()
    }

    onOpenChanged: {
        if (open) {
            root.forceActiveFocus()
        }
    }
}
