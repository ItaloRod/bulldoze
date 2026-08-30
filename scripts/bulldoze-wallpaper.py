#!/usr/bin/env python3
"""
Bulldoze 3.0 - Wallpaper Engine Manager Backend
Scans Steam Workshop wallpapers, parses project.json properties,
manages configuration, and launches linux-wallpaperengine with
full interactive mouse, scaling, and shader customization.
"""

import os
import sys
import json
import glob
import struct
import subprocess
from PIL import Image

WORKSHOP_DIR = os.path.expanduser("~/.local/share/Steam/steamapps/workshop/content/431960")
ASSETS_DIR = os.path.expanduser("~/.local/share/Steam/steamapps/common/wallpaper_engine/assets")
OWUI_DIR = os.path.expanduser("~/.local/share/owui/wpe")
OWUI_SETTINGS = os.path.expanduser("~/.config/owui/settings.ndl")
CONFIG_FILE = os.path.expanduser("~/.config/bulldoze/wallpaper.json")
CACHE_DIR = os.path.expanduser("~/.cache/bulldoze/wallpapers")

SPONSOR_KEYWORDS = [
    'sponsor', 'tip', 'qrcode', 'pay', 'author', 'donate',
    'zan', 'weixin', 'wechat', 'afdian', '赞助', '打赏', '求赞助', '红书', 'rednote'
]

def read_str(f):
    ln = struct.unpack('<I', f.read(4))[0]
    return f.read(ln).decode('utf-8', errors='ignore')

def get_scene_data(folder):
    pkg_path = os.path.join(folder, 'scene.pkg')
    if os.path.exists(pkg_path):
        try:
            with open(pkg_path, 'rb') as f:
                magic = read_str(f)
                count = struct.unpack('<I', f.read(4))[0]
                files = {}
                for _ in range(count):
                    name = read_str(f)
                    offset, size = struct.unpack('<II', f.read(8))
                    files[name] = (offset, size)
                data_start = f.tell()
                if 'scene.json' in files:
                    off, sz = files['scene.json']
                    f.seek(data_start + off)
                    content = f.read(sz).decode('utf-8', errors='ignore')
                    return json.loads(content)
        except Exception:
            pass
    json_path = os.path.join(folder, 'scene.json')
    if os.path.exists(json_path):
        try:
            with open(json_path, 'r', encoding='utf-8', errors='ignore') as f:
                return json.load(f)
        except Exception:
            pass
    return None

def find_scene_objects(folder):
    """Extracts all objects and detects sponsor objects from scene.pkg"""
    scene = get_scene_data(folder)
    if not scene or 'objects' not in scene:
        return [], []
    
    all_objs = []
    sponsor_ids = []
    
    for obj in scene.get('objects', []):
        obj_id = obj.get('id')
        name = str(obj.get('name', '')).strip()
        img = str(obj.get('image', '')).strip()
        if obj_id is not None:
            is_sponsor = any(k in name.lower() or k in img.lower() for k in SPONSOR_KEYWORDS)
            if is_sponsor:
                sponsor_ids.append(obj_id)
            all_objs.append({
                'id': obj_id,
                'name': name or img or f"Objeto #{obj_id}",
                'is_sponsor': is_sponsor
            })
    return all_objs, sponsor_ids

