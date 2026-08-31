# Bulldoze 3.0 --- System-Wide Design Specification & Design System

> **Status:** authoritative visual specification\
> **Audience:** AI coding agents / Codex / future maintainers\
> **Scope:** complete visual definition, geometry, hierarchy, tokens, and implementation rules of the entire Bulldoze 3.0 desktop shell (Dynamic Top Notch Bar, Launcher, Control Center, Power Menu, Notification Bar View, OSD, Top-Docked Lock Screen, Top-Docked QuickShell Greeter, Dolphin File Manager)
> **Priority:** visual fidelity over implementation convenience

------------------------------------------------------------------------

# 1. Purpose & Conceptual Foundation

This document defines the authoritative design system specification for the **entire Bulldoze 3.0 desktop shell environment**.

Bulldoze is a cohesive, translucent, glassmorphic desktop interface composed of:
1. **Central Morphing Top Notch (Dynamic Island Shell)**: An integrated physical glass notch attached to the top monitor bezel ($y = 0$) with dynamic parametric morphing:
   - **Default Resting State**: Minimalist 32px height capsule with centered Clock/Date locked to physical horizontal center.
   - **2-Level Hover Expansion (64px)**: Top row perfectly balanced (Left: Bulldoze Spotlight Logo + Workspaces; Center: Clock/Date; Right: System Tray + Notifications + User Avatar), and Bottom row centered with Quick Controls (Wi-Fi, Bluetooth, Audio, Gaming).
   - **Segmented Control Modes**: Direct morphing into dedicated views for Wi-Fi, Bluetooth, Unified Audio, Gaming Hub, Integrated Notification View, and Unified Profile & Power Menu.
   - **Integrated Notification Stack (FILO)**: Incoming notifications trigger the top notch bar (520x82px) with a 5-second inactivity timer.
2. **Bottom-Docked Morphing Spotlight Launcher (`BottomLauncher.qml`, `shell.qml`)**:
   - An inverted search dock physically fused to the 8px bottom perimeter frame ($640 \times 480\text{px}$) emerging from the bottom bezel ($y = \text{height}$).
   - **Inverted Hierarchy**: Search input bar at the bottom bezel (`ESC` badge, autofocus) and results list expanding upwards above it with compact typography (13px titles, 11px categories, 22x22 icons).
   - **Unified Glass Geometry**: Fused into `unifiedShape` with single-pass background blur (`frameBlurContainer`) and concave wings.
3. **Top-Docked Morphing Lock Screen (`LockScreen.qml`, `GlassPanel.qml`)**: A continuous, top-docked physical glass notch ($680 \times 380\text{px}$) expanding smoothly downwards from the top notch bar on lock.
4. **Top-Docked QuickShell Greeter (`greeter.qml`, `Greeter.qml`, `GlassPanel.qml`)**: The system login screen executed by `greetd`, matching the Lock Screen's top-docked dynamic notch architecture ($680 \times 400\text{px}$) with 8px perimeter frame.
5. **Gaming Settings Modal (`GamingSettingsModal.qml`)**: Centered floating glass modal ($640 \times 560\text{px}$).
6. **Wallpaper Engine Manager Modal (`WallpaperManagerModal.qml`)**: Centered floating glass modal ($920 \times 640\text{px}$).

---

## 1.1 Fundamental Rule: BEZEL-DOCKED NOTCHES & NOT FLAT OPAQUE

- **Top Bar & Notches**: The shell components do **NOT float arbitrarily as detached rectangular cards**, and do **NOT span full screen width like traditional bars**. They physically attach to the screen bezels (Top, Right, and Bottom) utilizing concave corner flare arcs (`notchConcaveWidth: 16px`, `notchConcaveHeight: 10px`, `notchTopRadius: 12px`) and convex desktop corners (`notchBottomRadius: 14px`).
- **Modals & Overlays**: All overlays and menus are **NOT flat opaque gray/blue cards** (`#10141C`) and do **NOT use bright flat accent fills** (`#294EA6FF`). Every surface in the system is translucent glass backed by native compositor blur.
- **Component-Level Blur**: Blur is applied strictly to the glass components themselves via Hyprland layer shell rules and `GlassPanel.qml` masked sampling, eliminating obsolete background screenshot blurring scripts.

