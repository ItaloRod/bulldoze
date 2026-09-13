import QtQuick
import QtQuick.Shapes
import QtQuick.Effects
import "."

Item {
    id: root

    property real radius: Math.min(width, height) / 2
    property color fillColor: theme.glassFill
    property bool shadowEnabled: true
    property color shadowColor: theme.shadowColor
    property real shadowRadius: theme.shadowRadius
    property real shadowOffsetY: theme.shadowOffsetY
    property real shadowOffsetX: theme.shadowOffsetX
    property bool highlightEnabled: true
    property real borderWidth: 1
    property bool borderEnabled: true

    Theme {
        id: theme
    }

    // 1. Soft Drop Shadow Layer
    Item {
        id: shadowItem
        anchors.fill: parent
        visible: root.shadowEnabled && root.width > 0 && root.height > 0
        z: -1

        Rectangle {
            id: shadowCaster
            anchors.fill: parent
            radius: root.radius
            color: root.fillColor
            visible: false
        }

        MultiEffect {
            anchors.fill: shadowCaster
            source: shadowCaster
            shadowEnabled: true
            shadowColor: root.shadowColor
            shadowBlur: 0.8
            shadowHorizontalOffset: root.shadowOffsetX
            shadowVerticalOffset: root.shadowOffsetY
            shadowScale: 1.0
        }
    }

    // 2. Translucent Glass Fill & Subtle 1px Glass Border
    Rectangle {
        id: glassBackground
        anchors.fill: parent
        radius: root.radius
        color: root.fillColor
        border.width: root.borderEnabled ? root.borderWidth : 0
        border.color: theme.glassBorder
    }

    // 3. Specular Liquid Glass Top Highlight Point
    // Simulates physical curvature / refraction of curved glass
    Item {
        id: topHighlight
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: Math.min(parent.height * 0.5, 28)
        visible: root.highlightEnabled && root.height > 8
        clip: true

        Rectangle {
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: Math.max(root.radius * 2, 20)
            radius: root.radius
            color: "transparent"

            gradient: Gradient {
                GradientStop { position: 0.0; color: theme.glassHighlight }
                GradientStop { position: 0.25; color: Qt.rgba(1, 1, 1, 0.04) }
                GradientStop { position: 0.60; color: "transparent" }
            }
        }
    }

    // 4. Liquid Glass Top Specular Rim Light (Brilliant top edge highlight)
    Shape {
        id: topRimHighlight
        anchors.fill: parent
        antialiasing: true
        visible: root.highlightEnabled && root.width > 0 && root.height > 0

        ShapePath {
            strokeWidth: 1.2
            strokeColor: theme.glassBorderTop
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            startX: root.radius > 0 ? (root.radius * 0.5) : 0
            startY: root.radius > 0 ? Math.min(root.height * 0.25, root.radius * 0.3) : 0.6

            PathArc {
                x: Math.max(root.radius, 1)
                y: 0.6
                radiusX: Math.max(root.radius, 1)
                radiusY: Math.max(root.radius, 1)
            }

            PathLine {
                x: Math.max(root.radius, root.width - root.radius)
                y: 0.6
            }

            PathArc {
                x: root.radius > 0 ? (root.width - (root.radius * 0.5)) : root.width
                y: root.radius > 0 ? Math.min(root.height * 0.25, root.radius * 0.3) : 0.6
                radiusX: Math.max(root.radius, 1)
                radiusY: Math.max(root.radius, 1)
            }
        }
    }
}
