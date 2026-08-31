#!/usr/bin/env python3
import os
import sys
import time
import socket
import json
import subprocess

def get_hypr_socket():
    sig = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE", "")
    if not sig:
        return None
    return f"/run/user/{os.getuid()}/hypr/{sig}/.socket2.sock"

def check_active_fullscreen():
    try:
        res = subprocess.run(["hyprctl", "activeworkspace", "-j"], capture_output=True, text=True, timeout=1)
        if res.returncode == 0:
            data = json.loads(res.stdout)
            return bool(data.get("hasfullscreen", False))
    except Exception:
        pass
    return False

def main():
    sock_path = get_hypr_socket()
    if not sock_path or not os.path.exists(sock_path):
        print("FULLSCREEN:0", flush=True)
        return

    # Initial state
    initial_fs = check_active_fullscreen()
    print(f"FULLSCREEN:{1 if initial_fs else 0}", flush=True)

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
                if line.startswith("fullscreen>>"):
                    val = line.split(">>", 1)[1].strip()
                    print(f"FULLSCREEN:{1 if val == '1' else 0}", flush=True)
                elif line.startswith("workspace>>") or line.startswith("focusedmon>>"):
                    is_fs = check_active_fullscreen()
                    print(f"FULLSCREEN:{1 if is_fs else 0}", flush=True)
        except Exception:
            time.sleep(1)

if __name__ == "__main__":
    main()
