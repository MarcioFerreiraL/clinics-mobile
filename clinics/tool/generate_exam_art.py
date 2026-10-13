"""Gera as ilustrações 2D das categorias de exame (assets/exams/*.png).

Estilo chapado, só com a paleta da marca: azul, menta e branco. Uso: python3 tool/generate_exam_art.py
"""
import math
from PIL import Image, ImageDraw

S = 4
N = 512 * S
BLUE, DEEP, SOFT, MIST = (2, 132, 199), (11, 95, 143), (205, 231, 245), (224, 242, 254)
MINT, MINT_SOFT, WHITE = (143, 217, 182), (221, 243, 233), (255, 255, 255)


def canvas():
    img = Image.new("RGBA", (N, N), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.ellipse([20 * S, 20 * S, N - 20 * S, N - 20 * S], fill=MIST)
    return img, d


def pt(x, y):
    return (x * S, y * S)


def box(x0, y0, x1, y1):
    return [x0 * S, y0 * S, x1 * S, y1 * S]


def save(img, name):
    img.resize((512, 512), Image.LANCZOS).save(f"assets/exams/{name}.png", optimize=True)


def drop(d, cx, cy, r, fill):
    # gota: círculo + triângulo apontando para cima
    d.ellipse(box(cx - r, cy - r + r * 0.25, cx + r, cy + r + r * 0.25), fill=fill)
    d.polygon([pt(cx, cy - r * 1.75), pt(cx - r * 0.93, cy - r * 0.05), pt(cx + r * 0.93, cy - r * 0.05)], fill=fill)


def sangue():
    img, d = canvas()
    # tubo de ensaio
    d.rounded_rectangle(box(196, 150, 316, 430), radius=60 * S, fill=WHITE)
    d.rounded_rectangle(box(196, 270, 316, 430), radius=60 * S, fill=BLUE)
    d.rectangle(box(196, 270, 316, 340), fill=BLUE)
    d.rounded_rectangle(box(176, 130, 336, 172), radius=18 * S, fill=DEEP)
    d.rounded_rectangle(box(216, 190, 232, 330), radius=8 * S, fill=(255, 255, 255, 200))
    # gota
    drop(d, 372, 300, 52, BLUE)
    d.ellipse(box(350, 296, 366, 320), fill=WHITE)
    return img


def raiox():
    img, d = canvas()
    d.rounded_rectangle(box(132, 96, 380, 416), radius=26 * S, fill=DEEP)
    d.rounded_rectangle(box(216, 80, 296, 116), radius=14 * S, fill=SOFT)
    # osso (retângulo girado com pontas arredondadas)
    layer = Image.new("RGBA", (N, N), (0, 0, 0, 0))
    ld = ImageDraw.Draw(layer)
    ld.rounded_rectangle(box(176, 238, 336, 274), radius=18 * S, fill=WHITE)
    for cx in (176, 336):
        for cy in (232, 280):
            ld.ellipse(box(cx - 22, cy - 22, cx + 22, cy + 22), fill=WHITE)
    layer = layer.rotate(-35, center=(N // 2, N // 2), resample=Image.BICUBIC)
    img.alpha_composite(layer)
    d = ImageDraw.Draw(img)
    d.rounded_rectangle(box(156, 360, 356, 380), radius=10 * S, fill=BLUE)
    return img


def consultas():
    img, d = canvas()
    w = 26 * S
    # hastes e curva em U
    d.arc(box(150, 100, 362, 340), 0, 180, fill=DEEP, width=w)
    d.line([pt(150, 220), pt(150, 130)], fill=DEEP, width=w)
    d.line([pt(362, 220), pt(362, 130)], fill=DEEP, width=w)
    for x in (150, 362):
        d.ellipse(box(x - 22, 96, x + 22, 140), fill=BLUE)
    d.line([pt(256, 340), pt(256, 380)], fill=DEEP, width=w)
    d.ellipse(box(212, 372, 300, 460), fill=MINT)
    d.ellipse(box(232, 392, 280, 440), fill=WHITE)
    return img


def heart_points(cx, cy, size):
    pts = []
    for i in range(0, 360, 4):
        t = math.radians(i)
        x = 16 * math.sin(t) ** 3
        y = 13 * math.cos(t) - 5 * math.cos(2 * t) - 2 * math.cos(3 * t) - math.cos(4 * t)
        pts.append(pt(cx + x * size, cy - y * size))
    return pts


def cardio():
    img, d = canvas()
    d.polygon(heart_points(256, 250, 11.5), fill=MINT)
    zig = [pt(110, 262), pt(190, 262), pt(220, 200), pt(262, 332), pt(296, 236), pt(318, 262), pt(402, 262)]
    d.line(zig, fill=WHITE, width=18 * S, joint="curve")
    for p in (zig[0], zig[-1]):
        d.ellipse([p[0] - 9 * S, p[1] - 9 * S, p[0] + 9 * S, p[1] + 9 * S], fill=WHITE)
    return img


def ultrassom():
    img, d = canvas()
    # leque do ultrassom
    d.pieslice(box(76, -40, 436, 320), 40, 140, fill=SOFT)
    for r in (110, 170, 230):
        d.arc(box(256 - r, 140 - r + 0, 256 + r, 140 + r), 50, 130, fill=BLUE, width=6 * S)
    d.ellipse(box(222, 250, 290, 318), fill=MINT)
    d.ellipse(box(240, 268, 262, 290), fill=WHITE)
    # sonda
    d.rounded_rectangle(box(216, 70, 296, 150), radius=24 * S, fill=DEEP)
    d.rounded_rectangle(box(236, 20, 276, 90), radius=16 * S, fill=BLUE)
    return img


def padrao():
    img, d = canvas()
    d.ellipse(box(120, 120, 392, 392), fill=BLUE)
    d.rounded_rectangle(box(236, 170, 276, 342), radius=14 * S, fill=WHITE)
    d.rounded_rectangle(box(170, 236, 342, 276), radius=14 * S, fill=WHITE)
    return img


if __name__ == "__main__":
    for name, fn in [("sangue", sangue), ("raio-x", raiox), ("consultas", consultas), ("cardio", cardio),
                     ("ultrassom", ultrassom), ("padrao", padrao)]:
        save(fn(), name)
    print("ok")
