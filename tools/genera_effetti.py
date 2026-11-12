"""Genera le piccole immagini e i suoni degli effetti (assets/effects/).

Uso (dalla cartella del repository):
    python tools/genera_effetti.py

Tutto è disegnato dal codice: niente asset esterni, niente licenze da citare.
"""
import math, os, random, struct, sys, wave
from PIL import Image

proj = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), "..", "let's-learn-godot")
out = os.path.join(proj, "assets", "effects")
os.makedirs(out, exist_ok=True)

DARK = (39, 26, 33, 255)       # contorno, simile a quello di Tiny Town
CREAM = (245, 230, 196, 255)


def ellipse(w, h, alpha, size=None, center=None):
    """Ombra ovale a pixel pieni (niente sfumature: è pixel art)."""
    size = size or (w, h)
    cx, cy = center or ((size[0] - 1) / 2, (size[1] - 1) / 2)
    im = Image.new("RGBA", size, (0, 0, 0, 0))
    for y in range(size[1]):
        for x in range(size[0]):
            if ((x - cx) / (w / 2)) ** 2 + ((y - cy) / (h / 2)) ** 2 <= 1.0:
                im.putpixel((x, y), (20, 12, 28, alpha))
    return im


# Ombra dei personaggi: ovale 22x7, centrata.
ellipse(22, 7, 90).save(os.path.join(out, "shadow_character.png"))

# Ombra degli alberi: un tile 16x16 con l'ovale in basso, sotto il tronco.
ellipse(14, 5, 80, size=(16, 16), center=(7.5, 13.0)).save(os.path.join(out, "shadow_tree.png"))

# Icona "posso parlare": nuvoletta con tre puntini, 11x10.
bubble = [
    "..XXXXXXX..",
    ".XCCCCCCCX.",
    "XCCCCCCCCCX",
    "XCCDCDCDCCX",
    "XCCCCCCCCCX",
    ".XCCCCCCCX.",
    "..XXCCXXX..",
    "....XCX....",
    ".....X.....",
    "...........",
]
im = Image.new("RGBA", (11, 10), (0, 0, 0, 0))
for y, row in enumerate(bubble):
    for x, ch in enumerate(row):
        if ch in "XD": im.putpixel((x, y), DARK)
        elif ch == "C": im.putpixel((x, y), CREAM)
im.save(os.path.join(out, "interact_icon.png"))

# Freccia "continua" della finestra di dialogo, 7x5.
arrow = [
    "XXXXXXX",
    "XCCCCCX",
    ".XCCCX.",
    "..XCX..",
    "...X...",
]
im = Image.new("RGBA", (7, 5), (0, 0, 0, 0))
for y, row in enumerate(arrow):
    for x, ch in enumerate(row):
        if ch == "X": im.putpixel((x, y), DARK)
        elif ch == "C": im.putpixel((x, y), CREAM)
im.save(os.path.join(out, "next_arrow.png"))

# Suono "blip" del testo: onda quadra corta che si spegne in fretta.
rate, dur, freq = 22050, 0.045, 620.0
frames = bytearray()
for i in range(int(rate * dur)):
    t = i / rate
    env = (1 - t / dur) ** 2
    sample = (1.0 if math.sin(2 * math.pi * freq * t) >= 0 else -1.0) * 0.22 * env
    frames += struct.pack("<h", int(sample * 32767))
with wave.open(os.path.join(out, "blip.wav"), "wb") as w:
    w.setnchannels(1); w.setsampwidth(2); w.setframerate(rate)
    w.writeframes(bytes(frames))

# Suono del passo: un breve "tump" di rumore che si spegne, filtrato per essere morbido.
random.seed(3)
rate, dur = 22050, 0.06
frames = bytearray()
smooth = 0.0
for i in range(int(rate * dur)):
    t = i / rate
    env = (1 - t / dur) ** 3
    smooth += (random.uniform(-1, 1) - smooth) * 0.18   # filtro passa-basso: toglie gli acuti
    frames += struct.pack("<h", int(smooth * 0.9 * env * 32767))
with wave.open(os.path.join(out, "step.wav"), "wb") as w:
    w.setnchannels(1); w.setsampwidth(2); w.setframerate(rate)
    w.writeframes(bytes(frames))

print("effetti generati in", out)
