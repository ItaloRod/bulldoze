import QtQuick
import QtQuick.Shapes

Item {
    id: root

    Theme {
        id: theme
    }

    property string side: "right" // "right" or "left"
    property color fillColor: theme.glassFillDark
    property color borderColor: "transparent"
    property int borderWidth: 0
    readonly property real concaveWidth: theme.notchConcaveWidth
    readonly property real concaveHeight: theme.notchConcaveHeight
    readonly property real bottomRadius: theme.notchBottomRadius

    Shape {
        anchors.fill: parent
        antialiasing: true

        // ---------------------------------------------------------------------
        // RIGHT DOCKED SHAPE (side === "right")
        // ---------------------------------------------------------------------
        // 1. Fill
        ShapePath {
            strokeColor: "transparent"
            strokeWidth: 0
            fillColor: root.side === "right" ? root.fillColor : "transparent"

            startX: root.width
            startY: 0

            PathCubic {
                x: root.width - root.concaveHeight
                y: root.concaveWidth
                control1X: root.width
                control1Y: root.concaveWidth * 0.5
                control2X: root.width - root.concaveHeight * 0.5
                control2Y: root.concaveWidth
            }
            PathLine {
                x: root.bottomRadius
                y: root.concaveWidth
            }
            PathCubic {
                x: 0
                y: root.concaveWidth + root.bottomRadius
                control1X: root.bottomRadius * 0.5
                control1Y: root.concaveWidth
                control2X: 0
                control2Y: root.concaveWidth + root.bottomRadius * 0.5
            }
            PathLine {
                x: 0
                y: root.height - root.concaveWidth - root.bottomRadius
            }
            PathCubic {
                x: root.bottomRadius
                y: root.height - root.concaveWidth
                control1X: 0
                control1Y: root.height - root.concaveWidth - root.bottomRadius * 0.5
                control2X: root.bottomRadius * 0.5
                control2Y: root.height - root.concaveWidth
            }
            PathLine {
                x: root.width - root.concaveHeight
                y: root.height - root.concaveWidth
            }
            PathCubic {
                x: root.width
                y: root.height
                control1X: root.width - root.concaveHeight * 0.5
                control1Y: root.height - root.concaveWidth
                control2X: root.width
                control2Y: root.height - root.concaveWidth * 0.5
            }
            PathLine {
                x: root.width
                y: 0
            }
        }

        // 2. Stroke
        ShapePath {
            strokeColor: root.side === "right" ? root.borderColor : "transparent"
            strokeWidth: root.borderWidth
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            startX: root.width
            startY: 0

            PathCubic {
                x: root.width - root.concaveHeight
                y: root.concaveWidth
                control1X: root.width
                control1Y: root.concaveWidth * 0.5
                control2X: root.width - root.concaveHeight * 0.5
                control2Y: root.concaveWidth
            }
            PathLine {
                x: root.bottomRadius
                y: root.concaveWidth
            }
            PathCubic {
                x: 0
                y: root.concaveWidth + root.bottomRadius
                control1X: root.bottomRadius * 0.5
                control1Y: root.concaveWidth
                control2X: 0
                control2Y: root.concaveWidth + root.bottomRadius * 0.5
            }
            PathLine {
                x: 0
                y: root.height - root.concaveWidth - root.bottomRadius
            }
            PathCubic {
                x: root.bottomRadius
                y: root.height - root.concaveWidth
                control1X: 0
                control1Y: root.height - root.concaveWidth - root.bottomRadius * 0.5
                control2X: root.bottomRadius * 0.5
                control2Y: root.height - root.concaveWidth
            }
            PathLine {
                x: root.width - root.concaveHeight
                y: root.height - root.concaveWidth
            }
            PathCubic {
                x: root.width
                y: root.height
                control1X: root.width - root.concaveHeight * 0.5
                control1Y: root.height - root.concaveWidth
                control2X: root.width
                control2Y: root.height - root.concaveWidth * 0.5
            }
        }

        // ---------------------------------------------------------------------
        // LEFT DOCKED SHAPE (side === "left")
        // ---------------------------------------------------------------------
        // 1. Fill
        ShapePath {
            strokeColor: "transparent"
            strokeWidth: 0
            fillColor: root.side === "left" ? root.fillColor : "transparent"

            startX: 0
            startY: 0

            PathCubic {
                x: root.concaveHeight
                y: root.concaveWidth
                control1X: 0
                control1Y: root.concaveWidth * 0.5
                control2X: root.concaveHeight * 0.5
                control2Y: root.concaveWidth
            }
            PathLine {
                x: root.width - root.bottomRadius
                y: root.concaveWidth
            }
            PathCubic {
                x: root.width
                y: root.concaveWidth + root.bottomRadius
                control1X: root.width - root.bottomRadius * 0.5
                control1Y: root.concaveWidth
                control2X: root.width
                control2Y: root.concaveWidth + root.bottomRadius * 0.5
            }
            PathLine {
                x: root.width
                y: root.height - root.concaveWidth - root.bottomRadius
            }
            PathCubic {
                x: root.width - root.bottomRadius
                y: root.height - root.concaveWidth
                control1X: root.width
                control1Y: root.height - root.concaveWidth - root.bottomRadius * 0.5
                control2X: root.width - root.bottomRadius * 0.5
                control2Y: root.height - root.concaveWidth
            }
            PathLine {
                x: root.concaveHeight
                y: root.height - root.concaveWidth
            }
            PathCubic {
                x: 0
                y: root.height
                control1X: root.concaveHeight * 0.5
                control1Y: root.height - root.concaveWidth
                control2X: 0
                control2Y: root.height - root.concaveWidth * 0.5
            }
            PathLine {
                x: 0
                y: 0
            }
        }

        // 2. Stroke
        ShapePath {
            strokeColor: root.side === "left" ? root.borderColor : "transparent"
            strokeWidth: root.borderWidth
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            startX: 0
            startY: 0

            PathCubic {
                x: root.concaveHeight
                y: root.concaveWidth
                control1X: 0
                control1Y: root.concaveWidth * 0.5
                control2X: root.concaveHeight * 0.5
                control2Y: root.concaveWidth
            }
            PathLine {
                x: root.width - root.bottomRadius
                y: root.concaveWidth
            }
            PathCubic {
                x: root.width
                y: root.concaveWidth + root.bottomRadius
                control1X: root.width - root.bottomRadius * 0.5
                control1Y: root.concaveWidth
                control2X: root.width
                control2Y: root.concaveWidth + root.bottomRadius * 0.5
            }
            PathLine {
                x: root.width
                y: root.height - root.concaveWidth - root.bottomRadius
            }
            PathCubic {
                x: root.width - root.bottomRadius
                y: root.height - root.concaveWidth
                control1X: root.width
                control1Y: root.height - root.concaveWidth - root.bottomRadius * 0.5
                control2X: root.width - root.bottomRadius * 0.5
                control2Y: root.height - root.concaveWidth
            }
            PathLine {
                x: root.concaveHeight
                y: root.height - root.concaveWidth
            }
            PathCubic {
                x: 0
                y: root.height
                control1X: root.concaveHeight * 0.5
                control1Y: root.height - root.concaveWidth
                control2X: 0
                control2Y: root.height - root.concaveWidth * 0.5
            }
        }
    }
}
