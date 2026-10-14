#!/usr/bin/env python3
"""Regenerate docs/ pages from the skill sources so there is a single source of truth.

Front matter (title, nav_order) is kept from the table below; bodies are copied verbatim
from skills/. Run from anywhere: python3 scripts/build-docs.py
"""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DEV = ROOT / "skills/sailfishos-dev"
PAGES = [  # (docs file, title, nav_order, source)
    ("skill.md", "Skill Overview", 2, DEV / "SKILL.md"),
    ("silica-components.md", "Silica Components", 3, DEV / "references/silica-components.md"),
    ("design-guidelines.md", "Design Guidelines", 4, DEV / "references/design-guidelines.md"),
    ("harbour.md", "Harbour Submission", 5, DEV / "references/harbour.md"),
    ("platform-apis.md", "Platform APIs", 6, DEV / "references/platform-apis.md"),
    ("host-linux.md", "Linux Host", 8, DEV / "references/host-linux.md"),
    ("setup.md", "Setup and Updates", 9, ROOT / "skills/sailfishos-setup/SKILL.md"),
]

def body(path: Path) -> str:
    return re.sub(r"\A---\n.*?\n---\n", "", path.read_text(), count=1, flags=re.S).lstrip("\n")

for name, title, order, src in PAGES:
    (ROOT / "docs" / name).write_text(f"---\ntitle: {title}\nnav_order: {order}\n---\n\n{body(src)}")
print(f"wrote {len(PAGES)} pages")
