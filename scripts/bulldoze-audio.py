#!/usr/bin/env python3
import sys
import subprocess
import re
import json

def get_device_icon(name):
    n = name.lower()
    if any(k in n for k in ["headphone", "headset", "earphone", "buds", "airpods", "earbuds", "fone"]):
        return ""
    if any(k in n for k in ["hdmi", "displayport", "dp", "tv", "ultragear", "monitor"]):
        return "󰍹"
    if any(k in n for k in ["bluetooth", "bluez", "jbl", "boombox", "sound"]):
        return ""
    return ""

def list_sinks():
    try:
        out = subprocess.check_output(["wpctl", "status"], text=True)
    except Exception as e:
        print(json.dumps([]))
        return

    sinks = []
    in_sinks = False
    for line in out.splitlines():
        if "Sinks:" in line:
            in_sinks = True
            continue
        if in_sinks:
            if not line.strip() or line.startswith(" ├─") or line.startswith(" └─") or line.startswith(" ──") or line.startswith(" │  ├─") or line.startswith(" │  └─"):
                if "Sources:" in line or "Filters:" in line or "Streams:" in line or "Devices:" in line:
                    break
            if "Sources:" in line or "Filters:" in line or "Streams:" in line or "Devices:" in line:
                break
            m = re.search(r'([*]?)\s*(\d+)\.\s+(.*?)(?:\s+\[vol:.*?\])?$', line)
            if m:
                is_default = bool(m.group(1))
                sink_id = int(m.group(2))
                raw_name = m.group(3).strip()
                sinks.append({
                    "id": sink_id,
                    "name": raw_name,
                    "isDefault": is_default,
                    "icon": get_device_icon(raw_name)
                })

    print(json.dumps(sinks))

def set_sink(sink_id):
    try:
        subprocess.run(["wpctl", "set-default", str(sink_id)], check=True)
    except Exception as e:
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        cmd = sys.argv[1]
        if cmd == "sinks":
            list_sinks()
        elif cmd == "set-sink" and len(sys.argv) > 2:
            set_sink(sys.argv[2])
        else:
            list_sinks()
    else:
        list_sinks()
