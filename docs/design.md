# Bulldoze 3.0 --- System-Wide Design Specification & Design System

> **Status:** authoritative visual specification\
> **Audience:** AI coding agents / Codex / future maintainers\
> **Scope:** complete visual definition, geometry, hierarchy, tokens, and implementation rules of the entire Bulldoze 3.0 desktop shell (Dynamic Islands, Floating Pills, Central Launcher, System Tray, Workspace Bar, Left Audio Bar, Notification System, OSD, Centered Lock Screen, Centered QuickShell Greeter, Hyprland, Firefox, Thunar)
> **Priority:** visual fidelity over implementation convenience

------------------------------------------------------------------------

# 1. Purpose & Conceptual Foundation

This document defines the authoritative design system specification for the **entire Bulldoze 3.0 desktop shell environment**.

Bulldoze is a cohesive, translucent, glassmorphic desktop interface composed of:
1. **Central Morphing Dynamic Top Island (`shell.qml`, `LiquidGlass.qml`, `DefaultBarView.qml`)**: A floating Dynamic Island positioned at $y = 8\text{px}$ (`islandMargin: 8`):
   - **Resting Capsule Profile**: Fixed 32px height compact pill (~170px–200px width) displaying purely the centered digital Clock and localized Date (`pt-BR`).
   - **Hover-to-Open Central Launcher**: Moving the mouse over the resting island capsule profile directly morphs it into the full Central Launcher (`LauncherBarView.qml`, 920x640px) displaying the **Home** view by default. Moving the mouse out smoothly collapses it back to the resting island.
   - **Shortcut Access**: Quick Launcher & Controls (Home, Wi-Fi, Bluetooth, Som, Wallpapers, Gaming) can also be toggled via global shortcut `Super + H` (`SUPER + H`).
2. **Top-Right Floating System Tray (`TrayBarView.qml`, `shell.qml`)**:
   - Discrete floating pill positioned at the top-right corner with 8px margins ($x = \text{screen.width} - \text{width} - 8, y = 8$).
   - **Fixed 32px Height**: Exactly matches the top island's 32px vertical profile.
   - **Responsive Width**: Dynamically calculated based on the count of active tray icons ($26 \times 26\text{px}$ tiles with $6\text{px}$ spacing and design system paddings).
   - **Hover Activation (Corner Hot Zone)**: Touching the $48 \times 48\text{px}$ top-right hot zone instantly reveals the tray view. Retracts immediately on mouse exit; remains visible while an SNI context menu is active.
   - **Zero Footprint When Empty**: When no tray icons are registered, the hot zone and panel are completely removed from Wayland `mask: Region`, remaining 100% click-through.
3. **Bottom Floating Workspace Bar (`WorkspacePills.qml`, `shell.qml`)**:
   - Discrete floating pill positioned at the bottom-center with 8px margin ($y = \text{screen.height} - 32 - 8$).
   - **Keyboard Trigger (Auto-hide 2s)**: Switching workspaces via keyboard hotkeys (`SUPER + 1..9`, navigation keys) reveals the dock for 2 seconds before smoothly retracting.
   - **Bottom Hot Zone (Hover)**: 240x24px detection area mapped to Wayland `mask: Region` on the bottom border reveals the workspace dock immediately. Stays open while cursor is inside; retracts immediately on mouse exit.
   - **Minimalist Layout**: Exclusively presents dynamic workspace pills ($22 \times 6\text{px}$ active, $6 \times 6\text{px}$ inactive dots).
4. **Left Floating Volume Bar (`AudioBarView.qml`, `shell.qml`)**:
   - Discrete floating pill positioned at the left edge with 8px margin ($x = 8, y = (\text{screen.height} - 230)/2$, $48 \times 230\text{px}$).
   - Minimalist vertical volume slider, click-to-mute icon, and gear button navigating directly to the Sound tab in Settings.
   - 2-second auto-dismiss OSD triggered by keyboard volume hotkeys.
5. **Bottom-Right Floating Notification System (`NotificationBarView.qml`, `shell.qml`)**:
   - Discrete floating pill positioned at the bottom-right corner with 8px margins ($x = \text{screen.width} - 380 - 8, y = \text{screen.height} - \text{height} - 8$).
   - **Popup OSD (2.5s)**: Incoming notifications display only the single latest card for 2.5 seconds.
   - **Corner Hot Zone**: Hovering on the bottom-right corner hot zone reveals the latest notification immediately (or empty state). Closes immediately on mouse exit.
   - **2s Dwell Expansion**: Hovering for 2 seconds expands upwards into a stacked list of up to 4 cards (BottomToTop ordering: newest at bottom, older stacked upwards) with mouse wheel scroll for >4 items.
   - **Actions**: Individual dismiss button (``) and clear-all icon button (``) at the bottom of the expanded stack.
