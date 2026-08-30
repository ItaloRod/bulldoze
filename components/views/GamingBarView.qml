import QtQuick
import "../../modules"
import ".."

Item {
    id: root

    property var goBack
    property var gaming
    property var openSettings

    Theme {
        id: theme
    }

    readonly property var game: gaming

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

            // 3. Quick Toggle: GameMode
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                height: 32
                implicitWidth: gmRow.implicitWidth + 20
                radius: theme.radiusSmall
                color: root.game.gamemodeEnabled ? theme.activeFill : (gmMouse.containsMouse ? theme.hoverFill : theme.itemFill)
                border.width: 1
                border.color: root.game.gamemodeEnabled ? theme.glassBorderStrong : (gmMouse.containsMouse ? theme.glassBorderSubtle : "transparent")
                scale: gmMouse.pressed ? 0.92 : (gmMouse.containsMouse ? 1.06 : 1.0)
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

                Row {
                    id: gmRow
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: ""
                        color: root.game.gamemodeEnabled ? theme.textStrong : (gmMouse.containsMouse ? theme.textStrong : theme.textMedium)
                        font.pixelSize: theme.iconSizeSm
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "GameMode"
                        color: root.game.gamemodeEnabled ? theme.textStrong : (gmMouse.containsMouse ? theme.textStrong : theme.textMedium)
                        font.pixelSize: theme.fontSizeSubmenuBody
                        font.weight: root.game.gamemodeEnabled ? Font.Bold : Font.DemiBold
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: gmMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.game.toggleGamemode()
                }
            }

            // 4. Quick Toggle: Bulldoptimizer
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                height: 32
                implicitWidth: boRow.implicitWidth + 20
                radius: theme.radiusSmall
                color: root.game.bulldoptimizerEnabled ? theme.activeFill : (boMouse.containsMouse ? theme.hoverFill : theme.itemFill)
                border.width: 1
                border.color: root.game.bulldoptimizerEnabled ? theme.glassBorderStrong : (boMouse.containsMouse ? theme.glassBorderSubtle : "transparent")
                scale: boMouse.pressed ? 0.92 : (boMouse.containsMouse ? 1.06 : 1.0)
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

                Row {
                    id: boRow
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: ""
                        color: root.game.bulldoptimizerEnabled ? theme.textStrong : (boMouse.containsMouse ? theme.textStrong : theme.textMedium)
                        font.pixelSize: theme.iconSizeSm
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "Bulldoptimizer"
                        color: root.game.bulldoptimizerEnabled ? theme.textStrong : (boMouse.containsMouse ? theme.textStrong : theme.textMedium)
                        font.pixelSize: theme.fontSizeSubmenuBody
                        font.weight: root.game.bulldoptimizerEnabled ? Font.Bold : Font.DemiBold
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: boMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.game.toggleBulldoptimizer()
                }
            }

            // 5. Quick Toggle: MangoHud
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                height: 32
                implicitWidth: mhRow.implicitWidth + 20
                radius: theme.radiusSmall
                color: root.game.mangohudEnabled ? theme.activeFill : (mhMouse.containsMouse ? theme.hoverFill : theme.itemFill)
                border.width: 1
                border.color: root.game.mangohudEnabled ? theme.glassBorderStrong : (mhMouse.containsMouse ? theme.glassBorderSubtle : "transparent")
                scale: mhMouse.pressed ? 0.92 : (mhMouse.containsMouse ? 1.06 : 1.0)
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

                Row {
                    id: mhRow
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: ""
                        color: root.game.mangohudEnabled ? theme.textStrong : (mhMouse.containsMouse ? theme.textStrong : theme.textMedium)
                        font.pixelSize: theme.iconSizeSm
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "MangoHud"
                        color: root.game.mangohudEnabled ? theme.textStrong : (mhMouse.containsMouse ? theme.textStrong : theme.textMedium)
                        font.pixelSize: theme.fontSizeSubmenuBody
                        font.weight: root.game.mangohudEnabled ? Font.Bold : Font.DemiBold
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: mhMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.game.toggleMangohud()
                }
            }

            // 5. Quick Toggle: Gamescope
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                height: 32
                implicitWidth: gsRow.implicitWidth + 20
                radius: theme.radiusSmall
                color: root.game.gamescopeEnabled ? theme.activeFill : (gsMouse.containsMouse ? theme.hoverFill : theme.itemFill)
                border.width: 1
                border.color: root.game.gamescopeEnabled ? theme.glassBorderStrong : (gsMouse.containsMouse ? theme.glassBorderSubtle : "transparent")
                scale: gsMouse.pressed ? 0.92 : (gsMouse.containsMouse ? 1.06 : 1.0)
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

                Row {
                    id: gsRow
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: ""
                        color: root.game.gamescopeEnabled ? theme.textStrong : (gsMouse.containsMouse ? theme.textStrong : theme.textMedium)
                        font.pixelSize: theme.iconSizeSm
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "Gamescope"
                        color: root.game.gamescopeEnabled ? theme.textStrong : (gsMouse.containsMouse ? theme.textStrong : theme.textMedium)
                        font.pixelSize: theme.fontSizeSubmenuBody
                        font.weight: root.game.gamescopeEnabled ? Font.Bold : Font.DemiBold
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: gsMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.game.toggleGamescope()
                }
            }

            // 6. Vertical Separator
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 1
                height: 20
                color: theme.separator
            }

            // 7. Gear Settings Button (Opens floating modal)
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 32
                height: 32
                radius: theme.radiusSmall
                color: gearMouse.containsMouse ? theme.hoverFill : "transparent"
                border.width: 1
                border.color: gearMouse.containsMouse ? theme.glassBorderStrong : "transparent"
                scale: gearMouse.pressed ? 0.90 : (gearMouse.containsMouse ? 1.12 : 1.0)
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
}
