#!/bin/bash
# Export live XFCE keyboard shortcuts into shortcuts.conf
# Run this on the machine whose shortcuts you want to save.
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT="$DIR/shortcuts.conf"
LIVE="$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml"

if [ ! -f "$LIVE" ]; then
  echo "ERROR: $LIVE not found. Not an XFCE session?"
  exit 1
fi

python3 - "$LIVE" > "$OUT" <<'EOF'
import sys, xml.etree.ElementTree as ET

root = ET.parse(sys.argv[1]).getroot()
for section, kind in (("commands", "app"), ("xfwm4", "window")):
    for p in root.iter("property"):
        if p.get("name") == section:
            custom = p.find("property[@name='custom']")
            if custom is None:
                continue
            for s in custom.findall("property[@type='string']"):
                # window actions are stored as e.g. tile_left_key -> strip suffix
                value = s.get("value")
                if kind == "window" and value.endswith("_key"):
                    value = value[:-4]
                print(f"{kind}\t{s.get('name')}\t{value}")
EOF

echo "Wrote $OUT ($(grep -vc '^#' "$OUT") shortcuts)"
