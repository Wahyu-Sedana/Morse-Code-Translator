"""Generate app icons (Android, iOS) and the Play Store feature graphic.

Run from the project root:  python3 tool/branding/generate_assets.py
Requires Pillow. Colors and fonts mirror lib/core/theme.
"""

import json
import os

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
FONTS = os.path.join(ROOT, "assets", "fonts")
OUT = os.path.join(ROOT, "assets", "branding")
RES = os.path.join(ROOT, "android", "app", "src", "main", "res")
IOS = os.path.join(ROOT, "ios", "Runner", "Assets.xcassets", "AppIcon.appiconset")

INK = (0x14, 0x18, 0x1A)
PANEL = (0x1F, 0x25, 0x28)
PANEL_RAISED = (0x26, 0x2C, 0x30)
PANEL_BORDER = (0x2E, 0x35, 0x39)
LAMP_OFF = (0x3A, 0x42, 0x46)
ON_PANEL_MUTED = (0xB5, 0xBC, 0xC1)
ON_PANEL_FAINT = (0x8A, 0x92, 0x98)
ACCENT = (0xF2, 0xB3, 0x47)  # dashes (AppColors.signalDash)
DOT = (0x5B, 0xB4, 0xFF)  # dots (AppColors.signalDot)
WHITE = (0xFF, 0xFF, 0xFF)

MASTER = 2048  # icon supersampling canvas


def font(name, size):
    return ImageFont.truetype(os.path.join(FONTS, name), size)


def vertical_gradient(w, h, top, bottom):
    img = Image.new("RGB", (w, h))
    px = img.load()
    for y in range(h):
        t = y / max(1, h - 1)
        c = tuple(round(top[i] + (bottom[i] - top[i]) * t) for i in range(3))
        for x in range(w):
            px[x, y] = c
    return img


def radial_glow(size, center, radius, color, strength):
    """Soft amber light pooled behind the signal."""
    mask = Image.new("L", size, 0)
    d = ImageDraw.Draw(mask)
    cx, cy = center
    d.ellipse((cx - radius, cy - radius * 0.7, cx + radius, cy + radius * 0.7), fill=round(255 * strength))
    mask = mask.filter(ImageFilter.GaussianBlur(radius * 0.55))
    layer = Image.new("RGBA", size, color + (0,))
    layer.putalpha(mask)
    return layer


def pills(draw, symbols, x, cy, h, dash_ratio, gap, fill, letter_gap=None, dot_fill=None, only=None):
    """Draw '.', '-' and ' ' (letter break) as rounded pills. Returns end x.

    dot_fill colors dots differently from dashes; only ('.' or '-') draws just
    that kind while keeping the spacing, used to build per-color glow masks.
    """
    for s in symbols:
        if s == " ":
            x += (letter_gap or gap) - gap
            continue
        w = h if s == "." else h * dash_ratio
        if only is None or only == s:
            color = dot_fill if (s == "." and dot_fill is not None) else fill
            draw.rounded_rectangle((x, cy - h / 2, x + w, cy + h / 2), radius=h / 2, fill=color)
        x += w + gap
    return x - gap


def pills_width(symbols, h, dash_ratio, gap, letter_gap=None):
    w = 0
    for s in symbols:
        if s == " ":
            w += (letter_gap or gap) - gap
        else:
            w += (h if s == "." else h * dash_ratio) + gap
    return w - gap


def glowing_mark(size, mark_width, symbols=".-.", dash_ratio=46 / 18, gap_ratio=10 / 18, glow=True):
    """Transparent RGBA layer with the dot-dash-dot signal (blue dots, amber dashes), centered."""
    unit = mark_width / pills_width(symbols, 1, dash_ratio, gap_ratio)
    h, gap = unit, unit * gap_ratio
    x0 = (size - mark_width) / 2
    cy = size / 2
    layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    if glow:
        for kind, color in ((".", DOT), ("-", ACCENT)):
            m = Image.new("L", (size, size), 0)
            pills(ImageDraw.Draw(m), symbols, x0, cy, h, dash_ratio, gap, 255, only=kind)
            for blur, alpha in ((h * 1.4, 0.85), (h * 0.45, 0.6)):
                g = m.filter(ImageFilter.GaussianBlur(blur)).point(lambda v, a=alpha: round(v * a))
                gl = Image.new("RGBA", (size, size), color + (0,))
                gl.putalpha(g)
                layer = Image.alpha_composite(layer, gl)
    pills(ImageDraw.Draw(layer), symbols, x0, cy, h, dash_ratio, gap, ACCENT + (255,), dot_fill=DOT + (255,))
    return layer


