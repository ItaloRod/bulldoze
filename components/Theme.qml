import QtQuick

QtObject {
    // -------------------------------------------------------------------------
    // 1. Surface & Glass Tokens (Hex #AARRGGBB)
    // -------------------------------------------------------------------------
    readonly property color glassFill: "#33000000"           // ~20% alpha black (top notch)
    readonly property color glassFillDark: "#40000000"       // ~25% alpha black (cards, modals, popups)
    readonly property color glassBorder: "#24FFFFFF"         // ~14% alpha white (subtle 1px border)
    readonly property color glassBorderSubtle: "#18FFFFFF"   // ~9% alpha white (item borders, inner bounds)
    readonly property color glassBorderStrong: "#36FFFFFF"   // ~21% alpha white (focused/hovered borders)
    readonly property color glassBorderTop: "#4DFFFFFF"      // ~30% alpha white (Liquid Glass top rim highlight)
    readonly property color glassBorderBottom: "#14FFFFFF"   // ~8% alpha white (Liquid Glass bottom rim)
    readonly property color glassHighlight: "#26FFFFFF"      // ~15% alpha white (Liquid Glass internal reflection)

    // Shadow Tokens (Unique standard shadow across all components)
    readonly property color shadowColor: "#59000000"         // ~35% alpha black
    readonly property int shadowRadius: 20
    readonly property int shadowOffsetY: 6
    readonly property int shadowOffsetX: 0

    // Interactive States
    readonly property color itemFill: "#10FFFFFF"            // ~6% alpha white (tile background)
    readonly property color hoverFill: "#1CFFFFFF"           // ~11% alpha white (hover state)
    readonly property color activeFill: "#33FFFFFF"          // ~20% alpha white (active/selected toggle)
    readonly property color separator: "#1AFFFFFF"           // ~10% alpha white (subtle divider)
    readonly property color accent: "#FFFFFF"                // White highlight for indicators and spinners

    // -------------------------------------------------------------------------
    // 2. Typography & Contrast Tokens
    // -------------------------------------------------------------------------
    readonly property color textStrong: "#F2FFFFFF"          // ~95% white (titles, clock time, primary icons)
    readonly property color textMedium: "#DFFFFFFF"          // ~87% white (body, active workspaces, subtitles)
    readonly property color textMuted: "#BFFFFFFF"           // ~75% white (dates, metadata, status labels)
    readonly property color textSubtle: "#80FFFFFF"          // ~50% white (placeholders, inactive hints)
    readonly property color indicatorInactive: "#66FFFFFF"   // ~40% white (inactive workspace dots)

    // Font Sizes (Pixel Size)
    readonly property int fontSizeXs: 11                     // Micro labels, dates, notification app name
    readonly property int fontSizeSm: 12                     // Secondary body, OSD text, button labels
    readonly property int fontSizeMd: 13                     // Notch clock time, menu items, primary body
    readonly property int fontSizeLg: 15                     // App names, section titles
    readonly property int fontSizeXl: 18                     // Card titles, power menu icons
    readonly property int fontSizeTitle: 20                  // Modal headers, search input

    // Submenu Typography Scale
    readonly property int fontSizeSubmenuTitle: 15           // Bold titles in active submenus
    readonly property int fontSizeSubmenuBody: 12            // High-legibility subtitles in active submenus

    // Icon Size Scale
    readonly property int iconSizeXs: 12
    readonly property int iconSizeSm: 14
    readonly property int iconSizeMd: 16
    readonly property int iconSizeLg: 18
    readonly property int iconSizeXl: 22

    // Legacy aliases for backward compatibility in notch bar
    readonly property int dateTextSize: fontSizeXs
    readonly property int timeTextSize: fontSizeMd
    readonly property int statusTextSize: fontSizeXs

    // -------------------------------------------------------------------------
    // 3. Geometry & Corner Radii Scale
    // -------------------------------------------------------------------------
    readonly property int radiusSmall: 6                     // Minor tags, pills track
    readonly property int radiusPill: 9999                   // Fully rounded capsules / workspace pills
    readonly property int radiusItem: 12                     // Buttons, list rows, toggle tiles
    readonly property int radiusCard: 18                     // Notifications, Control Center, OSD
    readonly property int radiusModal: 28                    // Launcher modal, Power menu modal
    readonly property int radiusIsland: 28                   // Dynamic Island expanded panels
    readonly property int radiusIslandLarge: 32              // LockScreen and Greeter floating cards
    readonly property int islandMargin: 8                    // 8px margin from screen borders

    readonly property int borderThickness: 8
    readonly property int innerRadius: 8
    readonly property int notchHeight: 32
    readonly property int notchHoverHeight: 68               // Height on hover when showing 2-level menu items
    readonly property int notchExpandedHeight: 68            // Height when a submenu/activeMode is open
    readonly property int notchNotificationHeight: 96        // Height when notifications activeMode is open
    readonly property int notchRadius: 14
    readonly property int notchTopRadius: 12
    readonly property int notchConcaveWidth: 16
    readonly property int notchConcaveHeight: 10
    readonly property int notchBottomRadius: 14
    readonly property real notchWidthRatio: 0.28
    readonly property int notchCollapsedWidth: 200
    readonly property int notchExpandedWidth: 680

    // -------------------------------------------------------------------------
    // 4. Spacing & Padding Scale
    // -------------------------------------------------------------------------
    readonly property int spacingXs: 4
    readonly property int spacingSm: 8
    readonly property int spacingMd: 12
    readonly property int spacingLg: 16
    readonly property int spacingXl: 20
    readonly property int spacingXxl: 24

    readonly property int contentInset: 18
    readonly property int groupSpacing: 12
    readonly property int statusSpacing: 12
    readonly property int workspaceSpacing: 6

    // -------------------------------------------------------------------------
    // 5. Motion & Animation Tokens (Optimized for 240Hz High Refresh Rate)
    // -------------------------------------------------------------------------
    // At 240Hz (frame interval ~4.16ms), smooth cubic and spring-back curves
    // provide ~60-90 continuous interpolation steps with organic tactile response.
    readonly property int animDurationMicro: 120             // Color flash, active ripples (~30 frames @ 240Hz)
    readonly property int animDurationFast: 180              // Hover, button press, switches (~45 frames @ 240Hz)
    readonly property int animDurationNormal: 260            // Workspace pills, sliders (~65 frames @ 240Hz)
    readonly property int animDurationSticky: 320            // Sticky spring popups & notch side panels (~75 frames @ 240Hz)
    readonly property int animDurationSlow: 360              // Modal & full launcher transitions (~85 frames @ 240Hz)
    readonly property int animDurationExit: 200              // Snappy closing exit transition (~50 frames @ 240Hz)
    readonly property int notchExpandDuration: 340           // Notch expansion on hover
    readonly property int notchCollapseDuration: 240         // Notch collapse on leave
    readonly property real stickyOvershoot: 1.15             // Organic elastic overshoot factor
    readonly property real buttonOvershoot: 1.30             // Button tactile hover pop factor
}
