import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Shapes
import "components"
import "components/views"
import "modules"

ShellRoot {
    id: shell

    property string activeMode: "none" // "none" | "wifi" | "bluetooth" | "audio" | "gaming" | "gaming-settings" | "wallpaper" | "settings" | "power" | "profile" | "notifications"
    property string activeSettingsTab: "wifi"
    property bool isFullscreenActive: false
    property bool isLauncherOpen: false
    property real notchActualWidth: 200

    Process {
        id: hyprEventsProc
        command: [Quickshell.env("HOME") + "/.config/quickshell/bulldoze/scripts/bulldoze-hypr-events.py"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const line = data.trim()
                if (line.startsWith("FULLSCREEN:")) {
                    shell.isFullscreenActive = line.endsWith(":1")
                }
            }
        }
    }

    Theme {
        id: theme
    }

    Network {
        id: globalNetwork
    }

    Bluetooth {
        id: globalBluetooth
    }

    Gaming {
        id: globalGaming
    }

    UserProfile {
        id: globalUserProfile
    }

    WallpaperEngine {
        id: globalWallpaper
        optimizerActive: globalGaming.bulldoptimizerEnabled && globalGaming.boWallpaperStatic
    }

    Notifications {
        id: globalNotifications
        property bool ready: false

        onNotificationReceived: notif => {
            if (ready && shell.activeMode === "none" && !shell.isLauncherOpen) {
                shell.showNotificationOsd()
            }
        }

        Component.onCompleted: {
            readyTimer.start()
        }

        property var readyTimer: Timer {
            interval: 1000
            onTriggered: globalNotifications.ready = true
        }
    }

    Audio {
        id: globalAudio
        property bool ready: false

        onVolumeChanged: {
            if (ready && !(shell.activeMode === "settings" && shell.activeSettingsTab === "sound") && !shell.isLauncherOpen) {
                shell.showAudioBar()
            }
        }

        onMutedChanged: {
            if (ready && !(shell.activeMode === "settings" && shell.activeSettingsTab === "sound") && !shell.isLauncherOpen) {
                shell.showAudioBar()
            }
        }

        Component.onCompleted: {
            readyTimer.start()
        }

        property var readyTimer: Timer {
            interval: 1000
            onTriggered: globalAudio.ready = true
        }
    }

    property bool isAudioBarOpen: false

    property var audioBarTimer: Timer {
        id: audioBarTimer
        interval: 2000
        repeat: false
        onTriggered: {
            shell.isAudioBarOpen = false
        }
    }

    property var notificationTimer: Timer {
        id: notificationTimer
        interval: 5000
        repeat: false
        onTriggered: {
            if (shell.activeMode === "notifications") {
                shell.activeMode = "none"
            }
        }
    }

    function resetNotificationTimer() {
        if (shell.activeMode === "notifications") {
            notificationTimer.restart()
        }
    }

    function showAudioBar() {
        if (shell.isFullscreenActive) return
        if (shell.activeMode === "settings" && shell.activeSettingsTab === "sound") return
        shell.isAudioBarOpen = true
        audioBarTimer.restart()
    }

    function toggleAudioBar() {
        if (shell.isAudioBarOpen) {
            shell.isAudioBarOpen = false
            audioBarTimer.stop()
        } else {
            shell.isAudioBarOpen = true
            audioBarTimer.restart()
        }
    }

    function showNotificationOsd() {
        if (shell.isLauncherOpen) shell.isLauncherOpen = false
        if (shell.activeMode !== "notifications") {
            shell.activeMode = "notifications"
        }
        notificationTimer.restart()
    }

    function toggleMode(mode) {
        if (shell.isLauncherOpen) shell.isLauncherOpen = false
        notificationTimer.stop()
        if (activeMode === mode) {
            activeMode = "none"
        } else {
            activeMode = mode
            if (mode === "notifications") {
                notificationTimer.restart()
            }
        }
    }

    function closeActiveMode() {
        notificationTimer.stop()
        activeMode = "none"
    }

    function toggleLauncher() {
        if (shell.isLauncherOpen) {
            shell.isLauncherOpen = false
        } else {
            shell.closeActiveMode()
            shell.isLauncherOpen = true
        }
    }

    function toggleGamingModal() {
        shell.toggleMode("gaming-settings")
    }

    function openSettingsTab(tab) {
        if (shell.isLauncherOpen) shell.isLauncherOpen = false
        shell.isAudioBarOpen = false
        shell.audioBarTimer.stop()
        shell.activeSettingsTab = tab || "wifi"
        shell.activeMode = "settings"
    }

    function toggleWallpaperModal() {
        shell.toggleMode("wallpaper")
    }

    function activateWorkspace(id) {
        for (const workspace of Hyprland.workspaces.values) {
            if (workspace.id === id) {
                workspace.activate()
                return
            }
        }
    }

    function lockScreen() {
        shell.closeActiveMode()
        globalLockScreen.lock()
    }

    IpcHandler {
        target: "shell"
        function toggleLauncher() { shell.toggleLauncher() }
        function toggleSearch() { shell.toggleLauncher() }
        function toggleAudio() { shell.toggleAudioBar() }
        function toggleGaming() { shell.toggleMode("gaming") }
        function toggleGamingSettings() { shell.toggleMode("gaming-settings") }
        function toggleSettings() { shell.toggleMode("settings") }
        function openSettings(tab: string) { shell.openSettingsTab(tab) }
        function toggleWallpaper() { shell.toggleMode("wallpaper") }
        function toggleWallpaperModal() { shell.toggleWallpaperModal() }
        function toggleProfile() { shell.toggleMode("power") }
        function togglePowerMenu() { shell.toggleMode("power") }
        function toggleNotifications() { shell.toggleMode("notifications") }
        function toggleControlCenter() { shell.toggleMode("gaming") }
        function closeActiveMode() { shell.closeActiveMode(); shell.isLauncherOpen = false }
        function lockScreen() { shell.lockScreen() }
        function raiseVolume() { globalAudio.stepVolume(0.05); shell.showAudioBar() }
        function lowerVolume() { globalAudio.stepVolume(-0.05); shell.showAudioBar() }
        function toggleMute() { globalAudio.toggleMute(); shell.showAudioBar() }
    }

    // Static Desktop Wallpaper for GameMode (Zero-GPU Mode)
    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                required property var modelData
                screen: modelData

                WlrLayershell.namespace: "bulldoze-wallpaper-static"
                WlrLayershell.layer: WlrLayer.Background
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
                exclusiveZone: -1
                focusable: false
                visible: globalGaming.bulldoptimizerEnabled && globalGaming.boWallpaperStatic

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }

                color: "transparent"

                Image {
                    id: staticWallpaperImg
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectCrop
                    source: "file://" + Quickshell.env("HOME") + "/.cache/bulldoze/Wallpaper_greeter.png"
                    asynchronous: true
                    cache: false
                    onStatusChanged: {
                        if (status === Image.Error) {
                            source = "file:///var/lib/greetd/Wallpaper_greeter.png"
                        }
                    }

                    Connections {
                        target: globalWallpaper
                        function onSnapshotVersionChanged() {
                            staticWallpaperImg.source = ""
                            staticWallpaperImg.source = "file://" + Quickshell.env("HOME") + "/.cache/bulldoze/Wallpaper_greeter.png"
                        }
                    }
                }
            }
        }
    }

    // Unified Morphing Top Notch Bar & Screen Border Frame
    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: root
                required property var modelData
                screen: modelData

                WlrLayershell.namespace: "bulldoze-bar"
                WlrLayershell.layer: shell.isLauncherOpen ? WlrLayer.Overlay : WlrLayer.Top
                WlrLayershell.keyboardFocus: (shell.isLauncherOpen || shell.activeMode === "wallpaper" || shell.activeMode === "settings") ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
                exclusiveZone: 0
                focusable: shell.isLauncherOpen || shell.activeMode === "wallpaper" || shell.activeMode === "settings"
                visible: (!shell.isFullscreenActive || shell.activeMode !== "none" || shell.isLauncherOpen) && mainContainer.opacity > 0.001
                color: "transparent"

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }

                mask: Region {
                    item: shell.isLauncherOpen ? fullscreenOverlay : notchContainer

                    Region {
                        item: (shell.isAudioBarOpen || root.animAudioWidth > 0) ? leftAudioBarContainer : null
                    }
                }

                HyprlandFocusGrab {
                    windows: [root]
                    active: shell.isLauncherOpen
                    onCleared: {
                        if (shell.isLauncherOpen) {
                            shell.isLauncherOpen = false
                        }
                    }
                }

                Theme {
                    id: theme
                }

                readonly property real borderThickness: 8
                readonly property real innerRadius: 8
                readonly property real concaveWidth: theme.notchConcaveWidth
                readonly property real concaveHeight: theme.notchConcaveHeight
                readonly property real bottomRadius: theme.notchBottomRadius
                readonly property real topRadius: 18

                property bool isHovered: barHover.hovered
                property bool isExpanded: isHovered || shell.activeMode !== "none"
                property int expandedWidth: (defaultBarView && defaultBarView.contentExpandedWidth > 0) ? defaultBarView.contentExpandedWidth : 620
                property int collapsedWidth: (defaultBarView && defaultBarView.contentCollapsedWidth > 0) ? defaultBarView.contentCollapsedWidth : 170

                property int targetWidth: {
                    if (shell.activeMode === "gaming") return (gamingView && gamingView.idealWidth > 0) ? gamingView.idealWidth : 560
                    if (shell.activeMode === "gaming-settings") return 720
                    if (shell.activeMode === "wallpaper") return 920
                    if (shell.activeMode === "settings") return 920
                    if (shell.activeMode === "notifications") return 520
                    if (shell.activeMode === "power" || shell.activeMode === "profile") return 520
                    return root.isExpanded ? expandedWidth : collapsedWidth
                }

                property int targetHeight: {
                    if (shell.activeMode === "wallpaper") return 620
                    if (shell.activeMode === "settings") return 640
                    if (shell.activeMode === "gaming-settings") return 580
                    if (shell.activeMode === "notifications") return theme.notchNotificationHeight
                    if (shell.activeMode !== "none") return theme.notchExpandedHeight
                    return theme.notchHeight
                }

                property real animNotchWidth: targetWidth
                property real animNotchHeight: targetHeight

                Behavior on animNotchWidth {
                    NumberAnimation {
                        duration: shell.activeMode !== "none" ? theme.animDurationSlow : (root.isExpanded ? theme.notchExpandDuration : theme.notchCollapseDuration)
                        easing.type: shell.activeMode !== "none" ? Easing.OutBack : (root.isExpanded ? Easing.OutBack : Easing.InOutCubic)
                        easing.overshoot: theme.stickyOvershoot
                    }
                }

                Behavior on animNotchHeight {
                    NumberAnimation {
                        duration: shell.activeMode !== "none" ? theme.animDurationSlow : (root.isExpanded ? theme.notchExpandDuration : theme.notchCollapseDuration)
                        easing.type: shell.activeMode !== "none" ? Easing.OutBack : (root.isExpanded ? Easing.OutBack : Easing.InOutCubic)
                        easing.overshoot: theme.stickyOvershoot
                    }
                }

                readonly property real notchLeft: Math.round((root.width - animNotchWidth) / 2)
                readonly property real notchRight: notchLeft + animNotchWidth

                // Bottom Morphing Launcher Properties
                property int launcherTargetHeight: shell.isLauncherOpen ? 480 : 0
                property int launcherTargetWidth: shell.isLauncherOpen ? 640 : 0
                property real animLauncherHeight: launcherTargetHeight
                property real animLauncherWidth: launcherTargetWidth

                Behavior on animLauncherHeight {
                    NumberAnimation {
                        duration: shell.isLauncherOpen ? theme.animDurationSlow : theme.animDurationExit
                        easing.type: shell.isLauncherOpen ? Easing.OutBack : Easing.InQuad
                        easing.overshoot: 1.15
                    }
                }

                Behavior on animLauncherWidth {
                    NumberAnimation {
                        duration: shell.isLauncherOpen ? theme.animDurationSlow : theme.animDurationExit
                        easing.type: shell.isLauncherOpen ? Easing.OutBack : Easing.InQuad
                    }
                }

                readonly property real launcherLeft: Math.round((root.width - animLauncherWidth) / 2)
                readonly property real launcherRight: launcherLeft + animLauncherWidth
                readonly property real launcherTop: root.height - root.borderThickness - animLauncherHeight

                // Left Audio Bar Morphing Properties
                property int audioTargetWidth: shell.isAudioBarOpen ? 48 : 0
                property int audioTargetHeight: shell.isAudioBarOpen ? 230 : 0
                property real animAudioWidth: audioTargetWidth
                property real animAudioHeight: audioTargetHeight

                Behavior on animAudioWidth {
                    NumberAnimation {
                        duration: shell.isAudioBarOpen ? theme.animDurationSlow : theme.animDurationExit
                        easing.type: shell.isAudioBarOpen ? Easing.OutBack : Easing.InQuad
                        easing.overshoot: 1.15
                    }
                }

                Behavior on animAudioHeight {
                    NumberAnimation {
                        duration: shell.isAudioBarOpen ? theme.animDurationSlow : theme.animDurationExit
                        easing.type: shell.isAudioBarOpen ? Easing.OutBack : Easing.InQuad
                    }
                }

                readonly property real audioTop: Math.round((root.height - animAudioHeight) / 2)
                readonly property real audioBottom: audioTop + animAudioHeight
                readonly property real audioRight: root.borderThickness + animAudioWidth

                onAnimNotchWidthChanged: {
                    shell.notchActualWidth = animNotchWidth
                }
                Component.onCompleted: {
                    shell.notchActualWidth = animNotchWidth
                }

                Item {
                    id: mainContainer
                    anchors.fill: parent
                    opacity: (shell.isFullscreenActive && shell.activeMode === "none" && !shell.isLauncherOpen) ? 0.0 : 1.0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: theme.animDurationNormal
                            easing.type: Easing.OutCubic
                        }
                    }

                    // Continuous unified vector shape for perimeter frame + notch
                    Shape {
                        id: unifiedShape
                        anchors.fill: parent
                        antialiasing: true
                        visible: parent.width > 0 && parent.height > 0

                        // 1. Unified Glass Fill (Flush to screen edges + seamless notch cutout)
                        ShapePath {
                            fillRule: ShapePath.OddEvenFill
                            fillColor: theme.glassFill
                            strokeColor: "transparent"
                            strokeWidth: 0

                            // Outer Boundary (Flush with physical monitor edges)
                            startX: 0
                            startY: 0

                            PathLine { x: root.width; y: 0 }
                            PathLine { x: root.width; y: root.height }
                            PathLine { x: 0; y: root.height }
                            PathLine { x: 0; y: 0 }

                            // Inner Cutout (Counter-Clockwise - 16px frame seamlessly flaring down into notch)
                            PathMove {
                                x: root.notchLeft
                                y: root.borderThickness
                            }

                            // Top-left smooth concave transition flaring into notch
                            PathCubic {
                                x: root.notchLeft + root.concaveWidth
                                y: root.borderThickness + root.concaveHeight
                                control1X: root.notchLeft + (root.concaveWidth * 0.5)
                                control1Y: root.borderThickness
                                control2X: root.notchLeft + root.concaveWidth
                                control2Y: root.borderThickness + (root.concaveHeight * 0.5)
                            }

                            // Left vertical edge
                            PathLine {
                                x: root.notchLeft + root.concaveWidth
                                y: root.animNotchHeight - root.bottomRadius
                            }

                            // Bottom-left smooth convex rounded corner
                            PathCubic {
                                x: root.notchLeft + root.concaveWidth + root.bottomRadius
                                y: root.animNotchHeight
                                control1X: root.notchLeft + root.concaveWidth
                                control1Y: root.animNotchHeight - (root.bottomRadius * 0.5)
                                control2X: root.notchLeft + root.concaveWidth + (root.bottomRadius * 0.5)
                                control2Y: root.animNotchHeight
                            }

                            // Bottom horizontal edge
                            PathLine {
                                x: root.notchRight - root.concaveWidth - root.bottomRadius
                                y: root.animNotchHeight
                            }

                            // Bottom-right smooth convex rounded corner
                            PathCubic {
                                x: root.notchRight - root.concaveWidth
                                y: root.animNotchHeight - root.bottomRadius
                                control1X: root.notchRight - root.concaveWidth - (root.bottomRadius * 0.5)
                                control1Y: root.animNotchHeight
                                control2X: root.notchRight - root.concaveWidth
                                control2Y: root.animNotchHeight - (root.bottomRadius * 0.5)
                            }

                            // Right vertical edge
                            PathLine {
                                x: root.notchRight - root.concaveWidth
                                y: root.borderThickness + root.concaveHeight
                            }

                            // Top-right smooth concave transition flaring into top bezel
                            PathCubic {
                                x: root.notchRight
                                y: root.borderThickness
                                control1X: root.notchRight - root.concaveWidth
                                control1Y: root.borderThickness + (root.concaveHeight * 0.5)
                                control2X: root.notchRight - (root.concaveWidth * 0.5)
                                control2Y: root.borderThickness
                            }

                            // Top horizontal border towards top-right
                            PathLine {
                                x: root.width - root.borderThickness - root.innerRadius
                                y: root.borderThickness
                            }

                            // Top-right inner rounded corner
                            PathCubic {
                                x: root.width - root.borderThickness
                                y: root.borderThickness + root.innerRadius
                                control1X: root.width - root.borderThickness - (root.innerRadius * 0.5)
                                control1Y: root.borderThickness
                                control2X: root.width - root.borderThickness
                                control2Y: root.borderThickness + (root.innerRadius * 0.5)
                            }

                            // Right vertical inner border
                            PathLine {
                                x: root.width - root.borderThickness
                                y: root.height - root.borderThickness - root.innerRadius
                            }

                            // Bottom-right inner rounded corner
                            PathCubic {
                                x: root.width - root.borderThickness - root.innerRadius
                                y: root.height - root.borderThickness
                                control1X: root.width - root.borderThickness
                                control1Y: root.height - root.borderThickness - (root.innerRadius * 0.5)
                                control2X: root.width - root.borderThickness - (root.innerRadius * 0.5)
                                control2Y: root.height - root.borderThickness
                            }

                            // Bottom horizontal border towards launcher right
                            PathLine {
                                x: root.launcherRight
                                y: root.height - root.borderThickness
                            }

                            // Bottom-right concave transition flaring into bottom launcher
                            PathCubic {
                                x: root.launcherRight - root.concaveWidth
                                y: root.height - root.borderThickness - (root.concaveHeight * (root.animLauncherHeight > 0 ? 1 : 0))
                                control1X: root.launcherRight - (root.concaveWidth * 0.5)
                                control1Y: root.height - root.borderThickness
                                control2X: root.launcherRight - root.concaveWidth
                                control2Y: root.height - root.borderThickness - (root.concaveHeight * 0.5 * (root.animLauncherHeight > 0 ? 1 : 0))
                            }

                            // Right vertical edge of bottom launcher
                            PathLine {
                                x: root.launcherRight - root.concaveWidth
                                y: root.launcherTop + (root.topRadius * (root.animLauncherHeight > 0 ? 1 : 0))
                            }

                            // Top-right convex corner
                            PathCubic {
                                x: root.launcherRight - root.concaveWidth - (root.topRadius * (root.animLauncherHeight > 0 ? 1 : 0))
                                y: root.launcherTop
                                control1X: root.launcherRight - root.concaveWidth
                                control1Y: root.launcherTop + (root.topRadius * 0.5 * (root.animLauncherHeight > 0 ? 1 : 0))
                                control2X: root.launcherRight - root.concaveWidth - (root.topRadius * 0.5 * (root.animLauncherHeight > 0 ? 1 : 0))
                                control2Y: root.launcherTop
                            }

                            // Top horizontal ceiling of bottom launcher
                            PathLine {
                                x: root.launcherLeft + root.concaveWidth + (root.topRadius * (root.animLauncherHeight > 0 ? 1 : 0))
                                y: root.launcherTop
                            }

                            // Top-left convex corner
                            PathCubic {
                                x: root.launcherLeft + root.concaveWidth
                                y: root.launcherTop + (root.topRadius * (root.animLauncherHeight > 0 ? 1 : 0))
                                control1X: root.launcherLeft + root.concaveWidth + (root.topRadius * 0.5 * (root.animLauncherHeight > 0 ? 1 : 0))
                                control1Y: root.launcherTop
                                control2X: root.launcherLeft + root.concaveWidth
                                control2Y: root.launcherTop + (root.topRadius * 0.5 * (root.animLauncherHeight > 0 ? 1 : 0))
                            }

                            // Left vertical edge of bottom launcher
                            PathLine {
                                x: root.launcherLeft + root.concaveWidth
                                y: root.height - root.borderThickness - (root.concaveHeight * (root.animLauncherHeight > 0 ? 1 : 0))
                            }

                            // Bottom-left concave transition flaring into bottom bezel
                            PathCubic {
                                x: root.launcherLeft
                                y: root.height - root.borderThickness
                                control1X: root.launcherLeft + root.concaveWidth
                                control1Y: root.height - root.borderThickness - (root.concaveHeight * 0.5 * (root.animLauncherHeight > 0 ? 1 : 0))
                                control2X: root.launcherLeft + (root.concaveWidth * 0.5)
                                control2Y: root.height - root.borderThickness
                            }

                            // Bottom horizontal border to bottom-left inner corner
                            PathLine {
                                x: root.borderThickness + root.innerRadius
                                y: root.height - root.borderThickness
                            }

                            // Bottom-left inner rounded corner
                            PathCubic {
                                x: root.borderThickness
                                y: root.height - root.borderThickness - root.innerRadius
                                control1X: root.borderThickness + (root.innerRadius * 0.5)
                                control1Y: root.height - root.borderThickness
                                control2X: root.borderThickness
                                control2Y: root.height - root.borderThickness - (root.innerRadius * 0.5)
                            }

                            // Line from bottom-left corner up to audioBottom
                            PathLine {
                                x: root.borderThickness
                                y: root.audioBottom
                            }

                            // Bottom concave transition flaring into left audio panel
                            PathCubic {
                                x: root.borderThickness + (root.concaveHeight * (root.animAudioWidth > 0 ? 1 : 0))
                                y: root.audioBottom - (root.concaveWidth * (root.animAudioWidth > 0 ? 1 : 0))
                                control1X: root.borderThickness
                                control1Y: root.audioBottom - (root.concaveWidth * 0.5 * (root.animAudioWidth > 0 ? 1 : 0))
                                control2X: root.borderThickness + (root.concaveHeight * 0.5 * (root.animAudioWidth > 0 ? 1 : 0))
                                control2Y: root.audioBottom - (root.concaveWidth * (root.animAudioWidth > 0 ? 1 : 0))
                            }

                            // Bottom-right convex corner
                            PathLine {
                                x: root.audioRight - (root.bottomRadius * (root.animAudioWidth > 0 ? 1 : 0))
                                y: root.audioBottom - (root.concaveWidth * (root.animAudioWidth > 0 ? 1 : 0))
                            }
                            PathCubic {
                                x: root.audioRight
                                y: root.audioBottom - (root.concaveWidth * (root.animAudioWidth > 0 ? 1 : 0)) - (root.bottomRadius * (root.animAudioWidth > 0 ? 1 : 0))
                                control1X: root.audioRight - (root.bottomRadius * 0.5 * (root.animAudioWidth > 0 ? 1 : 0))
                                control1Y: root.audioBottom - (root.concaveWidth * (root.animAudioWidth > 0 ? 1 : 0))
                                control2X: root.audioRight
                                control2Y: root.audioBottom - (root.concaveWidth * (root.animAudioWidth > 0 ? 1 : 0)) - (root.bottomRadius * 0.5 * (root.animAudioWidth > 0 ? 1 : 0))
                            }

                            // Right vertical edge of left audio panel
                            PathLine {
                                x: root.audioRight
                                y: root.audioTop + (root.concaveWidth * (root.animAudioWidth > 0 ? 1 : 0)) + (root.bottomRadius * (root.animAudioWidth > 0 ? 1 : 0))
                            }

                            // Top-right convex corner
                            PathCubic {
                                x: root.audioRight - (root.bottomRadius * (root.animAudioWidth > 0 ? 1 : 0))
                                y: root.audioTop + (root.concaveWidth * (root.animAudioWidth > 0 ? 1 : 0))
                                control1X: root.audioRight
                                control1Y: root.audioTop + (root.concaveWidth * (root.animAudioWidth > 0 ? 1 : 0)) + (root.bottomRadius * 0.5 * (root.animAudioWidth > 0 ? 1 : 0))
                                control2X: root.audioRight - (root.bottomRadius * 0.5 * (root.animAudioWidth > 0 ? 1 : 0))
                                control2Y: root.audioTop + (root.concaveWidth * (root.animAudioWidth > 0 ? 1 : 0))
                            }

                            // Top horizontal ceiling of left audio panel
                            PathLine {
                                x: root.borderThickness + (root.concaveHeight * (root.animAudioWidth > 0 ? 1 : 0))
                                y: root.audioTop + (root.concaveWidth * (root.animAudioWidth > 0 ? 1 : 0))
                            }

                            // Top concave transition flaring into left screen bezel
                            PathCubic {
                                x: root.borderThickness
                                y: root.audioTop
                                control1X: root.borderThickness + (root.concaveHeight * 0.5 * (root.animAudioWidth > 0 ? 1 : 0))
                                control1Y: root.audioTop + (root.concaveWidth * (root.animAudioWidth > 0 ? 1 : 0))
                                control2X: root.borderThickness
                                control2Y: root.audioTop + (root.concaveWidth * 0.5 * (root.animAudioWidth > 0 ? 1 : 0))
                            }

                            // Left vertical inner border continuing to top-left corner
                            PathLine {
                                x: root.borderThickness
                                y: root.borderThickness + root.innerRadius
                            }

                            // Top-left inner rounded corner
                            PathCubic {
                                x: root.borderThickness + root.innerRadius
                                y: root.borderThickness
                                control1X: root.borderThickness
                                control1Y: root.borderThickness + (root.innerRadius * 0.5)
                                control2X: root.borderThickness + (root.innerRadius * 0.5)
                                control2Y: root.borderThickness
                            }

                            // Top horizontal border to notchLeft start
                            PathLine {
                                x: root.notchLeft
                                y: root.borderThickness
                            }
                        }

                        // 2. Continuous Inner Desktop 1px Stroke (Seamless single contour)
                        ShapePath {
                            fillColor: "transparent"
                            strokeColor: theme.glassBorderSubtle
                            strokeWidth: 1
                            capStyle: ShapePath.RoundCap

                            startX: root.notchLeft
                            startY: root.borderThickness + 0.5

                            // Top-left smooth concave transition
                            PathCubic {
                                x: root.notchLeft + root.concaveWidth + 0.5
                                y: root.borderThickness + root.concaveHeight
                                control1X: root.notchLeft + (root.concaveWidth * 0.5)
                                control1Y: root.borderThickness + 0.5
                                control2X: root.notchLeft + root.concaveWidth + 0.5
                                control2Y: root.borderThickness + (root.concaveHeight * 0.5)
                            }

                            // Left vertical edge
                            PathLine {
                                x: root.notchLeft + root.concaveWidth + 0.5
                                y: root.animNotchHeight - root.bottomRadius
                            }

                            // Bottom-left smooth convex rounded corner
                            PathCubic {
                                x: root.notchLeft + root.concaveWidth + root.bottomRadius
                                y: root.animNotchHeight - 0.5
                                control1X: root.notchLeft + root.concaveWidth + 0.5
                                control1Y: root.animNotchHeight - (root.bottomRadius * 0.5)
                                control2X: root.notchLeft + root.concaveWidth + (root.bottomRadius * 0.5)
                                control2Y: root.animNotchHeight - 0.5
                            }

                            // Bottom horizontal edge
                            PathLine {
                                x: root.notchRight - root.concaveWidth - root.bottomRadius
                                y: root.animNotchHeight - 0.5
                            }

                            // Bottom-right smooth convex rounded corner
                            PathCubic {
                                x: root.notchRight - root.concaveWidth - 0.5
                                y: root.animNotchHeight - root.bottomRadius
                                control1X: root.notchRight - root.concaveWidth - (root.bottomRadius * 0.5)
                                control1Y: root.animNotchHeight - 0.5
                                control2X: root.notchRight - root.concaveWidth - 0.5
                                control2Y: root.animNotchHeight - (root.bottomRadius * 0.5)
                            }

                            // Right vertical edge
                            PathLine {
                                x: root.notchRight - root.concaveWidth - 0.5
                                y: root.borderThickness + root.concaveHeight
                            }

                            // Top-right smooth concave transition
                            PathCubic {
                                x: root.notchRight
                                y: root.borderThickness + 0.5
                                control1X: root.notchRight - root.concaveWidth - 0.5
                                control1Y: root.borderThickness + (root.concaveHeight * 0.5)
                                control2X: root.notchRight - (root.concaveWidth * 0.5)
                                control2Y: root.borderThickness + 0.5
                            }

                            // Top-right inner horizontal line
                            PathLine {
                                x: root.width - root.borderThickness - root.innerRadius
                                y: root.borderThickness + 0.5
                            }

                            // Top-right inner rounded corner
                            PathCubic {
                                x: root.width - root.borderThickness - 0.5
                                y: root.borderThickness + root.innerRadius + 0.5
                                control1X: root.width - root.borderThickness - (root.innerRadius * 0.5)
                                control1Y: root.borderThickness + 0.5
                                control2X: root.width - root.borderThickness - 0.5
                                control2Y: root.borderThickness + (root.innerRadius * 0.5)
                            }

                            // Right inner vertical edge
                            PathLine {
                                x: root.width - root.borderThickness - 0.5
                                y: root.height - root.borderThickness - root.innerRadius - 0.5
                            }

                            // Bottom-right inner rounded corner
                            PathCubic {
                                x: root.width - root.borderThickness - root.innerRadius - 0.5
                                y: root.height - root.borderThickness - 0.5
                                control1X: root.width - root.borderThickness - 0.5
                                control1Y: root.height - root.borderThickness - (root.innerRadius * 0.5)
                                control2X: root.width - root.borderThickness - (root.innerRadius * 0.5)
                                control2Y: root.height - root.borderThickness - 0.5
                            }

                            // Bottom horizontal border towards launcher right
                            PathLine {
                                x: root.launcherRight
                                y: root.height - root.borderThickness - 0.5
                            }

                            // Bottom-right concave transition flaring into bottom launcher
                            PathCubic {
                                x: root.launcherRight - root.concaveWidth - 0.5
                                y: root.height - root.borderThickness - (root.concaveHeight * (root.animLauncherHeight > 0 ? 1 : 0))
                                control1X: root.launcherRight - (root.concaveWidth * 0.5)
                                control1Y: root.height - root.borderThickness - 0.5
                                control2X: root.launcherRight - root.concaveWidth - 0.5
                                control2Y: root.height - root.borderThickness - (root.concaveHeight * 0.5 * (root.animLauncherHeight > 0 ? 1 : 0))
                            }

                            // Right vertical edge of bottom launcher
                            PathLine {
                                x: root.launcherRight - root.concaveWidth - 0.5
                                y: root.launcherTop + (root.topRadius * (root.animLauncherHeight > 0 ? 1 : 0))
                            }

                            // Top-right convex corner
                            PathCubic {
                                x: root.launcherRight - root.concaveWidth - (root.topRadius * (root.animLauncherHeight > 0 ? 1 : 0))
                                y: root.launcherTop + 0.5
                                control1X: root.launcherRight - root.concaveWidth - 0.5
                                control1Y: root.launcherTop + (root.topRadius * 0.5 * (root.animLauncherHeight > 0 ? 1 : 0))
                                control2X: root.launcherRight - root.concaveWidth - (root.topRadius * 0.5 * (root.animLauncherHeight > 0 ? 1 : 0))
                                control2Y: root.launcherTop + 0.5
                            }

                            // Top horizontal ceiling of bottom launcher
                            PathLine {
                                x: root.launcherLeft + root.concaveWidth + (root.topRadius * (root.animLauncherHeight > 0 ? 1 : 0))
                                y: root.launcherTop + 0.5
                            }

                            // Top-left convex corner
                            PathCubic {
                                x: root.launcherLeft + root.concaveWidth + 0.5
                                y: root.launcherTop + (root.topRadius * (root.animLauncherHeight > 0 ? 1 : 0))
                                control1X: root.launcherLeft + root.concaveWidth + (root.topRadius * 0.5 * (root.animLauncherHeight > 0 ? 1 : 0))
                                control1Y: root.launcherTop + 0.5
                                control2X: root.launcherLeft + root.concaveWidth + 0.5
                                control2Y: root.launcherTop + (root.topRadius * 0.5 * (root.animLauncherHeight > 0 ? 1 : 0))
                            }

                            // Left vertical edge of bottom launcher
                            PathLine {
                                x: root.launcherLeft + root.concaveWidth + 0.5
                                y: root.height - root.borderThickness - (root.concaveHeight * (root.animLauncherHeight > 0 ? 1 : 0))
                            }

                            // Bottom-left concave transition flaring into bottom bezel
                            PathCubic {
                                x: root.launcherLeft
                                y: root.height - root.borderThickness - 0.5
                                control1X: root.launcherLeft + root.concaveWidth + 0.5
                                control1Y: root.height - root.borderThickness - (root.concaveHeight * 0.5 * (root.animLauncherHeight > 0 ? 1 : 0))
                                control2X: root.launcherLeft + (root.concaveWidth * 0.5)
                                control2Y: root.height - root.borderThickness - 0.5
                            }

                            // Bottom horizontal border to bottom-left inner corner
                            PathLine {
                                x: root.borderThickness + root.innerRadius + 0.5
                                y: root.height - root.borderThickness - 0.5
                            }

                            // Bottom-left inner rounded corner
                            PathCubic {
                                x: root.borderThickness + 0.5
                                y: root.height - root.borderThickness - root.innerRadius - 0.5
                                control1X: root.borderThickness + (root.innerRadius * 0.5)
                                control1Y: root.height - root.borderThickness - 0.5
                                control2X: root.borderThickness + 0.5
                                control2Y: root.height - root.borderThickness - (root.innerRadius * 0.5)
                            }

                            // Line from bottom-left corner up to audioBottom
                            PathLine {
                                x: root.borderThickness + 0.5
                                y: root.audioBottom
                            }

                            // Bottom concave transition
                            PathCubic {
                                x: root.borderThickness + (root.concaveHeight * (root.animAudioWidth > 0 ? 1 : 0)) + 0.5
                                y: root.audioBottom - (root.concaveWidth * (root.animAudioWidth > 0 ? 1 : 0))
                                control1X: root.borderThickness + 0.5
                                control1Y: root.audioBottom - (root.concaveWidth * 0.5 * (root.animAudioWidth > 0 ? 1 : 0))
                                control2X: root.borderThickness + (root.concaveHeight * 0.5 * (root.animAudioWidth > 0 ? 1 : 0)) + 0.5
                                control2Y: root.audioBottom - (root.concaveWidth * (root.animAudioWidth > 0 ? 1 : 0))
                            }

                            // Bottom horizontal line towards audioRight
                            PathLine {
                                x: root.audioRight - (root.bottomRadius * (root.animAudioWidth > 0 ? 1 : 0))
                                y: root.audioBottom - (root.concaveWidth * (root.animAudioWidth > 0 ? 1 : 0)) - 0.5
                            }

                            // Bottom-right convex corner
                            PathCubic {
                                x: root.audioRight + 0.5
                                y: root.audioBottom - (root.concaveWidth * (root.animAudioWidth > 0 ? 1 : 0)) - (root.bottomRadius * (root.animAudioWidth > 0 ? 1 : 0))
                                control1X: root.audioRight - (root.bottomRadius * 0.5 * (root.animAudioWidth > 0 ? 1 : 0))
                                control1Y: root.audioBottom - (root.concaveWidth * (root.animAudioWidth > 0 ? 1 : 0)) - 0.5
                                control2X: root.audioRight + 0.5
                                control2Y: root.audioBottom - (root.concaveWidth * (root.animAudioWidth > 0 ? 1 : 0)) - (root.bottomRadius * 0.5 * (root.animAudioWidth > 0 ? 1 : 0))
                            }

                            // Right vertical edge of left audio panel
                            PathLine {
                                x: root.audioRight + 0.5
                                y: root.audioTop + (root.concaveWidth * (root.animAudioWidth > 0 ? 1 : 0)) + (root.bottomRadius * (root.animAudioWidth > 0 ? 1 : 0))
                            }

                            // Top-right convex corner
                            PathCubic {
                                x: root.audioRight - (root.bottomRadius * (root.animAudioWidth > 0 ? 1 : 0))
                                y: root.audioTop + (root.concaveWidth * (root.animAudioWidth > 0 ? 1 : 0)) + 0.5
                                control1X: root.audioRight + 0.5
                                control1Y: root.audioTop + (root.concaveWidth * (root.animAudioWidth > 0 ? 1 : 0)) + (root.bottomRadius * 0.5 * (root.animAudioWidth > 0 ? 1 : 0))
                                control2X: root.audioRight - (root.bottomRadius * 0.5 * (root.animAudioWidth > 0 ? 1 : 0))
                                control2Y: root.audioTop + (root.concaveWidth * (root.animAudioWidth > 0 ? 1 : 0)) + 0.5
                            }

                            // Top horizontal ceiling of left audio panel
                            PathLine {
                                x: root.borderThickness + (root.concaveHeight * (root.animAudioWidth > 0 ? 1 : 0)) + 0.5
                                y: root.audioTop + (root.concaveWidth * (root.animAudioWidth > 0 ? 1 : 0)) + 0.5
                            }

                            // Top concave transition
                            PathCubic {
                                x: root.borderThickness + 0.5
                                y: root.audioTop
                                control1X: root.borderThickness + (root.concaveHeight * 0.5 * (root.animAudioWidth > 0 ? 1 : 0)) + 0.5
                                control1Y: root.audioTop + (root.concaveWidth * (root.animAudioWidth > 0 ? 1 : 0)) + 0.5
                                control2X: root.borderThickness + 0.5
                                control2Y: root.audioTop + (root.concaveWidth * 0.5 * (root.animAudioWidth > 0 ? 1 : 0))
                            }

                            // Left vertical inner border
                            PathLine {
                                x: root.borderThickness + 0.5
                                y: root.borderThickness + root.innerRadius + 0.5
                            }

                            // Top-left inner rounded corner
                            PathCubic {
                                x: root.borderThickness + root.innerRadius + 0.5
                                y: root.borderThickness + 0.5
                                control1X: root.borderThickness + 0.5
                                control1Y: root.borderThickness + (root.innerRadius * 0.5)
                                control2X: root.borderThickness + (root.innerRadius * 0.5)
                                control2Y: root.borderThickness + 0.5
                            }

                            // Top-left inner horizontal line to notchLeft
                            PathLine {
                                x: root.notchLeft
                                y: root.borderThickness + 0.5
                            }
                        }
                    }

                    // Interactive Notch Container
                    Item {
                        id: notchContainer
                        x: root.notchLeft
                        y: 0
                        width: root.animNotchWidth
                        height: root.animNotchHeight

                        HoverHandler {
                            id: barHover
                        }

                        Item {
                            id: viewsContainer
                            anchors.fill: parent
                            clip: true

                            // View 0: Default Bar View (Workspaces, Clock, Status)
                            DefaultBarView {
                                id: defaultBarView
                                anchors.fill: parent
                                clip: true
                                isExpanded: root.isExpanded && shell.activeMode === "none"
                                visible: opacity > 0.001
                                opacity: shell.activeMode === "none" ? 1.0 : 0.0

                                gaming: globalGaming
                                notifications: globalNotifications
                                userProfile: globalUserProfile

                                activateLauncher: () => shell.toggleLauncher()
                                activateWorkspace: workspaceId => shell.activateWorkspace(workspaceId)
                                toggleGaming: () => shell.toggleMode("gaming")
                                toggleNotifications: () => shell.toggleMode("notifications")
                                toggleSettings: () => shell.toggleMode("settings")
                                toggleProfile: () => shell.toggleMode("power")
                                togglePowerMenu: () => shell.toggleMode("power")

                                Behavior on opacity {
                                    NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic }
                                }
                            }

                            // View 4: Gaming Profile View
                            GamingBarView {
                                id: gamingView
                                anchors.fill: parent
                                visible: opacity > 0.001
                                opacity: shell.activeMode === "gaming" ? 1.0 : 0.0
                                gaming: globalGaming
                                goBack: () => shell.closeActiveMode()

                                Behavior on opacity {
                                    NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic }
                                }
                            }

                            // View 5: Unified Profile & Power Menu View
                            PowerBarView {
                                anchors.fill: parent
                                visible: opacity > 0.001
                                opacity: (shell.activeMode === "power" || shell.activeMode === "profile") ? 1.0 : 0.0
                                userProfile: globalUserProfile
                                lockScreen: () => shell.lockScreen()
                                goBack: () => shell.closeActiveMode()

                                Behavior on opacity {
                                    NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic }
                                }
                            }

                            // View 6: Notifications View
                            NotificationBarView {
                                anchors.fill: parent
                                visible: opacity > 0.001
                                opacity: shell.activeMode === "notifications" ? 1.0 : 0.0
                                notifications: globalNotifications
                                goBack: () => shell.closeActiveMode()
                                resetTimer: () => shell.resetNotificationTimer()

                                Behavior on opacity {
                                    NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic }
                                }
                            }

                            // View 7: Bulldoze Wallpaper Handler View (Full Notch Grid & Inspector)
                            WallpaperBarView {
                                anchors.fill: parent
                                visible: opacity > 0.001
                                opacity: shell.activeMode === "wallpaper" ? 1.0 : 0.0
                                wallpaperEngine: globalWallpaper
                                goBack: () => shell.closeActiveMode()

                                Behavior on opacity {
                                    NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic }
                                }
                            }

                            // View 8: Advanced Gaming Settings Notch View
                            GamingSettingsBarView {
                                anchors.fill: parent
                                visible: opacity > 0.001
                                opacity: shell.activeMode === "gaming-settings" ? 1.0 : 0.0
                                gaming: globalGaming
                                goBack: () => shell.toggleMode("gaming")

                                Behavior on opacity {
                                    NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic }
                                }
                            }

                            // View 9: Unified Settings View (WiFi + Bluetooth + Som + Wallpapers + Gaming)
                            SettingsBarView {
                                id: settingsView
                                anchors.fill: parent
                                visible: opacity > 0.001
                                opacity: shell.activeMode === "settings" ? 1.0 : 0.0
                                activeCategory: shell.activeSettingsTab
                                network: globalNetwork
                                bluetooth: globalBluetooth
                                audio: globalAudio
                                gaming: globalGaming
                                wallpaperEngine: globalWallpaper
                                goBack: () => shell.closeActiveMode()

                                Behavior on opacity {
                                    NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic }
                                }
                            }
                        }
                    }

                    // Dismiss overlay for bottom launcher
                    MouseArea {
                        id: fullscreenOverlay
                        anchors.fill: parent
                        visible: shell.isLauncherOpen
                        z: 50
                        onClicked: shell.isLauncherOpen = false
                    }

                    // Interactive Bottom Launcher Container
                    Item {
                        id: bottomLauncherContainer
                        x: root.launcherLeft
                        y: root.launcherTop
                        width: root.animLauncherWidth
                        height: root.animLauncherHeight + root.borderThickness
                        clip: true
                        visible: shell.isLauncherOpen || root.animLauncherHeight > 0
                        focus: shell.isLauncherOpen
                        z: 100

                        BottomLauncher {
                            anchors.fill: parent
                            open: shell.isLauncherOpen
                            closeLauncher: () => shell.isLauncherOpen = false
                        }
                    }

                    // Interactive Left Audio Bar Container (integrated with left border)
                    Item {
                        id: leftAudioBarContainer
                        x: 0
                        y: root.audioTop
                        width: root.animAudioWidth + root.borderThickness
                        height: root.animAudioHeight
                        clip: true
                        visible: shell.isAudioBarOpen || root.animAudioWidth > 0

                        HoverHandler {
                            id: sideBarHover
                            onHoveredChanged: {
                                if (hovered) {
                                    shell.audioBarTimer.stop()
                                } else {
                                    if (shell.isAudioBarOpen) {
                                        shell.audioBarTimer.restart()
                                    }
                                }
                            }
                        }

                        AudioBarView {
                            anchors {
                                left: parent.left
                                leftMargin: root.borderThickness
                                top: parent.top
                                bottom: parent.bottom
                            }
                            width: 48
                            audio: globalAudio
                            openSettings: () => {
                                shell.isAudioBarOpen = false
                                shell.audioBarTimer.stop()
                                shell.openSettingsTab("sound")
                            }
                        }
                    }
                }
            }
        }
    }

    LockScreen {
        id: globalLockScreen
    }

    NotificationCenter {
        notifications: globalNotifications
    }
}


