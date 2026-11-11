#!/usr/bin/env python3
"""Draws the icons for the Khmer Calendar update service and background service.

Both are the app icon with a badge in the bottom-right corner:
  update.*  down arrow  (the updater)
  bg.*      gear        (the background service)

Nothing is edited by hand: the badge position comes from the visible shape of the
app icon and the badge colours are picked from the app icon's own palette, so when
khmer_calendar/assets/icons/icon-512.png changes, just run this again (CI does it
before packaging, see generate.sh).

Outputs, next to this script: <name>.png (512), <name>.ico (16-256, PNG frames),
<name>.icns (macOS). Needs Pillow:  pip install pillow
Run from anywhere:  python3 tools/icons/make_icons.py
Options:  --base FILE  --update-color #RRGGBB  --bg-color #RRGGBB  --out DIR
"""
import argparse, colorsys, io, math, os, struct
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
BASE = os.path.join(HERE, '..', '..', 'khmer_calendar', 'assets', 'icons', 'icon-512.png')

SS = 4                         # supersampling for smooth edges
# Fallbacks, used only if the palette cannot be read from the icon.
WHITE = (255, 255, 255, 255)
UPDATE_COLOR = (107, 33, 32, 255)    # deep maroon
BG_COLOR = (228, 180, 85, 255)       # gold


def hsv(c):
    h, s, v = colorsys.rgb_to_hsv(c[0] / 255, c[1] / 255, c[2] / 255)
    return h * 360, s, v


def pick_palette(path):
    """Returns (paper, update_color, bg_color) taken from the app icon itself."""
    im = Image.open(path).convert('RGBA')
    px = Image.new('RGB', im.size, (0, 0, 0))
    px.paste(im, mask=im.getchannel('A'))
    q = px.quantize(colors=10, method=Image.MEDIANCUT)
    pal = q.getpalette()
    found = [(n, tuple(pal[i * 3:i * 3 + 3])) for n, i in q.getcolors()]
    total = sum(n for n, _ in found)
    big = [(n, c) for n, c in found if n >= total * 0.01]

    def best(test, key):
        pool = [(n, c) for n, c in big if test(hsv(c))]
        return max(pool, key=key)[1] + (255,) if pool else None

    paper = best(lambda t: t[1] < 0.15 and t[2] > 0.9, lambda x: x[0]) or WHITE
    gold = best(lambda t: 25 <= t[0] <= 60 and t[1] > 0.45 and t[2] > 0.7, lambda x: x[0]) or BG_COLOR
    dark = best(lambda t: (t[0] <= 20 or t[0] >= 340) and t[1] > 0.45 and t[2] < 0.55,
                lambda x: -hsv(x[1])[2]) or UPDATE_COLOR
    return paper, dark, gold


def hex_color(v):
    v = v.lstrip('#')
    return (int(v[0:2], 16), int(v[2:4], 16), int(v[4:6], 16), 255)


def visible_box(base):
    """Fraction box (x0, y0, x1, y1) of the icon's visible shape (transparent margins are skipped)."""
    b = base.getchannel('A').point(lambda a: 255 if a > 16 else 0).getbbox() or (0, 0) + base.size
    w, h = base.size
    return b[0] / w, b[1] / h, b[2] / w, b[3] / h


def gear(d, cx, cy, r, color, hole_color):
    teeth, outer, inner, tooth_w = 8, r, r * 0.74, 0.30
    pts = []
    for i in range(teeth):
        a = 2 * math.pi * i / teeth
        for da, rad in ((-tooth_w * 1.35, inner), (-tooth_w * 0.8, outer),
                        (tooth_w * 0.8, outer), (tooth_w * 1.35, inner)):
            pts.append((cx + rad * math.cos(a + da), cy + rad * math.sin(a + da)))
    d.polygon(pts, fill=color)
    d.ellipse([cx - inner, cy - inner, cx + inner, cy + inner], fill=color)
    hr = r * 0.34
    d.ellipse([cx - hr, cy - hr, cx + hr, cy + hr], fill=hole_color)


def arrow_down(d, cx, cy, r, color):
    sw = r * 0.26                                  # shaft half width
    top, neck, tip = cy - r * 0.62, cy + r * 0.02, cy + r * 0.50
    d.rectangle([cx - sw, top, cx + sw, neck], fill=color)
    d.polygon([(cx - r * 0.58, neck - r * 0.04), (cx + r * 0.58, neck - r * 0.04), (cx, tip)], fill=color)


def render(kind, size):
    base = BASE_IMG.resize((size, size), Image.LANCZOS)
    big = size * SS
    layer = Image.new('RGBA', (big, big), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    frac = 0.60 if size <= 32 else 0.50 if size <= 64 else 0.38   # bigger badge when tiny
    r = big * frac / 2
    x0, y0, x1, y1 = BOX
    cx = big * x1 - r - big * 0.0   # bottom-right corner of the visible icon
    cy = big * y1 - r - big * 0.0
    ring = max(SS * 1.2, r * 0.10)
    fill = UPDATE_COLOR if kind == 'update' else BG_COLOR
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=PAPER)
    d.ellipse([cx - r + ring, cy - r + ring, cx + r - ring, cy + r - ring], fill=fill)
    inner = r - ring
    if kind == 'update':
        arrow_down(d, cx, cy, inner * 0.80, PAPER)
    else:
        gear(d, cx, cy, inner * 0.78, PAPER, fill)
    layer = layer.resize((size, size), Image.LANCZOS)
    return Image.alpha_composite(base, layer)


def png_bytes(im):
    b = io.BytesIO(); im.save(b, 'PNG', optimize=True); return b.getvalue()


def write_ico(path, frames):
    out = struct.pack('<HHH', 0, 1, len(frames))
    data, off = b'', 6 + 16 * len(frames)
    for s, im in frames:
        p = png_bytes(im)
        out += struct.pack('<BBBBHHII', 0 if s >= 256 else s, 0 if s >= 256 else s, 0, 0, 1, 32, len(p), off + len(data))
        data += p
    open(path, 'wb').write(out + data)


ap = argparse.ArgumentParser(description=__doc__.split('\n')[0])
ap.add_argument('--base', default=BASE)
ap.add_argument('--out', default=HERE)
ap.add_argument('--update-color')
ap.add_argument('--bg-color')
args = ap.parse_args()
BASE_IMG = Image.open(args.base).convert('RGBA')
BOX = visible_box(BASE_IMG)
PAPER, UPDATE_COLOR, BG_COLOR = pick_palette(args.base)
if args.update_color: UPDATE_COLOR = hex_color(args.update_color)
if args.bg_color: BG_COLOR = hex_color(args.bg_color)
print('badge colours: update', UPDATE_COLOR[:3], 'bg', BG_COLOR[:3], 'ring', PAPER[:3], 'icon box', BOX)
os.makedirs(args.out, exist_ok=True)
HERE = args.out

for kind, name in (('update', 'update'), ('bg', 'bg')):
    sizes = (16, 24, 32, 48, 64, 128, 256)
    write_ico(os.path.join(HERE, name + '.ico'), [(s, render(kind, s)) for s in sizes])
    big512 = render(kind, 512)
    big512.save(os.path.join(HERE, name + '.png'), optimize=True)
    big512.save(os.path.join(HERE, name + '.icns'), sizes=[(16, 16), (32, 32), (64, 64), (128, 128), (256, 256), (512, 512)])
    print('wrote', name)