```text
                      SCREEN WIDTH = 100%

┌──────────────────────────────────────────────────────────────┐
│                                                              │
│         ╭──────────────────────────────────────────╮         │
│         │    ● ━━━ ●     13:45        (󰊠)   │         │ (Morphing Top Notch Bar:
│         ╰──────────────────────────────────────────╯         │  36px Idle → 42px Hover
│          ←── 160px IDLE / EXPANDS TO 680px SUBVIEWS ──→      │  → 48px Subviews)
│                                                              │
│         ╭──────────────────────────────────────────╮         │
│         │              13:45:00                    │         │
│         │     Quinta-feira, 24 de Agosto           │         │ (Top-Docked Morphing
│         │                                          │         │  LockScreen & Greeter:
│         │             [ Avatar ]                   │         │  680x380px / 680x400px
│         │          Paulo Italo (bulldoze)          │         │  Attached to Top Bezel)
│         │         [   Digite a senha... ]         │         │
│         │                                       │         │
│         ╰──────────────────────────────────────────╯         │
│                                                              │
│                    ╭────────────────────╮                    │
│                    │  Áudio [ ━━━━●━━ ]│                    │ (Bottom OSD Capsule:
│                    ╰────────────────────╯                    │  Secondary Indicators)
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
| `glassFill` | `#33000000` | ~20% alpha black (Top notch bar, LockScreen, Greeter) |
| `glassFillDark` | `#40000000` | ~25% alpha black (Side notches, bottom notch, cards, modals, popups, toasts) |
| `glassBorder` | `#24FFFFFF` | ~14% alpha white (Subtle 1px outer glass boundary along exposed contours) |
| `glassBorderSubtle` | `#18FFFFFF` | ~9% alpha white (Inner item borders, tile outlines) |
| `glassBorderStrong` | `#36FFFFFF` | ~21% alpha white (Hovered, focused, or active borders) |
| `itemFill` | `#10FFFFFF` | ~6% alpha white (Inactive toggle / button container) |
| `hoverFill` | `#1CFFFFFF` | ~11% alpha white (Hover interaction feedback) |
| `activeFill` | `#33FFFFFF` | ~20% alpha white (Active toggle / selected pill) |
| `separator` | `#1AFFFFFF` | ~10% alpha white (1px horizontal or vertical divider) |
| `accent` | `#5294E2` | Accent blue for indicators, focus rings, and spinners |

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
- `radiusPill: 6px` --- Dynamic workspace pills.
- `radiusItem: 12px` --- Buttons, list rows, toggle tiles, avatar masks.
- `radiusCard: 18px` --- Floating cards, Control Center.
- `radiusModal: 22px` --- Launcher modal, Wallpaper Manager, Gaming Settings.
- `borderThickness: 8px` --- Full 360° screen glass perimeter frame thickness (flush to physical monitor bezels).
- `innerRadius: 8px` --- Tangent cubic bezier rounded corners on the inner frame boundary (aligns with Hyprland window rounding: 8px).
- `notchConcaveWidth: 16px` --- Horizontal extent of the concave cubic bezier transition curve.
- `notchConcaveHeight: 10px` --- Vertical drop of the concave cubic bezier transition curve.
- `notchBottomRadius: 14px` --- Convex rounded corners exposed to desktop.
- `notchHeight: 32px` --- Idle closed notch bar height (resting state).
- `notchHoverHeight: 48px` --- Expanded hover bar height (reveals quick action items).
- `notchExpandedHeight: 60px` --- Height during active submenu modes (Wi-Fi, Bluetooth, Audio, Gaming, Power, Notifs).
- `notchCollapsedWidth: 170px-200px` --- Idle capsule width displaying clock and date (dynamically computed via clock implicitWidth + insets).
- `notchExpandedWidth: 680px` --- Expanded bar width and LockScreen/Greeter width.