6. **Bottom Floating Spotlight Launcher (`BottomLauncher.qml`, `shell.qml`)**:
   - Floating search island positioned at bottom center ($640 \times 480\text{px}$, $y = \text{screen.height} - 480 - 8$).
   - **Inverted Hierarchy**: Search input bar at the bottom (`ESC` badge, autofocus) and results list expanding upwards above it with compact typography (13px titles, 11px categories, 22x22 icons).
7. **Centered Floating Lock Screen (`LockScreen.qml`, `LiquidGlass.qml`)**: A floating Liquid Glass card ($680 \times 380\text{px}$) centered horizontally and vertically on the screen with backdrop blur.
8. **Centered Floating QuickShell Greeter (`greeter.qml`, `Greeter.qml`, `LiquidGlass.qml`)**: The system login screen executed by `greetd`, matching the Lock Screen's centered floating Liquid Glass card architecture ($680 \times 400\text{px}$).
9. **Gaming Settings Modal (`GamingSettingsModal.qml`)**: Centered floating glass modal ($640 \times 560\text{px}$).
10. **Wallpaper Engine Manager Modal (`WallpaperManagerModal.qml`)**: Centered floating glass modal ($920 \times 640\text{px}$).

---

## 1.1 Fundamental Rule: FLOATING DYNAMIC ISLANDS & LIQUID GLASS

- **Floating Dynamic Islands & Pills**: Shell components do **NOT attach physically to monitor bezels with concave flares**, and the full-screen 8px perimeter frame (`unifiedShape`) has been **completely removed**. The screen boundaries are 100% free and open. Every component floats as a discrete pill/island with an 8px margin (`islandMargin: 8`) from monitor edges.
- **Unified Standard Shadow**: Every component features a uniform drop shadow:
  - `shadowColor`: `#59000000` (~35% alpha black)
  - `shadowRadius`: 20
  - `shadowOffsetY`: 6
  - `shadowOffsetX`: 0
- **Liquid Glass Light Simulation**: Inspired by Apple's Liquid Glass, every pill surface incorporates:
  1. Specular top rim highlight (`glassBorderTop: "#4DFFFFFF"`): a brilliant edge light simulating light reflecting off the top curved bevel.
  2. Bottom rim highlight (`glassBorderBottom: "#14FFFFFF"`): a subtle rim light defining the lower edge.
  3. Internal diffuse highlight (`glassHighlight: "#26FFFFFF"`): an internal top gradient glow simulating internal refraction through the glass lens.
  4. Translucent glass fill: `#33000000` (Top Island, LockScreen, Greeter) / `#40000000` (Modals, cards, side/bottom pills).
  5. Backdrop blur: native compositor blur or masked MultiEffect blur.
- **Pill vs. Island Radii**:
  - Small pills, toggles, capsule bars: `radius: height / 2` (`radiusPill: 9999`).
  - Expanded islands and large modals: `radiusIsland: 28` / `radiusIslandLarge: 32`.

```text
                      SCREEN WIDTH = 100%

┌──────────────────────────────────────────────────────────────┐
│                                                              │
│                   ╭──────────────────────╮                   │
│                   │   13:45  Qui, 24 Ago │                   │ (Dynamic Top Island:
│                   ╰──────────────────────╯                   │  8px Top Margin, 32px H
│            ←── 170px IDLE / EXPANDS TO 920x640 LAUNCHER ──→  │  Pill / Dynamic Island)
│                                                              │
│                   ╭──────────────────────╮                   │
│                   │       13:45:00       │                   │ (Centered Floating
│                   │  Quinta, 24 de Ago   │                   │  LockScreen & Greeter:
│                   │                      │                   │  680x380px / 680x400px
│                   │      [ Avatar ]      │                   │  Centered in Screen)
│                   │Paulo Italo (bulldoze)│                   │
│                   │ [  Digite senha... ]│                   │
│                   │                   │                   │
│                   ╰──────────────────────╯                   │
│                                                              │
│                      ╭────────────────╮                      │
│                      │  ●  ━━━  ●  ●  │                      │ (Floating Workspaces:
│                      ╰────────────────╯                      │  8px Bottom Margin)
└──────────────────────────────────────────────────────────────┘
```

------------------------------------------------------------------------

# 2. Bulldoze 3.0 Design Philosophy

Bulldoze is explicitly NOT minimalist flat design and NOT a generic desktop theme.

The visual language is defined by the core equation:

```text
glass
+
transparency
+
blur
+
depth
+
soft geometry
+
atmosphere
+
subtle contrast
+
personality
```

### The Physical Depth Stack
```text
wallpaper → Hyprland native blur → 20%-25% translucent dark glass → subtle 1px white border (#24FFFFFF) → content
```

The wallpaper remains crisp and visible through every surface in the system. Depth is created through optical transparency and subtle edge boundaries rather than heavy drop shadows or opaque solids.

## 2.1 Forbidden Visual Directions

