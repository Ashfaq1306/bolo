"""Draws Bolo's app icon (the cute robot head) at every Android density.

Run:  python scripts/make_icons.py
Writes legacy icons (mipmap-*/ic_launcher.png), adaptive-icon foregrounds
(mipmap-*/ic_launcher_foreground.png) and a 512 px store icon (assets/icon/).
Requires Pillow.
"""
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
RES = ROOT / "app/android/app/src/main/res"
NAVY = (11, 16, 38)
TEAL = (45, 212, 191)
VIOLET = (124, 92, 255)
LED = (125, 249, 255)
METAL = (207, 216, 227)
METAL_DARK = (107, 122, 144)


def robot(size: int, background: bool) -> Image.Image:
    s = size * 4  # supersample for smooth edges
    img = Image.new("RGBA", (s, s), NAVY + (255,) if background else (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cx, cy = s / 2, s / 2 + s * 0.04
    # Adaptive icons get cropped to a circle/squircle: keep the head inside the safe zone.
    r = s * (0.30 if not background else 0.33)

    # Glow behind the head.
    glow = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    ImageDraw.Draw(glow).ellipse([cx - r * 1.25, cy - r * 1.25, cx + r * 1.25, cy + r * 1.25], fill=TEAL + (110,))
    img.alpha_composite(glow.filter(ImageFilter.GaussianBlur(s * 0.05)))

    # Antenna.
    d.line([cx, cy - r * 0.9, cx, cy - r * 1.32], fill=METAL_DARK, width=int(r * 0.08))
    b = r * 0.12
    d.ellipse([cx - b, cy - r * 1.32 - b, cx + b, cy - r * 1.32 + b], fill=LED)

    # Ears.
    for side in (-1, 1):
        ex = cx + side * r * 1.0
        er = r * 0.22
        d.ellipse([ex - er, cy - er, ex + er, cy + er], fill=METAL)
        d.ellipse([ex - er * 0.55, cy - er * 0.55, ex + er * 0.55, cy + er * 0.55], fill=LED)

    # Head: teal → violet orb.
    head = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    hd = ImageDraw.Draw(head)
    steps = 40
    for i in range(steps):
        t = i / steps
        col = tuple(int(TEAL[k] * (1 - t) + VIOLET[k] * t) for k in range(3)) + (255,)
        rr = r * (1 - t * 0.35)
        ox, oy = -r * 0.25 * t, -r * 0.3 * t
        hd.ellipse([cx + ox - rr, cy + oy - rr, cx + ox + rr, cy + oy + rr], fill=col)
    mask = Image.new("L", (s, s), 0)
    ImageDraw.Draw(mask).ellipse([cx - r, cy - r, cx + r, cy + r], fill=255)
    img.paste(head, (0, 0), mask)

    # Visor.
    vw, vh = r * 1.42, r * 0.72
    vy = cy - r * 0.12
    d.rounded_rectangle([cx - vw / 2, vy - vh / 2, cx + vw / 2, vy + vh / 2], radius=vh / 2, fill=(9, 14, 28))
    # LED eyes.
    for side in (-1, 1):
        ex = cx + side * r * 0.32
        ew, eh = r * 0.26, r * 0.34
        d.rounded_rectangle([ex - ew / 2, vy - eh / 2, ex + ew / 2, vy + eh / 2], radius=ew / 2, fill=LED)
        d.rounded_rectangle([ex - ew * 0.32, vy - eh * 0.38, ex - ew * 0.02, vy - eh * 0.16], radius=ew * 0.1, fill=(255, 255, 255))
    # Smile: LED bars.
    bars = 7
    width = r * 0.62
    for i in range(bars):
        u = i / (bars - 1) * 2 - 1
        x = cx + u * width / 2
        y = cy + r * 0.45 - r * 0.12 * u * u
        h = r * (0.07 + 0.08 * (1 - abs(u)))
        w = width / (bars - 1) * 0.62
        d.rounded_rectangle([x - w / 2, y - h / 2, x + w / 2, y + h / 2], radius=w / 2, fill=LED)

    return img.resize((size, size), Image.LANCZOS)


def main() -> None:
    legacy = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}
    for density, px in legacy.items():
        out = RES / f"mipmap-{density}"
        out.mkdir(parents=True, exist_ok=True)
        icon = robot(px, background=True)
        # Round legacy icon.
        m = Image.new("L", (px * 4, px * 4), 0)
        ImageDraw.Draw(m).ellipse([0, 0, px * 4 - 1, px * 4 - 1], fill=255)
        rounded = Image.new("RGBA", (px, px), (0, 0, 0, 0))
        rounded.paste(icon, (0, 0), m.resize((px, px), Image.LANCZOS))
        rounded.save(out / "ic_launcher.png")
        # Adaptive foreground is 108dp with the 72dp safe zone in the middle.
        robot(int(px * 108 / 48), background=False).save(out / "ic_launcher_foreground.png")
    anydpi = RES / "mipmap-anydpi-v26"
    anydpi.mkdir(exist_ok=True)
    (anydpi / "ic_launcher.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <background android:drawable="@color/ic_launcher_background"/>\n'
        '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
        '    <monochrome android:drawable="@drawable/ic_stat_bolo"/>\n'
        "</adaptive-icon>\n",
        encoding="utf-8",
    )
    (RES / "values/ic_launcher_background.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n<resources>\n    <color name="ic_launcher_background">#0B1026</color>\n</resources>\n',
        encoding="utf-8",
    )
    store = ROOT / "app/assets/icon"
    store.mkdir(parents=True, exist_ok=True)
    robot(512, background=True).save(store / "bolo_icon_512.png")
    print("icons written")


if __name__ == "__main__":
    main()
