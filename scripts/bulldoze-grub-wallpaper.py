#!/usr/bin/env python3
"""
Bulldoze 3.0 — GRUB Wallpaper & Theme Baker
Bakes a clean frosted glass card with rounded corners (20px)
and Gaussian blur directly into the GRUB wallpaper for QHD (2560x1440).
Strictly follows design.md: pure smooth blur, no borders, no dark slab.
"""
import os
import sys
import argparse
import subprocess
import shutil
import json
import time
from PIL import Image, ImageDraw, ImageFilter

CARD_X = 60
CARD_Y = 520
CARD_W = 560
CARD_H = 620
RADIUS = 20

def ensure_selection_pixmaps(theme_dir):
    """
    Generates compact Spotlight-style 9-slice selection box for GRUB boot menu:
    - Frosted glass light highlight fill (~20% white)
    - Crisp 1px glass border (~35% white)
    - 8px smooth antialiased corner radius
    """
    os.makedirs(theme_dir, exist_ok=True)
    scale = 8
    corner_size = 8
    radius = 8
    cs = corner_size * scale
    r = radius * scale
    w = cs * 2 + 16 * scale
    h = cs * 2 + 16 * scale

    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    fill_color = (255, 255, 255, 48)
    border_color = (255, 255, 255, 90)
    border_width = 1 * scale

    draw.rounded_rectangle(
        [(0, 0), (w - 1, h - 1)],
        radius=r,
        fill=fill_color,
        outline=border_color,
        width=border_width
    )

    target_w = w // scale
    target_h = h // scale
    final_img = img.resize((target_w, target_h), Image.Resampling.LANCZOS)

    cw = corner_size
    ch = corner_size
    cx = cw + 4
    cy = ch + 4

    slices = {
        "nw": final_img.crop((0, 0, cw, ch)),
        "ne": final_img.crop((target_w - cw, 0, target_w, ch)),
        "sw": final_img.crop((0, target_h - ch, cw, target_h)),
        "se": final_img.crop((target_w - cw, target_h - ch, target_w, target_h)),
        "n": final_img.crop((cx, 0, cx + 1, ch)),
        "s": final_img.crop((cx, target_h - ch, cx + 1, target_h)),
        "w": final_img.crop((0, cy, cw, cy + 1)),
        "e": final_img.crop((target_w - cw, cy, target_w, cy + 1)),
        "c": final_img.crop((cx, cy, cx + 1, cy + 1))
    }

    for name, slice_im in slices.items():
        slice_im.save(os.path.join(theme_dir, f"select_{name}.png"))

def find_best_source_image(src_path, wallpaper_id=None):
    if not src_path and not wallpaper_id:
        return None
        
    cache_dir = os.path.expanduser("~/.cache/bulldoze")
    os.makedirs(cache_dir, exist_ok=True)
    
    # 1. Determine wallpaper ID
    wp_id = str(wallpaper_id).strip() if wallpaper_id else ""
    if not wp_id and src_path and "workshop/content/431960/" in src_path:
        parts = src_path.split("workshop/content/431960/")
        if len(parts) > 1:
            wp_id = parts[1].split("/")[0]

    # 2. Check for high-res snapshot in cache or generate it
    if wp_id:
        hires_cand = os.path.join(cache_dir, f"Wallpaper_hires_{wp_id}.png")
        if os.path.exists(hires_cand) and os.path.getsize(hires_cand) > 1000:
            return hires_cand
            
        # Try generating high-res snapshot via bulldoze-wallpaper.py
        try:
            script_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "bulldoze-wallpaper.py")
            res = subprocess.run(
                [sys.executable, script_path, "snapshot-hires", wp_id],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                timeout=12
            )
            if os.path.exists(hires_cand) and os.path.getsize(hires_cand) > 1000:
                return hires_cand
        except Exception as e:
            sys.stderr.write(f"Warning: Failed to capture high-res snapshot for {wp_id}: {e}\n")

    # 3. If src_path is a direct image
    if src_path and os.path.exists(src_path):
        if not src_path.endswith("grub_background.png") and not src_path.endswith("grub/background.png"):
            basename = os.path.basename(src_path)
            base_id = os.path.splitext(basename)[0]
            hires_cand = os.path.join(cache_dir, f"Wallpaper_hires_{base_id}.png")
            if os.path.exists(hires_cand) and os.path.getsize(hires_cand) > 1000:
                return hires_cand
            return src_path

    greeter_cand = os.path.join(cache_dir, "Wallpaper_greeter.png")
    if os.path.exists(greeter_cand) and os.path.getsize(greeter_cand) > 1000:
        return greeter_cand
        
    return src_path