## 3.4 Spacing, Hyprland & Padding Scale

- `gaps_in: 8px` --- Internal spacing between tiled windows in Hyprland.
- `gaps_out: { top: 40px, right: 24px, bottom: 24px, left: 24px }` --- Hyprland authoritative outer window margins (24px side/bottom margins providing desktop wallpaper breathing space around the 8px glass frame; 40px top gap ensuring 32px closed notch + 8px inner margin).
- `border_size: 0px` --- Window borders removed in favor of the glassmorphic shell aesthetic.
- `spacingXs: 4px`, `spacingSm: 8px`, `spacingMd: 12px`, `spacingLg: 16px`, `spacingXl: 20px`, `spacingXxl: 24px`.
- `contentInset: 18px` (horizontal inset inside the top notch).
- `groupSpacing: 12px` (gap between left groups).
- `statusSpacing: 12px` (gap between status buttons).
- `workspaceSpacing: 6px` (gap between workspace indicators).

## 3.5 Motion & Animation Tokens (Calibrated for 240Hz High Refresh Rate)

Bulldoze motion design implements organic, tactile, and responsive micro-interactions calibrated for **high refresh rate displays (240Hz)**:
- **High-Rate Fluidity**: At 240Hz (frame interval $\approx 4.16\text{ms}$), animations render across 60–90 distinct sub-frame steps, delivering seamless physical inertia without stutter.
- **Sticky Elastic Spring ("Pegajoso")**: Entrances and expansions use `Easing.OutBack` with overshoot tokens (`stickyOvershoot: 1.15`, `buttonOvershoot: 1.30`, LockScreen/Greeter overshoot: `1.25`) giving UI panels a tactile, organic landing feeling.
- **Zero Heavy Render Passes**: Only `opacity`, local `Translate` (`x`, `y`), and `scale` transitions.
- **Static Blur**: Blur is provided exclusively by Hyprland (`bulldoze-*` namespaces) and `GlassPanel.qml` backdrop sampling. Blur radius is never dynamically animated in QML.
- **Asymmetric Motion**: Entrances use gentle elastic easing (`Easing.OutBack` / `Easing.OutCubic`) for perceived responsiveness and smoothness; exits are faster with direct decay (`Easing.InCubic` / `Easing.InQuad`).

| Token | Duration | Easing Curve | Application |
| :--- | :---: | :---: | :--- |
| `animDurationMicro` | **120ms** | `Easing.OutCubic` | Micro-flash, ripple feedback (~30 frames @ 240Hz). |
| `animDurationFast` | **180ms** | `Easing.OutCubic` | Hover states, button press scaling, switch toggling (~45 frames @ 240Hz). |
| `animDurationNormal` | **260ms** | `Easing.OutCubic` | Workspace pill morphing, OSD bar fill (~65 frames @ 240Hz). |
| `animDurationSticky` | **320ms** | `Easing.OutBack` (overshoot 1.15) | Sticky side notch panels, toast entrances, card transitions (~75 frames @ 240Hz). |
| `animDurationSlow` | **360ms** | `Easing.OutCubic` | Launcher modal, lockscreen intro sequences (~85 frames @ 240Hz). |
| `animDurationExit` | **200ms** | `Easing.InCubic` / `InQuad` | Snappy closing / exit transitions (~50 frames @ 240Hz). |
| `notchExpandDuration`| **340ms** | `Easing.OutBack` (overshoot 1.15) | Dynamic notch hover expansion. |
| `notchCollapseDuration`| **240ms**| `Easing.InOutCubic` | Smooth notch collapse when mouse leaves. |
| `stickyOvershoot` | **1.15** | --- | Elastic bounce coefficient for bezel-docked notches. |
| `buttonOvershoot` | **1.30** | --- | Tactile pop factor for interactive icons. |

