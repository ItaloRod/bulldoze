#!/usr/bin/env python3
import json
import os
import glob
import urllib.request
import shutil
import pwd
import socket
import subprocess

def main():
    home = os.path.expanduser("~")
    assets_dir = os.path.join(home, ".config", "bulldoze", "assets")
    os.makedirs(assets_dir, exist_ok=True)
    avatar_path = os.path.join(assets_dir, "avatar.png")
    url_cache_file = os.path.join(assets_dir, ".avatar_url")

    # Locate signedInUser.json in all possible Firefox profile directories
    patterns = [
        os.path.join(home, ".config", "mozilla", "firefox", "*", "signedInUser.json"),
        os.path.join(home, ".mozilla", "firefox", "*", "signedInUser.json"),
        os.path.join(home, ".var", "app", "org.mozilla.firefox", ".mozilla", "firefox", "*", "signedInUser.json"),
    ]

    json_files = []
    for p in patterns:
        json_files.extend(glob.glob(p))

    avatar_url = None
    display_name = None

    if json_files:
        for jf in sorted(json_files, key=os.path.getmtime, reverse=True):
            try:
                with open(jf, "r", encoding="utf-8") as f:
                    data = json.load(f)
                    prof = data.get("accountData", {}).get("profileCache", {}).get("profile", {})
                    if prof.get("avatar") and not prof.get("avatarDefault", False):
                        avatar_url = prof.get("avatar")
                        display_name = prof.get("displayName")
                        break
                    elif prof.get("displayName"):
                        display_name = prof.get("displayName")
            except Exception:
                pass

    # Login and system user info
    login_user = os.environ.get("USER") or os.getlogin() or "user"
    if not display_name:
        try:
            gecos = pwd.getpwnam(login_user).pw_gecos
            display_name = gecos.split(",")[0].strip() or login_user
        except Exception:
            display_name = login_user

    # Hostname resolution
    try:
        with open("/etc/hostname", "r", encoding="utf-8") as f:
            hostname = f.read().strip()
    except Exception:
        hostname = socket.gethostname()

    has_avatar = False

    if avatar_url:
        last_url = ""
        if os.path.exists(url_cache_file):
            try:
                with open(url_cache_file, "r", encoding="utf-8") as f:
                    last_url = f.read().strip()
            except Exception:
                pass

        # If avatar changed in Firefox or local file is missing, download it
        if avatar_url != last_url or not os.path.exists(avatar_path) or os.path.getsize(avatar_path) == 0:
            try:
                req = urllib.request.Request(avatar_url, headers={"User-Agent": "Mozilla/5.0 Bulldoze/3.0"})
                with urllib.request.urlopen(req, timeout=5) as resp, open(avatar_path, "wb") as out_f:
                    shutil.copyfileobj(resp, out_f)
                with open(url_cache_file, "w", encoding="utf-8") as f:
                    f.write(avatar_url)
            except Exception:
                pass

        if os.path.exists(avatar_path) and os.path.getsize(avatar_path) > 0:
            has_avatar = True
            # Sync to ~/.face and ~/.face.icon for lock screen / desktop
            for face_name in [".face", ".face.icon"]:
                face_dest = os.path.join(home, face_name)
                try:
                    shutil.copy2(avatar_path, face_dest)
                except Exception:
                    pass

            # Sync to AccountsService for nwg-hello / greeter
            try:
                uid = os.getuid()
                subprocess.run(
                    ["gdbus", "call", "--system", "--dest", "org.freedesktop.Accounts",
                     "--object-path", f"/org/freedesktop/Accounts/User{uid}",
                     "--method", "org.freedesktop.Accounts.User.SetIconFile",
                     os.path.join(home, ".face")],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                    timeout=3
                )
            except Exception:
                pass
    else:
        # Firefox has no avatar or was uninstalled
        if os.path.exists(url_cache_file):
            try:
                os.remove(url_cache_file)
            except Exception:
                pass
        has_avatar = False

    initial = (display_name[0] if display_name else login_user[0]).upper()

    output = {
        "displayName": display_name,
        "loginUser": login_user,
        "hostName": hostname,
        "avatarPath": avatar_path if has_avatar else "",
        "hasAvatar": has_avatar,
        "initial": initial,
        "avatarUrl": avatar_url or ""
    }

    print(json.dumps(output))

if __name__ == "__main__":
    main()