Do NOT introduce:
- Flat opaque surfaces (e.g. `#CC10141C`, solid dark gray, solid black);
- Saturated flat color fills for buttons or toggles (e.g. flat blue `#294EA6FF`);
- Floating waybars spanning full screen width;
- Excessive white highlights or bright top light strips;
- Neon effects or glowing borders;
- Gradients unless explicitly specified;
- Glow effects / blooms / halos;
- Fake reflections or shine rectangles;
- Borders > 1px;
- Arbitrary heavy drop shadows;
- Linear straight borders cutting across curved concave arcs.

------------------------------------------------------------------------

# 3. Global Design System Tokens (`Theme.qml`)

All components in the Bulldoze shell must consume tokens exclusively from `components/Theme.qml`.

## 3.1 Color & Surface Tokens (`#AARRGGBB`)

| Token | Value | Visual Purpose |
| :--- | :--- | :--- |
| `glassFill` | `#33000000` | ~20% alpha black (Top Island, LockScreen, Greeter) |
| `glassFillDark` | `#40000000` | ~25% alpha black (Side pills, bottom launcher, cards, modals, popups, toasts) |
| `glassBorder` | `#24FFFFFF` | ~14% alpha white (Subtle 1px perimeter glass boundary) |
| `glassBorderTop` | `#4DFFFFFF` | ~30% alpha white (Liquid Glass specular top rim light highlight) |
| `glassBorderBottom` | `#14FFFFFF` | ~8% alpha white (Liquid Glass subtle bottom rim highlight) |
| `glassHighlight` | `#26FFFFFF` | ~15% alpha white (Liquid Glass internal diffuse refraction glow) |
| `glassBorderSubtle` | `#18FFFFFF` | ~9% alpha white (Inner item borders, tile outlines) |
| `glassBorderStrong` | `#36FFFFFF` | ~21% alpha white (Hovered, focused, or active borders) |
| `shadowColor` | `#59000000` | ~35% alpha black (Unified standard drop shadow) |
| `itemFill` | `#10FFFFFF` | ~6% alpha white (Inactive toggle / button container) |
| `hoverFill` | `#1CFFFFFF` | ~11% alpha white (Hover interaction feedback) |
| `activeFill` | `#33FFFFFF` | ~20% alpha white (Active toggle / selected pill) |
| `separator` | `#1AFFFFFF` | ~10% alpha white (1px horizontal or vertical divider) |
| `accent` | `#FFFFFF` | White highlight for indicators, focus rings, and spinners |

## 3.2 Typography & Contrast Tokens

| Token | Value | Usage |
| :--- | :--- | :--- |
| `textStrong` | `#F2FFFFFF` | 95% white (Titles, clock time, modal headers, active icons) |
| `textMedium` | `#DFFFFFFF` | 87% white (Body text, active workspaces, primary labels) |
| `textMuted` | `#BFFFFFFF` | 75% white (Dates, metadata, subtitles, inactive icons) |
| `textSubtle` | `#80FFFFFF` | 50% white (Search placeholders, hints) |
| `indicatorInactive`| `#66FFFFFF` | 40% white (Inactive workspace dots, toggle status) |

### Font Size Scale
- `fontSizeXs: 11px` --- Micro metadata, date, notification app name.
- `fontSizeSm: 12px` --- Secondary body, button labels, battery footer.
- `fontSizeMd: 13px` --- Clock time, quick toggle labels, primary body.
- `fontSizeLg: 15px` --- Launcher application names, list item titles.
- `fontSizeXl: 18px` --- Card headers, power menu icons, section titles.
- `fontSizeTitle: 20px` --- Modal titles, launcher search input.
- `fontSizeSubmenuTitle: 15px` --- Bold titles in active submenus.
- `fontSizeSubmenuBody: 12px` --- High-legibility subtitles in active submenus.

## 3.3 Geometry & Radii Scale

- `radiusSmall: 6px` --- Micro tags, progress bar tracks, button corners.
- `radiusPill: 9999px` --- Full capsule rounding for compact pills, buttons, toggles (`height / 2`).
- `radiusItem: 12px` --- Buttons, list rows, toggle tiles, avatar masks, Hyprland window rounding.
- `radiusCard: 18px` --- Floating cards, Control Center.
- `radiusModal: 22px` --- Modals, Wallpaper Manager, Gaming Settings.
- `radiusIsland: 28px` --- Dynamic Island expanded panels (Central Launcher, bottom search).
- `radiusIslandLarge: 32px` --- Centered LockScreen and Greeter floating cards.
- `islandMargin: 8px` --- Standard floating clearance margin from monitor boundaries.
- `shadowRadius: 20px` --- Blur radius of the unified drop shadow.
- `shadowOffsetY: 6px` --- Vertical offset of the unified drop shadow (`shadowOffsetX: 0px`).
- `topIslandCollapsedWidth: 170px-200px` --- Idle top island capsule width (clock + date).
- `topIslandExpandedWidth: 920px` --- Central Launcher width.
- `topIslandHeight: 32px` --- Fixed single-line top island resting height.
- `audioBarWidth: 48px`, `audioBarHeight: 230px` --- Left-docked vertical volume pill.
- `notifWidth: 380px`, `notifCollapsedHeight: 64px`, `notifExpandedHeight: 96px-270px` --- Floating notification panel (1 to 4 items).