------------------------------------------------------------------------

# 4. Component Specifications

## 4.1 Top Shell / Dynamic Central Glass Notch (`shell.qml`, `GlassPanel.qml`, `DefaultBarView.qml`)
- **Bezel Docking**: Physically docked to the top monitor bezel ($y = 0$).
- **Dynamic Geometric Scaling & Bounds**:
  - **Collapsed State (Idle)**: Compact pill ($160\text{px} \times 36\text{px}$) displaying the central Clock and localized Date (`pt-BR`).
  - **Expanded State (Hover)**: Expands smoothly to $680\text{px} \times 42\text{px}$ with `notchExpandDuration` (340ms) and `Easing.OutBack` whenever the user hovers over the bar or opens a menu.
  - **Dynamic Content Calculation**: Dynamic bounds (`contentExpandedWidth = leftContentWidth + clockContentWidth + rightContentWidth + dynamic gaps`) guarantee zero overlap between the clock, workspace pills, and status buttons. The clock is dynamically centered in the free middle space.
  - **Active Submode State**: Expands to $48\text{px}$ height (`notchExpandedHeight`) with dedicated subview widths.
- **Geometry (`GlassPanel.qml`)**: Top-left and top-right smooth concave arcs (`notchConcaveWidth: 16px`, `notchConcaveHeight: 10px`, `notchTopRadius: 12px`) flaring into the top bezel; bottom-left and bottom-right convex corners (`notchBottomRadius: 14px`).
- **Border**: 1px subtle glass stroke (`#24FFFFFF`) drawn exclusively along the bottom and lateral edges exposed to the desktop (never across the top bezel $y=0$ and never with internal cutting lines).
- **Content Encapsulation**:
  - **Left (revealed on expand)**: Bulldoze Logo (`""`, 16px, `textStrong`) + Dynamic Workspace Pills (active: $22 \times 6\text{px}$, inactive: $6 \times 6\text{px}$ dot, no numbers).
  - **Center (always visible)**: Single-line Clock (Time 13px DemiBold + Date 11px Medium localized in `pt-BR`, format `"ddd, dd MMM"` via `Qt.locale("pt_BR")`).
  - **Right (revealed on expand)**: Status icon buttons (Wi-Fi `""`, Bluetooth `""`, Audio `""`, Gaming Hub `""`, Notifications `""`, Power `""`, System Tray).

## 4.2 Application Launcher (`Launcher.qml`)
- **Type**: Centered modal overlay (`exclusiveZone: 0`, `focusable: true`).
- **Layer Namespace**: `"bulldoze-launcher"`.
- **Dimensions**: $580 \times 480\text{ px}$, centered on screen.
- **Surface**: `radiusModal` (22px), `glassFillDark` (`#40000000`), 1px `glassBorder` (`#24FFFFFF`).
- **Search Header**:
  - Search icon `""` in `textSubtle` + `TextInput` (20px, `textStrong`, placeholder in `textSubtle`).
  - 1px horizontal separator line (`#1AFFFFFF`).
- **App List (`DesktopEntries.applications`)**:
  - Rows: 48px height, `radiusItem` (12px), smooth hover transition (`hoverFill`).
  - App Icon (`Quickshell.Widgets.IconImage`, 24px com fallback para o glifo do Arch `""`) + Name (`textMedium`, 15px) + Subtitle/GenericName (`textMuted`, 11px).
  - Keyboard navigation with Arrow keys (Up/Down) and Enter to launch, Escape to dismiss, click-outside to close.

