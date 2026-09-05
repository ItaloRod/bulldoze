import QtQuick
import QtQuick.Effects
import "../../modules"
import ".."

Item {
    id: root

    property var goBack
    property var userProfile

    Theme {
        id: theme
    }

    readonly property var prof: userProfile

    Column {
        anchors.fill: parent
        anchors.margins: theme.spacingLg
        spacing: theme.spacingMd

        // Header
        Row {
            width: parent.width
            height: 32
            spacing: theme.spacingSm

            // Back Button (Icon only)
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 32
                height: 32
                radius: theme.radiusSmall
                color: backMouse.containsMouse ? theme.hoverFill : "transparent"
                border.width: 1
                border.color: backMouse.containsMouse ? theme.glassBorderStrong : "transparent"
                scale: backMouse.pressed ? 0.92 : 1.0

                Behavior on color {
                    ColorAnimation { duration: theme.animDurationFast }
                }
                Behavior on border.color {
                    ColorAnimation { duration: theme.animDurationFast }
                }
                Behavior on scale {
                    NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic }
                }

                Text {
                    renderType: Text.NativeRendering
                    anchors.centerIn: parent
                    text: ""
                    color: backMouse.containsMouse ? theme.textStrong : theme.textMedium
                    font.pixelSize: theme.fontSizeMd
                }

                MouseArea {
                    id: backMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (root.goBack) root.goBack()
                }
            }

            // Title and Icon
            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: theme.spacingSm

                Text {
                    renderType: Text.NativeRendering
                    text: ""
                    color: theme.textStrong
                    font.pixelSize: theme.fontSizeMd
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    renderType: Text.NativeRendering
                    text: "Perfil do Usuário"
                    color: theme.textStrong
                    font.pixelSize: theme.fontSizeMd
                    font.weight: Font.DemiBold
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // Separator
        Rectangle {
            width: parent.width
            height: 1
            color: theme.separator
        }

        // Profile Card
        Rectangle {
            width: parent.width
            height: 64
            radius: theme.radiusSmall
            color: theme.itemFill
            border.width: 1
            border.color: theme.glassBorderSubtle

            Row {
                anchors {
                    left: parent.left
                    leftMargin: theme.spacingMd
                    right: parent.right
                    rightMargin: theme.spacingMd
                    verticalCenter: parent.verticalCenter
                }
                spacing: theme.spacingMd

                // Avatar Container
                Item {
                    id: avatarContainer
                    width: 44
                    height: 44
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        anchors.fill: parent
                        radius: 22
                        color: theme.glassFillDark
                    }

                    Image {
                        id: avatarImg
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectCrop
                        source: root.prof.hasAvatar && root.prof.avatarPath !== "" ? ("file://" + root.prof.avatarPath) : ""
                        visible: root.prof.hasAvatar && status === Image.Ready
                        asynchronous: true
                        cache: false
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            maskEnabled: true
                            maskSource: avatarMask
                        }
                    }

                    Item {
                        id: avatarMask
                        width: avatarContainer.width
                        height: avatarContainer.height
                        visible: false
                        layer.enabled: true

                        Rectangle {
                            anchors.fill: parent
                            radius: 22
                            color: "black"
                        }
                    }

                    Text {
                        renderType: Text.NativeRendering
                        anchors.centerIn: parent
                        visible: !avatarImg.visible
                        text: root.prof.initial
                        color: theme.textStrong
                        font.pixelSize: theme.fontSizeXl
                        font.weight: Font.DemiBold
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 22
                        color: "transparent"
                        border.width: 1
                        border.color: theme.glassBorder
                    }
                }

                // User Info with Privacy Blur
                Item {
                    width: parent.width - avatarContainer.width - eyeBtn.width - (theme.spacingMd * 2)
                    height: 44
                    anchors.verticalCenter: parent.verticalCenter

                    Column {
                        anchors {
                            left: parent.left
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: 2

                        layer.enabled: true
                        layer.effect: MultiEffect {
                            blurEnabled: root.prof.privacyBlur > 0.001
                            blur: root.prof.privacyBlur
                            blurMax: 64
                            blurMultiplier: 3.0
                        }

                        Text {
                            renderType: Text.NativeRendering
                            width: parent.width
                            text: root.prof.displayName
                            color: theme.textStrong
                            opacity: 1.0 - (root.prof.privacyBlur * 0.7)
                            font.pixelSize: theme.fontSizeMd
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }

                        Row {
                            spacing: theme.spacingXs
                            opacity: 1.0 - (root.prof.privacyBlur * 0.7)

                            Text {
                                renderType: Text.NativeRendering
                                text: ""
                                color: theme.textMuted
                                font.pixelSize: theme.fontSizeXs
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                renderType: Text.NativeRendering
                                text: root.prof.hostName
                                color: theme.textMuted
                                font.pixelSize: theme.fontSizeXs
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    // Frosted Privacy Placeholder Pill Bars (When blurred)
                    Column {
                        anchors {
                            left: parent.left
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: 6
                        opacity: root.prof.privacyBlur
                        visible: opacity > 0.001

                        Rectangle {
                            width: Math.min(130, parent.width * 0.65)
                            height: 14
                            radius: 7
                            color: theme.glassFillDark
                            border.width: 1
                            border.color: theme.glassBorderSubtle
                        }

                        Rectangle {
                            width: Math.min(85, parent.width * 0.4)
                            height: 10
                            radius: 5
                            color: theme.glassFillDark
                            border.width: 1
                            border.color: theme.glassBorderSubtle
                        }
                    }
                }

                // Privacy Eye Button
                Rectangle {
                    id: eyeBtn
                    width: 32
                    height: 32
                    radius: theme.radiusSmall
                    anchors.verticalCenter: parent.verticalCenter
                    color: eyeMouse.containsMouse ? theme.hoverFill : (root.prof.privacyMode ? theme.activeFill : theme.itemFill)
                    border.width: 1
                    border.color: root.prof.privacyMode ? theme.glassBorderStrong : theme.glassBorderSubtle
                    scale: eyeMouse.pressed ? 0.94 : 1.0

                    Behavior on color {
                        ColorAnimation { duration: theme.animDurationFast }
                    }
                    Behavior on scale {
                        NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic }
                    }

                    Text {
                        renderType: Text.NativeRendering
                        anchors.centerIn: parent
                        text: root.prof.privacyMode ? "" : ""
                        color: root.prof.privacyMode ? theme.textStrong : theme.textMuted
                        font.pixelSize: theme.fontSizeMd
                    }

                    MouseArea {
                        id: eyeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.prof.togglePrivacy()
                    }
                }
            }
        }
    }
}
