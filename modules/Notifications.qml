import QtQuick
import Quickshell
import Quickshell.Services.Notifications

QtObject {
    id: root

    readonly property int maxBuffer: 7
    property var buffer: []

    readonly property var list: buffer
    readonly property int count: buffer ? buffer.length : 0
    readonly property bool hasNotifications: count > 0
    readonly property var current: hasNotifications ? buffer[0] : null
    readonly property var latest: current

    signal notificationReceived(var notification)

    property NotificationServer server: NotificationServer {
        id: serverInstance
        keepOnReload: true
        persistenceSupported: true
        bodySupported: true
        actionsSupported: true

        onNotification: notif => {
            if (!notif) return
            root.push(notif)
        }
    }

    Component.onCompleted: {
        syncFromTracked()
    }

    function syncFromTracked() {
        if (!serverInstance || !serverInstance.trackedNotifications) return
        let vals = serverInstance.trackedNotifications.values || serverInstance.trackedNotifications
        if (vals && vals.length !== undefined && vals.length > 0) {
            let cur = []
            for (let i = vals.length - 1; i >= 0 && cur.length < maxBuffer; i--) {
                if (vals[i]) {
                    cur.push(vals[i])
                    try {
                        vals[i].closed.connect(() => root.remove(vals[i]))
                    } catch(e) {}
                }
            }
            root.buffer = cur
        }
    }

    function push(notif) {
        if (!notif) return

        notif.tracked = true

        let cur = root.buffer ? root.buffer.slice() : []

        // If duplicate id exists, remove old one
        let existingIdx = -1
        for (let i = 0; i < cur.length; i++) {
            if (cur[i] && cur[i].id === notif.id) {
                existingIdx = i
                break
            }
        }
        if (existingIdx !== -1) {
            cur.splice(existingIdx, 1)
        }

        // Push to top of stack (index 0)
        cur.unshift(notif)

        // Enforce maximum capacity of 7 (FILO: drop oldest at the bottom)
        while (cur.length > root.maxBuffer) {
            let oldest = cur.pop()
            if (oldest) {
                oldest.tracked = false
                try { oldest.dismiss() } catch(e) {}
            }
        }

        root.buffer = cur

        try {
            notif.closed.connect(() => {
                root.remove(notif)
            })
        } catch(e) {}

        root.notificationReceived(notif)
    }

    function pop() {
        if (!root.buffer || root.buffer.length === 0) return null
        let cur = root.buffer.slice()
        let topNotif = cur.shift() // Remove top of stack
        if (topNotif) {
            topNotif.tracked = false
            try { topNotif.dismiss() } catch(e) {}
        }
        root.buffer = cur
        return topNotif
    }

    function remove(notif) {
        if (!notif || !root.buffer) return
        let cur = root.buffer.slice()
        let idx = -1
        for (let i = 0; i < cur.length; i++) {
            if (cur[i] === notif || (cur[i] && notif && cur[i].id === notif.id)) {
                idx = i
                break
            }
        }
        if (idx !== -1) {
            cur.splice(idx, 1)
            root.buffer = cur
        }
    }

    function dismiss(notif) {
        if (!notif) return
        notif.tracked = false
        try {
            notif.dismiss()
        } catch(e) {}
        remove(notif)
    }

    function dismissAll() {
        if (!root.buffer) return
        let cur = root.buffer.slice()
        for (let i = 0; i < cur.length; i++) {
            if (cur[i]) {
                cur[i].tracked = false
                try {
                    cur[i].dismiss()
                } catch(e) {}
            }
        }
        root.buffer = []
    }

    function resolveIconSource(notif) {
        if (!notif) return ""
        let icon = notif.appIcon || notif.image || notif.desktopEntry || ""
        if (icon) {
            if (icon.startsWith("/") || icon.startsWith("file://") || icon.startsWith("image://")) {
                return icon.startsWith("/") ? ("file://" + icon) : icon
            }
            let p = Quickshell.iconPath(icon, "")
            if (p !== "") return p
        }
        if (notif.appName) {
            let p = Quickshell.iconPath(notif.appName.toLowerCase(), "")
            if (p !== "") return p
        }
        return ""
    }
}
