"""Genera il TileSet e la mappa di prova (world/tileset.tres e world/main.tscn).

Uso (dalla cartella del repository):
    python tools/genera_mappa.py

ATTENZIONE: sovrascrive world/main.tscn. Se hai già modificato la mappa
nell'editor di Godot, quelle modifiche andranno perse.
"""
import os, sys, struct, random
proj = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), "..", "let's-learn-godot")
random.seed(7)
W, H = 40, 24
A = lambda n: (n % 12, n // 12)

# ---------- TileSet ----------
GROUND = [0, 1, 2, 12, 13, 14, 24, 25, 26, 36, 37, 38, 39, 40, 41, 42, 17, 29]
TREES = [3, 4, 15, 16, 27, 28]
rect = lambda x0, y0, x1, y1: f"PackedVector2Array({x0}, {y0}, {x1}, {y0}, {x1}, {y1}, {x0}, {y1})"
COLL = {t: rect(-6, 0, 6, 8) for t in TREES}
COLL.update({5: rect(-7, -2, 7, 8), 44: rect(-6, -1, 8, 5), 45: rect(-8, -1, 8, 5), 46: rect(-8, -1, 6, 5), 83: rect(-4, 2, 4, 8)})
lines = []
for t in sorted(set(GROUND) | set(COLL)):
    x, y = A(t)
    lines.append(f"{x}:{y}/0 = 0")
    if t in COLL:
        lines.append(f"{x}:{y}/0/y_sort_origin = 6")
        lines.append(f"{x}:{y}/0/physics_layer_0/polygon_0/points = {COLL[t]}")
tileset = f'''[gd_resource type="TileSet" load_steps=3 format=3]

[ext_resource type="Texture2D" path="res://assets/kenney_tiny_town/tilemap_packed.png" id="1_atlas"]

[sub_resource type="TileSetAtlasSource" id="TileSetAtlasSource_town"]
texture = ExtResource("1_atlas")
{chr(10).join(lines)}

[resource]
physics_layer_0/collision_layer = 1
sources/0 = SubResource("TileSetAtlasSource_town")
'''
open(f"{proj}/world/tileset.tres", "w", newline="\n").write(tileset)

# ---------- Map ----------
dirt = [[False] * W for _ in range(H)]
def fill(x0, y0, x1, y1):
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1): dirt[y][x] = True
fill(3, 11, 36, 13)    # horizontal path
fill(19, 3, 21, 20)    # vertical path
fill(15, 9, 25, 15)    # plaza
D = lambda x, y: 0 <= x < W and 0 <= y < H and dirt[y][x]

ground = {}
for y in range(H):
    for x in range(W):
        if not dirt[y][x]:
            ground[(x, y)] = random.choices([0, 1, 2], [85, 10, 5])[0]
            continue
        n, s, w, e = D(x, y-1), D(x, y+1), D(x-1, y), D(x+1, y)
        if not n and not w: t = 12
        elif not n and not e: t = 14
        elif not s and not w: t = 36
        elif not s and not e: t = 38
        elif not n: t = 13
        elif not s: t = 37
        elif not w: t = 24
        elif not e: t = 26
        elif not D(x-1, y-1): t = 39
        elif not D(x+1, y-1): t = 40
        elif not D(x+1, y+1): t = 41
        elif not D(x-1, y+1): t = 42
        else: t = 25
        ground[(x, y)] = t

objects = {}
for y in range(H):
    for x in range(W):
        if x < 2 or y < 2 or x >= W - 2 or y >= H - 2:
            objects[(x, y)] = random.choice([16, 28, 16, 28, 3, 15, 27])
near_dirt = lambda x, y: any(D(x+dx, y+dy) for dx in (-1, 0, 1) for dy in (-1, 0, 1))
for y in range(2, H - 2):
    for x in range(2, W - 2):
        if (x, y) in objects or near_dirt(x, y): continue
        r = random.random()
        if r < 0.07: objects[(x, y)] = random.choice([16, 28, 27, 15, 5])
        elif r < 0.10: objects[(x, y)] = random.choice([17, 29])  # decorations, walkable
for x in range(4, 13):  # fence above the west path
    objects[(x, 8)] = 44 if x == 4 else 46 if x == 12 else 45
    for yy in (7, 9): objects.pop((x, yy), None)
objects[(14, 10)] = 83  # sign by the plaza

def pack(cells):
    b = bytearray(struct.pack("<H", 0))
    for (x, y), t in sorted(cells.items(), key=lambda kv: (kv[0][1], kv[0][0])):
        ax, ay = A(t)
        b += struct.pack("<hhHHHH", x, y, 0, ax, ay, 0)
    return "PackedByteArray(" + ", ".join(map(str, b)) + ")"

main = f'''[gd_scene load_steps=3 format=3]

[ext_resource type="TileSet" path="res://world/tileset.tres" id="1_tiles"]
[ext_resource type="PackedScene" path="res://characters/subaru/subaru.tscn" id="2_subaru"]

[node name="Main" type="Node2D"]

[node name="Ground" type="TileMapLayer" parent="."]
scale = Vector2(2, 2)
tile_map_data = {pack(ground)}
tile_set = ExtResource("1_tiles")

[node name="World" type="Node2D" parent="."]
y_sort_enabled = true

[node name="Objects" type="TileMapLayer" parent="World"]
y_sort_enabled = true
scale = Vector2(2, 2)
tile_map_data = {pack(objects)}
tile_set = ExtResource("1_tiles")

[node name="Subaru" parent="World" instance=ExtResource("2_subaru")]
position = Vector2(656, 416)

[node name="Camera2D" type="Camera2D" parent="World/Subaru"]
limit_left = 0
limit_top = 0
limit_right = {W * 32}
limit_bottom = {H * 32}
position_smoothing_enabled = true
'''
open(f"{proj}/world/main.tscn", "w", newline="\n").write(main)
print("ground", len(ground), "objects", len(objects))