def icon_background(size):
    bg = vertical_gradient(size, size, PANEL_RAISED, INK).convert("RGBA")
    return Image.alpha_composite(bg, radial_glow((size, size), (size / 2, size / 2), size * 0.42, ACCENT, 0.10))


def full_icon(size=MASTER, mark_ratio=0.58):
    return Image.alpha_composite(icon_background(size), glowing_mark(size, size * mark_ratio))


def rounded(img, radius_ratio):
    s = img.size[0]
    mask = Image.new("L", img.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, s - 1, s - 1), radius=s * radius_ratio, fill=255)
    out = img.copy()
    out.putalpha(mask)
    return out


def save(img, path, size=None, rgb=False):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    if size:
        img = img.resize((size, size), Image.LANCZOS)
    if rgb:
        img = img.convert("RGB")
    img.save(path, optimize=True)


def android(master):
    densities = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}
    legacy = rounded(master, 0.22)
    # Adaptive icon: 108dp canvas, launcher shows the center ~72dp.
    # Mark at 0.58 of the visible 72dp keeps it identical to the legacy icon.
    fg = glowing_mark(MASTER, MASTER * 0.58 * 72 / 108)
    bg = icon_background(MASTER)
    mono = glowing_mark(MASTER, MASTER * 0.58 * 72 / 108, glow=False)
    mono_white = Image.new("RGBA", mono.size, WHITE + (0,))
    mono_white.putalpha(mono.getchannel("A"))
    for name, k in densities.items():
        d = os.path.join(RES, f"mipmap-{name}")
        save(legacy, os.path.join(d, "ic_launcher.png"), round(48 * k))
        save(fg, os.path.join(d, "ic_launcher_foreground.png"), round(108 * k))
        save(bg, os.path.join(d, "ic_launcher_background.png"), round(108 * k), rgb=True)
        save(mono_white, os.path.join(d, "ic_launcher_monochrome.png"), round(108 * k))
    anydpi = os.path.join(RES, "mipmap-anydpi-v26")
    os.makedirs(anydpi, exist_ok=True)
    with open(os.path.join(anydpi, "ic_launcher.xml"), "w") as f:
        f.write(
            '<?xml version="1.0" encoding="utf-8"?>\n'
            '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
            '    <background android:drawable="@mipmap/ic_launcher_background" />\n'
            '    <foreground android:drawable="@mipmap/ic_launcher_foreground" />\n'
            '    <monochrome android:drawable="@mipmap/ic_launcher_monochrome" />\n'
            "</adaptive-icon>\n"
        )


def ios(master):
    with open(os.path.join(IOS, "Contents.json")) as f:
        images = json.load(f)["images"]
    for i in images:
        px = round(float(i["size"].split("x")[0]) * int(i["scale"].rstrip("x")))
        save(master, os.path.join(IOS, i["filename"]), px, rgb=True)  # App Store rejects alpha