## 3.4 Spacing, Hyprland & Padding Scale

- `gaps_in: 8px` --- Internal spacing between tiled windows in Hyprland.
- `gaps_out: { top: 56px, right: 16px, bottom: 16px, left: 16px }` --- Hyprland authoritative outer window margins (calibrated with 8px top margin + 32px island height + 16px clearance gap to windows, ensuring uniform 16px wallpaper breathing space around all windows without overlap).
- `rounding: 12px` --- Hyprland window rounding harmonizing with `radiusItem`.
- `decoration.shadow`: Enabled in Hyprland (`range: 20`, `color: "rgba(00000059)"`, `offset: "0 6"`), exactly matching the shell's standard shadow.
- `border_size: 0px` --- Window borders removed in favor of the glassmorphic shell aesthetic.
- `spacingXs: 4px`, `spacingSm: 8px`, `spacingMd: 12px`, `spacingLg: 16px`, `spacingXl: 20px`, `spacingXxl: 24px`.
- `contentInset: 18px` (horizontal inset inside the top island).
- `groupSpacing: 12px` (gap between left groups).
- `statusSpacing: 12px` (gap between status buttons).
- `workspaceSpacing: 6px` (gap between workspace indicators).

## 3.5 Motion & Animation Tokens (Calibrated for 240Hz High Refresh Rate)

Bulldoze motion design implements organic, tactile, and responsive micro-interactions calibrated for **high refresh rate displays (240Hz)**:
- **High-Rate Fluidity**: At 240Hz (frame interval $\approx 4.16\text{ms}$), animations render across 60–90 distinct sub-frame steps, delivering seamless physical inertia without stutter.
- **Sticky Elastic Spring ("Pegajoso")**: Entrances and expansions use `Easing.OutBack` with overshoot tokens (`stickyOvershoot: 1.15`, `buttonOvershoot: 1.30`, LockScreen/Greeter overshoot: `1.25`) giving UI panels a tactile, organic landing feeling.
- **Zero Heavy Render Passes**: Only `opacity`, local `Translate` (`x`, `y`), and `scale` transitions.
- **Static Blur**: Blur is provided exclusively by Hyprland (`bulldoze-*` namespaces) and `LiquidGlass.qml` backdrop sampling. Blur radius is never dynamically animated in QML.
- **Asymmetric Motion**: Entrances use gentle elastic easing (`Easing.OutBack` / `Easing.OutCubic`) for perceived responsiveness and smoothness; exits are faster with direct decay (`Easing.InCubic` / `Easing.InQuad`).

| Token | Duration | Easing Curve | Application |
| :--- | :---: | :---: | :--- |
| `animDurationMicro` | **120ms** | `Easing.OutCubic` | Micro-flash, ripple feedback (~30 frames @ 240Hz). |
| `animDurationFast` | **180ms** | `Easing.OutCubic` | Hover states, button press scaling, switch toggling (~45 frames @ 240Hz). |
| `animDurationNormal` | **260ms** | `Easing.OutCubic` | Workspace pill morphing, OSD bar fill (~65 frames @ 240Hz). |
| `animDurationSticky` | **320ms** | `Easing.OutBack` (overshoot 1.15) | Floating side pill panels, toast entrances, card transitions (~75 frames @ 240Hz). |
| `animDurationSlow` | **360ms** | `Easing.OutCubic` | Launcher modal, lockscreen intro sequences (~85 frames @ 240Hz). |
| `animDurationExit` | **200ms** | `Easing.InCubic` / `InQuad` | Snappy closing / exit transitions (~50 frames @ 240Hz). |
| `notchExpandDuration`| **340ms** | `Easing.OutBack` (overshoot 1.15) | Dynamic island hover expansion. |
| `notchCollapseDuration`| **240ms**| `Easing.InOutCubic` | Smooth island collapse when mouse leaves. |
| `stickyOvershoot` | **1.15** | --- | Elastic bounce coefficient for floating panels. |
| `buttonOvershoot` | **1.30** | --- | Tactile pop factor for interactive icons. |

------------------------------------------------------------------------

# # 4. Component Specifications

## 4.1 Top Shell / Dynamic Central Glass Island (`shell.qml`, `LiquidGlass.qml`, `DefaultBarView.qml`)
- **Floating Dynamic Island**: Positioned at $y = 8\text{px}$ (`islandMargin: 8`), floating completely detached from the top monitor bezel.
- **Streamlined Minimalist Profile**:
  - **Fixed 32px Height**: Ultra-clean single row of 32px fixed height in resting idle state.
  - **Collapsed State (Idle)**: Compact pill ($170\text{px} \times 32\text{px}$) displaying strictly the central Clock and localized Date (`pt-BR`).
  - **Direct Morphing (Hover & Hotspot)**: Moving the cursor over the resting island capsule directly triggers the Central Launcher (`LauncherBarView.qml`, 920x640px) with the **Home** tab open. No intermediate expanded bar state exists.
  - **Exit Behavior**: Moving the mouse outside the Central Launcher collapses it back into the resting capsule (or via `SUPER + H`).
