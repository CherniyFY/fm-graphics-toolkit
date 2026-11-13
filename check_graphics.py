#!/usr/bin/env python3
# Validate a Football Manager graphics folder: every config.xml record must
# resolve to a file that exists next to that config.xml.
#
# Usage: check_graphics.py <graphics-root>
# Output: one summary line plus up to 20 missing mappings and 10 XML errors.
import sys
from pathlib import Path
import xml.etree.ElementTree as ET

if len(sys.argv) != 2:
    raise SystemExit("usage: check_graphics.py <graphics-root>")

base = Path(sys.argv[1])
if not base.is_dir():
    raise SystemExit(f"error: not a directory: {base}")

mappings = 0
missing = []
errors = []
configs = 0

for cfg in sorted(base.rglob("config.xml")):
    configs += 1
    try:
        root = ET.parse(cfg).getroot()
    except Exception as e:
        errors.append((str(cfg), repr(e)))
        continue
    for rec in root.iter("record"):
        src = rec.attrib.get("from")
        if not src:
            continue
        mappings += 1
        p = cfg.parent / src.replace("\\", "/")
        cands = [p, p.with_suffix(".png"), p.with_name(p.name + ".png")]
        if not any(c.exists() for c in cands):
            missing.append((str(cfg.relative_to(base)), src))

print(f"configs={configs} mappings={mappings} xml_errors={len(errors)} missing={len(missing)}")
for cfg, src in missing[:20]:
    print("MISSING", cfg, src)
for cfg, err in errors[:10]:
    print("XMLERR", cfg, err)
