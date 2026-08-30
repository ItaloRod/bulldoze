#!/usr/bin/env python3
"""
Bulldoze 3.0 — Greetd IPC Helper & System Query Client
Provides user listing, desktop session discovery, and greetd socket authentication.
"""

import sys
import os
import json
import socket
import subprocess
import argparse

def get_temp_dir():
    return os.getenv("TMPDIR") or os.getenv("TEMP") or "/tmp"

def log_debug(msg):
    if os.getenv("DEBUG") or os.getenv("USER") == "greeter":
        log_file = os.path.join(get_temp_dir(), "bulldoze-greeter.log")
        with open(log_file, "a") as f:
            f.write(f"{msg}\n")

def get_hostname():
    try:
        if os.path.isfile("/etc/hostname"):
            with open("/etc/hostname", "r", encoding="utf-8") as f:
                h = f.read().strip()
                if h:
                    return h
    except Exception:
        pass
    try:
        return socket.gethostname()
    except Exception:
        return "bulldoze"

def list_system_users():
    """Finds all human users with UID >= 1000."""
    uid_min = 1000
    try:
        if os.path.isfile("/etc/login.defs"):
            with open("/etc/login.defs") as f:
                for line in f:
                    if line.startswith("UID_MIN"):
                        parts = line.split()
                        if len(parts) >= 2:
                            uid_min = int(parts[1])
    except Exception as e:
        log_debug(f"Error reading /etc/login.defs: {e}")

    hostname = get_hostname()
    users = []
    try:
        passwd_output = subprocess.check_output(["getent", "passwd"]).decode("utf-8").strip()
        for line in passwd_output.splitlines():
            parts = line.split(":")
            if len(parts) >= 6:
                uname = parts[0]
                uid = int(parts[2])
                gecos = parts[4].split(",")[0] if parts[4] else uname
                home = parts[5]

                if uid >= uid_min and uid < 65000 and os.path.isdir(home):
                    avatar = ""
                    as_icon = f"/var/lib/AccountsService/icons/{uname}"
                    if os.path.isfile(as_icon):
                        avatar = as_icon
                    elif os.path.isfile(f"{home}/.config/bulldoze/assets/avatar.png"):
                        avatar = f"{home}/.config/bulldoze/assets/avatar.png"
                    elif os.path.isfile(f"/var/cache/nwg-hello/{uname}.face"):
                        avatar = f"/var/cache/nwg-hello/{uname}.face"
                    elif os.path.isfile(f"/var/lib/greetd/{uname}.face"):
                        avatar = f"/var/lib/greetd/{uname}.face"
                    elif os.path.isfile(f"{home}/.face"):
                        avatar = f"{home}/.face"
                    elif os.path.isfile(f"{home}/.face.icon"):
                        avatar = f"{home}/.face.icon"

                    users.append({
                        "username": uname,
                        "displayName": gecos or uname,
                        "hostName": hostname,
                        "avatar": avatar,
                        "home": home
                    })
    except Exception as e:
        log_debug(f"Error listing users: {e}")

    if not users:
        user = os.getenv("USER") or "paulo"
        users.append({
            "username": user,
            "displayName": user.capitalize(),
            "hostName": hostname,
            "avatar": "",
            "home": f"/home/{user}"
        })

    return users

def parse_desktop_entry(path):
    """Parses .desktop file to extract session Name and Exec."""
    try:
        with open(path, "r", encoding="utf-8") as f:
            lines = f.read().splitlines()
        session = {"file": path}
        for line in lines:
            line = line.strip()
            if line.startswith("Name=") and "name" not in session:
                session["name"] = line[5:]
            elif line.startswith("Exec=") and "exec" not in session:
                session["exec"] = line[5:]
            elif line.startswith("TryExec=") and "try_exec" not in session:
                session["try_exec"] = line[8:]
        
        if "name" in session and "exec" in session:
            raw_name = session["name"]
            # Clean up display name
            if raw_name == "Hyprland (uwsm-managed)":
                session["name"] = "Hyprland (UWSM)"
            elif raw_name == "Hyprland":
                session["name"] = "Hyprland"

            name_lower = session["name"].lower()
            if "hyprland" in name_lower:
                session["icon"] = ""
            elif "sway" in name_lower:
                session["icon"] = ""
            elif "gnome" in name_lower:
                session["icon"] = ""
            elif "kde" in name_lower or "plasma" in name_lower:
                session["icon"] = ""
            elif "shell" in name_lower or "bash" in name_lower:
                session["icon"] = ""
            else:
                session["icon"] = ""
            return session
    except Exception as e:
        log_debug(f"Error reading {path}: {e}")
    return None

