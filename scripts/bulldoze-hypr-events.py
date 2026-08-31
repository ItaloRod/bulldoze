#!/usr/bin/env python3
import os
import sys
import time
import socket
import json
import subprocess
import signal

CONFIG_FILE = os.path.expanduser("~/.config/bulldoze/wallpaper.json")

def get_hypr_socket():
    sig = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE", "")
    if not sig:
        return None
    return f"/run/user/{os.getuid()}/hypr/{sig}/.socket2.sock"

def get_wallpaper_pids():
    try:
        out = subprocess.check_output(["pidof", "linux-wallpaperengine"], text=True)
        return [int(p) for p in out.strip().split()]
    except Exception:
        return []

def set_wallpaper_paused(pause: bool):
    sig = signal.SIGSTOP if pause else signal.SIGCONT
    for pid in get_wallpaper_pids():
        try:
            os.kill(pid, sig)
        except Exception:
            pass

def is_pause_on_window_enabled():
    if os.path.exists(CONFIG_FILE):
        try:
            with open(CONFIG_FILE, "r", encoding="utf-8") as f:
                data = json.load(f)
                return bool(data.get("pause_on_window", True))
        except Exception:
            pass
    return True

def check_active_workspace_state():
    try:
        res = subprocess.run(["hyprctl", "activeworkspace", "-j"], capture_output=True, text=True, timeout=1)
        if res.returncode == 0:
            data = json.loads(res.stdout)
            has_fs = bool(data.get("hasfullscreen", False))
            win_count = int(data.get("windows", 0))
            return has_fs, win_count
    except Exception:
        pass
    return False, 0

def main():
    sock_path = get_hypr_socket()
    if not sock_path or not os.path.exists(sock_path):
        print("FULLSCREEN:0", flush=True)
        return

    # Initial state
    initial_fs, initial_wins = check_active_workspace_state()
    print(f"FULLSCREEN:{1 if initial_fs else 0}", flush=True)

    last_paused = None
    if is_pause_on_window_enabled():
        should_pause = (initial_wins > 0)
        set_wallpaper_paused(should_pause)
        last_paused = should_pause

    while True:
        try:
            s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            s.connect(sock_path)
            f = s.makefile()
            while True:
                line = f.readline()
                if not line:
                    break
                line = line.strip()
                
                # Check for any event that changes windows or workspace state
                if any(line.startswith(prefix) for prefix in [
                    "fullscreen>>", "workspace>>", "focusedmon>>",
                    "openwindow>>", "closewindow>>", "movewindow>>",
                    "changefloatingmode>>", "activespecial>>", "activewindow>>"
                ]):
                    has_fs, win_count = check_active_workspace_state()
                    if line.startswith("fullscreen>>"):
                        val = line.split(">>", 1)[1].strip()
                        print(f"FULLSCREEN:{1 if val == '1' else 0}", flush=True)
                    else:
                        print(f"FULLSCREEN:{1 if has_fs else 0}", flush=True)

                    if is_pause_on_window_enabled():
                        should_pause = (win_count > 0)
                        if should_pause != last_paused or should_pause:
                            set_wallpaper_paused(should_pause)
                            last_paused = should_pause
                    else:
                        if last_paused is True:
                            set_wallpaper_paused(False)
                            last_paused = False
        except Exception:
            time.sleep(1)

if __name__ == "__main__":
    main()
