"""Gera o logo do Clinics: pino de localização azul, cruz branca e selo verde-menta.

Estilo 2D chapado: cores sólidas, sem degradê, sombra ou textura.

Uso: python3 tool/generate_logo.py  (saída em assets/branding/)
"""
import math
from PIL import Image, ImageChops, ImageDraw, ImageFilter

S = 4  # supersampling
SIZE = 1024 * S


def lerp(a, b, t):
    return tuple(round(a[i] + (b[i] - a[i]) * t) for i in range(3))


def vertical_gradient(w, h, top, bottom):
    img = Image.new("RGB", (w, h))
    px = ImageDraw.Draw(img)
    for y in range(h):
        px.line([(0, y), (w, y)], fill=lerp(top, bottom, y / (h - 1)))
    return img


def pin_mask():
    m = Image.new("L", (SIZE, SIZE), 0)
    d = ImageDraw.Draw(m)
    cx, cy, r = 512 * S, 430 * S, 255 * S
    tip = (512 * S, 880 * S)
    dist = tip[1] - cy
    a = math.asin(r / dist)
    # pontos de tangência entre a ponta e o círculo
    tx = r * math.cos(a)
    ty = r * math.sin(a)
    left = (cx - tx, cy + ty)
    right = (cx + tx, cy + ty)
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=255)
    d.polygon([left, right, tip], fill=255)
    return m


def cross_mask():
    m = Image.new("L", (SIZE, SIZE), 0)
    d = ImageDraw.Draw(m)
    cx, cy = 512 * S, 430 * S
    arm, thick, rad = 150 * S, 50 * S, 24 * S
    d.rounded_rectangle([cx - arm, cy - thick, cx + arm, cy + thick], radius=rad, fill=255)
    d.rounded_rectangle([cx - thick, cy - arm, cx + thick, cy + arm], radius=rad, fill=255)
    return m


def badge(img):
    d = ImageDraw.Draw(img)
    cx, cy, r = 712 * S, 712 * S, 118 * S
    d.ellipse([cx - r - 18 * S, cy - r - 18 * S, cx + r + 18 * S, cy + r + 18 * S], fill=(255, 255, 255, 255))
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(143, 217, 182, 255))
    # check branco
    pts = [(cx - 52 * S, cy + 4 * S), (cx - 14 * S, cy + 44 * S), (cx + 56 * S, cy - 40 * S)]
    d.line(pts, fill=(255, 255, 255, 255), width=26 * S, joint="curve")
    for p in (pts[0], pts[-1]):
        d.ellipse([p[0] - 13 * S, p[1] - 13 * S, p[0] + 13 * S, p[1] + 13 * S], fill=(255, 255, 255, 255))


def mark():
    """Marca com fundo transparente."""
    out = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    mask = pin_mask()

    fill = Image.new("RGBA", (SIZE, SIZE), (2, 132, 199, 255))
    fill.putalpha(mask)
    out.alpha_composite(fill)

    cross = Image.new("RGBA", (SIZE, SIZE), (255, 255, 255, 255))
    cross.putalpha(cross_mask())
    out.alpha_composite(cross)
    badge(out)
    return out


def down(img, size):
    return img.resize((size, size), Image.LANCZOS)


def place(mark_img, scale):
    canvas = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    m = mark_img.resize((int(SIZE * scale),) * 2, Image.LANCZOS)
    off = (SIZE - m.width) // 2
    canvas.alpha_composite(m, (off, off - int(SIZE * 0.02)))
    return canvas


if __name__ == "__main__":
    m = mark()
    down(m, 1024).save("assets/branding/logo_mark.png")

    bg = Image.new("RGBA", (SIZE, SIZE), (227, 242, 251, 255))
    icon = bg.copy()
    icon.alpha_composite(place(m, 0.96))
    down(icon, 1024).convert("RGB").save("assets/branding/app_icon.png")

    down(place(m, 0.62), 1024).save("assets/branding/app_icon_foreground.png")
    print("ok")
