"""Prepara Subaru per Godot a partire dal suo charset.

Uso (dalla cartella del repository):
    python tools/genera_subaru.py

Legge  characters/subaru/subaru_charset.png   (formato RPG Maker: 4x4 celle da 32x48,
       righe giù / sinistra / destra / su, colonne fermo / passo / fermo / altro passo)
Scrive characters/subaru/subaru_sheet.png     (6 colonne x 4 righe)
       characters/subaru/subaru_frames.tres   (le 8 animazioni per AnimatedSprite2D)

Colonne del foglio finale:
    0 idle, 1 idle "respiro" (busto giù di 1 px),
    2-5 camminata: passo, fermo, altro passo, fermo
    (così i passi cadono sui frame 0 e 2, dove subaru.gd fa suonare i passi).
"""
import os, sys
import numpy as np
from PIL import Image

proj = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), "..", "let's-learn-godot")
folder = os.path.join(proj, "characters", "subaru")
CW, CH = 32, 48              # grandezza di una cella
WAIST = 30                   # sopra questa riga c'è il busto (per il "respiro")
DIRS = ["down", "left", "right", "up"]
WALK_ORDER = [1, 2, 3, 0]    # colonne del charset, in ordine di camminata

charset = np.asarray(Image.open(os.path.join(folder, "subaru_charset.png")).convert("RGBA"))
cell = lambda r, c: charset[r*CH:(r+1)*CH, c*CW:(c+1)*CW].copy()

def breathe(f):
    """Abbassa di 1 px tutto quello che sta sopra la vita."""
    g = f.copy()
    g[1:WAIST + 1] = f[0:WAIST]
    g[0] = 0
    return g

sheet = np.zeros((4 * CH, 6 * CW, 4), np.uint8)
for r in range(4):
    frames = [cell(r, 0), breathe(cell(r, 0))] + [cell(r, c) for c in WALK_ORDER]
    for c, f in enumerate(frames):
        sheet[r*CH:(r+1)*CH, c*CW:(c+1)*CW] = f

# PNG a colori indicizzati: stessa immagine, file molto più piccolo.
img = Image.fromarray(sheet, "RGBA")
opaque = sheet[..., 3] > 0
colors = np.unique(sheet[opaque][:, :3], axis=0)
index = {tuple(c): i + 1 for i, c in enumerate(colors)}
idx = np.zeros(sheet.shape[:2], np.uint8)
for y, x in zip(*np.where(opaque)):
    idx[y, x] = index[tuple(sheet[y, x, :3])]
p = Image.fromarray(idx, "P")
p.putpalette([0, 0, 0] + colors.flatten().tolist())
p.save(os.path.join(folder, "subaru_sheet.png"), optimize=True, transparency=0)

# Risorsa SpriteFrames.
subs = []
for r, d in enumerate(DIRS):
    for c in range(6):
        subs.append(f'[sub_resource type="AtlasTexture" id="{d}_{c}"]\natlas = ExtResource("1_sheet")\nregion = Rect2({c*CW}, {r*CH}, {CW}, {CH})\n')
def anim(name, ids, speed):
    fr = ", ".join('{\n"duration": 1.0,\n"texture": SubResource("%s")\n}' % i for i in ids)
    return '{\n"frames": [%s],\n"loop": true,\n"name": &"%s",\n"speed": %s\n}' % (fr, name, speed)
anims = []
for d in DIRS:
    anims.append(anim(f"idle_{d}", [f"{d}_0", f"{d}_1"], 2.0))
    anims.append(anim(f"walk_{d}", [f"{d}_{c}" for c in range(2, 6)], 8.0))
with open(os.path.join(folder, "subaru_frames.tres"), "w", encoding="utf-8", newline="\n") as f:
    f.write(f'[gd_resource type="SpriteFrames" load_steps={len(subs) + 2} format=3]\n\n'
            '[ext_resource type="Texture2D" path="res://characters/subaru/subaru_sheet.png" id="1_sheet"]\n\n'
            + "\n".join(subs) + "\n[resource]\nanimations = [" + ", ".join(anims) + "]\n")

print("foglio", img.size, "colori", len(colors))