def bake_grub_background(src_wallpaper_path, out_theme_path, out_cache_path, wallpaper_id=None):
    resolved_path = find_best_source_image(src_wallpaper_path, wallpaper_id)
    if not resolved_path or not os.path.exists(resolved_path):
        print(f"Error: Source wallpaper not found at {src_wallpaper_path}", file=sys.stderr)
        return False

    # 1. Open and scale base wallpaper with aspect-fill (center crop to 16:9 2560x1440)
    img = Image.open(resolved_path).convert("RGB")
    target_w, target_h = 2560, 1440
    if img.size != (target_w, target_h):
        src_w, src_h = img.size
        target_ratio = target_w / target_h
        src_ratio = src_w / src_h

        if src_ratio > target_ratio:
            new_w = int(src_h * target_ratio)
            left = (src_w - new_w) // 2
            img = img.crop((left, 0, left + new_w, src_h))
        elif src_ratio < target_ratio:
            new_h = int(src_w / target_ratio)
            top = (src_h - new_h) // 2
            img = img.crop((0, top, src_w, top + new_h))

        img = img.resize((target_w, target_h), Image.Resampling.LANCZOS)

    scale = 4
    W_s = CARD_W * scale
    H_s = CARD_H * scale
    r_s = RADIUS * scale

    # 2. Antialiased rounded rectangle mask (NO BORDERS, radius 20px)
    mask_hires = Image.new("L", (W_s, H_s), 0)
    draw_m = ImageDraw.Draw(mask_hires)
    draw_m.rounded_rectangle([(0, 0), (W_s - 1, H_s - 1)], radius=r_s, fill=255)
    mask = mask_hires.resize((CARD_W, CARD_H), resample=Image.Resampling.LANCZOS)

    # 3. Gaussian blur under card area (radius 30, exactly matching design.md blur)
    pad = 40
    crop_x1 = max(0, CARD_X - pad)
    crop_y1 = max(0, CARD_Y - pad)
    crop_x2 = min(2560, CARD_X + CARD_W + pad)
    crop_y2 = min(1440, CARD_Y + CARD_H + pad)

    crop_region = img.crop((crop_x1, crop_y1, crop_x2, crop_y2))
    blurred_crop = crop_region.filter(ImageFilter.GaussianBlur(radius=30))

    offset_x = CARD_X - crop_x1
    offset_y = CARD_Y - crop_y1
    card_blurred = blurred_crop.crop((offset_x, offset_y, offset_x + CARD_W, offset_y + CARD_H)).convert("RGBA")

    # 4. Very subtle optical glass tint (design.md glassFill ~15% alpha black only for soft text legibility)
    # NO BORDERS, NO HEAVY DARK SLAB
    glass_hires = Image.new("RGBA", (W_s, H_s), (0, 0, 0, 0))
    draw_g = ImageDraw.Draw(glass_hires)
    draw_g.rounded_rectangle([(0, 0), (W_s - 1, H_s - 1)], radius=r_s, fill=(0, 0, 0, 32))
    glass_layer = glass_hires.resize((CARD_W, CARD_H), resample=Image.Resampling.LANCZOS)

    # 5. Composite blur + faint glass tint
    card_composite = Image.alpha_composite(card_blurred, glass_layer)

    # 6. Paste back onto base wallpaper with smooth antialiased mask
    img.paste(card_composite, (CARD_X, CARD_Y), mask)

    # Save to local theme repo
    theme_dir = os.path.dirname(out_theme_path)
    os.makedirs(theme_dir, exist_ok=True)
    img.save(out_theme_path, "PNG", optimize=True)

    # Ensure Spotlight-style 9-slice selection box pixmaps exist
    ensure_selection_pixmaps(theme_dir)

    # Save to user cache
    if out_cache_path:
        os.makedirs(os.path.dirname(out_cache_path), exist_ok=True)
        shutil.copy2(out_theme_path, out_cache_path)

    # Sync to /boot/grub/themes/bulldoze/background.png
    boot_theme_bg = "/boot/grub/themes/bulldoze/background.png"
    synced = False
    try:
        if os.path.exists(boot_theme_bg) and os.access(boot_theme_bg, os.W_OK):
            shutil.copy2(out_theme_path, boot_theme_bg)
            synced = True
    except Exception:
        pass

    if not synced:
        try:
            res = subprocess.run(
                ["sudo", "-n", "/usr/local/bin/bulldoze-sync-grub-bg"],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                timeout=3
            )
            synced = (res.returncode == 0)
        except Exception:
            pass

    print(f"SUCCESS: Baked and applied GRUB wallpaper to {out_theme_path} (synced to boot: {synced})")
    return True

def save_grub_state(image_path, wallpaper_id="", wallpaper_title=""):
    config_dir = os.path.expanduser("~/.config/bulldoze")
    os.makedirs(config_dir, exist_ok=True)
    state_file = os.path.join(config_dir, "grub_wallpaper.json")

    # If id not provided, try to detect from path
    if not wallpaper_id and "workshop/content/431960/" in image_path:
        parts = image_path.split("workshop/content/431960/")
        if len(parts) > 1:
            wallpaper_id = parts[1].split("/")[0]

    # If title not provided, try to read project.json if steam workshop
    if not wallpaper_title and wallpaper_id:
        parent_dir = os.path.dirname(image_path)
        project_file = os.path.join(parent_dir, "project.json")
        if os.path.isfile(project_file):
            try:
                with open(project_file, "r", encoding="utf-8") as f:
                    pdata = json.load(f)
                    wallpaper_title = pdata.get("title", "")
            except Exception:
                pass

    if not wallpaper_title:
        wallpaper_title = os.path.basename(image_path)

    state = {
        "id": wallpaper_id,
        "title": wallpaper_title,
        "path": image_path,
        "timestamp": int(time.time())
    }

    try:
        with open(state_file, "w", encoding="utf-8") as f:
            json.dump(state, f, indent=2, ensure_ascii=False)
    except Exception as e:
        print(f"Warning: Failed to save {state_file}: {e}", file=sys.stderr)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Bulldoze GRUB Wallpaper Baker")
    parser.add_argument("--image", "-i", required=True, help="Path to source wallpaper image")
    parser.add_argument("--id", default="", help="Wallpaper ID")
    parser.add_argument("--title", default="", help="Wallpaper Title")
    args = parser.parse_args()

    theme_bg = os.path.expanduser("~/.config/quickshell/bulldoze/grub/background.png")
    cache_bg = os.path.expanduser("~/.cache/bulldoze/grub_background.png")

    ok = bake_grub_background(args.image, theme_bg, cache_bg, args.id)
    if ok:
        save_grub_state(args.image, args.id, args.title)
    sys.exit(0 if ok else 1)