def parse_owui_settings():
    """Extract initial settings from OWUI settings.ndl if available"""
    if not os.path.exists(OWUI_SETTINGS):
        return {}
    
    settings = {
        "active_id": "",
        "per_wallpaper_settings": {}
    }
    try:
        with open(OWUI_SETTINGS, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
        
        for line in content.splitlines():
            line = line.strip()
            if line.startswith("autorun_wallpapers.HDMI-A-1") or line.startswith("autorun_wallpapers"):
                parts = line.split('"')
                if len(parts) >= 2:
                    val = parts[1].strip()
                    wp_id = os.path.basename(val)
                    settings["active_id"] = wp_id
    except Exception as e:
        sys.stderr.write(f"Error parsing OWUI settings: {e}\n")
    return settings

def get_cached_preview(entry, preview_path):
    """Converts webp or missing formats to standard jpeg in cache"""
    if not preview_path or not os.path.exists(preview_path):
        return ""
    
    ext = os.path.splitext(preview_path)[1].lower()
    if ext in [".jpg", ".jpeg", ".png"]:
        return preview_path
    
    os.makedirs(CACHE_DIR, exist_ok=True)
    cached_file = os.path.join(CACHE_DIR, f"{entry}.jpg")
    if os.path.exists(cached_file) and os.path.getmtime(cached_file) >= os.path.getmtime(preview_path):
        return cached_file

    try:
        with Image.open(preview_path) as im:
            im.convert("RGB").save(cached_file, "JPEG", quality=85)
        return cached_file
    except Exception:
        return preview_path

def scan_wallpapers():
    """Scans all wallpapers in Steam Workshop and returns enriched metadata"""
    wallpapers = []
    if not os.path.exists(WORKSHOP_DIR):
        return wallpapers

    for entry in sorted(os.listdir(WORKSHOP_DIR)):
        folder = os.path.join(WORKSHOP_DIR, entry)
        if not os.path.isdir(folder):
            continue

        proj_path = os.path.join(folder, "project.json")
        if not os.path.exists(proj_path):
            continue

        try:
            with open(proj_path, "r", encoding="utf-8", errors="ignore") as f:
                data = json.load(f)
        except Exception:
            continue

        # Find preview image
        preview_file = data.get("preview", "preview.jpg")
        preview_path = os.path.join(folder, preview_file)
        if not os.path.exists(preview_path):
            for ext in ["jpg", "jpeg", "png", "gif", "webp"]:
                cand = os.path.join(folder, f"preview.{ext}")
                if os.path.exists(cand):
                    preview_path = cand
                    break
        
        if not os.path.exists(preview_path):
            owui_tex = glob.glob(os.path.join(OWUI_DIR, entry, "textures", "*.*"))
            if owui_tex:
                preview_path = owui_tex[0]

        final_preview = get_cached_preview(entry, preview_path)

        # Parse objects and sponsor layers from scene.pkg
        all_objs, sponsor_ids = find_scene_objects(folder)

        # Parse general properties
        raw_props = data.get("general", {}).get("properties", {})
        props_list = []
        for prop_key, prop_val in raw_props.items():
            if not isinstance(prop_val, dict):
                continue
            p_type = str(prop_val.get("type", "text")).lower()
            p_text = prop_val.get("text", prop_key)
            p_val = prop_val.get("value")
            p_min = prop_val.get("min", 0)
            p_max = prop_val.get("max", 1)
            p_step = prop_val.get("step", 0.05)
            p_options = prop_val.get("options", [])
            
            props_list.append({
                "key": prop_key,
                "type": p_type,
                "text": p_text,
                "value": p_val,
                "min": float(p_min) if isinstance(p_min, (int, float)) else 0.0,
                "max": float(p_max) if isinstance(p_max, (int, float)) else 1.0,
                "step": float(p_step) if isinstance(p_step, (int, float)) else 0.05,
                "options": p_options
            })

        wallpapers.append({
            "id": str(entry),
            "title": data.get("title", entry),
            "type": str(data.get("type", "scene")).lower(),
            "preview": final_preview,
            "tags": data.get("tags", []),
            "contentrating": data.get("contentrating", "Everyone"),
            "properties": props_list,
            "objects": all_objs,
            "sponsor_object_ids": sponsor_ids,
            "folder": folder
        })

    return wallpapers

def get_current_config():
    """Loads wallpaper.json or initializes default"""
    if os.path.exists(CONFIG_FILE):
        try:
            with open(CONFIG_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            pass

    owui = parse_owui_settings()
    active_id = owui.get("active_id", "3522563935")
    default_config = {
        "active_id": active_id,
        "fps": 60,
        "scaling": "fill",
        "clamp": "border",
        "background_color": "#000000",
        "volume": 0,
        "mouse_enabled": True,
        "hide_sponsor": True,
        "screen": "HDMI-A-1",
        "per_wallpaper_settings": {}
    }
    save_config(default_config)
    return default_config

def save_config(cfg):
    """Saves config to ~/.config/bulldoze/wallpaper.json"""
    os.makedirs(os.path.dirname(CONFIG_FILE), exist_ok=True)
    with open(CONFIG_FILE, "w", encoding="utf-8") as f:
        json.dump(cfg, f, indent=2, ensure_ascii=False)

def detect_primary_monitor():
    """Detects active Hyprland monitor"""
    try:
        out = subprocess.check_output(["hyprctl", "monitors", "-j"], text=True)
        mons = json.loads(out)
        if mons and len(mons) > 0:
            for m in mons:
                if m.get("focused"):
                    return m.get("name", "HDMI-A-1")
            return mons[0].get("name", "HDMI-A-1")
    except Exception:
        pass
    return "HDMI-A-1"

def stop_running_wallpaper():
    """Kills any running instance of linux-wallpaperengine or wallpaperd"""
    try:
        subprocess.run(["pkill", "-9", "-f", "linux-wallpaperengine"], stderr=subprocess.DEVNULL)
        subprocess.run(["pkill", "-9", "-f", "wallpaperd"], stderr=subprocess.DEVNULL)
    except Exception:
        pass

def apply_wallpaper(wp_id=None, overrides=None):
    """Applies wallpaper with settings"""
    cfg = get_current_config()
    if wp_id:
        cfg["active_id"] = str(wp_id)
    if overrides and isinstance(overrides, dict):
        for k, v in overrides.items():
            cfg[k] = v

    active_id = str(cfg.get("active_id", "3522563935"))
    screen = cfg.get("screen") or detect_primary_monitor()
    fps = int(cfg.get("fps", 60))
    scaling = cfg.get("scaling", "fill")
    clamp = cfg.get("clamp", "border")
    volume = int(cfg.get("volume", 0))
    mouse = cfg.get("mouse_enabled", True)
    hide_sponsor = cfg.get("hide_sponsor", True)

    wp_settings = cfg.get("per_wallpaper_settings", {}).get(active_id, {})
    custom_props = dict(wp_settings.get("properties", {}))
    skip_objects = set(wp_settings.get("skip_objects", []))
    skip_effects = set(wp_settings.get("skip_effects", []))

    # If hide_sponsor is active, auto-detect and skip sponsor objects
    folder = os.path.join(WORKSHOP_DIR, active_id)
    if hide_sponsor and os.path.exists(folder):
        _, sponsor_ids = find_scene_objects(folder)
        for sid in sponsor_ids:
            skip_objects.add(sid)

    stop_running_wallpaper()

    cmd = [
        "linux-wallpaperengine",
        "--assets-dir", ASSETS_DIR,
        "--screen-root", screen,
        "--bg", active_id,
        "--scaling", scaling,
        "--clamp", clamp,
        "--fps", str(fps)
    ]

    if not mouse:
        cmd.append("--disable-mouse")

    if volume <= 0:
        cmd.append("--silent")
    else:
        cmd.extend(["--volume", str(volume)])

    # Set individual properties
    for p_key, p_val in custom_props.items():
        if isinstance(p_val, bool):
            cmd.extend(["--set-property", f"{p_key}={1 if p_val else 0}"])
        elif isinstance(p_val, (int, float)):
            cmd.extend(["--set-property", f"{p_key}={p_val}"])
        else:
            cmd.extend(["--set-property", f"{p_key}={p_val}"])

    # Skip objects and effects
    for obj_id in sorted(skip_objects):
        cmd.extend(["--render-debug", f"skip-object={obj_id}"])
    for eff_id in sorted(skip_effects):
        cmd.extend(["--render-debug", f"skip-effect={eff_id}"])

    save_config(cfg)

    # Launch daemon in background detached
    subprocess.Popen(
        cmd,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        start_new_session=True
    )

    # Automatically generate clean snapshot for LockScreen & Greeter in background
    subprocess.Popen(
        [sys.executable, os.path.abspath(__file__), "snapshot-silent", active_id],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        start_new_session=True
    )

    return {"status": "ok", "active_id": active_id, "cmd": cmd}

def generate_clean_snapshot(wp_id=None):
    """Captures clean frame with native engine screenshot and updates Lockscreen/Greeter blur"""
    import time
    import shutil
    from PIL import ImageFilter
    
    cfg = get_current_config()
    if wp_id:
        cfg["active_id"] = str(wp_id)
    
    active_id = str(cfg.get("active_id", "3522563935"))
    screen = cfg.get("screen") or detect_primary_monitor()
    scaling = cfg.get("scaling", "fill")
    clamp = cfg.get("clamp", "border")
    hide_sponsor = cfg.get("hide_sponsor", True)
    
    wp_settings = cfg.get("per_wallpaper_settings", {}).get(active_id, {})
    custom_props = dict(wp_settings.get("properties", {}))
    skip_objects = set(wp_settings.get("skip_objects", []))
    skip_effects = set(wp_settings.get("skip_effects", []))

    folder = os.path.join(WORKSHOP_DIR, active_id)
    if hide_sponsor and os.path.exists(folder):
        _, sponsor_ids = find_scene_objects(folder)
        for sid in sponsor_ids:
            skip_objects.add(sid)

    user_cache = os.path.expanduser("~/.cache/bulldoze")
    os.makedirs(user_cache, exist_ok=True)
    temp_snap = os.path.join(user_cache, "Wallpaper_greeter_raw.png")
    user_out = os.path.join(user_cache, "Wallpaper_greeter.png")

    if os.path.exists(temp_snap):
        try:
            os.remove(temp_snap)
        except Exception:
            pass

    # Launch in clean snapshot mode: no mouse, no sound, native engine screenshot
    cmd = [
        "linux-wallpaperengine",
        "--assets-dir", ASSETS_DIR,
        "--screen-root", screen,
        "--bg", active_id,
        "--scaling", scaling,
        "--clamp", clamp,
        "--fps", "60",
        "--disable-mouse",
        "--silent",
        "--screenshot", temp_snap,
        "--screenshot-delay", "25"
    ]
    for p_key, p_val in custom_props.items():
        if isinstance(p_val, bool):
            cmd.extend(["--set-property", f"{p_key}={1 if p_val else 0}"])
        elif isinstance(p_val, (int, float)):
            cmd.extend(["--set-property", f"{p_key}={p_val}"])
        else:
            cmd.extend(["--set-property", f"{p_key}={p_val}"])
            
    for obj_id in sorted(skip_objects):
        cmd.extend(["--render-debug", f"skip-object={obj_id}"])
    for eff_id in sorted(skip_effects):
        cmd.extend(["--render-debug", f"skip-effect={eff_id}"])

    proc = subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    
    # Wait for engine screenshot to be created
    start_time = time.time()
    generated = False
    while time.time() - start_time < 4.0:
        if os.path.exists(temp_snap) and os.path.getsize(temp_snap) > 1000:
            generated = True
            break
        time.sleep(0.05)

    try:
        proc.terminate()
        proc.wait(timeout=1.0)
    except Exception:
        try:
            proc.kill()
        except Exception:
            pass

    # Fallback to workshop preview if engine screenshot failed
    if not generated:
        preview = ""
        for cand in ["preview.jpg", "preview.jpeg", "preview.png", "preview.webp"]:
            p = os.path.join(folder, cand)
            if os.path.exists(p):
                preview = p
                break
        if preview:
            try:
                with Image.open(preview) as im:
                    im.convert("RGB").save(temp_snap, "PNG")
                    generated = True
            except Exception:
                pass

    if generated and os.path.exists(temp_snap):
        try:
            shutil.copy2(temp_snap, user_out)

            # Update /var/lib/greetd if writable
            dst = "/var/lib/greetd/Wallpaper_greeter.png"
            try:
                if os.path.exists(dst) and os.access(dst, os.W_OK):
                    shutil.copy2(user_out, dst)
                elif os.access("/var/lib/greetd", os.W_OK):
                    shutil.copy2(user_out, dst)
            except Exception:
                pass
            return {"status": "ok", "file": user_out}
        except Exception as e:
            sys.stderr.write(f"Snapshot processing error: {e}\n")
    return {"status": "error"}

def capture_clean_snapshot(wp_id=None):
    """Launches clean snapshot and applies interactive wallpaper"""
    stop_running_wallpaper()
    res = generate_clean_snapshot(wp_id)
    cfg = get_current_config()
    active_id = str(wp_id) if wp_id else str(cfg.get("active_id", "3522563935"))
    return apply_wallpaper(active_id)

def main():
    if len(sys.argv) < 2:
        print("Usage: bulldoze-wallpaper.py [list|config|apply <id>|daemon|snapshot|snapshot-silent|save]")
        sys.exit(1)

    action = sys.argv[1]

    if action == "list":
        wallpapers = scan_wallpapers()
        print(json.dumps(wallpapers, ensure_ascii=False))

    elif action == "config":
        cfg = get_current_config()
        print(json.dumps(cfg, ensure_ascii=False))

    elif action == "apply":
        wp_id = sys.argv[2] if len(sys.argv) > 2 else None
        overrides = None
        if len(sys.argv) > 3:
            try:
                overrides = json.loads(sys.argv[3])
            except Exception as e:
                sys.stderr.write(f"Invalid JSON overrides: {e}\n")
        res = apply_wallpaper(wp_id, overrides)
        print(json.dumps(res, ensure_ascii=False))

    elif action == "snapshot":
        wp_id = sys.argv[2] if len(sys.argv) > 2 else None
        res = capture_clean_snapshot(wp_id)
        print(json.dumps(res, ensure_ascii=False))

    elif action == "snapshot-silent":
        wp_id = sys.argv[2] if len(sys.argv) > 2 else None
        res = generate_clean_snapshot(wp_id)
        print(json.dumps(res, ensure_ascii=False))

    elif action == "daemon":
        res = apply_wallpaper()
        print(json.dumps(res, ensure_ascii=False))

    elif action == "save":
        if len(sys.argv) > 2:
            try:
                cfg = json.loads(sys.argv[2])
                save_config(cfg)
                print(json.dumps({"status": "saved"}))
            except Exception as e:
                print(json.dumps({"status": "error", "message": str(e)}))

if __name__ == "__main__":
    main()