- **Content Encapsulation**:
  - **Center (always visible)**: Single-line Clock (Time 13px DemiBold + Date 11px Medium localized in `pt-BR`, format `"ddd, dd MMM"` via `Qt.locale("pt_BR")`).
  - **Redundant Items Consolidated**: Gaming mode toggles and power/profile controls are consolidated into the Central Launcher (Home & Gaming tabs), eliminating status buttons from the top island for maximum visual clarity.

## 4.2 Bottom Floating Minimalist Workspace Bar (`WorkspacePills.qml`, `shell.qml`)
- **Discrete Floating Pill**:
  - Positioned at bottom center with 8px margin ($y = \text{screen.height} - 32 - 8$).
  - Built with `LiquidGlass.qml` wrapped in `BottomGlassPanel.qml`, floating free of the bottom monitor bezel.
- **Geometrical Profile**:
  - **Fixed 32px Height**: Exactly matches the top island's 32px vertical height for visual rhythm and harmony.
  - **Responsive Width**: Dynamically calculated based on the count of active workspaces (`workspaceCount`), with 18px lateral content inset padding (`theme.contentInset`).
- **Interaction Model**:
  - **Keyboard Command Trigger**: Every workspace switch event from Hyprland triggers a 2-second temporary reveal (`showWorkspaceBar(2000)`).
  - **Bottom Hot Zone (Hover)**: Cursor touching the 240x24px bottom center hot zone (registered in `mask: Region`) reveals the dock immediately with no auto-close timeout.
  - **Hover Persistence**: Stays open while cursor is inside; closes immediately when cursor leaves the area.
  - **Spotlight Coexistence**: Closes instantly when Spotlight (`SUPER + D`) opens; switching workspaces while Spotlight is open closes Spotlight and shows the workspace bar for 2 seconds.

## 4.3 Application Launcher (`BottomLauncher.qml`, `shell.qml`)
- **Type**: Floating search island positioned at bottom center ($640 \times 480\text{px}$, $y = \text{screen.height} - 480 - 8$).
- **Inverted Hierarchy**: Search input bar at the bottom (`ESC` badge, autofocus) and results list expanding upwards above it with compact typography (13px titles, 11px categories, 22x22 icons).
- **Liquid Glass Geometry**: Encapsulated in `LiquidGlass.qml` with `radiusIsland` (28px), standard shadow, specular top highlight, and background blur.

## 4.4 Central Launcher / System Hub (`LauncherBarView.qml`)
- **Central Launcher View (`LauncherBarView.qml`, 920x640px)**:
  - Accessible via hovering the resting closed island or global shortcut `Super + H` (`SUPER + H`).
  - **Top Centered Horizontal Category Rail**: Centered horizontal row of 6 category icons (Home, Wi-Fi, Bluetooth, Som, Wallpapers, Gaming) independent of scroll, providing 100% full width to the content area below. Default landing category is **Home**.
  - **Home Tab (`Início`)**:
    - **Top Full-Width Welcome Card**:
      - 180px height banner with rounded top corners matching the welcome card (`radius: theme.radiusItem`), masked with MultiEffect to contain blur cleanly.
      - Reactive reload on wallpaper changes (`wpVersion` / `snapshotVersion`) pointing to `~/.cache/bulldoze/Wallpaper_greeter.png`.
      - **Enquadramento / Crop Adjustment**: Top-left pen button (``) opens a popover with a vertical slider (0% to 100%, default 0% showing the top/beginning of the wallpaper), persisted in `~/.config/bulldoze/banner_crop.json`.
      - Discrete top-right privacy eye toggle (`""` / `""`).
      - 80x80px circular user avatar centered horizontally and overlapping the bottom border of the banner with 3px glass border.
      - Single-line contextual greeting (with Unicode emojis: ☀️, 🌇, 🌙, 💤) addressing the user's `displayName`. When streamer privacy mode is enabled, `displayName` is smoothly blurred alongside `@hostName`.
    - **Full-Width Stacked Sections (100% Width)**:
      - **Data, Hora e Calendário**: High-contrast digital clock time (48px Bold), prominent day of the week badge, full Portuguese date, and a complete monthly calendar with pure white circular highlight for the current day.
      - **Central de Jogos & Performance**: Single horizontal row spanning 100% width with 4 shortcut tiles for **GameMode** (``), **Bulldoptimizer** (``), **MangoHud** (``), and **Gamescope** (``), featuring tactile hover scaling and active indicator dots.
    - **Fixed Bottom Power & System Info Bar**:
      - Left: OS Name & Icon (`` Arch Linux), Linux Kernel version (``), and System uptime (``).
      - Right: Action buttons for Bloquear (``), Encerrar Sessão (``), Reiniciar (``), e Desligar (``).
      - Interactive confirmation modal overlay protecting against accidental session termination, reboots, or shutdowns.
  - **Sound Tab (`Som`)**: Full PipeWire audio manager with horizontal volume slider, real-time percentage, mute toggle, and interactive list of all audio sinks (Speakers, HDMI, Bluetooth headphones) with instant switching via `wpctl set-default <id>`.
  - **Wi-Fi & Bluetooth Tabs**: Complete network scanner, connection manager, and power controls.
  - **Gaming Tab (`Jogos`)**: Full gaming profile settings, Bulldoptimizer tweaks, and performance diagnostics.

