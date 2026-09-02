import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property string configPath: Quickshell.env("HOME") + "/.config/bulldoze/gaming.json"
    property string mangohudConfPath: Quickshell.env("HOME") + "/.config/MangoHud/MangoHud.conf"

    // Quick Toggles (Main view)
    property bool gamemodeEnabled: false
    property bool bulldoptimizerEnabled: false
    property bool mangohudEnabled: false
    property bool gamescopeEnabled: false

    // Bulldoptimizer Advanced Options
    property bool boWallpaperStatic: true
    property bool boHyprlandEffects: true
    property bool boPowerMizer: false

    // Gamescope Advanced Options
    property bool gsHdr: false
    property bool gsHdrItm: false
    property int gsHdrSdrNits: 400
    property int gsWidth: 2560
    property int gsHeight: 1440
    property int gsRenderWidth: 0
    property int gsRenderHeight: 0
    property int gsRefreshRate: 240
    property bool gsFullscreen: true
    property bool gsBorderless: false
    property bool gsFsr: false
    property int gsFsrSharpness: 2
    property string gsScalerFilter: "fsr"
    property string gsScalerType: "fit"
    property bool gsIntegerScaling: false
    property bool gsAdaptiveSync: false
    property int gsFpsLimit: 0
    property string gsCustomArgs: ""

    // MangoHud Advanced Options
    property bool mhVram: true
    property bool mhRam: true
    property bool mhGpuStats: true
    property bool mhGpuTemp: true
    property bool mhGpuCoreClock: false
    property bool mhGpuPower: false
    property bool mhCpuStats: true
    property bool mhCpuTemp: true
    property bool mhCpuMhz: false
    property bool mhCpuPower: false
    property bool mhFps: true
    property bool mhFrametime: true
    property string mhPosition: "top-left"
    property int mhFpsLimit: 0
    property bool mhCompact: false

    readonly property bool anyActive: gamemodeEnabled || bulldoptimizerEnabled || mangohudEnabled || gamescopeEnabled

    function buildGamescopeArgs() {
        let args = "-W " + gsWidth + " -H " + gsHeight + " -r " + gsRefreshRate
        if (gsRenderWidth > 0 && gsRenderHeight > 0) {
            args += " -w " + gsRenderWidth + " -h " + gsRenderHeight
        }
        if (gsFullscreen) args += " --fullscreen"
        if (gsBorderless) args += " -b"
        if (gsHdr) args += " --hdr-enabled"
        if (gsHdrItm) args += " --hdr-itm-enabled"
        if (gsHdrSdrNits !== 400 && gsHdrSdrNits > 0) args += " --hdr-sdr-content-nits " + gsHdrSdrNits
        if (gsFsr) {
            args += " -F " + (gsScalerFilter || "fsr") + " --fsr-sharpness " + gsFsrSharpness
        } else if (gsScalerFilter && gsScalerFilter !== "fsr" && gsScalerFilter !== "linear" && gsScalerFilter !== "auto") {
            args += " -F " + gsScalerFilter
        }
        if (gsIntegerScaling) {
            args += " -S integer"
        } else if (gsScalerType && gsScalerType !== "fit" && gsScalerType !== "auto") {
            args += " -S " + gsScalerType
        }
        if (gsAdaptiveSync) args += " --adaptive-sync"
        if (gsFpsLimit > 0) args += " --max-fps " + gsFpsLimit
        if (gsCustomArgs && gsCustomArgs.trim() !== "") args += " " + gsCustomArgs.trim()
        return args
    }

    function buildMangohudConfigString() {
        const items = []
        if (mhFps) items.push("fps")
        if (mhFrametime) items.push("frametime")
        if (mhVram) items.push("vram")
        if (mhRam) items.push("ram")
        if (mhGpuStats) items.push("gpu_stats")
        if (mhGpuTemp) items.push("gpu_temp")
        if (mhGpuCoreClock) items.push("gpu_core_clock")
        if (mhGpuPower) items.push("gpu_power")
        if (mhCpuStats) items.push("cpu_stats")
        if (mhCpuTemp) items.push("cpu_temp")
        if (mhCpuMhz) items.push("cpu_mhz")
        if (mhCpuPower) items.push("cpu_power")
        if (mhPosition) items.push("position=" + mhPosition)
        if (mhFpsLimit > 0) items.push("fps_limit=" + mhFpsLimit)
        if (mhCompact) items.push("hud_compact")
        return items.join(",")
    }

    function buildMangohudConfFile() {
        let conf = "# MangoHud Configuration (Gerado pelo Bulldoze 3.0)\n"
        if (mhFps) conf += "fps\n"
        if (mhFrametime) conf += "frametime\n"
        if (mhVram) conf += "vram\n"
        if (mhRam) conf += "ram\n"
        if (mhGpuStats) conf += "gpu_stats\n"
        if (mhGpuTemp) conf += "gpu_temp\n"
        if (mhGpuCoreClock) conf += "gpu_core_clock\n"
        if (mhGpuPower) conf += "gpu_power\n"
        if (mhCpuStats) conf += "cpu_stats\n"
        if (mhCpuTemp) conf += "cpu_temp\n"
        if (mhCpuMhz) conf += "cpu_mhz\n"
        if (mhCpuPower) conf += "cpu_power\n"
        if (mhPosition) conf += "position=" + mhPosition + "\n"
        if (mhFpsLimit > 0) conf += "fps_limit=" + mhFpsLimit + "\n"
        if (mhCompact) conf += "hud_compact\n"
        return conf
    }

    function applyMangohudPreset(preset) {
        if (preset === "completo") {
            mhFps = true
            mhFrametime = true
            mhVram = true
            mhRam = true
            mhGpuStats = true
            mhGpuTemp = true
            mhGpuCoreClock = true
            mhGpuPower = true
            mhCpuStats = true
            mhCpuTemp = true
            mhCpuMhz = true
            mhCpuPower = true
            mhCompact = false
        } else if (preset === "essencial") {
            mhFps = true
            mhFrametime = true
            mhVram = true
            mhRam = true
            mhGpuStats = true
            mhGpuTemp = true
            mhGpuCoreClock = false
            mhGpuPower = false
            mhCpuStats = true
            mhCpuTemp = true
            mhCpuMhz = false
            mhCpuPower = false
            mhCompact = false
        } else if (preset === "minimo") {
            mhFps = true
            mhFrametime = false
            mhVram = false
            mhRam = false
            mhGpuStats = false
            mhGpuTemp = false
            mhGpuCoreClock = false
            mhGpuPower = false
            mhCpuStats = false
            mhCpuTemp = false
            mhCpuMhz = false
            mhCpuPower = false
            mhCompact = true
        }
        saveConfig()
    }

    function setResolution(w, h) {
        gsWidth = w
        gsHeight = h
        saveConfig()
    }

    function setRenderResolution(w, h) {
        gsRenderWidth = w
        gsRenderHeight = h
        saveConfig()
    }

    function setScalerFilter(f) {
        gsScalerFilter = f
        saveConfig()
    }

    function setScalerType(s) {
        gsScalerType = s
        saveConfig()
    }

    function setRefreshRate(r) {
        gsRefreshRate = r
        saveConfig()
    }

    function setPosition(pos) {
        mhPosition = pos
        saveConfig()
    }

    function toggleGamemode() {
        gamemodeEnabled = !gamemodeEnabled
        saveConfig()
    }

    function toggleBulldoptimizer() {
        bulldoptimizerEnabled = !bulldoptimizerEnabled
        applyBulldoptimizer(bulldoptimizerEnabled)
        saveConfig()
    }

    function applyBulldoptimizer(enabled) {
        if (enabled) {
            if (boHyprlandEffects) {
                hyprOptProc.exec(["sh", "-c", "hyprctl keyword decoration:blur:enabled false && hyprctl keyword decoration:shadow:enabled false && hyprctl keyword animations:enabled false && hyprctl keyword render:direct_scanout 1 2>/dev/null || true"])
            }
            if (boPowerMizer) {
                gpuOptProc.exec(["sh", "-c", "command -v nvidia-settings &>/dev/null && nvidia-settings -a '[gpu:0]/GpuPowerMizerMode=1' 2>/dev/null; command -v nvidia-smi &>/dev/null && nvidia-smi -pm 1 2>/dev/null || true"])
            }
        } else {
            if (boHyprlandEffects) {
                hyprOptProc.exec(["sh", "-c", "hyprctl keyword decoration:blur:enabled true && hyprctl keyword decoration:shadow:enabled true && hyprctl keyword animations:enabled true 2>/dev/null || true"])
            }
            if (boPowerMizer) {
                gpuOptProc.exec(["sh", "-c", "command -v nvidia-settings &>/dev/null && nvidia-settings -a '[gpu:0]/GpuPowerMizerMode=0' 2>/dev/null || true"])
            }
        }
    }

    function toggleMangohud() {
        mangohudEnabled = !mangohudEnabled
        saveConfig()
    }

    function toggleGamescope() {
        gamescopeEnabled = !gamescopeEnabled
        saveConfig()
    }

    function saveConfig() {
        const payload = {
            "gamemode": gamemodeEnabled,
            "bulldoptimizer": bulldoptimizerEnabled,
            "mangohud": mangohudEnabled,
            "gamescope": gamescopeEnabled,
            "bulldoptimizer_config": {
                "wallpaper_static": boWallpaperStatic,
                "hyprland_effects": boHyprlandEffects,
                "powermizer": boPowerMizer
            },
            "gamescope_args": buildGamescopeArgs(),
            "gamescope_config": {
                "hdr": gsHdr,
                "hdr_itm": gsHdrItm,
                "hdr_sdr_nits": gsHdrSdrNits,
                "width": gsWidth,
                "height": gsHeight,
                "render_width": gsRenderWidth,
                "render_height": gsRenderHeight,
                "refresh_rate": gsRefreshRate,
                "fullscreen": gsFullscreen,
                "borderless": gsBorderless,
                "fsr": gsFsr,
                "fsr_sharpness": gsFsrSharpness,
                "scaler_filter": gsScalerFilter,
                "scaler_type": gsScalerType,
                "integer_scaling": gsIntegerScaling,
                "adaptive_sync": gsAdaptiveSync,
                "fps_limit": gsFpsLimit,
                "custom_args": gsCustomArgs
            },
            "mangohud_config": {
                "vram": mhVram,
                "ram": mhRam,
                "gpu_stats": mhGpuStats,
                "gpu_temp": mhGpuTemp,
                "gpu_core_clock": mhGpuCoreClock,
                "gpu_power": mhGpuPower,
                "cpu_stats": mhCpuStats,
                "cpu_temp": mhCpuTemp,
                "cpu_mhz": mhCpuMhz,
                "cpu_power": mhCpuPower,
                "fps": mhFps,
                "frametime": mhFrametime,
                "position": mhPosition,
                "fps_limit": mhFpsLimit,
                "hud_compact": mhCompact
            }
        }
        const jsonStr = JSON.stringify(payload, null, 2)
        const mangohudConf = buildMangohudConfFile()
        
        writeProc.exec([
            "bash", "-c",
            "mkdir -p ~/.config/bulldoze ~/.config/MangoHud && " +
            "cat << 'EOF' > '" + configPath + "'\n" + jsonStr + "\nEOF\n" +
            "cat << 'EOF' > '" + mangohudConfPath + "'\n" + mangohudConf + "\nEOF\n"
        ])
    }

    function loadConfig() {
        if (!readProc.running) {
            readProc.running = true
        }
    }

    property var readProc: Process {
        id: readProc
        command: ["sh", "-c", "cat '" + root.configPath + "' 2>/dev/null | tr '\\n' ' '"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    const parsed = JSON.parse(data.trim())
                    root.gamemodeEnabled = !!parsed.gamemode
                    root.bulldoptimizerEnabled = !!parsed.bulldoptimizer
                    root.mangohudEnabled = !!parsed.mangohud
                    root.gamescopeEnabled = !!parsed.gamescope
                    
                    if (parsed.bulldoptimizer_config) {
                        const bc = parsed.bulldoptimizer_config
                        root.boWallpaperStatic = bc.wallpaper_static !== undefined ? !!bc.wallpaper_static : true
                        root.boHyprlandEffects = bc.hyprland_effects !== undefined ? !!bc.hyprland_effects : true
                        root.boPowerMizer = !!bc.powermizer
                    }
                    
                    if (root.bulldoptimizerEnabled) {
                        root.applyBulldoptimizer(true)
                    }
                    
                    if (parsed.gamescope_config) {
                        const gc = parsed.gamescope_config
                        root.gsHdr = !!gc.hdr
                        root.gsHdrItm = !!gc.hdr_itm
                        root.gsHdrSdrNits = gc.hdr_sdr_nits !== undefined ? gc.hdr_sdr_nits : 400
                        root.gsWidth = gc.width || 2560
                        root.gsHeight = gc.height || 1440
                        root.gsRenderWidth = gc.render_width || 0
                        root.gsRenderHeight = gc.render_height || 0
                        root.gsRefreshRate = gc.refresh_rate || 240
                        root.gsFullscreen = gc.fullscreen !== undefined ? gc.fullscreen : true
                        root.gsBorderless = !!gc.borderless
                        root.gsFsr = !!gc.fsr
                        root.gsFsrSharpness = gc.fsr_sharpness !== undefined ? gc.fsr_sharpness : 2
                        root.gsScalerFilter = gc.scaler_filter || "fsr"
                        root.gsScalerType = gc.scaler_type || "fit"
                        root.gsIntegerScaling = !!gc.integer_scaling
                        root.gsAdaptiveSync = !!gc.adaptive_sync
                        root.gsFpsLimit = gc.fps_limit || 0
                        root.gsCustomArgs = gc.custom_args || ""
                    }
                    
                    if (parsed.mangohud_config) {
                        const mc = parsed.mangohud_config
                        root.mhVram = mc.vram !== undefined ? mc.vram : true
                        root.mhRam = mc.ram !== undefined ? mc.ram : true
                        root.mhGpuStats = mc.gpu_stats !== undefined ? mc.gpu_stats : true
                        root.mhGpuTemp = mc.gpu_temp !== undefined ? mc.gpu_temp : true
                        root.mhGpuCoreClock = !!mc.gpu_core_clock
                        root.mhGpuPower = !!mc.gpu_power
                        root.mhCpuStats = mc.cpu_stats !== undefined ? mc.cpu_stats : true
                        root.mhCpuTemp = mc.cpu_temp !== undefined ? mc.cpu_temp : true
                        root.mhCpuMhz = !!mc.cpu_mhz
                        root.mhCpuPower = !!mc.cpu_power
                        root.mhFps = mc.fps !== undefined ? mc.fps : true
                        root.mhFrametime = mc.frametime !== undefined ? mc.frametime : true
                        root.mhPosition = mc.position || "top-left"
                        root.mhFpsLimit = mc.fps_limit || 0
                        root.mhCompact = !!mc.hud_compact
                    }
                } catch(e) {
                    // Default values
                }
            }
        }
    }

    property var writeProc: Process {
        id: writeProc
    }

    property var hyprOptProc: Process {
        id: hyprOptProc
    }

    property var gpuOptProc: Process {
        id: gpuOptProc
    }

    Component.onCompleted: loadConfig()
}
