import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import "components"
import "components/views"
import "modules"

ShellRoot {
    id: shell

    property string activeMode: "none" // "none" | "wifi" | "bluetooth" | "audio" | "gaming" | "power" | "profile" | "notifications"

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
            if (ready && shell.activeMode === "none" && !launcher.open && !gamingModal.open && !wallpaperModal.open) {
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
            if (ready) {
                shell.showAudioOsd()
            }
        }

        onMutedChanged: {
            if (ready) {
                shell.showAudioOsd()
            }
        }

        Component.onCompleted: {
            readyTimer.start()
        }

        property var readyTimer: Timer {
            interval: 500
            onTriggered: globalAudio.ready = true
        }
    }

    property bool audioTriggeredByOsd: false

    Timer {
        id: audioOsdTimer
        interval: 2000
        onTriggered: {
            if (shell.audioTriggeredByOsd && shell.activeMode === "audio") {
                shell.activeMode = "none"
                shell.audioTriggeredByOsd = false
            }
        }
    }

    Timer {
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

    function showAudioOsd() {
        if (launcher.open) launcher.open = false
        if (gamingModal.open) gamingModal.open = false
        if (wallpaperModal.open) wallpaperModal.open = false
        notificationTimer.stop()
        if (shell.activeMode !== "audio") {
            shell.activeMode = "audio"
        }
        shell.audioTriggeredByOsd = true
        audioOsdTimer.restart()
    }

    function showNotificationOsd() {
        if (launcher.open) launcher.open = false
        if (gamingModal.open) gamingModal.open = false
        if (wallpaperModal.open) wallpaperModal.open = false
        audioOsdTimer.stop()
        shell.audioTriggeredByOsd = false
        if (shell.activeMode !== "notifications") {
            shell.activeMode = "notifications"
        }
        notificationTimer.restart()
    }

    function toggleMode(mode) {
        if (launcher.open) launcher.open = false
        if (gamingModal.open) gamingModal.open = false
        if (wallpaperModal.open) wallpaperModal.open = false
        audioOsdTimer.stop()
        notificationTimer.stop()
        shell.audioTriggeredByOsd = false
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
        audioOsdTimer.stop()
        notificationTimer.stop()
        shell.audioTriggeredByOsd = false
        activeMode = "none"
        if (gamingModal.open) gamingModal.open = false
        if (wallpaperModal.open) wallpaperModal.open = false
    }

    function toggleLauncher() {
        if (launcher.open) {
            launcher.open = false
        } else {
            shell.closeActiveMode()
            if (gamingModal.open) gamingModal.open = false
            if (wallpaperModal.open) wallpaperModal.open = false
            launcher.open = true
        }
    }

    function toggleGamingModal() {
        if (gamingModal.open) {
            gamingModal.open = false
        } else {
            shell.closeActiveMode()
            if (launcher.open) launcher.open = false
            if (wallpaperModal.open) wallpaperModal.open = false
            gamingModal.open = true
        }
    }

    function toggleWallpaperModal() {
        if (wallpaperModal.open) {
            wallpaperModal.open = false
        } else {
            shell.closeActiveMode()
            if (launcher.open) launcher.open = false
            if (gamingModal.open) gamingModal.open = false
            wallpaperModal.open = true
        }
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
        function toggleWifi() { shell.toggleMode("wifi") }
        function toggleBluetooth() { shell.toggleMode("bluetooth") }
        function toggleAudio() { shell.toggleMode("audio") }
        function toggleGaming() { shell.toggleMode("gaming") }
        function toggleGamingSettings() { shell.toggleGamingModal() }
        function toggleWallpaperManager() { shell.toggleWallpaperModal() }
        function toggleWallpaper() { shell.toggleWallpaperModal() }
        function toggleProfile() { shell.toggleMode("power") }
        function togglePowerMenu() { shell.toggleMode("power") }
        function toggleNotifications() { shell.toggleMode("notifications") }
        function toggleControlCenter() { shell.toggleMode("gaming") }
        function closeActiveMode() { shell.closeActiveMode(); launcher.open = false; gamingModal.open = false; wallpaperModal.open = false }
        function lockScreen() { shell.lockScreen() }
        function raiseVolume() { globalAudio.stepVolume(0.05) }
        function lowerVolume() { globalAudio.stepVolume(-0.05) }
        function toggleMute() { globalAudio.toggleMute() }
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

    // Unified Morphing Top Notch Bar
    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                id: root
                required property var modelData
                screen: modelData

                WlrLayershell.namespace: "bulldoze-bar"
                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
                exclusiveZone: theme.notchHeight
                focusable: false

                anchors {
                    top: true
                }

                property bool isHovered: barHover.hovered
                property bool isExpanded: isHovered || shell.activeMode !== "none" || launcher.open
                property int expandedWidth: (defaultBarView && defaultBarView.contentExpandedWidth > 0) ? defaultBarView.contentExpandedWidth : 620
                property int collapsedWidth: (defaultBarView && defaultBarView.contentCollapsedWidth > 0) ? defaultBarView.contentCollapsedWidth : 170

                property int targetWidth: {
                    if (shell.activeMode === "wifi") return 460
                    if (shell.activeMode === "bluetooth") return 470
                    if (shell.activeMode === "audio") return 380
                    if (shell.activeMode === "gaming") return 620
                    if (shell.activeMode === "notifications") return 520
                    if (shell.activeMode === "power" || shell.activeMode === "profile") return 490
                    return root.isExpanded ? expandedWidth : collapsedWidth
                }

                property int targetHeight: {
                    if (shell.activeMode === "notifications") return theme.notchNotificationHeight
                    if (shell.activeMode !== "none") return theme.notchExpandedHeight
                    if (root.isHovered || launcher.open) return theme.notchHoverHeight
                    return theme.notchHeight
                }

                implicitWidth: targetWidth
                implicitHeight: targetHeight
                color: "transparent"

                Behavior on implicitWidth {
                    NumberAnimation {
                        duration: shell.activeMode !== "none" ? theme.animDurationSlow : (root.isExpanded ? theme.notchExpandDuration : theme.notchCollapseDuration)
                        easing.type: shell.activeMode !== "none" ? Easing.OutBack : (root.isExpanded ? Easing.OutBack : Easing.InOutCubic)
                        easing.overshoot: theme.stickyOvershoot
                    }
                }

                Behavior on implicitHeight {
                    NumberAnimation {
                        duration: shell.activeMode !== "none" ? theme.animDurationSlow : (root.isExpanded ? theme.notchExpandDuration : theme.notchCollapseDuration)
                        easing.type: shell.activeMode !== "none" ? Easing.OutBack : (root.isExpanded ? Easing.OutBack : Easing.InOutCubic)
                        easing.overshoot: theme.stickyOvershoot
                    }
                }

                GlassPanel {
                    anchors.fill: parent

                    HoverHandler {
                        id: barHover
                    }

                    // View 0: Default Bar View (Workspaces, Clock, Status)
                    DefaultBarView {
                        id: defaultBarView
                        anchors.fill: parent
                        isExpanded: root.isExpanded && shell.activeMode === "none"
                        visible: opacity > 0.001
                        opacity: shell.activeMode === "none" ? 1.0 : 0.0

                        network: globalNetwork
                        bluetooth: globalBluetooth
                        audio: globalAudio
                        gaming: globalGaming
                        notifications: globalNotifications
                        userProfile: globalUserProfile

                        activateLauncher: () => shell.toggleLauncher()
                        activateWorkspace: workspaceId => shell.activateWorkspace(workspaceId)
                        toggleWifi: () => shell.toggleMode("wifi")
                        toggleBluetooth: () => shell.toggleMode("bluetooth")
                        toggleAudio: () => shell.toggleMode("audio")
                        toggleGaming: () => shell.toggleMode("gaming")
                        toggleNotifications: () => shell.toggleMode("notifications")
                        toggleProfile: () => shell.toggleMode("power")
                        togglePowerMenu: () => shell.toggleMode("power")

                        Behavior on opacity {
                            NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic }
                        }
                    }

                    // View 1: Wi-Fi View
                    WifiBarView {
                        anchors.fill: parent
                        visible: opacity > 0.001
                        opacity: shell.activeMode === "wifi" ? 1.0 : 0.0
                        network: globalNetwork
                        goBack: () => shell.closeActiveMode()

                        Behavior on opacity {
                            NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic }
                        }
                    }

                    // View 2: Bluetooth View
                    BluetoothBarView {
                        anchors.fill: parent
                        visible: opacity > 0.001
                        opacity: shell.activeMode === "bluetooth" ? 1.0 : 0.0
                        bluetooth: globalBluetooth
                        goBack: () => shell.closeActiveMode()

                        Behavior on opacity {
                            NumberAnimation { duration: theme.animDurationFast; easing.type: Easing.OutCubic }
                        }
                    }

                    // View 3: Audio View
                    AudioBarView {
                        anchors.fill: parent
                        visible: opacity > 0.001
                        opacity: shell.activeMode === "audio" ? 1.0 : 0.0
                        audio: globalAudio
                        goBack: () => shell.closeActiveMode()

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
                        openSettings: () => {
                            shell.closeActiveMode()
                            gamingModal.open = true
                        }

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
                }
            }
        }
    }

    Launcher {
        id: launcher
    }

    GamingSettingsModal {
        id: gamingModal
        gaming: globalGaming
    }

    WallpaperManagerModal {
        id: wallpaperModal
        wallpaperEngine: globalWallpaper
    }

    LockScreen {
        id: globalLockScreen
    }

    NotificationCenter {
        notifications: globalNotifications
    }
}
