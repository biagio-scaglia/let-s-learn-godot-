"""Riporta a pixel art vera un charset "finto": un'immagine ingrandita, con sfondo bianco
e colori sporcati dalla compressione (per esempio un JPEG generato da un'IA).

Uso (dalla cartella del repository):
    python tools/charset_da_immagine.py <immagine> <uscita.png> <px_per_pixel> [colonne righe colori]

Esempio (la spritesheet v2 di Subaru, dove ogni pixel del disegno è un blocco di 13,2 px):
    python tools/charset_da_immagine.py "Sprite Sheet Subaru (v2).jpg" \\
        "let's-learn-godot/characters/subaru/subaru_charset.png" 13.2

Come funziona:
1. Toglie lo sfondo: il bianco collegato ai bordi diventa trasparente (il bianco della
   maglia, chiuso dal contorno, resta).
2. Trova dove cadono i bordi dei "pixel" del disegno (la fase della griglia), guardando
   dove l'immagine cambia colore più spesso.
3. Per ogni pixel del disegno prende il colore mediano del centro del blocco.
4. Riduce a una palette di pochi colori e toglie i pixel isolati.

Di default produce un charset 128x192 (4x4 celle da 32x48) con 32 colori.
"""
import sys
import numpy as np
from PIL import Image
from scipy import ndimage

src, out, P = sys.argv[1], sys.argv[2], float(sys.argv[3])
COLS = int(sys.argv[4]) if len(sys.argv) > 4 else 128
ROWS = int(sys.argv[5]) if len(sys.argv) > 5 else 192
NCOL = int(sys.argv[6]) if len(sys.argv) > 6 else 32

a = np.asarray(Image.open(src).convert("RGB")).astype(np.int16)

# 1. Sfondo
near_white = (a.min(2) > 215) & ((a.max(2) - a.min(2)) < 25)
lab, _ = ndimage.label(near_white)
border = set(np.unique(np.concatenate([lab[0], lab[-1], lab[:, 0], lab[:, -1]]))) - {0}
fg = ndimage.binary_opening(~np.isin(lab, list(border)), iterations=2)

# 2. Fase della griglia, per ogni asse
def phase(axis):
    g = np.abs(np.diff(a, axis=axis)).sum(2).sum(1 - axis).astype(float)
    b = np.arange(len(g)) + 1.0
    z = (g * np.exp(2j * np.pi * b / P)).sum()
    return (np.angle(z) / (2 * np.pi) * P) % P

# La griglia deve finire con l'immagine: si sposta la fase di un numero intero di blocchi.
start_x = phase(1) - P * round((phase(1) + COLS * P - a.shape[1]) / P)
start_y = phase(0) - P * round((phase(0) + ROWS * P - a.shape[0]) / P)

# 3. Un colore per ogni pixel del disegno
o = np.zeros((ROWS, COLS, 4), np.uint8)
for j in range(ROWS):
    for i in range(COLS):
        x0, y0 = start_x + i * P, start_y + j * P
        xa, xb = max(int(round(x0 + P * .25)), 0), min(int(round(x0 + P * .75)), a.shape[1])
        ya, yb = max(int(round(y0 + P * .25)), 0), min(int(round(y0 + P * .75)), a.shape[0])
        if xb <= xa or yb <= ya:
            continue
        m = fg[ya:yb, xa:xb]
        if m.mean() < 0.5:
            continue
        o[j, i, :3] = np.median(a[ya:yb, xa:xb][m], axis=0)
        o[j, i, 3] = 255

# 4. Palette e pulizia
opaque = o[..., 3] > 0
strip = Image.fromarray(o[opaque][:, :3].reshape(1, -1, 3))
pal = np.array(strip.quantize(colors=NCOL, method=Image.Quantize.MEDIANCUT, kmeans=3).getpalette()[:NCOL * 3]).reshape(-1, 3)
rgb = o[..., :3].astype(int)
o[..., :3] = pal[((rgb[..., None, :] - pal[None, None]) ** 2).sum(-1).argmin(-1)]
o[~opaque] = 0
p = np.pad(opaque, 1)
neighbours = sum(p[1 + dy:1 + dy + ROWS, 1 + dx:1 + dx + COLS] for dy in (-1, 0, 1) for dx in (-1, 0, 1) if dy or dx)
o[opaque & (neighbours <= 1)] = 0

Image.fromarray(o).save(out)
print("charset", (COLS, ROWS), "colori", len(np.unique(o[o[..., 3] > 0][:, :3], axis=0)))
