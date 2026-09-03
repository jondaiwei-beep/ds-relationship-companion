#!/usr/bin/env python3
"""Rasterise the frozen emblem (app/assets/svg/emblem-ritual-evening.svg) into
the Android launcher icons and the launch splash.

No SVG toolchain is assumed: the emblem is four strokes, so it is drawn
straight from the same coordinates the SVG carries. Re-run after changing the
master; the outputs are committed.

  python3 ops/render-emblem.py
"""
from pathlib import Path
from PIL import Image, ImageDraw

CANVAS = (0x08, 0x0B, 0x07)      # DsColors.canvasRitual
INK = (0xE8, 0xE3, 0xD6)         # ivory, as the emblem renders on the ritual surface
RES = Path(__file__).resolve().parents[1] / "client/android/app/src/main/res"
SS = 4                           # supersampling


def cubic(p0, p1, p2, p3, n=48):
    pts = []
    for i in range(n + 1):
        t = i / n
        u = 1 - t
        pts.append((u**3 * p0[0] + 3 * u * u * t * p1[0] + 3 * u * t * t * p2[0] + t**3 * p3[0],
                    u**3 * p0[1] + 3 * u * u * t * p1[1] + 3 * u * t * t * p2[1] + t**3 * p3[1]))
    return pts


def emblem(size_px, height_frac, background):
    """Square image, emblem centred, emblem height = height_frac of the side."""
    s = size_px * SS
    img = Image.new("RGBA", (s, s), background + (255,) if background else (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # SVG viewBox 0 0 64 88 → scale so the 80-unit vertical stroke is height_frac
    k = s * height_frac / 80
    ox, oy = s / 2 - 32 * k, s / 2 - 44 * k
    P = lambda x, y: (ox + x * k, oy + y * k)
    w = max(1, round(1.6 * k))
    d.line([P(32, 4), P(32, 84)], fill=INK, width=w)
    d.ellipse([P(13, 15), P(51, 73)], outline=INK, width=w)
    # M32 15 c-13 13 -13 45 0 58  (relative cubic) and its mirror
    for sgn in (-1, 1):
        d.line(cubic(P(32, 15), P(32 + sgn * -13, 28), P(32 + sgn * -13, 60), P(32, 73)), fill=INK, width=w, joint="curve")
    # M24 18 c-7 15 -7 37 0 52 / M40 18 c7 15 7 37 0 52  at .7 opacity
    soft = tuple(round(c * 0.7 + b * 0.3) for c, b in zip(INK, background or CANVAS))
    d.line(cubic(P(24, 18), P(17, 33), P(17, 55), P(24, 70)), fill=soft, width=w, joint="curve")
    d.line(cubic(P(40, 18), P(47, 33), P(47, 55), P(40, 70)), fill=soft, width=w, joint="curve")
    return img.resize((size_px, size_px), Image.LANCZOS)


def main():
    # Legacy launcher icons: full-bleed canvas, emblem at 58% (the OS masks
    # the square, so the emblem must sit well inside).
    for dpi, px in {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}.items():
        emblem(px, 0.58, CANVAS).save(RES / f"mipmap-{dpi}/ic_launcher.png")
    # Adaptive foreground: 108dp canvas, safe zone is the inner 66dp.
    for dpi, px in {"mdpi": 108, "hdpi": 162, "xhdpi": 216, "xxhdpi": 324, "xxxhdpi": 432}.items():
        emblem(px, 0.50, None).save(RES / f"mipmap-{dpi}/ic_launcher_foreground.png")
    (RES / "mipmap-anydpi-v26").mkdir(exist_ok=True)
    (RES / "mipmap-anydpi-v26/ic_launcher.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <background android:drawable="@color/ic_launcher_background"/>\n'
        '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
        '</adaptive-icon>\n')
    (RES / "values/ic_launcher_background.xml").write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n<resources>\n'
        '    <color name="ic_launcher_background">#%02X%02X%02X</color>\n</resources>\n' % CANVAS)
    # Splash emblem, transparent, 96dp tall at xxhdpi-ish density-independent use.
    (RES / "drawable-nodpi").mkdir(exist_ok=True)
    emblem(288, 0.92, None).save(RES / "drawable-nodpi/splash_emblem.png")
    print("ok")


if __name__ == "__main__":
    main()
