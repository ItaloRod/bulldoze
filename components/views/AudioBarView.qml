import QtQuick
import "../../modules"
import ".."

Item {
    id: root

    property var audio
    property var openSettings

    readonly property var aud: audio

    Theme {
        id: theme
    }

    Column {
        anchors.fill: parent
        anchors.topMargin: theme.notchConcaveWidth + 2
        anchors.bottomMargin: theme.notchConcaveWidth + 2
        anchors.leftMargin: 2
        anchors.rightMargin: 4
        spacing: theme.spacingSm

        // 1. Mute / Volume Icon Toggle Button (Top)
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 32
            height: 32
            radius: theme.radiusSmall
            color: muteMouse.containsMouse ? theme.hoverFill : "transparent"
            border.width: 1
            border.color: muteMouse.containsMouse ? theme.glassBorderStrong : "transparent"
            scale: muteMouse.pressed ? 0.90 : (muteMouse.containsMouse ? 1.15 : 1.0)

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
                text: root.aud ? root.aud.icon : ""
                color: root.aud && root.aud.muted ? theme.indicatorInactive : (muteMouse.containsMouse ? theme.textStrong : theme.textMedium)
                font.pixelSize: theme.iconSizeMd
            }

            MouseArea {
                id: muteMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: if (root.aud) root.aud.toggleMute()
            }
        }

        // 2. Vertical Volume Slider (Middle)
        Item {
            id: sliderTrack
            anchors.horizontalCenter: parent.horizontalCenter
            width: 28
            height: parent.height - 32 - 32 - (theme.spacingSm * 2)

            // Vertical Track Line
            Rectangle {
                anchors.centerIn: parent
                width: 6
                height: parent.height
                radius: 3
                color: theme.glassFillDark
                border.width: 1
                border.color: theme.glassBorderSubtle

                // Fill Bar (from bottom up)
                Rectangle {
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }
                    height: Math.max(0, Math.min(parent.height, parent.height * (root.aud ? root.aud.volumeRatio : 0)))
                    radius: 3
                    color: root.aud && root.aud.muted ? theme.indicatorInactive : theme.textStrong

                    Behavior on height {
                        NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic }
                    }
                }
            }

            // Slider Thumb
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                y: Math.max(0, Math.min(sliderTrack.height - height, (sliderTrack.height - height) * (1.0 - (root.aud ? root.aud.volumeRatio : 0))))
                width: 14
                height: 14
                radius: 7
                color: theme.textStrong
                border.width: 1
                border.color: theme.glassFillDark

                Behavior on y {
                    NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic }
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                function updateVolume(mouseY) {
                    const ratio = Math.max(0, Math.min(1.0, 1.0 - (mouseY / sliderTrack.height)))
                    if (root.aud) root.aud.setVolume(ratio)
                }

                onClicked: mouse => updateVolume(mouse.y)
                onPositionChanged: mouse => {
                    if (pressed) updateVolume(mouse.y)
                }
            }
        }

        // 3. Settings Gear Icon (Bottom)
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 32
            height: 32
            radius: theme.radiusSmall
            color: gearMouse.containsMouse ? theme.hoverFill : "transparent"
            border.width: 1
            border.color: gearMouse.containsMouse ? theme.glassBorderStrong : "transparent"
            scale: gearMouse.pressed ? 0.90 : (gearMouse.containsMouse ? 1.15 : 1.0)

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
                text: ""
                color: gearMouse.containsMouse ? theme.textStrong : theme.textMedium
                font.pixelSize: theme.iconSizeSm
            }

            MouseArea {
                id: gearMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: if (root.openSettings) root.openSettings()
            }
        }
    }
}