## 4.5 Left Floating Volume Bar (`AudioBarView.qml`, `shell.qml`)
- **Discrete Floating Pill**: Positioned on the left side with 8px margin ($x = 8, y = (\text{screen.height} - 230)/2$, $48 \times 230\text{px}$), floating free of screen edges.
- **Vertical Minimalist Controls**:
  - Top: Interactive volume icon with click-to-mute.
  - Middle: Sleek vertical slider for precise volume control.
  - Bottom: Gear button (``) opening directly into the Sound tab of the Settings modal.
- **Auto-Dismiss OSD**: Automatically displays for 2 seconds on volume key presses (`raiseVolume`, `lowerVolume`, `toggleMute`), with timer paused on mouse hover.

## 4.6 Bottom-Right Floating Notification System (`NotificationBarView.qml`, `shell.qml`)
- **Discrete Floating Pill**:
  - Positioned at the bottom-right corner with 8px margin ($x = \text{screen.width} - 380 - 8, y = \text{screen.height} - \text{height} - 8$).
  - Floating Liquid Glass container with standard shadow and specular highlights.
- **Popup OSD (2.5s Auto-Dismiss)**:
  - Incoming alerts display only the single latest notification card for 2.5 seconds before smoothly retracting.
- **Corner Hot Zone Trigger**:
  - Hovering over the bottom-right corner hot zone instantly reveals the latest notification (or *"Nenhuma notificação"* empty state).
  - Closes immediately when the mouse leaves the area.
- **2-Second Dwell Expansion**:
  - Holding the mouse over the notification card for 2 seconds expands the view vertically upwards into a stacked list of up to 4 notifications ($380 \times 96\text{px}$ to $380 \times 270\text{px}$).
- **Stack Ordering & Mouse Scroll**:
  - **BottomToTop Layout**: The newest notification is positioned at the bottom; older alerts stack upwards.
  - For stacks greater than 4 items, native mouse wheel scrolling navigates older alerts smoothly.
- **Actions & Discard**:
  - Individual dismiss button (``) on each card.
  - Clear-all icon button (``) located at the bottom of the stack, visible strictly when expanded.
  - Clean card typography: app icon, app name with timestamp, bold summary, and body text.

## 4.7 Top-Right Floating System Tray (`TrayBarView.qml`, `shell.qml`)
- **Discrete Floating Pill**:
  - Positioned at the top-right corner with 8px margin ($x = \text{screen.width} - \text{width} - 8, y = 8$).
  - Fixed 32px height, matching the central top island and workspace bar.
  - Built with `LiquidGlass.qml` wrapped in `SideGlassPanel.qml` with standard shadow.
- **Responsive Width**:
  - Dynamically calculated based on the count of active StatusNotifierItem (SNI) icons: $N \times 26\text{px} + (N-1) \times 6\text{px} + 16\text{px}$ insets (minimum 48px).
- **Interactive Tiles**:
  - Each item container is a $26 \times 26\text{px}$ tile (`radiusSmall`: 6px) with tactile hover feedback (`hoverFill`, `scale: 1.15`), $16 \times 16\text{px}$ icon, and click animations.
- **Mouse Interactions & SNI Context Menus**:
  - Left click activates the application (`modelData.activate()`).
  - Right click opens the DBus/SNI context menu (`QsMenuAnchor`) or secondary activate.
  - While a context menu is open, the view remains pinned and open.
- **Instant Hover Exit & Click-Through**:
  - Disappears immediately upon mouse exit (unless a context menu is open).
  - When no tray icons exist (`count === 0`), the hot zone and view are excluded from the Wayland `mask: Region`, leaving the desktop area completely click-through to underlying application windows.

## 4.8 On-Screen Display / OSD (`Osd.qml`, `BottomGlassPanel.qml`)
- **Type**: Centered floating glass pill ($300 \times 74\text{px}$) with 8px bottom margin (`margins.bottom: 8`).
- **Layer Namespace**: `"bulldoze-osd"`.
- **Surface Geometry**: Floating capsule (`radiusPill: 9999` / `height / 2`), Liquid Glass lighting, and standard drop shadow.
- **Motion**: Sticky vertical slide-up ($y: 28 \to 0$) + scale ($0.90 \to 1.0$) with `animDurationSticky` (320ms), `Easing.OutBack` (overshoot 1.15) on entry and `animDurationExit` (200ms) on dismiss.

