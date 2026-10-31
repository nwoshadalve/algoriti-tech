"""Copy the web app's production build into the tablet app.

Usage (from algoritiQ/app):
    python tool/bundle_web.py [path to web/dist]

The tablet serves these files at `/` (see lib/api/web_site.dart). Run
`npm run build` in algoritiQ/web first, then this, then build the app.
Flutter bundles assets folder by folder, so every folder of the build must be
listed in pubspec.yaml under `assets/web/...`; this script stops if one is not.
"""
import re
import shutil
import sys
from pathlib import Path

app = Path(__file__).resolve().parent.parent
dist = Path(sys.argv[1]) if len(sys.argv) > 1 else app.parent / "web" / "dist"
target = app / "assets" / "web"

if not (dist / "index.html").is_file():
    sys.exit(f"No build at {dist}: run `npm run build` in algoritiQ/web first.")

declared = set(re.findall(r"^\s*-\s*(assets/web/[^\s#]*)\s*$", (app / "pubspec.yaml").read_text(encoding="utf-8"), re.M))
folders = {"assets/web/"} | {
    f"assets/web/{path.relative_to(dist).as_posix()}/" for path in dist.rglob("*") if path.is_dir()
}
missing = sorted(folders - declared)
if missing:
    sys.exit("Add these folders to the assets list in pubspec.yaml:\n  - " + "\n  - ".join(missing))

if target.exists():
    shutil.rmtree(target)
shutil.copytree(dist, target)
files = [path for path in target.rglob("*") if path.is_file()]
size = sum(path.stat().st_size for path in files)
print(f"Bundled {len(files)} files ({size / 1024:.0f} KiB) into {target.relative_to(app)}")
