import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property string scriptPath: Quickshell.env("HOME") + "/.config/quickshell/bulldoze/scripts/bulldoze-wallpaper.py"
    property string configPath: Quickshell.env("HOME") + "/.config/bulldoze/wallpaper.json"

    property var wallpapers: []
    property string activeId: "3680199367"
    property string selectedId: "3680199367"

    // Global Settings
    property int fps: 60
    property string scaling: "fill" // "fill" | "fit" | "stretch"
    property string clamp: "border"
    property string backgroundColor: "#000000"
    property int volume: 0
    property bool mouseEnabled: true
    property bool hideSponsor: true
    property bool pauseOnWindow: true
    property bool optimizerActive: false
    property int snapshotVersion: 0

    onOptimizerActiveChanged: {
        if (optimizerActive) {
            stopEngine()
        } else {
            saveAndApplyActive()
        }
    }

    // Per wallpaper settings map
    property var perWallpaperSettings: ({})

    readonly property var activeWallpaper: getWallpaperById(activeId)
    readonly property var selectedWallpaper: getWallpaperById(selectedId)

    function getWallpaperById(id) {
        if (!wallpapers || wallpapers.length === 0) return null
        for (let i = 0; i < wallpapers.length; i++) {
            if (wallpapers[i].id === id) return wallpapers[i]
        }
        return wallpapers[0] || null
    }

    function loadWallpapers() {
        if (!listProc.running) {
            listProc.running = true
        }
    }

    function loadConfig() {
        if (!configProc.running) {
            configProc.running = true
        }
    }

    function selectWallpaper(id) {
        selectedId = id
    }

    function applySelectedWallpaper() {
        applyWallpaper(selectedId)
    }

    function getActiveIndex() {
        if (!wallpapers || wallpapers.length === 0) return 0
        for (let i = 0; i < wallpapers.length; i++) {
            if (wallpapers[i].id === activeId) return i
        }
        return 0
    }

    function nextWallpaper() {
        if (!wallpapers || wallpapers.length === 0) return
        let idx = getActiveIndex()
        let nextIdx = (idx + 1) % wallpapers.length
        applyWallpaper(wallpapers[nextIdx].id)
    }

    function previousWallpaper() {
        if (!wallpapers || wallpapers.length === 0) return
        let idx = getActiveIndex()
        let prevIdx = (idx - 1 + wallpapers.length) % wallpapers.length
        applyWallpaper(wallpapers[prevIdx].id)
    }

    function toggleMute() {
        if (volume > 0) {
            setVolumeLevel(0)
        } else {
            setVolumeLevel(50)
        }
    }

    function toggleMouse() {
        setMouseEnabled(!mouseEnabled)
    }

    function stopEngine() {
        stopProc.exec(["python3", root.scriptPath, "stop"])
    }

    function applyWallpaper(id) {
        if (!id) return
        activeId = id
        selectedId = id

        const payload = {
            "fps": root.fps,
            "scaling": root.scaling,
            "clamp": root.clamp,
            "background_color": root.backgroundColor,
            "volume": root.volume,
            "mouse_enabled": root.mouseEnabled,
            "hide_sponsor": root.hideSponsor,
            "pause_on_window": root.pauseOnWindow,
            "per_wallpaper_settings": root.perWallpaperSettings
        }

        if (optimizerActive) {
            applyProc.exec([
                "python3",
                root.scriptPath,
                "snapshot-silent",
                id
            ])
            stopEngine()
        } else {
            applyProc.exec([
                "python3",
                root.scriptPath,
                "apply",
                id,
                JSON.stringify(payload)
            ])
        }
    }

    function setScalingMode(mode) {
        scaling = mode
        saveAndApplyActive()
    }

    function setFps(newFps) {
        fps = newFps
        saveAndApplyActive()
    }

    function setVolumeLevel(vol) {
        volume = vol
        saveAndApplyActive()
    }

    function setMouseEnabled(enabled) {
        mouseEnabled = enabled
        saveAndApplyActive()
    }

    function setHideSponsor(hide) {
        hideSponsor = hide
        saveAndApplyActive()
    }

    function setPauseOnWindow(paused) {
        pauseOnWindow = paused
        saveAndApplyActive()
    }

    function setWallpaperProperty(wpId, key, value) {
        if (!wpId || !key) return
        const settings = Object.assign({}, perWallpaperSettings)
        if (!settings[wpId]) {
            settings[wpId] = { properties: {}, skip_objects: [], skip_effects: [] }
        }
        if (!settings[wpId].properties) {
            settings[wpId].properties = {}
        }
        settings[wpId].properties[key] = value
        perWallpaperSettings = settings
        saveAndApplyActive()
    }

    function getWallpaperPropertyValue(wpId, key, defaultValue) {
        if (!perWallpaperSettings || !perWallpaperSettings[wpId]) return defaultValue
        const wp = perWallpaperSettings[wpId]
        if (wp.properties && wp.properties[key] !== undefined) {
            return wp.properties[key]
        }
        return defaultValue
    }

    function toggleSponsor(wpId, disableSponsor) {
        // Many wallpapers have 'sponsorme', 'sponsorinfo', 'sponsor'
        setWallpaperProperty(wpId, "sponsorme", !disableSponsor)
        setWallpaperProperty(wpId, "sponsorinfo", !disableSponsor)
        setWallpaperProperty(wpId, "sponsor", !disableSponsor)
    }

    function saveAndApplyActive() {
        if (activeId) {
            applyWallpaper(activeId)
        }
    }

    property var listProc: Process {
        id: listProc
        command: ["python3", root.scriptPath, "list"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    const parsed = JSON.parse(data.trim())
                    if (Array.isArray(parsed)) {
                        root.wallpapers = parsed
                        if (!root.selectedId && parsed.length > 0) {
                            root.selectedId = parsed[0].id
                        }
                    }
                } catch(e) {
                    console.warn("Error parsing wallpaper list:", e)
                }
            }
        }
    }

    property var configProc: Process {
        id: configProc
        command: ["python3", root.scriptPath, "config"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    const cfg = JSON.parse(data.trim())
                    if (cfg.active_id) {
                        root.activeId = cfg.active_id
                        root.selectedId = cfg.active_id
                    }
                    if (cfg.fps !== undefined) root.fps = cfg.fps
                    if (cfg.scaling) root.scaling = cfg.scaling
                    if (cfg.clamp) root.clamp = cfg.clamp
                    if (cfg.background_color) root.backgroundColor = cfg.background_color
                    if (cfg.volume !== undefined) root.volume = cfg.volume
                    if (cfg.mouse_enabled !== undefined) root.mouseEnabled = !!cfg.mouse_enabled
                    if (cfg.hide_sponsor !== undefined) root.hideSponsor = !!cfg.hide_sponsor
                    if (cfg.pause_on_window !== undefined) root.pauseOnWindow = !!cfg.pause_on_window
                    if (cfg.per_wallpaper_settings) root.perWallpaperSettings = cfg.per_wallpaper_settings
                } catch(e) {
                    console.warn("Error parsing wallpaper config:", e)
                }
            }
        }
    }

    property var applyProc: Process {
        id: applyProc
        onExited: (code, status) => {
            snapshotVersion++
        }
    }

    property var stopProc: Process {
        id: stopProc
    }

    Component.onCompleted: {
        loadConfig()
        loadWallpapers()
        if (optimizerActive) {
            stopEngine()
        }
    }
}