## 4.9 File Manager / Dolphin & Thunar (`KDE / GTK Integration`)
- **Physical Depth Stack**: Wallpaper → Hyprland native blur → 20%-25% translucent dark glass → 1px glass border (`rgba(ffffff24)`) → content.
- **Thunar / GTK3 Integration (`~/.config/gtk-3.0/gtk.css`)**:
  - Window rounding: 12px.
  - Toolbar, navigation, and action buttons: pill shapes (`border-radius: 9999px`) with subtle shadow (`box-shadow: 0 4px 14px rgba(0, 0, 0, 0.35)`).
  - Notebook tabs: rounded top corners (`12px 12px 0 0`).

## 4.10 Web Browser / Firefox (`userChrome.css Integration`)
- **Physical Depth Stack**: Wallpaper → Hyprland compositor blur → translucent dark glass (`--bulldoze-glass-fill`: `rgba(14, 16, 22, 0.40)`) → Liquid Glass border (`--bulldoze-glass-border-top`, `--bulldoze-glass-border-bottom`).
- **Tab & Vertical Tab Selection System (`#tabbrowser-tabs[orient="vertical"]`, `#vertical-tabs`)**:
  - **Selected / Active Tab Pill**: Full conformance with Bulldoze Liquid Glass selection standard:
    - Background: `activeFill` (`rgba(255, 255, 255, 0.18)` / `--bulldoze-active-fill`).
    - Outer Boundary: Continuous 1px subtle white stroke `glassBorderStrong` with top rim highlight and inset top refraction glow (`box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.15), 0 6px 20px rgba(0, 0, 0, 0.35)`).
    - Geometry: `border-radius: 9999px` (full pill shape) preserving symmetric margins and padding.
    - Typography: `textStrong` (`rgba(255, 255, 255, 0.95)`), `font-weight: 600`.
  - **URL Bar**: Rounded pill (`border-radius: 9999px`), standard shadow, and top specular glow.

## 4.11 Lock Screen (`LockScreen.qml`, `LiquidGlass.qml`)
- **Type**: Wayland Session Lock (`WlSessionLock` & `WlSessionLockSurface`, `ext-session-lock-v1`).
- **Surface Transparency & 100% Natural Wallpaper Fidelity**:
  - `WlSessionLockSurface.color` is strictly `"transparent"`.
  - **Zero Background Darkening Veil**: Strictly zero full-screen darkening overlays (`#30000000` or similar). The background wallpaper is displayed with 100% of its natural saturation, brightness, and sharpness identical to the logged-in desktop session.
  - Dynamic image buffer refresh (`bgImage.source`) on `onLockedChanged` to ensure instant visual parity when wallpapers change.
- **Centered Floating Liquid Glass Card Architecture**:
  - The authentication card ($680 \times 380\text{px}$) floats centered vertically and horizontally on the screen (`anchors.centerIn: parent`).
  - Perimeter frame and top bezel attachment are completely removed.
  - Card-level backdrop blur container with `radiusIslandLarge` (32px).
  - Enclosed in `LiquidGlass.qml` with standard shadow (`shadowEnabled: true`, radius 20, offset Y 6) and specular rim highlights.
- **Continuity Motion & Expansion**:
  - Expands smoothly with `Easing.OutBack` (overshoot 1.25, duration 380ms) triggered deterministically via `onLockedChanged`.
  - On successful PAM authentication, collapses smoothly before unlocking the session.
- **Integrated Header Typography**:
  - Large time (52px Bold) + Full localized Brazilian Portuguese date (14px Medium) integrated inside the upper header of the card, unified with `Clock.qml` and `Greeter.qml`.
- **Identity & Password**:
  - Masked Avatar (`MultiEffect` mask with `radiusItem`: 12px) + Display Name (`textStrong`, 15px) + Hostname (`textMuted`).
  - Password Input: Pill container (`radiusItem`, `itemFill`, 1px `glassBorderSubtle`), password echo mode, visibility toggle (`""`/`""`), submit button, and PAM horizontal shake animation upon invalid attempt.
- **Integrated Power Actions**: Icon-only action tiles ($36 \times 36\text{px}$) for Suspender (`systemctl suspend`), Reiniciar (`systemctl reboot`), Desligar (`systemctl poweroff`) with tactile hover scaling (`buttonOvershoot: 1.30`) and upward tooltip tags in `pt-BR`.

## 4.12 QuickShell Greeter / Login Screen (`greeter.qml`, `Greeter.qml`, `LiquidGlass.qml`)
- **Type**: Display Manager / Greeter Session for `greetd` (`WlrLayer.Overlay`, `WlrKeyboardFocus.Exclusive`, `quickshell -p /etc/greetd/bulldoze-greeter`).
- **Layer Namespace**: `"bulldoze-greeter"`.
- **Surface Transparency & 100% Natural Wallpaper Fidelity**:
  - `PanelWindow.color` is strictly `"transparent"`.
  - **Zero Background Darkening Veil**: Strictly zero full-screen darkening overlays (`#30000000` or similar). Displays the native wallpaper of `/var/lib/greetd/Wallpaper_greeter.png`.
