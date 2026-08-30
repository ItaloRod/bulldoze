import QtQuick
import "../../modules"
import ".."

Item {
    id: root

    property var goBack
    property var audio

    Theme {
        id: theme
    }

    readonly property var aud: audio

    Item {
        anchors {
            left: parent.left
            leftMargin: theme.contentInset + theme.notchConcaveWidth
            right: parent.right
            rightMargin: theme.contentInset + theme.notchConcaveWidth
            verticalCenter: parent.verticalCenter
        }
        height: parent.height

        Row {
            anchors.fill: parent
            spacing: theme.spacingSm

            // 1. Back Button (Icon only)
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 32
                height: 32
                radius: theme.radiusSmall
                color: backMouse.containsMouse ? theme.hoverFill : "transparent"
                border.width: 1
                border.color: backMouse.containsMouse ? theme.glassBorderStrong : "transparent"
                scale: backMouse.pressed ? 0.90 : (backMouse.containsMouse ? 1.12 : 1.0)
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
                    anchors.centerIn: parent
                    text: ""
                    color: backMouse.containsMouse ? theme.textStrong : theme.textMedium
                    font.pixelSize: theme.iconSizeSm
                }

                MouseArea {
                    id: backMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (root.goBack) root.goBack()
                }
            }

            // 2. Vertical Separator
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 1
                height: 20
                color: theme.separator
            }

            // 3. Mute / Audio Icon Toggle Button
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 34
                height: 34
                radius: theme.radiusSmall
                color: muteMouse.containsMouse ? theme.hoverFill : (root.aud.muted ? theme.activeFill : "transparent")
                border.width: 1
                border.color: root.aud.muted ? theme.glassBorderStrong : (muteMouse.containsMouse ? theme.glassBorderStrong : "transparent")
                scale: muteMouse.pressed ? 0.90 : (muteMouse.containsMouse ? 1.12 : 1.0)
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
                    anchors.centerIn: parent
                    text: root.aud.icon
                    color: root.aud.muted ? theme.indicatorInactive : (muteMouse.containsMouse ? theme.textStrong : theme.textMedium)
                    font.pixelSize: theme.iconSizeLg
                }

                MouseArea {
                    id: muteMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.aud.toggleMute()
                }
            }

            // 4. Volume Slider Track (Flexible Width)
            Item {
                id: sliderTrack
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 32 - 1 - 34 - 52 - (theme.spacingSm * 4)
                height: 24

                // Track Background
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: 6
                    radius: 3
                    color: theme.glassFillDark
                    border.width: 1
                    border.color: theme.glassBorderSubtle

                    // Fill Bar
                    Rectangle {
                        anchors {
                            left: parent.left
                            top: parent.top
                            bottom: parent.bottom
                        }
                        width: Math.max(0, Math.min(parent.width, parent.width * root.aud.volumeRatio))
                        radius: 3
                        color: root.aud.muted ? theme.indicatorInactive : theme.textStrong

                        Behavior on width {
                            NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic }
                        }
                    }
                }

                // Thumb Handle
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    x: Math.max(0, Math.min(sliderTrack.width - width, (sliderTrack.width - width) * root.aud.volumeRatio))
                    width: 16
                    height: 16
                    radius: 8
                    color: theme.textStrong
                    border.width: 1
                    border.color: theme.glassFillDark

                    Behavior on x {
                        NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    function updateVolume(mouseX) {
                        const ratio = Math.max(0, Math.min(1.0, mouseX / sliderTrack.width))
                        root.aud.setVolume(ratio)
                    }

                    onClicked: mouse => updateVolume(mouse.x)
                    onPositionChanged: mouse => {
                        if (pressed) updateVolume(mouse.x)
                    }
                }
            }

            // 5. Volume Percentage Text
            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: 52
                horizontalAlignment: Text.AlignRight
                text: root.aud.volume + "%"
                color: root.aud.muted ? theme.textMuted : theme.textStrong
                font.pixelSize: theme.fontSizeSubmenuTitle
                font.weight: Font.Bold
            }
        }
    }
}
