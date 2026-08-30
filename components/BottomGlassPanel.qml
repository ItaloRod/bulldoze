import QtQuick
import QtQuick.Shapes

Item {
    id: root

    Theme {
        id: theme
    }

    property color fillColor: theme.glassFillDark
    property color borderColor: "transparent"
    property int borderWidth: 0
    readonly property real concaveWidth: theme.notchConcaveWidth
    readonly property real concaveHeight: theme.notchConcaveHeight
    readonly property real bottomRadius: theme.notchBottomRadius

    Shape {
        anchors.fill: parent
        antialiasing: true

        // 1. Translucent Glass Fill (closed polygon docked to bottom screen bezel)
        ShapePath {
            strokeColor: "transparent"
            strokeWidth: 0
            fillColor: root.fillColor

            // Start at bottom-left screen bezel (0, height)
            startX: 0
            startY: root.height

            // Bottom-left smooth concave transition flaring into bottom bezel
            PathCubic {
                x: root.concaveWidth
                y: root.height - root.concaveHeight
                control1X: root.concaveWidth * 0.5
                control1Y: root.height
                control2X: root.concaveWidth
                control2Y: root.height - root.concaveHeight * 0.5
            }

            // Left vertical edge
            PathLine {
                x: root.concaveWidth
                y: root.bottomRadius
            }

            // Top-left smooth convex rounded corner
            PathCubic {
                x: root.concaveWidth + root.bottomRadius
                y: 0
                control1X: root.concaveWidth
                control1Y: root.bottomRadius * 0.5
                control2X: root.concaveWidth + root.bottomRadius * 0.5
                control2Y: 0
            }

            // Top horizontal edge
            PathLine {
                x: root.width - root.concaveWidth - root.bottomRadius
                y: 0
            }

            // Top-right smooth convex rounded corner
            PathCubic {
                x: root.width - root.concaveWidth
                y: root.bottomRadius
                control1X: root.width - root.concaveWidth - root.bottomRadius * 0.5
                control1Y: 0
                control2X: root.width - root.concaveWidth
                control2Y: root.bottomRadius * 0.5
            }

            // Right vertical edge
            PathLine {
                x: root.width - root.concaveWidth
                y: root.height - root.concaveHeight
            }

            // Bottom-right smooth concave transition flaring into bottom bezel
            PathCubic {
                x: root.width
                y: root.height
                control1X: root.width - root.concaveWidth
                control1Y: root.height - root.concaveHeight * 0.5
                control2X: root.width - root.concaveWidth * 0.5
                control2Y: root.height
            }

            // Close polygon along screen bottom boundary (y = height)
            PathLine {
                x: 0
                y: root.height
            }
        }

        // 2. Subtle 1px Glass Border along exposed desktop contour (NO stroke across bottom screen bezel)
        ShapePath {
            strokeColor: root.borderColor
            strokeWidth: root.borderWidth
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            // Start at bottom-left screen bezel (0, height - 0.5)
            startX: 0
            startY: root.height - 0.5

            // Bottom-left smooth concave transition
            PathCubic {
                x: root.concaveWidth + 0.5
                y: root.height - root.concaveHeight
                control1X: root.concaveWidth * 0.5
                control1Y: root.height - 0.5
                control2X: root.concaveWidth + 0.5
                control2Y: root.height - root.concaveHeight * 0.5
            }

            // Left vertical edge
            PathLine {
                x: root.concaveWidth + 0.5
                y: root.bottomRadius
            }

            // Top-left smooth convex rounded corner
            PathCubic {
                x: root.concaveWidth + root.bottomRadius
                y: 0.5
                control1X: root.concaveWidth + 0.5
                control1Y: root.bottomRadius * 0.5
                control2X: root.concaveWidth + root.bottomRadius * 0.5
                control2Y: 0.5
            }

            // Top horizontal edge
            PathLine {
                x: root.width - root.concaveWidth - root.bottomRadius
                y: 0.5
            }

            // Top-right smooth convex rounded corner
            PathCubic {
                x: root.width - root.concaveWidth - 0.5
                y: root.bottomRadius
                control1X: root.width - root.concaveWidth - root.bottomRadius * 0.5
                control1Y: 0.5
                control2X: root.width - root.concaveWidth - 0.5
                control2Y: root.bottomRadius * 0.5
            }

            // Right vertical edge
            PathLine {
                x: root.width - root.concaveWidth - 0.5
                y: root.height - root.concaveHeight
            }

            // Bottom-right smooth concave transition
            PathCubic {
                x: root.width
                y: root.height - 0.5
                control1X: root.width - root.concaveWidth - 0.5
                control1Y: root.height - root.concaveHeight * 0.5
                control2X: root.width - root.concaveWidth * 0.5
                control2Y: root.height - 0.5
            }
        }
    }
}