## 4.3 Control Center / Quick Settings Submodes (`components/views/`)
- **Submode Views in Top Notch Bar**:
  - **Wi-Fi View (`WifiBarView.qml`, 460x48px)**: SSID display, scan/refresh, settings launcher, and power toggle.
  - **Bluetooth View (`BluetoothBarView.qml`, 470x48px)**: Connected device name, pair button, manager launcher, and power toggle.
  - **Audio View (`AudioBarView.qml`, 380x48px)**: Mute toggle, smooth volume slider, percentage indicator, and auto-dismiss OSD integration.
  - **Gaming Hub View (`GamingBarView.qml`, 480x48px)**: Quick toggles for **GameMode**, **MangoHud**, and **Gamescope**, with gear button `""` opening `GamingSettingsModal.qml`.
  - **Power & Profile View (`PowerBarView.qml`, 490x48px)**: Masked avatar ($26\text{px}$), username with Privacy Blur toggle (`""`/`""`), and 4 quick actions (Lock, Logout, Reboot, Poweroff).

## 4.4 Wallpaper Engine Manager Modal (`WallpaperManagerModal.qml`, `modules/WallpaperEngine.qml`)
- **Type**: Centered modal overlay (`exclusiveZone: 0`, `focusable: true`, `WlrKeyboardFocus.OnDemand`).
- **Shortcut Trigger**: Global keybinding `ALT + W` (`hyprland.lua`).
- **Layer Namespace**: `"bulldoze-wallpaper-manager"`.
- **Dimensions**: $920 \times 640\text{ px}$, centered on screen.
- **Surface**: `radiusModal` (22px), `glassFillDark` (`#40000000`), 1px `glassBorder` (`#24FFFFFF`).
- **Left Gallery Column (54% Width)**:
  - Real-time Steam Workshop reader scanning `~/.local/share/Steam/steamapps/workshop/content/431960/` with multi-format preview caching in `~/.cache/bulldoze/wallpapers/`.
  - Search Header with instant filtering by title, ID, or tags.
  - Interactive cards with rounded high-res thumbnail masks (`radiusSmall`), active wallpaper indicator badge (` ATIVO`), and type badge (`CENA` / `VÍDEO`).
- **Right Configuration Panel (46% Width)**:
  - **Aspect Ratio & Enquadramento**: Segmented Pills for `Preencher (Fill - 16:9)`, `Adaptar (Fit - Inteiro sem cortes)` e `Esticar (Stretch)`.
  - **Sponsor & Layer Suppression**: Automatic deep scanning of `scene.pkg` to detect QR Code / donation objects (`sponsor_tip_x`, `微信赞助码`, etc.) and hardware-level skip pass via `--render-debug skip-object=<id>`.
  - **Dynamic Scene Shader Properties**: Real-time interactive sliders and toggles for scene uniforms.
  - **Performance**: 60 / 120 / 240 FPS selectors, pause on visible windows, and mouse tracking toggle (strict `--silent` execution with no audio output).
- **Direct Wallpaper Sync**:
  - Python engine in `scripts/bulldoze-wallpaper.py` syncs wallpaper image directly to `~/.cache/bulldoze/Wallpaper_greeter.png` and `/var/lib/greetd/Wallpaper_greeter.png` cleanly without capturing mouse hover states or overlay notches.

## 4.5 Integrated Notification System (`NotificationBarView.qml`, `NotificationCenter.qml`, `modules/Notifications.qml`)
- **Top Notch Notification Bar View (`NotificationBarView.qml`)**:
  - Dimensions: $520 \times 82\text{ px}$ (`notchNotificationHeight: 82`) integrated directly into the top notch bar.
  - **Stack (FILO - First In, Last Out)**: Notifications form a stack of up to 7 items max, displaying the newest notification on top with an indicator badge (e.g., `(3)`).
  - **Inactivity Timer (5s)**: Inactivity auto-dismiss timer of 5 seconds automatically collapses the bar to default. The timer resets dynamically on mouse hover or when popping a notification via ``.
  - Controls: App icon with Arch fallback `""`, app name + stack count badge, notification title & message body, and direct dismiss button `` that pops the current notification and immediately exposes the previous one in the stack until empty.
- **Auxiliary Toast Center (`NotificationCenter.qml`)**:
  - Background module queue tracking all system notifications.

