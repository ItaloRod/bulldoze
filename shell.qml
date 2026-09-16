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

    property string activeMode: "none" // "none" | "launcher" | "settings" | "wallpaper" | "gaming"
    property string activeLauncherTab: "home"
    property alias activeSettingsTab: shell.activeLauncherTab
    property bool isFullscreenActive: false
    property bool isLauncherOpen: false
    property bool isSpotlightOpen: false
    property bool isNotifOpen: false
    property bool isConfirmOpen: false
    property string confirmTitle: ""
    property string confirmDesc: ""
    property string confirmAction: ""
    property string confirmIcon: ""

    Process {
        id: confirmActionProc
    }

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

    Appearance {
        id: globalAppearance
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
            if (ready && !(shell.isLauncherOpen && shell.activeLauncherTab === "sound")) {
                shell.showAudioBar()
            }
        }

        onMutedChanged: {
            if (ready && !(shell.isLauncherOpen && shell.activeLauncherTab === "sound")) {
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

    function showAudioBar() {
        if (shell.isFullscreenActive) return
        if (shell.isLauncherOpen && shell.activeLauncherTab === "sound") return
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

    function showWorkspaceBar(timeout) {
        if (shell.isFullscreenActive) return
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

    function toggleLauncher() {
        if (shell.isLauncherOpen) {
            shell.closeLauncher()
        } else {
            shell.openLauncherTab("home")
        }
    }

    function openLauncherTab(tab) {
        shell.closeWorkspaceBar()
        shell.closeSpotlight()
        shell.closeNotification()
        shell.isAudioBarOpen = false
        shell.audioBarTimer.stop()
        shell.activeLauncherTab = tab || "home"
        shell.activeMode = "launcher"
        shell.isLauncherOpen = true
    }

    function openSettingsTab(tab) {
        shell.openLauncherTab(tab)
    }

    function toggleLauncherBar() {
        shell.toggleLauncher()
    }

    function toggleSettings() {
        shell.toggleLauncher()
    }

    function closeLauncher() {
        shell.isLauncherOpen = false
        shell.activeMode = "none"
    }

    function closeActiveMode() {
        shell.closeLauncher()
    }

    function toggleSpotlight() {
        if (shell.isSpotlightOpen) {
            shell.closeSpotlight()
        } else {
            shell.closeLauncher()
            shell.closeNotification()
            shell.isSpotlightOpen = true
        }
    }

    function openSpotlight() {
        shell.closeLauncher()
        shell.closeNotification()
        shell.isSpotlightOpen = true
    }

    function closeSpotlight() {
        shell.isSpotlightOpen = false
    }

    function toggleNotifications() {
        if (shell.isNotifOpen) {
            shell.closeNotification()
        } else {
            shell.closeSpotlight()
            shell.isNotifOpen = true
        }
    }

    function openNotifications() {
        shell.closeSpotlight()
        shell.isNotifOpen = true
    }

    function closeNotification() {
        shell.isNotifOpen = false
    }

    function activateWorkspace(id) {
        if (shell.isLauncherOpen) shell.closeLauncher()
        for (const workspace of Hyprland.workspaces.values) {
            if (workspace.id === id) {
                workspace.activate()
                return
            }
        }
    }

    function lockScreen() {
        shell.closeLauncher()
        shell.closeSpotlight()
        shell.closeNotification()
        globalLockScreen.lock()
    }

    function requestConfirm(title, desc, action, icon) {
        shell.closeLauncher()
        shell.closeSpotlight()
        shell.closeNotification()
        shell.confirmTitle = title || "Confirmação"
        shell.confirmDesc = desc || "Deseja realmente prosseguir?"
        shell.confirmAction = action || ""
        shell.confirmIcon = icon || ""
        shell.isConfirmOpen = true
    }

    function cancelConfirm() {
        shell.isConfirmOpen = false
        shell.confirmAction = ""
    }

    function acceptConfirm() {
        const act = shell.confirmAction
        shell.isConfirmOpen = false
        shell.confirmAction = ""
        if (act) {
            confirmActionProc.exec(["sh", "-c", act])
        }
    }

    IpcHandler {
        target: "shell"
        function toggleLauncher() { shell.toggleLauncher() }
        function toggleSearch() { shell.toggleSpotlight() }
        function toggleSpotlight() { shell.toggleSpotlight() }
        function openSpotlight() { shell.openSpotlight() }
        function closeSpotlight() { shell.closeSpotlight() }
        function toggleWorkspaces() { if (shell.isWorkspaceOpen) shell.closeWorkspaceBar(); else shell.showWorkspaceBar(2000) }
        function showWorkspaces() { shell.showWorkspaceBar(2000) }
        function toggleAudio() { shell.toggleAudioBar() }
        function toggleGaming() { shell.openLauncherTab("gaming") }
        function toggleGamingSettings() { shell.openLauncherTab("gaming") }
        function toggleSettings() { shell.toggleLauncher() }
        function toggleLauncherBar() { shell.toggleLauncher() }
        function openSettings(tab: string) { shell.openLauncherTab(tab) }
        function openLauncher(tab: string) { shell.openLauncherTab(tab) }
        function toggleWallpaper() { shell.openLauncherTab("wallpaper") }
        function toggleWallpaperModal() { shell.openLauncherTab("wallpaper") }
        function toggleProfile() { shell.openLauncherTab("home") }
        function togglePowerMenu() { shell.openLauncherTab("home") }
        function toggleNotifications() { shell.toggleNotifications() }
        function expandNotifications() { shell.openNotifications() }
        function toggleControlCenter() { shell.openLauncherTab("home") }
        function closeActiveMode() { shell.closeLauncher() }
        function lockScreen() { shell.lockScreen() }
        function requestConfirm(title: string, desc: string, action: string, icon: string) { shell.requestConfirm(title, desc, action, icon) }
        function cancelConfirm() { shell.cancelConfirm() }
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

    // Top Bar (Continuous 100% width macOS style, 32px height, transparent background)
    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                required property var modelData
                screen: modelData

                WlrLayershell.namespace: "bulldoze-top-bar"
                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
                exclusiveZone: 32
                focusable: false
                visible: !shell.isFullscreenActive && !shell.isLauncherOpen
                color: "transparent"

                anchors {
                    top: true
                    left: true
                    right: true
                }
                implicitHeight: 32

                TopBar {
                    anchors.fill: parent
                    iconColor: globalAppearance.topBarColor
                    openLauncher: () => shell.toggleLauncher()
                    toggleNotifications: () => shell.toggleNotifications()
                }
            }
        }
    }

    // Main Overlay Window: Handles Fullscreen Launcher, Spotlight, Notification Center, Audio Bar, Workspace Dock, and Confirm Dialog
    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: root
                required property var modelData
                screen: modelData

                WlrLayershell.namespace: "bulldoze-overlay"
                WlrLayershell.layer: (shell.isConfirmOpen || shell.isLauncherOpen || shell.isSpotlightOpen) ? WlrLayer.Overlay : WlrLayer.Top
                WlrLayershell.keyboardFocus: (shell.isConfirmOpen || shell.isLauncherOpen || shell.isSpotlightOpen || shell.isNotifOpen) ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
                exclusiveZone: -1
                focusable: shell.isConfirmOpen || shell.isLauncherOpen || shell.isSpotlightOpen || shell.isNotifOpen
                visible: (!shell.isFullscreenActive || shell.isLauncherOpen || shell.isSpotlightOpen || shell.isConfirmOpen || shell.isNotifOpen) && mainContainer.opacity > 0.001
                color: "transparent"

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }

                mask: Region {
                    item: shell.isConfirmOpen ? confirmDialog :
                          shell.isLauncherOpen ? fullscreenLauncherModal :
                          shell.isSpotlightOpen ? spotlightModal :
                          shell.isNotifOpen ? notifCenter : null

                    Region {
                        item: (shell.isAudioBarOpen || root.animAudioWidth > 0) ? leftAudioBarContainer : null
                    }

                    Region {
                        item: (!shell.isNotifOpen && notifCenter.toastVisible) ? notifCenter.toastContainer : null
                    }

                    Region {
                        item: (shell.isWorkspaceOpen || root.animLauncherHeight > 0)
                            ? bottomLauncherContainer
                            : workspaceBottomTrigger
                    }
                }

                HyprlandFocusGrab {
                    windows: [root]
                    active: shell.isConfirmOpen || shell.isLauncherOpen || shell.isSpotlightOpen || shell.isNotifOpen
                    onCleared: {
                        if (shell.isConfirmOpen) {
                            shell.cancelConfirm()
                        } else if (shell.isSpotlightOpen) {
                            shell.closeSpotlight()
                        } else if (shell.isLauncherOpen) {
                            shell.closeLauncher()
                        } else if (shell.isNotifOpen) {
                            shell.closeNotification()
                        }
                    }
                }

                Theme {
                    id: theme
                }

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

                // Bottom Workspace Dock
                readonly property real concaveWidth: theme.notchConcaveWidth
                readonly property real concaveHeight: theme.notchConcaveHeight
                readonly property real bottomRadius: theme.notchBottomRadius
                readonly property real topRadius: 18

                readonly property int workspaceCount: {
                    let count = 0
                    for (const ws of Hyprland.workspaces.values) {
                        if (ws && ws.id > 0) count++
                    }
                    return Math.max(1, count)
                }
                readonly property int workspacePillsWidth: 22 + (12 * (workspaceCount - 1))
                property int workspaceTargetWidth: Math.max(80, workspacePillsWidth + (theme.contentInset * 2) + (root.concaveWidth * 2))
                property int launcherTargetHeight: shell.isWorkspaceOpen ? 32 : 0
                property int launcherTargetWidth: root.workspaceTargetWidth
                property real animLauncherHeight: launcherTargetHeight
                property real animLauncherWidth: launcherTargetWidth

                Behavior on animLauncherHeight {
                    NumberAnimation {
                        duration: shell.isWorkspaceOpen ? theme.animDurationNormal : theme.animDurationExit
                        easing.type: shell.isWorkspaceOpen ? Easing.OutBack : Easing.InQuad
                        easing.overshoot: 1.15
                    }
                }

                Behavior on animLauncherWidth {
                    NumberAnimation {
                        duration: shell.isWorkspaceOpen ? theme.animDurationNormal : theme.animDurationExit
                        easing.type: shell.isWorkspaceOpen ? Easing.OutBack : Easing.InQuad
                    }
                }

                readonly property real launcherLeft: Math.round((root.width - animLauncherWidth) / 2)
                readonly property real launcherRight: launcherLeft + animLauncherWidth
                readonly property real launcherTop: root.height - theme.islandMargin - animLauncherHeight

                Item {
                    id: mainContainer
                    anchors.fill: parent
                    opacity: (shell.isFullscreenActive && !shell.isLauncherOpen && !shell.isSpotlightOpen && !shell.isConfirmOpen && !shell.isNotifOpen) ? 0.0 : 1.0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: theme.animDurationNormal
                            easing.type: Easing.OutCubic
                        }
                    }

                    // Centered Spotlight Search Modal
                    Spotlight {
                        id: spotlightModal
                        anchors.fill: parent
                        open: shell.isSpotlightOpen
                        onCloseRequested: shell.closeSpotlight()
                        z: 160
                    }

                    // Fullscreen Launcher with iOS-style blur backdrop
                    Item {
                        id: fullscreenLauncherModal
                        anchors.fill: parent
                        visible: shell.isLauncherOpen
                        opacity: shell.isLauncherOpen ? 1.0 : 0.0
                        z: 150

                        Behavior on opacity {
                            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                        }

                        // Transparent glass backdrop (matches kitty 10% opacity)
                        Rectangle {
                            anchors.fill: parent
                            color: theme.glassFill
                        }

                        LauncherBarView {
                            id: launcherBarView
                            anchors.fill: parent
                            activeCategory: shell.activeLauncherTab
                            network: globalNetwork
                            bluetooth: globalBluetooth
                            audio: globalAudio
                            gaming: globalGaming
                            wallpaperEngine: globalWallpaper
                            userProfile: globalUserProfile
                            appearance: globalAppearance
                            lockScreen: () => shell.lockScreen()
                            goBack: () => shell.closeLauncher()
                            requestConfirm: (title, desc, action, icon) => shell.requestConfirm(title, desc, action, icon)
                        }
                    }

                    // Notification Center & Floating Toast
                    NotificationCenter {
                        id: notifCenter
                        anchors.fill: parent
                        notifications: globalNotifications
                        open: shell.isNotifOpen
                        onCloseRequested: shell.closeNotification()
                        z: 140
                    }

                    // Centered Confirmation Dialog Modal (Power / Reboot / Logout actions)
                    ConfirmDialog {
                        id: confirmDialog
                        anchors.fill: parent
                        open: shell.isConfirmOpen
                        title: shell.confirmTitle
                        description: shell.confirmDesc
                        icon: shell.confirmIcon
                        onConfirm: () => shell.acceptConfirm()
                        onCancel: () => shell.cancelConfirm()
                        z: 200
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
                        z: 80

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

                    // Interactive Bottom Workspace Container
                    Item {
                        id: bottomLauncherContainer
                        x: root.launcherLeft
                        y: root.launcherTop
                        width: root.animLauncherWidth
                        height: root.animLauncherHeight
                        clip: false
                        visible: shell.isWorkspaceOpen || root.animLauncherHeight > 0
                        z: 70

                        LiquidGlass {
                            anchors.fill: parent
                            radius: (root.animLauncherHeight <= 48) ? (root.animLauncherHeight / 2) : theme.radiusIsland
                            fillColor: theme.glassFillDark
                            shadowEnabled: true
                        }

                        // Minimalist Bottom Workspace View
                        Item {
                            id: bottomWorkspaceView
                            anchors.fill: parent
                            visible: shell.isWorkspaceOpen || root.animLauncherHeight > 0
                            opacity: shell.isWorkspaceOpen ? 1.0 : 0.0

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
                        visible: !shell.isWorkspaceOpen && !shell.isLauncherOpen && !shell.isConfirmOpen

                        HoverHandler {
                            onHoveredChanged: {
                                if (hovered && !shell.isLauncherOpen) {
                                    shell.showWorkspaceBar(0)
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
}