def list_desktop_sessions():
    """Scans /usr/share/wayland-sessions and /usr/share/xsessions with Hyprland priority."""
    session_dirs = [
        "/usr/share/wayland-sessions",
        "/usr/share/xsessions"
    ]
    sessions = []
    seen = set()

    for sdir in session_dirs:
        if os.path.isdir(sdir):
            try:
                for fname in sorted(os.listdir(sdir)):
                    if fname.endswith(".desktop"):
                        full_path = os.path.join(sdir, fname)
                        entry = parse_desktop_entry(full_path)
                        if entry and entry["exec"] not in seen:
                            seen.add(entry["exec"])
                            sessions.append(entry)
            except Exception as e:
                log_debug(f"Error scanning {sdir}: {e}")

    # Prioritize standard Hyprland first, then Hyprland (UWSM), then other sessions
    def session_sort_key(s):
        name = s.get("name", "").strip()
        fname = os.path.basename(s.get("file", "")).lower()
        if name == "Hyprland" or fname == "hyprland.desktop":
            return (0, name)
        if "hyprland" in name.lower():
            return (1, name)
        if "wayland" in s.get("file", "").lower():
            return (2, name)
        return (3, name)

    sessions.sort(key=session_sort_key)

    if not sessions:
        sessions.append({
            "name": "Hyprland",
            "exec": "Hyprland",
            "icon": "",
            "file": "/usr/share/wayland-sessions/hyprland.desktop"
        })

    return sessions

def greetd_ipc_send(client, payload):
    """Sends JSON-RPC payload to greetd socket and receives JSON response."""
    msg = json.dumps(payload).encode("utf-8")
    length = len(msg).to_bytes(4, "little")
    client.sendall(length + msg)

    raw_len = client.recv(4)
    if len(raw_len) < 4:
        return {"type": "error", "description": "Socket connection closed unexpectedly"}
    resp_len = int.from_bytes(raw_len, "little")
    resp_bytes = b""
    while len(resp_bytes) < resp_len:
        chunk = client.recv(min(4096, resp_len - len(resp_bytes)))
        if not chunk:
            break
        resp_bytes += chunk
    
    return json.loads(resp_bytes.decode("utf-8"))

def authenticate_and_launch(username, password, cmd):
    """Performs full handshake with greetd socket."""
    sock_path = os.getenv("GREETD_SOCK")
    if not sock_path or not os.path.exists(sock_path):
        log_debug("GREETD_SOCK not available (running in test mode)")
        import time
        time.sleep(0.5)
        if password == "test" or password == "1234" or password == "demo":
            return {"success": True, "message": "Autenticado (Modo de Teste)"}
        return {"success": False, "error": "Senha incorreta (Modo de Teste: tente 'test')"}

    try:
        client = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        client.connect(sock_path)

        try:
            greetd_ipc_send(client, {"type": "cancel_session"})
        except Exception:
            pass

        resp = greetd_ipc_send(client, {"type": "create_session", "username": username})
        log_debug(f"create_session resp: {resp}")

        resp = greetd_ipc_send(client, {"type": "post_auth_message_response", "response": password})
        log_debug(f"post_auth_message_response resp: {resp}")

        if resp.get("type") == "error" or resp.get("error_type") == "auth_error":
            return {"success": False, "error": "Senha incorreta"}

        cmd_args = cmd.split()
        resp = greetd_ipc_send(client, {"type": "start_session", "cmd": cmd_args, "env": []})
        log_debug(f"start_session resp: {resp}")

        if resp.get("type") == "success":
            return {"success": True}
        else:
            return {"success": False, "error": resp.get("description", "Falha ao iniciar a sessão")}

    except Exception as e:
        log_debug(f"IPC exception: {e}")
        return {"success": False, "error": str(e)}

def main():
    parser = argparse.ArgumentParser(description="Bulldoze Greetd Helper")
    parser.add_argument("action", choices=["users", "sessions", "login"], help="Action to perform")
    parser.add_argument("--user", help="Username for login")
    parser.add_argument("--password", help="Password for login")
    parser.add_argument("--cmd", help="Command / Session executable to start")

    args = parser.parse_args()

    if args.action == "users":
        print(json.dumps(list_system_users()))
    elif args.action == "sessions":
        print(json.dumps(list_desktop_sessions()))
    elif args.action == "login":
        if not args.user or not args.cmd:
            print(json.dumps({"success": False, "error": "Parâmetros de login incompletos"}))
            sys.exit(1)
        res = authenticate_and_launch(args.user, args.password or "", args.cmd)
        print(json.dumps(res))

if __name__ == "__main__":
    main()