## 4.6 On-Screen Display / OSD (`Osd.qml`, `BottomGlassPanel.qml`)
- **Type**: Bottom-docked glass notch (physically attached to bottom screen bezel $y = \text{screen.height}$).
- **Layer Namespace**: `"bulldoze-osd"`.
- **Dimensions**: $300 \times 74\text{ px}$, centered horizontally at the bottom of the screen (`margins.bottom: 0px`).
- **Surface Geometry (`BottomGlassPanel.qml`)**: Smooth concave arcs flaring into the bottom screen bezel; convex rounded top corners. Exposed 1px glass border (`#24FFFFFF`) along left, top, and right edges.
- **Motion**: Sticky vertical slide-up ($y: 28 \to 0$) + scale ($0.90 \to 1.0$) with `animDurationSticky` (320ms), `Easing.OutBack` (overshoot 1.15) on entry and `animDurationExit` (200ms) on dismiss.

## 4.7 File Manager / Dolphin (`KDE / Qt Integration`)
- **Physical Depth Stack**: Wallpaper → Hyprland native blur → 20%-25% translucent dark glass (`opacity: 0.78 override`) → 1px glass border (`rgba(ffffff24)`) → content.
- **Color Scheme (`Bulldoze.colors` / `kdeglobals`)**: Pure neutral dark `#0E0E10` / `#121214` (strictly zero saturated blue/Nord `#0F1926` or opaque `#10141C`).

## 4.8 Web Browser / Firefox (`userChrome.css Integration`)
- **Physical Depth Stack**: Wallpaper → Hyprland compositor blur → translucent dark glass (`--bulldoze-glass-fill`: `rgba(14, 16, 22, 0.40)`) → 1px glass border (`--bulldoze-glass-border`: `rgba(255, 255, 255, 0.14)`).

## 4.9 User Identity & Avatar Strategy
- **Single Source of Truth**: Logged-in Mozilla / Firefox Sync account (`signedInUser.json`), synchronized to `~/.face` and AccountsService via `scripts/sync-profile.py`.
- **Authoritative QML Masking Pattern**: Masked via `MultiEffect` with `radiusItem` (12px) and 1px `glassBorder`.

## 4.10 Lock Screen (`LockScreen.qml`, `GlassPanel.qml`)
- **Type**: Wayland Session Lock (`WlSessionLock` & `WlSessionLockSurface`, `ext-session-lock-v1`).
- **Surface Transparency & 100% Natural Wallpaper Fidelity**:
  - `WlSessionLockSurface.color` is strictly `"transparent"`.
  - **Zero Background Darkening Veil**: Strictly zero full-screen darkening overlays (`#30000000` or similar). The background wallpaper is displayed with 100% of its natural saturation, brightness, and sharpness identical to the logged-in desktop session.
  - Dynamic image buffer refresh (`bgImage.source`) on `onLockedChanged` to ensure instant visual parity when wallpapers change.
- **Top-Docked Morphing Dynamic Notch Architecture**:
  - The authentication surface ($680 \times 380\text{px}$) is docked directly to the top monitor bezel ($y = 0$) using `GlassPanel.qml`.
- **Continuity Motion & Expansion**:
  - **Lock Event**: The top notch expands smoothly from resting idle geometry ($200\text{px} \times 36\text{px}$) to the full credential card ($680\text{px} \times 380\text{px}$) with `Easing.OutBack` (overshoot 1.25, duration 380ms) triggered deterministically via `onLockedChanged`.
  - **Unlock Event**: On successful PAM authentication, the card smoothly collapses back to resting notch dimensions before unlocking the desktop session.
- **Integrated Header Typography**:
  - Large time (52px Bold) + Full localized Brazilian Portuguese date (14px Medium) integrated inside the upper header of the notch card, unified with `Clock.qml` and `Greeter.qml`.
