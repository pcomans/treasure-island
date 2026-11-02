#!/usr/bin/env python3
"""Tree shootout variant B: unpacks Sketchfab downloads for the driver.

    python3 -I tools/tree_shootout/stage_sketchfab.py DROP_DIR

Each zip in DROP_DIR (or loose .glb) whose name mentions the palm or a conifer
stand-in is unpacked into its own new folder,
game/resources/_eval/sketchfab/<palm|cypress>/, which .git/info/exclude keeps
out of Git. Downloads are untrusted data: members with absolute paths or ".."
are refused and nothing from them is executed. Run tools/godot --import after.
"""

import shutil
import sys
import zipfile
from pathlib import Path

EVAL = Path(__file__).resolve().parents[2] / "game" / "resources" / "_eval" / "sketchfab"
# First match wins per species; the cypress stand-ins in order of preference.
KEYWORDS = {"palm": ["mexican_fan_palm", "mexican-fan-palm", "washingtonia", "palm"], "cypress": ["umbrella", "cedar", "cypress", "pine"]}


def species_for(name):
    lower = name.lower()
    for species, words in KEYWORDS.items():
        for rank, word in enumerate(words):
            if word in lower:
                return species, rank
    return None, None


def safe_extract(archive, target):
    with zipfile.ZipFile(archive) as bundle:
        for member in bundle.infolist():
            path = Path(member.filename)
            if path.is_absolute() or ".." in path.parts:
                raise ValueError(f"refusing unsafe member {member.filename!r} in {archive}")
        bundle.extractall(target)


def main():
    drop = Path(sys.argv[1])
    chosen = {}
    for item in sorted(drop.iterdir()):
        if item.suffix.lower() not in (".zip", ".glb"):
            continue
        species, rank = species_for(item.name)
        if species and (species not in chosen or rank < chosen[species][1]):
            chosen[species] = (item, rank)
    for species, (item, _rank) in chosen.items():
        target = EVAL / species
        if target.exists():
            shutil.rmtree(target)
        target.mkdir(parents=True)
        if item.suffix.lower() == ".zip":
            safe_extract(item, target)
        else:
            shutil.copyfile(item, target / item.name)
        scenes = [p for p in target.rglob("*") if p.suffix.lower() in (".gltf", ".glb")]
        print(f"{species}: {item.name} -> {target} ({', '.join(str(p.relative_to(target)) for p in scenes) or 'no glTF found'})")
        # The driver looks for the scene directly in the species folder.
        for scene in scenes:
            if scene.parent != target:
                print(f"  note: scene is in {scene.parent.relative_to(target)}; move its folder contents up if the driver cannot find it")
        for licence in target.rglob("license.txt"):
            print("  licence file:", licence.read_text(errors="replace").strip().replace("\n", " | ")[:400])
    if not chosen:
        print("no Sketchfab downloads found in", drop)


if __name__ == "__main__":
    main()
