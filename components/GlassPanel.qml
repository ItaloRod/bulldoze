import QtQuick
import QtQuick.Shapes
import QtQuick.Effects
import "."

Item {
    id: root

    property var blurSource: null

    Theme {
        id: theme
    }

    property real topOffset: theme.borderThickness
    property color fillColor: theme.glassFill
    property color borderColor: theme.glassBorderSubtle
    property int borderWidth: 1
    property bool showBorder: true

    readonly property real concaveWidth: theme.notchConcaveWidth
    readonly property real concaveHeight: theme.notchConcaveHeight
    readonly property real bottomRadius: theme.notchBottomRadius

    // 1. Frosted Glass Backdrop (blurs only the area directly behind the notch)
    Item {
        id: blurContainer
        anchors.fill: parent
        visible: root.blurSource !== null && root.width > 0 && root.height > 0
        layer.enabled: true
        layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: shapeMask
        }

        ShaderEffectSource {
            id: sliceSample
            anchors.fill: parent
            sourceItem: root.blurSource
            sourceRect: {
                if (!root.blurSource || root.width <= 0 || root.height <= 0) return Qt.rect(0, 0, 1, 1)
                const p = root.mapToItem(root.blurSource, 0, 0)
                return Qt.rect(p.x, p.y, root.width, root.height)
            }
            live: true
        }

        MultiEffect {
            anchors.fill: parent
            source: sliceSample
            blurEnabled: true
            blur: 0.85
            blurMax: 48
            brightness: 0.0
            contrast: 0.0
        }
    }

    // 2. Shape Mask for Concave Geometry
    Item {
        id: shapeMask
        anchors.fill: parent
        visible: false
        layer.enabled: true

        Shape {
            anchors.fill: parent
            antialiasing: true

            ShapePath {
                fillColor: "black"
                strokeWidth: 0
                strokeColor: "transparent"

                startX: 0
                startY: 0

                PathLine {
                    x: 0
                    y: root.topOffset
                }

                PathCubic {
                    x: root.concaveWidth
                    y: root.topOffset + root.concaveHeight
                    control1X: root.concaveWidth * 0.5
                    control1Y: root.topOffset
                    control2X: root.concaveWidth
                    control2Y: root.topOffset + root.concaveHeight * 0.5
                }
                PathLine {
                    x: root.concaveWidth
                    y: root.height - root.bottomRadius
                }
                PathCubic {
                    x: root.concaveWidth + root.bottomRadius
                    y: root.height
                    control1X: root.concaveWidth
                    control1Y: root.height - root.bottomRadius * 0.5
                    control2X: root.concaveWidth + root.bottomRadius * 0.5
                    control2Y: root.height
                }
                PathLine {
                    x: root.width - root.concaveWidth - root.bottomRadius
                    y: root.height
                }
                PathCubic {
                    x: root.width - root.concaveWidth
                    y: root.height - root.bottomRadius
                    control1X: root.width - root.concaveWidth - root.bottomRadius * 0.5
                    control1Y: root.height
                    control2X: root.width - root.concaveWidth
                    control2Y: root.height - root.bottomRadius * 0.5
                }
                PathLine {
                    x: root.width - root.concaveWidth
                    y: root.topOffset + root.concaveHeight
                }
                PathCubic {
                    x: root.width
                    y: root.topOffset
                    control1X: root.width - root.concaveWidth
                    control1Y: root.topOffset + root.concaveHeight * 0.5
                    control2X: root.width - root.concaveWidth * 0.5
                    control2Y: root.topOffset
                }
                PathLine {
                    x: root.width
                    y: 0
                }
                PathLine {
                    x: 0
                    y: 0
                }
            }
        }
    }

    // 3. Shape Fill & Contour Border
    Shape {
        anchors.fill: parent
        antialiasing: true

        // 1. Translucent Glass Fill (closed polygon)
        ShapePath {
            strokeColor: "transparent"
            strokeWidth: 0
            fillColor: root.fillColor

            startX: 0
            startY: 0

            PathLine {
                x: 0
                y: root.topOffset
            }

            // Top-left smooth concave transition flaring into top bezel
            PathCubic {
                x: root.concaveWidth
                y: root.topOffset + root.concaveHeight
                control1X: root.concaveWidth * 0.5
                control1Y: root.topOffset
                control2X: root.concaveWidth
                control2Y: root.topOffset + root.concaveHeight * 0.5
            }

            // Left vertical edge
            PathLine {
                x: root.concaveWidth
                y: root.height - root.bottomRadius
            }

            // Bottom-left smooth convex rounded corner
            PathCubic {
                x: root.concaveWidth + root.bottomRadius
                y: root.height
                control1X: root.concaveWidth
                control1Y: root.height - root.bottomRadius * 0.5
                control2X: root.concaveWidth + root.bottomRadius * 0.5
                control2Y: root.height
            }

            // Bottom horizontal edge
            PathLine {
                x: root.width - root.concaveWidth - root.bottomRadius
                y: root.height
            }

            // Bottom-right smooth convex rounded corner
            PathCubic {
                x: root.width - root.concaveWidth
                y: root.height - root.bottomRadius
                control1X: root.width - root.concaveWidth - root.bottomRadius * 0.5
                control1Y: root.height
                control2X: root.width - root.concaveWidth
                control2Y: root.height - root.bottomRadius * 0.5
            }

            // Right vertical edge
            PathLine {
                x: root.width - root.concaveWidth
                y: root.topOffset + root.concaveHeight
            }

            // Top-right smooth concave transition flaring into top bezel
            PathCubic {
                x: root.width
                y: root.topOffset
                control1X: root.width - root.concaveWidth
                control1Y: root.topOffset + root.concaveHeight * 0.5
                control2X: root.width - root.concaveWidth * 0.5
                control2Y: root.topOffset
            }

            PathLine {
                x: root.width
                y: 0
            }

            PathLine {
                x: 0
                y: 0
            }
        }

        // 2. Subtle 1px Glass Border along exposed desktop contour
        ShapePath {
            strokeColor: root.showBorder ? root.borderColor : "transparent"
            strokeWidth: root.borderWidth
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            startX: 0
            startY: root.topOffset + 0.5

            // Top-left smooth concave transition
            PathCubic {
                x: root.concaveWidth + 0.5
                y: root.topOffset + root.concaveHeight
                control1X: root.concaveWidth * 0.5
                control1Y: root.topOffset + 0.5
                control2X: root.concaveWidth + 0.5
                control2Y: root.topOffset + root.concaveHeight * 0.5
            }

            // Left vertical edge
            PathLine {
                x: root.concaveWidth + 0.5
                y: root.height - root.bottomRadius
            }

            // Bottom-left smooth convex rounded corner
            PathCubic {
                x: root.concaveWidth + root.bottomRadius
                y: root.height - 0.5
                control1X: root.concaveWidth + 0.5
                control1Y: root.height - root.bottomRadius * 0.5
                control2X: root.concaveWidth + root.bottomRadius * 0.5
                control2Y: root.height - 0.5
            }

            // Bottom horizontal edge
            PathLine {
                x: root.width - root.concaveWidth - root.bottomRadius
                y: root.height - 0.5
            }

            // Bottom-right smooth convex rounded corner
            PathCubic {
                x: root.width - root.concaveWidth - 0.5
                y: root.height - root.bottomRadius
                control1X: root.width - root.concaveWidth - root.bottomRadius * 0.5
                control1Y: root.height - 0.5
                control2X: root.width - root.concaveWidth - 0.5
                control2Y: root.height - root.bottomRadius * 0.5
            }

            // Right vertical edge
            PathLine {
                x: root.width - root.concaveWidth - 0.5
                y: root.topOffset + root.concaveHeight
            }

            // Top-right smooth concave transition
            PathCubic {
                x: root.width
                y: root.topOffset + 0.5
                control1X: root.width - root.concaveWidth - 0.5
                control1Y: root.topOffset + root.concaveHeight * 0.5
                control2X: root.width - root.concaveWidth * 0.5
                control2Y: root.topOffset + 0.5
            }
        }
    }
}