- **Centered Floating Liquid Glass Card Architecture**:
  - High-fidelity login card ($680 \times 400\text{px}$) floats centered vertically and horizontally on the screen (`anchors.centerIn: parent`), fully unified with the Lock Screen design language.
  - Perimeter frame removed completely; card-level backdrop blur container with `radiusIslandLarge` (32px).
  - Enclosed in `LiquidGlass.qml` with standard shadow and specular highlights.
- **240Hz Dynamic Intro & Exit Motion**:
  - Intro expansion on startup with `Easing.OutBack` (overshoot 1.25, 380ms) and collapses smoothly on login success.
- **Identity & Multi-User Switcher**:
  - Masked avatar ($52 \times 52\text{px}$, `MultiEffect` mask with `radiusItem: 12px`, 1px `glassBorder`) with AccountsService / `~/.face` sync.
  - Interactive user switcher dropdown for switching between system accounts.
  - Display Name (`textStrong`, 15px DemiBold) + Host Name (`textMuted`, 12px).
- **Session Selector Pill**:
  - Glass pill showing active session icon and name, prioritizing standard ` Hyprland` as default first option (`index 0`).
  - Translucent popup dropdown menu (`glassFillDark`, `radiusItem: 12px`, anchored below pill) listing all detected Wayland sessions (`/usr/share/wayland-sessions`).
- **Password Input & Feedback**:
  - Pill container with lock icon `""`, text input, eye visibility toggle (`""` / `""`), submit button (`""`), and loading spinner (`""`).
  - Horizontal shake animation (`shakeAnim`, 5-phase oscillation) and error message display on invalid credentials.
- **Integrated Power Actions**: Icon-only action tiles ($36 \times 36\text{px}$) for Suspender, Reiniciar, and Desligar with upward tooltip reveal tags in `pt-BR`.
- **Backend IPC Client (`scripts/greetd-client.py`)**: Python-based JSON-RPC client communicating over `$GREETD_SOCK`.
- **Automated Full-Package Deployment (`scripts/install-greeter.sh`)**:
  - Copies all `components/*` (including `LiquidGlass.qml`) and `modules/*` to `/etc/greetd/bulldoze-greeter/` with permissions `root:greeter` (755).
  - Configures `/usr/local/bin/bulldoze-greeter-start` to invoke wallpaper setup and `quickshell -p /etc/greetd/bulldoze-greeter`.

------------------------------------------------------------------------

# 5. Compositor Blur Integration (Hyprland)

Blur is provided natively by Hyprland to all Bulldoze surfaces through the Wayland layer shell namespace pattern:

```lua
-- ~/.config/hypr/hyprland.lua
hl.layer_rule({
    match = {
        namespace = "bulldoze-.*",
    },
    blur = true,
    ignore_alpha = 0.1,
})
```

All windows define their matching layer namespace:
- `bulldoze-bar`
- `bulldoze-backdrop`
- `bulldoze-launcher`
- `bulldoze-gaming-settings`
- `bulldoze-wallpaper-manager`
- `bulldoze-control-center`
- `bulldoze-power`
- `bulldoze-notifications`
- `bulldoze-osd`
- `bulldoze-greeter`

------------------------------------------------------------------------

# 6. Acceptance & Quality Criteria

1. **System-wide Consistency**: All components consume colors, metrics, and radii strictly from `Theme.qml`.
2. **Zero Opaque Solids**: No solid dark/blue fills; every surface is translucent glass (`#33000000` / `#40000000`) with native Hyprland blur.
3. **1px Glass Boundaries**: All borders are exactly 1px subtle white strokes (`#24FFFFFF` / `#18FFFFFF` / `#36FFFFFF`).
4. **Floating Dynamic Islands & Centered Cards**: Top Island, Tray, Workspaces, Audio, Notifications, and OSD float with 8px margin (`islandMargin: 8`). LockScreen and Greeter are centered floating cards.
5. **Liquid Glass & Unified Standard Shadow**: Every surface implements Apple-style specular top rim highlight (`glassBorderTop`), bottom rim (`glassBorderBottom`), internal specular diffuse reflection (`glassHighlight`), and unified drop shadow (`#59000000`, radius 20, offset Y 6).
6. **Screen Boundary Freedom**: 100% free perimeter with zero frame and zero concave bezel curves.
7. **Clean QML Code**: 0 syntax errors, 0 `qmllint` warnings.
8. **Localization (pt-BR)**: 100% of text strings, dates, times, modal headers, action labels, placeholders, and tooltips across the entire QuickShell / Bulldoze environment MUST strictly be in Brazilian Portuguese (`pt-BR`). Dates must explicitly consume `Qt.locale("pt_BR")` (e.g. `clock.date.toLocaleDateString(Qt.locale("pt_BR"), ...)`).