def feature_graphic():
    S = 2
    W, H = 1024 * S, 500 * S
    img = vertical_gradient(W, H, PANEL, INK).convert("RGBA")
    img = Image.alpha_composite(img, radial_glow((W, H), (W * 0.76, H * 0.5), 380 * S, ACCENT, 0.12))

    # Faint morse texture across the background
    tex = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    td = ImageDraw.Draw(tex)
    rows = [".-- .- .-.. .- .- .- -.-", "... .. --. -. .- .-.. --- ..-"]
    for r, row in enumerate(rows):
        y = (36 + r * 428) * S
        x = (-30 - r * 70) * S
        while x < W:
            x = pills(td, row + " ", x, y, 10 * S, 2.6, 8 * S, LAMP_OFF + (70,), letter_gap=22 * S) + 22 * S
    img = Image.alpha_composite(img, tex)
    d = ImageDraw.Draw(img)

    # Left: brand block
    lx = 72 * S
    tile = 112 * S
    ty = 86 * S
    mark = rounded(full_icon(tile * 2), 0.28).resize((tile, tile), Image.LANCZOS)
    border = Image.new("RGBA", (tile + 4 * S, tile + 4 * S), (0, 0, 0, 0))
    ImageDraw.Draw(border).rounded_rectangle(
        (0, 0, tile + 4 * S - 1, tile + 4 * S - 1), radius=tile * 0.28 + 2 * S, fill=PANEL_BORDER + (255,)
    )
    img.alpha_composite(border, (lx - 2 * S, ty - 2 * S))
    img.alpha_composite(mark, (lx, ty))

    d = ImageDraw.Draw(img)
    d.text((lx - 4 * S, 300 * S), "Morse", font=font("SpaceGrotesk-700.ttf", 92 * S), fill=WHITE, anchor="ls")
    d.text((lx, 346 * S), "Translate signals, send messages", font=font("Inter-500.ttf", 27 * S),
           fill=ON_PANEL_MUTED, anchor="ls")

    chip_font = font("Inter-600.ttf", 15 * S)
    cx, cy = lx, 392 * S
    for label in ("Text and Morse", "Sound, light, vibration", "100% offline"):
        tw = d.textlength(label, font=chip_font)
        w, h = tw + 40 * S, 36 * S
        d.rounded_rectangle((cx, cy, cx + w, cy + h), radius=h / 2, fill=PANEL_RAISED, outline=PANEL_BORDER,
                            width=2 * S)
        dot = 7 * S
        d.ellipse((cx + 14 * S, cy + h / 2 - dot / 2, cx + 14 * S + dot, cy + h / 2 + dot / 2), fill=ACCENT)
        d.text((cx + 27 * S, cy + h / 2), label, font=chip_font, fill=ON_PANEL_MUTED, anchor="lm")
        cx += w + 10 * S

    # Right: translator card mock
    x0, y0, x1, y1 = 604 * S, 84 * S, 956 * S, 416 * S
    shadow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle((x0, y0 + 18 * S, x1, y1 + 18 * S), radius=36 * S, fill=(0, 0, 0, 150))
    img = Image.alpha_composite(img, shadow.filter(ImageFilter.GaussianBlur(28 * S)))
    d = ImageDraw.Draw(img)
    d.rounded_rectangle((x0, y0, x1, y1), radius=36 * S, fill=PANEL, outline=PANEL_BORDER, width=2 * S)

    px = x0 + 32 * S
    mono = font("JetBrainsMono-700.ttf", 15 * S)
    d.text((px, y0 + 50 * S), "TEXT", font=mono, fill=ON_PANEL_FAINT, anchor="ls")
    d.text((px - 3 * S, y0 + 128 * S), "SOS", font=font("SpaceGrotesk-700.ttf", 68 * S), fill=WHITE, anchor="ls")

    # Signal lamp, lit
    lr = 13 * S
    lcx, lcy = x1 - 46 * S, y0 + 44 * S
    lamp = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ld = ImageDraw.Draw(lamp)
    ld.ellipse((lcx - lr * 2.6, lcy - lr * 2.6, lcx + lr * 2.6, lcy + lr * 2.6), fill=ACCENT + (150,))
    img = Image.alpha_composite(img, lamp.filter(ImageFilter.GaussianBlur(lr * 1.3)))
    d = ImageDraw.Draw(img)
    d.ellipse((lcx - lr * 1.35, lcy - lr * 1.35, lcx + lr * 1.35, lcy + lr * 1.35), fill=ACCENT + (90,))
    d.ellipse((lcx - lr, lcy - lr, lcx + lr, lcy + lr), fill=ACCENT)

    d.line((px, y0 + 160 * S, x1 - 32 * S, y0 + 160 * S), fill=PANEL_BORDER, width=2 * S)
    d.text((px, y0 + 206 * S), "MORSE", font=mono, fill=ON_PANEL_FAINT, anchor="ls")

    sos = "... --- ..."
    ph, pg, plg = 13 * S, 7 * S, 18 * S
    sig = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    sy = y0 + 256 * S
    pills(ImageDraw.Draw(sig), sos, px, sy, ph, 3.2, pg, ACCENT + (255,), letter_gap=plg, dot_fill=DOT + (255,))
    glow = sig.filter(ImageFilter.GaussianBlur(ph * 0.9))
    img = Image.alpha_composite(img, glow)
    img = Image.alpha_composite(img, sig)
    d = ImageDraw.Draw(img)

    # Progress track under the signal
    ty2 = y1 - 40 * S
    d.rounded_rectangle((px, ty2, x1 - 32 * S, ty2 + 6 * S), radius=3 * S, fill=PANEL_BORDER)
    d.rounded_rectangle((px, ty2, px + (x1 - 32 * S - px) * 0.62, ty2 + 6 * S), radius=3 * S, fill=ACCENT)

    return img.resize((1024, 500), Image.LANCZOS).convert("RGB")


def main():
    master = full_icon()
    android(master)
    ios(master)
    os.makedirs(OUT, exist_ok=True)
    save(master, os.path.join(OUT, "icon-1024.png"), 1024, rgb=True)
    save(master, os.path.join(OUT, "play-store-icon-512.png"), 512, rgb=True)
    feature_graphic().save(os.path.join(OUT, "feature-graphic-1024x500.png"), optimize=True)
    print("done")


if __name__ == "__main__":
    main()
