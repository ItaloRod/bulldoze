import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Shapes
import "components"
import "components/views"
import "modules"

ShellRoot {
    id: shell

    property string activeMode: "none" // "none" | "wifi" | "bluetooth" | "audio" | "gaming" | "gaming-settings" | "wallpaper" | "launcher" | "settings" | "power" | "profile" | "notifications"
    property string activeLauncherTab: "home"
    property alias activeSettingsTab: shell.activeLauncherTab
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
            if (ready && !shell.isLauncherOpen) {
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
            if (ready && !((shell.activeMode === "launcher" || shell.activeMode === "settings") && shell.activeLauncherTab === "sound") && !shell.isLauncherOpen) {
                shell.showAudioBar()
            }
        }

        onMutedChanged: {
            if (ready && !((shell.activeMode === "launcher" || shell.activeMode === "settings") && shell.activeLauncherTab === "sound") && !shell.isLauncherOpen) {
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

    property bool wsReady: false
    property var currentFocusedWorkspace: Hyprland.focusedWorkspace
    onCurrentFocusedWorkspaceChanged: {
        if (shell.wsReady) {
            if (shell.isLauncherOpen) {
                shell.isLauncherOpen = false
            }
            shell.showWorkspaceBar(2000)
        }
    }

    property var wsReadyTimer: Timer {
        id: wsReadyTimer
        interval: 1000
        running: true
        onTriggered: shell.wsReady = true
    }

    property bool isWorkspaceOpen: false

    property var workspaceBarTimer: Timer {
        id: workspaceBarTimer
        interval: 2000
        repeat: false
        onTriggered: {
            shell.isWorkspaceOpen = false
        }
    }

    property bool isNotifOpen: false
    property bool isNotifExpanded: false

    property var notifDismissTimer: Timer {
        id: notifDismissTimer
        interval: 2500
        repeat: false
        onTriggered: {
            shell.closeNotification()
        }
    }

    property var notifExpandTimer: Timer {
        id: notifExpandTimer
        interval: 2000
        repeat: false
        onTriggered: {
            if (shell.isNotifOpen && globalNotifications.count > 1) {
                shell.isNotifExpanded = true
            }
        }
    }

    function showAudioBar() {
        if (shell.isFullscreenActive) return
        if ((shell.activeMode === "launcher" || shell.activeMode === "settings") && shell.activeLauncherTab === "sound") return
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
        if (shell.isFullscreenActive) return
        shell.isNotifExpanded = false
        shell.isNotifOpen = true
        notifDismissTimer.restart()
    }

    function showNotificationCorner() {
        if (shell.isFullscreenActive) return
        notifDismissTimer.stop()
        shell.isNotifExpanded = false
        shell.isNotifOpen = true
    }

    function closeNotification() {
        notifDismissTimer.stop()
        notifExpandTimer.stop()
        shell.isNotifOpen = false
        shell.isNotifExpanded = false
    }

    function showWorkspaceBar(timeout) {
        if (shell.isFullscreenActive) return
        if (shell.isLauncherOpen) return
        shell.isWorkspaceOpen = true
        if (timeout > 0) {
            workspaceBarTimer.interval = timeout
            workspaceBarTimer.restart()
        } else {
            workspaceBarTimer.stop()
        }
    }

    function closeWorkspaceBar() {
        workspaceBarTimer.stop()
        shell.isWorkspaceOpen = false
    }

    property bool isTrayOpen: false
    property bool isTrayMenuOpen: false
    readonly property int trayItemCount: (SystemTray.items && SystemTray.items.values) ? SystemTray.items.values.length : 0

    function showTrayBar() {
        if (shell.isFullscreenActive) return
        if (shell.trayItemCount === 0) return
        shell.isTrayOpen = true
    }

    function closeTrayBar() {
        if (shell.isTrayMenuOpen) return
        shell.isTrayOpen = false
    }

    function toggleMode(mode) {
        if (shell.isLauncherOpen) shell.isLauncherOpen = false
        if (activeMode === mode) {
            activeMode = "none"
        } else {
            activeMode = mode
        }
    }

    property bool preventAutoOpenSettings: false

    function closeActiveMode(manual) {
        if (manual && (shell.activeMode === "launcher" || shell.activeMode === "settings")) {
            shell.preventAutoOpenSettings = true
        } else {
            shell.preventAutoOpenSettings = false
        }
        activeMode = "none"
    }

    function toggleLauncher() {
        if (shell.isLauncherOpen) {
            shell.isLauncherOpen = false
        } else {
            shell.closeWorkspaceBar()
            shell.closeActiveMode()
            shell.isLauncherOpen = true
        }
    }

    function toggleGamingModal() {
        shell.toggleMode("gaming-settings")
    }

    function openLauncherTab(tab) {
        if (shell.isLauncherOpen) shell.isLauncherOpen = false
        shell.isAudioBarOpen = false
        shell.audioBarTimer.stop()
        shell.preventAutoOpenSettings = false
        shell.activeLauncherTab = tab || "home"
        shell.activeMode = "launcher"
    }

    function openSettingsTab(tab) {
        shell.openLauncherTab(tab)
    }

    function toggleLauncherBar() {
        if (shell.activeMode === "launcher" || shell.activeMode === "settings") {
            shell.closeActiveMode(true)
        } else {
            shell.openLauncherTab("home")
        }
    }

    function toggleSettings() {
        shell.toggleLauncherBar()
    }

    function toggleWallpaperModal() {
        shell.toggleMode("wallpaper")
    }

    function activateWorkspace(id) {
        if (shell.isLauncherOpen) shell.isLauncherOpen = false
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
        function toggleWorkspaces() { if (shell.isWorkspaceOpen) shell.closeWorkspaceBar(); else shell.showWorkspaceBar(2000) }
        function showWorkspaces() { shell.showWorkspaceBar(2000) }
        function toggleAudio() { shell.toggleAudioBar() }
        function toggleGaming() { shell.openLauncherTab("gaming") }
        function toggleGamingSettings() { shell.toggleMode("gaming-settings") }
        function toggleSettings() { shell.toggleLauncherBar() }
        function toggleLauncherBar() { shell.toggleLauncherBar() }
        function openSettings(tab: string) { shell.openLauncherTab(tab) }
        function openLauncher(tab: string) { shell.openLauncherTab(tab) }
        function toggleWallpaper() { shell.toggleMode("wallpaper") }
        function toggleWallpaperModal() { shell.toggleWallpaperModal() }
        function toggleProfile() { shell.openLauncherTab("home") }
        function togglePowerMenu() { shell.openLauncherTab("home") }
        function toggleNotifications() { if (shell.isNotifOpen) shell.closeNotification(); else shell.showNotificationCorner() }
        function expandNotifications() { shell.isNotifOpen = true; shell.isNotifExpanded = true }
        function toggleControlCenter() { shell.openLauncherTab("home") }
        function closeActiveMode() { shell.closeActiveMode(true); shell.isLauncherOpen = false }
        function lockScreen() { shell.lockScreen() }
        function raiseVolume() { globalAudio.stepVolume(0.05); shell.showAudioBar() }
        function lowerVolume() { globalAudio.stepVolume(-0.05); shell.showAudioBar() }
        function toggleMute() { globalAudio.toggleMute(); shell.showAudioBar() }
        function reloadWallpaperSnapshot() { globalWallpaper.snapshotVersion++ }
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
                WlrLayershell.keyboardFocus: (shell.isLauncherOpen || shell.activeMode === "wallpaper") ? WlrKeyboardFocus.Exclusive : ((shell.activeMode === "launcher" || shell.activeMode === "settings") ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None)
                exclusiveZone: 0
                focusable: shell.isLauncherOpen || shell.activeMode === "wallpaper" || shell.activeMode === "launcher" || shell.activeMode === "settings"
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
                        item: (shell.activeMode === "none" && !shell.isLauncherOpen && typeof notchTopTrigger !== "undefined") ? notchTopTrigger : null
                    }

                    Region {
                        item: (shell.isAudioBarOpen || root.animAudioWidth > 0) ? leftAudioBarContainer : null
                    }

                    Region {
                        item: (shell.isNotifOpen || root.animNotifHeight > 0) ? (typeof bottomNotifContainer !== "undefined" ? bottomNotifContainer : null) : (typeof notifCornerTrigger !== "undefined" ? notifCornerTrigger : null)
                    }

                    Region {
                        item: (shell.trayItemCount > 0)
                            ? ((shell.isTrayOpen || root.animTrayHeight > 0)
                                ? (typeof topTrayContainer !== "undefined" ? topTrayContainer : null)
                                : (typeof trayCornerTrigger !== "undefined" ? trayCornerTrigger : null))
                            : null
                    }

                    Region {
                        item: (shell.isLauncherOpen || shell.isWorkspaceOpen || root.animLauncherHeight > 0)
                            ? (typeof bottomLauncherContainer !== "undefined" ? bottomLauncherContainer : null)
                            : (typeof workspaceBottomTrigger !== "undefined" ? workspaceBottomTrigger : null)
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

                property bool isHovered: (typeof notchHover !== "undefined" && typeof topHoverHandler !== "undefined") ? (notchHover.hovered || topHoverHandler.hovered) : false
                property int collapsedWidth: (defaultBarView && defaultBarView.contentCollapsedWidth > 0) ? defaultBarView.contentCollapsedWidth : 170

                property int targetWidth: {
                    if (shell.activeMode === "launcher" || shell.activeMode === "settings") return 920
                    if (shell.activeMode === "wallpaper") return 920
                    if (shell.activeMode === "gaming-settings") return 720
                    return collapsedWidth
                }

                property int targetHeight: {
                    if (shell.activeMode === "launcher" || shell.activeMode === "settings") return 640
                    if (shell.activeMode === "wallpaper") return 620
                    if (shell.activeMode === "gaming-settings") return 580
                    return theme.notchHeight
                }

                property real animNotchWidth: targetWidth
                property real animNotchHeight: targetHeight

                Behavior on animNotchWidth {
                    NumberAnimation {
                        duration: shell.activeMode !== "none" ? theme.animDurationSlow : theme.notchCollapseDuration
                        easing.type: shell.activeMode !== "none" ? Easing.OutBack : Easing.InOutCubic
                        easing.overshoot: theme.stickyOvershoot
                    }
                }

                Behavior on animNotchHeight {
                    NumberAnimation {
                        duration: shell.activeMode !== "none" ? theme.animDurationSlow : theme.notchCollapseDuration
                        easing.type: shell.activeMode !== "none" ? Easing.OutBack : Easing.InOutCubic
                        easing.overshoot: theme.stickyOvershoot
                    }
                }

                readonly property real notchLeft: Math.round((root.width - animNotchWidth) / 2)
                readonly property real notchRight: notchLeft + animNotchWidth

                // Bottom Morphing Dock (Launcher & Workspace View)
                readonly property int workspaceCount: {
                    let count = 0
                    for (const ws of Hyprland.workspaces.values) {
                        if (ws && ws.id > 0) count++
                    }
                    return Math.max(1, count)
                }
                readonly property int workspacePillsWidth: 22 + (12 * (workspaceCount - 1))
                property int workspaceTargetWidth: Math.max(80, workspacePillsWidth + (theme.contentInset * 2) + (root.concaveWidth * 2))
                property int launcherTargetHeight: shell.isLauncherOpen ? 480 : (shell.isWorkspaceOpen ? 32 : 0)
                property int launcherTargetWidth: shell.isLauncherOpen ? 640 : root.workspaceTargetWidth
                property real animLauncherHeight: launcherTargetHeight
                property real animLauncherWidth: launcherTargetWidth

                readonly property real dockCurveFactor: Math.min(1.0, Math.max(0.0, animLauncherHeight / (concaveHeight + topRadius)))
                readonly property real dockConcaveHeight: concaveHeight * dockCurveFactor
                readonly property real dockConcaveWidth: concaveWidth * dockCurveFactor
                readonly property real dockTopRadius: topRadius * dockCurveFactor

                Behavior on animLauncherHeight {
                    NumberAnimation {
                        duration: shell.isLauncherOpen ? theme.animDurationSlow : (shell.isWorkspaceOpen ? theme.animDurationNormal : theme.animDurationExit)
                        easing.type: (shell.isLauncherOpen || shell.isWorkspaceOpen) ? Easing.OutBack : Easing.InQuad
                        easing.overshoot: 1.15
                    }
                }

                Behavior on animLauncherWidth {
                    NumberAnimation {
                        duration: shell.isLauncherOpen ? theme.animDurationSlow : (shell.isWorkspaceOpen ? theme.animDurationNormal : theme.animDurationExit)
                        easing.type: (shell.isLauncherOpen || shell.isWorkspaceOpen) ? Easing.OutBack : Easing.InQuad
                    }
                }

                readonly property real launcherLeft: Math.round((root.width - animLauncherWidth) / 2)
                readonly property real launcherRight: launcherLeft + animLauncherWidth
                readonly property real launcherTop: root.height - theme.islandMargin - animLauncherHeight

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

                readonly property real audioLeft: theme.islandMargin
                readonly property real audioTop: Math.round((root.height - animAudioHeight) / 2)
                readonly property real audioBottom: audioTop + animAudioHeight
                readonly property real audioRight: audioLeft + animAudioWidth

                // Notification Panel geometry (bottom-right corner)
                readonly property int notifWidth: 400
                readonly property int notifCollapsedHeight: 66
                readonly property int notifEmptyHeight: 56
                property int notifExpandedHeight: {
                    if (globalNotifications.count === 0) return notifEmptyHeight
                    let visibleCount = Math.min(globalNotifications.count, 4)
                    return (visibleCount * 66) + 38
                }

                property real targetNotifHeight: {
                    if (!shell.isNotifOpen) return 0
                    if (shell.isNotifExpanded) return notifExpandedHeight
                    if (globalNotifications.count === 0) return notifEmptyHeight
                    return notifCollapsedHeight
                }

                property real targetNotifWidth: {
                    if (!shell.isNotifOpen && animNotifHeight === 0) return 0
                    return notifWidth
                }

                property real animNotifWidth: targetNotifWidth
                property real animNotifHeight: targetNotifHeight

                Behavior on animNotifWidth {
                    NumberAnimation {
                        duration: shell.isNotifOpen ? theme.animDurationFast : theme.animDurationExit
                        easing.type: shell.isNotifOpen ? Easing.OutBack : Easing.InCubic
                        easing.overshoot: 1.05
                    }
                }

                Behavior on animNotifHeight {
                    NumberAnimation {
                        duration: shell.isNotifOpen ? theme.animDurationFast : theme.animDurationExit
                        easing.type: shell.isNotifOpen ? Easing.OutBack : Easing.InCubic
                        easing.overshoot: 1.05
                    }
                }

                readonly property real notifRight: root.width - theme.islandMargin
                readonly property real notifLeft: notifRight - animNotifWidth
                readonly property real notifTop: root.height - theme.islandMargin - animNotifHeight

                // System Tray Panel geometry (top-right corner)
                readonly property int trayHeight: theme.notchHeight
                property int trayTargetWidth: (topTrayView && topTrayView.idealWidth > 0) ? topTrayView.idealWidth : 48
                property real targetTrayWidth: (shell.isTrayOpen && shell.trayItemCount > 0) ? trayTargetWidth : 0
                property real targetTrayHeight: (shell.isTrayOpen && shell.trayItemCount > 0) ? trayHeight : 0

                property real animTrayWidth: targetTrayWidth
                property real animTrayHeight: targetTrayHeight

                Behavior on animTrayWidth {
                    NumberAnimation {
                        duration: shell.isTrayOpen ? theme.animDurationFast : theme.animDurationExit
                        easing.type: shell.isTrayOpen ? Easing.OutBack : Easing.InCubic
                        easing.overshoot: 1.05
                    }
                }

                Behavior on animTrayHeight {
                    NumberAnimation {
                        duration: shell.isTrayOpen ? theme.animDurationFast : theme.animDurationExit
                        easing.type: shell.isTrayOpen ? Easing.OutBack : Easing.InCubic
                        easing.overshoot: 1.05
                    }
                }

                readonly property real trayRight: root.width - theme.islandMargin
                readonly property real trayLeft: trayRight - animTrayWidth
                readonly property real trayTop: theme.islandMargin
                readonly property real trayBottom: trayTop + animTrayHeight

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

                    // Interactive Top Hover Trigger (Restrito à geometria da ilha fechada)
                    Item {
                        id: notchTopTrigger
                        x: root.notchLeft
                        y: theme.islandMargin
                        width: root.animNotchWidth
                        height: root.animNotchHeight
                        visible: shell.activeMode === "none" && !shell.isLauncherOpen

                        HoverHandler {
                            id: topHoverHandler
                            onHoveredChanged: {
                                if (hovered) {
                                    if (!shell.preventAutoOpenSettings && shell.activeMode === "none" && !shell.isLauncherOpen) {
                                        shell.openLauncherTab("home")
                                    }
                                } else {
                                    shell.preventAutoOpenSettings = false
                                }
                            }
                        }
                    }

                    // Interactive Dynamic Island Top Bar Container
                    Item {
                        id: notchContainer
                        x: root.notchLeft
                        y: theme.islandMargin
                        width: root.animNotchWidth
                        height: root.animNotchHeight

                        LiquidGlass {
                            anchors.fill: parent
                            radius: (root.animNotchHeight <= 48) ? (root.animNotchHeight / 2) : theme.radiusIsland
                            fillColor: theme.glassFill
                            shadowEnabled: true
                        }

                        HoverHandler {
                            id: notchHover
                            onHoveredChanged: {
                                if (hovered) {
                                    launcherExitTimer.stop()
                                } else {
                                    if (shell.activeMode === "launcher" || shell.activeMode === "settings") {
                                        launcherExitTimer.restart()
                                    }
                                }
                            }
                        }

                        Timer {
                            id: launcherExitTimer
                            interval: 280
                            repeat: false
                            onTriggered: {
                                if (!notchHover.hovered && !topHoverHandler.hovered) {
                                    if (shell.activeMode === "launcher" || shell.activeMode === "settings") {
                                        shell.closeActiveMode(false)
                                    }
                                }
                            }
                        }

                        Item {
                            id: viewsContainer
                            anchors.fill: parent
                            clip: true

                            // View 0: Default Bar View (Clock & Date)
                            DefaultBarView {
                                id: defaultBarView
                                anchors.fill: parent
                                clip: true
                                visible: opacity > 0.001
                                opacity: shell.activeMode === "none" ? 1.0 : 0.0

                                gaming: globalGaming
                                notifications: globalNotifications
                                userProfile: globalUserProfile

                                activateLauncher: () => shell.toggleLauncher()
                                activateWorkspace: workspaceId => shell.activateWorkspace(workspaceId)
                                toggleNotifications: () => shell.toggleMode("notifications")
                                toggleSettings: () => shell.toggleLauncherBar()

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
                                goBack: () => shell.closeActiveMode()

                                Behavior on opacity {
                                    NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic }
                                }
                            }

                            // View 9: Central Launcher View (WiFi + Bluetooth + Som + Wallpapers + Gaming)
                            LauncherBarView {
                                id: launcherBarView
                                anchors.fill: parent
                                visible: opacity > 0.001
                                opacity: (shell.activeMode === "launcher" || shell.activeMode === "settings") ? 1.0 : 0.0
                                activeCategory: shell.activeLauncherTab
                                network: globalNetwork
                                bluetooth: globalBluetooth
                                audio: globalAudio
                                gaming: globalGaming
                                wallpaperEngine: globalWallpaper
                                userProfile: globalUserProfile
                                lockScreen: () => shell.lockScreen()
                                goBack: () => shell.closeActiveMode(true)

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

                    // Interactive Bottom Launcher / Workspace Container (Dynamic Island)
                    Item {
                        id: bottomLauncherContainer
                        x: root.launcherLeft
                        y: root.launcherTop
                        width: root.animLauncherWidth
                        height: root.animLauncherHeight
                        clip: false
                        visible: shell.isLauncherOpen || shell.isWorkspaceOpen || root.animLauncherHeight > 0
                        focus: shell.isLauncherOpen
                        z: 100

                        LiquidGlass {
                            anchors.fill: parent
                            radius: (root.animLauncherHeight <= 48) ? (root.animLauncherHeight / 2) : theme.radiusIsland
                            fillColor: theme.glassFillDark
                            shadowEnabled: true
                        }

                        BottomLauncher {
                            anchors.fill: parent
                            visible: shell.isLauncherOpen
                            open: shell.isLauncherOpen
                            closeLauncher: () => shell.isLauncherOpen = false
                        }

                        // Minimalist Bottom Workspace View
                        Item {
                            id: bottomWorkspaceView
                            anchors.fill: parent
                            visible: !shell.isLauncherOpen && (shell.isWorkspaceOpen || root.animLauncherHeight > 0)
                            opacity: (!shell.isLauncherOpen && shell.isWorkspaceOpen) ? 1.0 : 0.0

                            Behavior on opacity {
                                NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic }
                            }

                            HoverHandler {
                                id: bottomWorkspaceHover
                                onHoveredChanged: {
                                    if (hovered) {
                                        shell.workspaceBarTimer.stop()
                                    } else {
                                        if (shell.isWorkspaceOpen) {
                                            shell.closeWorkspaceBar()
                                        }
                                    }
                                }
                            }

                            WorkspacePills {
                                id: bottomWorkspacePills
                                anchors.centerIn: parent
                                activateWorkspace: workspaceId => {
                                    shell.activateWorkspace(workspaceId)
                                    if (!bottomWorkspaceHover.hovered) {
                                        shell.closeWorkspaceBar()
                                    }
                                }
                            }
                        }
                    }

                    // Bottom Center Workspace Trigger Hot Zone
                    Item {
                        id: workspaceBottomTrigger
                        x: Math.round((root.width - Math.max(240, root.workspaceTargetWidth)) / 2)
                        y: root.height - theme.islandMargin - 28
                        width: Math.max(240, root.workspaceTargetWidth)
                        height: 28 + theme.islandMargin
                        visible: !shell.isWorkspaceOpen && !shell.isLauncherOpen

                        HoverHandler {
                            onHoveredChanged: {
                                if (hovered && !shell.isLauncherOpen) {
                                    shell.showWorkspaceBar(0)
                                }
                            }
                        }
                    }

                    // Interactive Left Audio Bar Container (Floating Capsule)
                    Item {
                        id: leftAudioBarContainer
                        x: root.audioLeft
                        y: root.audioTop
                        width: root.animAudioWidth
                        height: root.animAudioHeight
                        clip: false
                        visible: shell.isAudioBarOpen || root.animAudioWidth > 0

                        LiquidGlass {
                            anchors.fill: parent
                            radius: root.animAudioWidth / 2
                            fillColor: theme.glassFillDark
                            shadowEnabled: true
                        }

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
                            anchors.fill: parent
                            width: 48
                            audio: globalAudio
                            openSettings: () => {
                                shell.isAudioBarOpen = false
                                shell.audioBarTimer.stop()
                                shell.openSettingsTab("sound")
                            }
                        }
                    }

                    // Interactive Bottom-Right Notification Container (Floating Pill)
                    Item {
                        id: bottomNotifContainer
                        x: root.notifLeft
                        y: root.notifTop
                        width: root.animNotifWidth
                        height: root.animNotifHeight
                        clip: false
                        visible: shell.isNotifOpen || root.animNotifHeight > 0

                        LiquidGlass {
                            anchors.fill: parent
                            radius: (root.animNotifHeight <= 66) ? 20 : theme.radiusIsland
                            fillColor: theme.glassFillDark
                            shadowEnabled: true
                        }

                        HoverHandler {
                            id: bottomNotifHover
                            onHoveredChanged: {
                                if (hovered) {
                                    shell.notifDismissTimer.stop()
                                    if (globalNotifications.count > 1) {
                                        shell.notifExpandTimer.restart()
                                    }
                                } else {
                                    shell.closeNotification()
                                }
                            }
                        }

                        NotificationBarView {
                            anchors.fill: parent
                            anchors.margins: 10
                            notifications: globalNotifications
                            isExpanded: shell.isNotifExpanded
                            dismissAll: () => globalNotifications.dismissAll()
                            dismissOne: notif => globalNotifications.dismiss(notif)
                        }
                    }

                    // Bottom-Right Corner Trigger Hot Zone
                    Item {
                        id: notifCornerTrigger
                        x: root.width - theme.islandMargin - 48
                        y: root.height - theme.islandMargin - 48
                        width: 48 + theme.islandMargin
                        height: 48 + theme.islandMargin
                        visible: !shell.isNotifOpen

                        HoverHandler {
                            onHoveredChanged: {
                                if (hovered) {
                                    shell.showNotificationCorner()
                                }
                            }
                        }
                    }

                    // Interactive Top-Right System Tray Container (Floating Pill)
                    Item {
                        id: topTrayContainer
                        x: root.trayLeft
                        y: root.trayTop
                        width: root.animTrayWidth
                        height: root.animTrayHeight
                        clip: false
                        visible: (shell.isTrayOpen || root.animTrayHeight > 0) && shell.trayItemCount > 0

                        LiquidGlass {
                            anchors.fill: parent
                            radius: root.animTrayHeight / 2
                            fillColor: theme.glassFillDark
                            shadowEnabled: true
                        }

                        HoverHandler {
                            id: topTrayHover
                            onHoveredChanged: {
                                if (!hovered && !shell.isTrayMenuOpen) {
                                    shell.closeTrayBar()
                                }
                            }
                        }

                        TrayBarView {
                            id: topTrayView
                            anchors.centerIn: parent
                            onIsAnyMenuOpenChanged: {
                                shell.isTrayMenuOpen = isAnyMenuOpen
                                if (!isAnyMenuOpen && !topTrayHover.hovered) {
                                    shell.closeTrayBar()
                                }
                            }
                        }
                    }

                    // Top-Right Corner Trigger Hot Zone (Screen Bezel)
                    Item {
                        id: trayCornerTrigger
                        x: root.width - theme.islandMargin - 48
                        y: 0
                        width: 48 + theme.islandMargin
                        height: 48 + theme.islandMargin
                        visible: !shell.isTrayOpen && shell.trayItemCount > 0 && !shell.isLauncherOpen

                        HoverHandler {
                            onHoveredChanged: {
                                if (hovered && !shell.isLauncherOpen && shell.trayItemCount > 0) {
                                    shell.showTrayBar()
                                }
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


