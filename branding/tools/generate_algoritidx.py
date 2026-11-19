"""Generate AlgoritiDx brand assets. Requires Pillow; run from any directory."""
import json
from pathlib import Path
import xml.etree.ElementTree as ET

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1] / 'logo' / 'algoritidx'
NAVY, CORAL, WHITE = '#0B1F3A', '#FF5C39', '#FFFFFF'
# Rounded bars and a central diagnostic cross, in the existing brand vocabulary.
SHAPES = [(8, 14, 56, 20, 6, False), (8, 66, 56, 20, 6, False),
          (8, 40, 74, 20, 6, True), (35, 27, 20, 46, 6, True)]


def write(path, content):
    target = ROOT / path
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(content + '\n', encoding='utf-8')


def symbol(light=False):
    return ''.join(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{r}" fill="{CORAL if accent else WHITE if light else NAVY}"/>'
                   for x, y, w, h, r, accent in SHAPES)


def icon(size, round_icon=False, maskable=False):
    scale = 4
    canvas = Image.new('RGBA', (size * scale, size * scale))
    draw = ImageDraw.Draw(canvas)
    edge = size * scale
    if round_icon:
        draw.ellipse((0, 0, edge - 1, edge - 1), fill=NAVY)
    else:
        draw.rounded_rectangle((0, 0, edge - 1, edge - 1), radius=0 if maskable else edge * .22, fill=NAVY)
    factor = edge * .60 / 100
    ox, oy = edge / 2 - 45 * factor, edge / 2 - 50 * factor
    for x, y, w, h, radius, accent in SHAPES:
        draw.rounded_rectangle((ox + x * factor, oy + y * factor, ox + (x+w) * factor, oy + (y+h) * factor),
                               radius=radius * factor, fill=CORAL if accent else WHITE)
    return canvas.resize((size, size), Image.Resampling.LANCZOS)


def vector(monochrome=False):
    paths = []
    for x, y, w, h, radius, accent in SHAPES:
        x, y, w, h, r = 27 + x * .6, 24 + y * .6, w * .6, h * .6, radius * .6
        d = (f'M{x+r},{y}H{x+w-r}Q{x+w},{y} {x+w},{y+r}V{y+h-r}'
             f'Q{x+w},{y+h} {x+w-r},{y+h}H{x+r}Q{x},{y+h} {x},{y+h-r}'
             f'V{y+r}Q{x},{y} {x+r},{y}Z')
        color = '#FFFF5C39' if accent and not monochrome else '#FFFFFFFF'
        paths.append(f'    <path android:fillColor="{color}" android:pathData="{d}"/>')
    return '<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="108dp" android:height="108dp" android:viewportWidth="108" android:viewportHeight="108">\n' + '\n'.join(paths) + '\n</vector>'


for reversed_mark in (False, True):
    suffix = '-reversed' if reversed_mark else ''
    for wordmark in (False, True):
        kind, width = ('wordmark', 410) if wordmark else ('logo', 90)
        text = (f'<text x="100" y="66" font-family="\'Plus Jakarta Sans\',\'Segoe UI\',system-ui,sans-serif" font-size="46" font-weight="700" letter-spacing="-1.5" fill="{WHITE if reversed_mark else NAVY}">Algoriti<tspan fill="{CORAL}">Dx</tspan></text>' if wordmark else '')
        write(f'svg/algoritidx-{kind}{suffix}.svg', f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width} 100" role="img" aria-label="AlgoritiDx">{symbol(reversed_mark)}{text}</svg>')

write('web/favicon.svg', f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><rect width="100" height="100" rx="22" fill="{NAVY}"/><g transform="translate(23 20) scale(.6)">{symbol(True)}</g></svg>')
for name, size in [('favicon-16x16', 16), ('favicon-32x32', 32), ('favicon-48x48', 48), ('apple-touch-icon', 180), ('icon-192', 192), ('icon-512', 512), ('icon-maskable-512', 512)]:
    icon(size, maskable=name in ('icon-maskable-512', 'apple-touch-icon')).save(ROOT / 'web' / f'{name}.png')
icon(256).save(ROOT / 'web/favicon.ico', sizes=[(n, n) for n in (16, 32, 48, 64)])
write('web/site.webmanifest', json.dumps({'name': 'AlgoritiDx', 'short_name': 'AlgoritiDx', 'icons': [dict(src=f'icon-{n}.png', sizes=f'{n}x{n}', type='image/png') for n in (192, 512)] + [dict(src='icon-maskable-512.png', sizes='512x512', type='image/png', purpose='maskable')], 'theme_color': NAVY, 'background_color': NAVY, 'display': 'standalone'}, indent=2))
for density, size in [('mdpi', 48), ('hdpi', 72), ('xhdpi', 96), ('xxhdpi', 144), ('xxxhdpi', 192)]:
    directory = ROOT / f'android/res/mipmap-{density}'
    directory.mkdir(parents=True, exist_ok=True)
    icon(size).save(directory / 'ic_launcher.png')
    icon(size, round_icon=True).save(directory / 'ic_launcher_round.png')
write('android/res/drawable/ic_launcher_foreground.xml', vector())
write('android/res/drawable/ic_launcher_monochrome.xml', vector(True))
write('android/res/values/ic_launcher_background.xml', f'<resources><color name="ic_launcher_background">{NAVY}</color></resources>')
adaptive = '''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@drawable/ic_launcher_foreground"/>
    <monochrome android:drawable="@drawable/ic_launcher_monochrome"/>
</adaptive-icon>'''
for name in ('ic_launcher', 'ic_launcher_round'):
    write(f'android/res/mipmap-anydpi-v26/{name}.xml', adaptive)
icon(512, maskable=True).save(ROOT / 'android/ic_launcher-playstore.png')

# Validate generated XML/SVG and PNG dimensions on each run.
for path in ROOT.rglob('*'):
    if path.suffix in ('.svg', '.xml'):
        ET.parse(path)
    elif path.suffix == '.png':
        with Image.open(path) as image:
            image.verify()
print(f'Generated and validated {sum(p.is_file() for p in ROOT.rglob("*"))} assets in {ROOT}')