- **Identity & Password**:
  - Masked Avatar (`MultiEffect` mask with `radiusItem`: 12px) + Display Name (`textStrong`, 15px) + Hostname (`textMuted`).
  - Password Input: Pill container (`radiusItem`, `itemFill`, 1px `glassBorderSubtle`), password echo mode, visibility toggle (`""`/`""`), submit button, and PAM horizontal shake animation upon invalid attempt.
- **Integrated Power Actions**: Icon-only action tiles ($36 \times 36\text{px}$) for Suspender (`systemctl suspend`), Reiniciar (`systemctl reboot`), Desligar (`systemctl poweroff`) with tactile hover scaling (`buttonOvershoot: 1.30`) and upward tooltip tags in `pt-BR`.
- **Scoped Frosted Glass Blur (`GlassPanel.qml`)**:
  - Blur is applied strictly behind the notch card geometry (`brightness: 0.0`, `contrast: 0.0`) preserving 100% luminosity of the underlying wallpaper without any synthetic darkening pass.

## 4.11 QuickShell Greeter / Login Screen (`greeter.qml`, `Greeter.qml`, `GlassPanel.qml`)
- **Type**: Display Manager / Greeter Session for `greetd` (`WlrLayer.Overlay`, `WlrKeyboardFocus.Exclusive`, `quickshell -p /etc/greetd/bulldoze-greeter`).
- **Layer Namespace**: `"bulldoze-greeter"`.
- **Surface Transparency & 100% Natural Wallpaper Fidelity**:
  - `PanelWindow.color` is strictly `"transparent"`.
  - **Zero Background Darkening Veil**: Strictly zero full-screen darkening overlays (`#30000000` or similar). The background wallpaper is displayed with 100% of its natural saturation, brightness, and sharpness identical to the logged-in desktop session.
- **Top-Docked Morphing Dynamic Notch Architecture**:
  - High-fidelity login card ($680 \times 400\text{px}$) docked to the top monitor bezel ($y = 0$) through `GlassPanel.qml`, fully unified with the Lock Screen design language.
- **240Hz Dynamic Intro & Exit Motion**:
  - Expands from top notch resting dimensions ($200\text{px} \times 36\text{px} \to 680\text{px} \times 400\text{px}$) on startup with `Easing.OutBack` (overshoot 1.25, 380ms) and collapses smoothly on login success.
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
- **Scoped Frosted Glass Blur (`GlassPanel.qml`)**:
  - Blur is rendered strictly behind the notch card surface (`brightness: 0.0`, `contrast: 0.0`), keeping the background wallpaper fully illuminated.
- **Backend IPC Client (`scripts/greetd-client.py`)**: Python-based JSON-RPC client communicating over `$GREETD_SOCK`.
- **Automated Full-Package Deployment (`scripts/install-greeter.sh`)**:
  - Copies all `components/*` (including `GlassPanel.qml`) and `modules/*` to `/etc/greetd/bulldoze-greeter/` with permissions `root:greeter` (755).
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
3. **1px Glass Boundaries**: All borders are exactly 1px subtle white strokes (`#24FFFFFF` / `#18FFFFFF` / `#36FFFFFF`) with zero straight lines cutting through concave flare arcs.
4. **Top-Docked Morphing Continuity**: Top Bar, Lock Screen, and Greeter share the physical top bezel anchor ($y = 0$), expanding organically with `Easing.OutBack` and collapsing on dismissal/unlock.
5. **Concave Bezel Integration**: Symmetrical 16px concave arcs smoothly flare the notch into the top monitor bezel ($y = 0$).
6. **No Fake Effects**: Zero glows, zero drop shadows, zero top light strips, zero fake reflections.
7. **Clean QML Code**: 0 syntax errors, 0 `qmllint` warnings.
8. **Localization (pt-BR)**: 100% of text strings, dates, times, modal headers, action labels, placeholders, and tooltips across the entire QuickShell / Bulldoze environment MUST strictly be in Brazilian Portuguese (`pt-BR`). Dates must explicitly consume `Qt.locale("pt_BR")` (e.g. `clock.date.toLocaleDateString(Qt.locale("pt_BR"), ...)`).
