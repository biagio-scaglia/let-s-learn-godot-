"""Genera l'interno della casa di Lina (world/house_tileset.tres e world/house.tscn).

Uso (dalla cartella del repository):
    python tools/genera_casa.py

ATTENZIONE: sovrascrive world/house.tscn. Se hai già modificato la casa
nell'editor di Godot, quelle modifiche andranno perse.

I numeri dei tile sono quelli di gamelog/assets/tiny_dungeon_numerata.png
(numero = riga * 12 + colonna).
"""
import os, struct, sys

proj = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), "..", "let's-learn-godot")
W, H = 12, 9           # la stanza, in tile
T = 32                 # un tile da 16 px, ingrandito x2
A = lambda n: (n % 12, n // 12)

# ---------- Tile di Tiny Dungeon ----------
FLOOR = 0
WALL, WINDOW, TORCH = 40, 28, 29             # muro di fondo in mattoni
PILLAR = 18                                  # muri laterali (visti dall'alto)
# Nota: i tile 6 e 30 (testa e piede della colonna) hanno lo sfondo marrone e negli
# angoli stonano, quindi la colonna usa sempre il 18.
BAR = [36, 37, 38, 39]                       # muro basso: estremità sinistra, centro, centro, destra
SHELF_A, SHELF_B, CHEST, BARREL, TABLE, STOOL = 63, 75, 89, 82, 72, 73
FURNITURE = [SHELF_A, SHELF_B, CHEST, BARREL, TABLE, STOOL]

rect = lambda x0, y0, x1, y1: f"PackedVector2Array({x0}, {y0}, {x1}, {y0}, {x1}, {y1}, {x0}, {y1})"

# ---------- TileSet ----------
lines = []
for t in sorted({FLOOR, WALL, WINDOW, TORCH, PILLAR, *BAR, *FURNITURE}):
    x, y = A(t)
    lines.append(f"{x}:{y}/0 = 0")
    if t in FURNITURE:   # i mobili bloccano nella parte bassa e si ordinano dalla base
        lines.append(f"{x}:{y}/0/y_sort_origin = 6")
        lines.append(f"{x}:{y}/0/physics_layer_0/polygon_0/points = {rect(-7, 0, 7, 8)}")
tileset = f'''[gd_resource type="TileSet" load_steps=3 format=3]

[ext_resource type="Texture2D" path="res://assets/kenney_tiny_dungeon/tilemap_packed.png" id="1_atlas"]

[sub_resource type="TileSetAtlasSource" id="TileSetAtlasSource_dungeon"]
texture = ExtResource("1_atlas")
{chr(10).join(lines)}

[resource]
physics_layer_0/collision_layer = 1
sources/0 = SubResource("TileSetAtlasSource_dungeon")
'''
open(f"{proj}/world/house_tileset.tres", "w", encoding="utf-8", newline="\n").write(tileset)

# ---------- La stanza ----------
EXIT = (5, 6)          # le colonne del varco d'uscita nel muro basso

floor = {(x, y): FLOOR for x in range(1, W - 1) for y in range(2, H - 1)}
floor.update({(x, H - 1): FLOOR for x in EXIT})

walls = {}
for x in range(1, W - 1):          # muro di fondo, due file di mattoni
    walls[(x, 0)] = WALL
    walls[(x, 1)] = WALL
walls[(3, 1)] = WINDOW
walls[(8, 1)] = TORCH
for x in (0, W - 1):               # muri laterali
    for y in range(H):
        walls[(x, y)] = PILLAR
for x0 in (1, EXIT[1] + 1):        # muro basso, a sinistra e a destra del varco
    for i, t in enumerate(BAR):
        walls[(x0 + i, H - 1)] = t

objects = {
    (2, 2): SHELF_A, (3, 2): SHELF_B,        # libreria
    (9, 2): CHEST,                           # baule
    (10, 2): BARREL, (10, 3): BARREL,        # barili
    (5, 4): TABLE, (4, 4): STOOL, (6, 4): STOOL,
}

def pack(cells):
    """Formato di tile_map_data: 2 byte di versione, poi 12 byte per cella."""
    b = bytearray(struct.pack("<H", 0))
    for (x, y), t in sorted(cells.items(), key=lambda kv: (kv[0][1], kv[0][0])):
        ax, ay = A(t)
        b += struct.pack("<hhHHHH", x, y, 0, ax, ay, 0)
    return "PackedByteArray(" + ", ".join(map(str, b)) + ")"

def packed(strings):
    """Scrive una lista di frasi come PackedStringArray, con le virgolette protette."""
    return "PackedStringArray(" + ", ".join('"' + s.replace('"', '\\"') + '"' for s in strings) + ")"

px = lambda x, y: (x * T + T // 2, y * T + T // 2)   # centro di una cella, in pixel

LINA = [
    "Oh! Ciao! Non ti avevo sentito entrare.",
    "Io sono Lina. Il Saggio è mio nonno... sì, quello che guarda crescere gli alberi.",
    "Il baule in fondo è chiuso a chiave. Chissà dove l'ho messa...",
]
LINA_REPEAT = ["Se trovi la chiave del baule, dimmelo!"]
CHEST_LINES = ["È chiuso a chiave."]
CHEST_REPEAT = ["Ancora chiuso. Da qualche parte ci sarà una chiave..."]
SHELF_LINES = ["Tanti libri polverosi.", 'Uno si intitola: "Godot per principianti, volume 1".']
SHELF_REPEAT = ["Il volume 2 non c'è. Forse non l'hanno ancora scritto."]

RW, RH = W * T, H * T
house = f'''[gd_scene load_steps=16 format=3]

[ext_resource type="Script" path="res://world/level.gd" id="1_level"]
[ext_resource type="TileSet" path="res://world/house_tileset.tres" id="2_tiles"]
[ext_resource type="PackedScene" path="res://characters/subaru/subaru.tscn" id="3_subaru"]
[ext_resource type="PackedScene" path="res://characters/npc/npc.tscn" id="4_npc"]
[ext_resource type="PackedScene" path="res://interactables/interactable.tscn" id="5_interactable"]
[ext_resource type="PackedScene" path="res://interactables/door.tscn" id="6_door"]
[ext_resource type="Script" path="res://effects/flicker.gd" id="7_flicker"]
[ext_resource type="Shader" path="res://effects/vignette.gdshader" id="8_vignette"]

[sub_resource type="Gradient" id="light_falloff"]
offsets = PackedFloat32Array(0, 1)
colors = PackedColorArray(1, 1, 1, 1, 1, 1, 1, 0)

[sub_resource type="GradientTexture2D" id="light_tex"]
gradient = SubResource("light_falloff")
width = 128
height = 128
fill = 1
fill_from = Vector2(0.5, 0.5)
fill_to = Vector2(0.5, 0)

[sub_resource type="RectangleShape2D" id="wall_h"]
size = Vector2({RW}, {2 * T})

[sub_resource type="RectangleShape2D" id="wall_v"]
size = Vector2({T}, {RH})

[sub_resource type="RectangleShape2D" id="wall_bottom"]
size = Vector2({EXIT[0] * T}, {T})

[sub_resource type="ShaderMaterial" id="vignette_mat"]
shader = ExtResource("8_vignette")

[node name="House" type="Node2D"]
script = ExtResource("1_level")

[node name="Floor" type="TileMapLayer" parent="."]
scale = Vector2(2, 2)
tile_map_data = {pack(floor)}
tile_set = ExtResource("2_tiles")

[node name="Walls" type="TileMapLayer" parent="."]
scale = Vector2(2, 2)
tile_map_data = {pack(walls)}
tile_set = ExtResource("2_tiles")

[node name="Darkness" type="CanvasModulate" parent="."]
color = Color(0.5, 0.46, 0.58, 1)

[node name="TorchLight" type="PointLight2D" parent="."]
position = Vector2{px(8, 1)}
color = Color(1, 0.72, 0.42, 1)
energy = 1.3
texture = SubResource("light_tex")
texture_scale = 3.2
script = ExtResource("7_flicker")

[node name="WindowLight" type="PointLight2D" parent="."]
position = Vector2{px(3, 2)}
color = Color(0.62, 0.78, 1, 1)
energy = 0.7
texture = SubResource("light_tex")
texture_scale = 2.4

[node name="World" type="Node2D" parent="."]
y_sort_enabled = true

[node name="Objects" type="TileMapLayer" parent="World"]
y_sort_enabled = true
scale = Vector2(2, 2)
tile_map_data = {pack(objects)}
tile_set = ExtResource("2_tiles")

[node name="Bounds" type="StaticBody2D" parent="World"]

[node name="Top" type="CollisionShape2D" parent="World/Bounds"]
position = Vector2({RW // 2}, {T})
shape = SubResource("wall_h")

[node name="Left" type="CollisionShape2D" parent="World/Bounds"]
position = Vector2({T // 2}, {RH // 2})
shape = SubResource("wall_v")

[node name="Right" type="CollisionShape2D" parent="World/Bounds"]
position = Vector2({RW - T // 2}, {RH // 2})
shape = SubResource("wall_v")

[node name="BottomLeft" type="CollisionShape2D" parent="World/Bounds"]
position = Vector2({EXIT[0] * T // 2}, {RH - T // 2})
shape = SubResource("wall_bottom")

[node name="BottomRight" type="CollisionShape2D" parent="World/Bounds"]
position = Vector2({RW - EXIT[0] * T // 2}, {RH - T // 2})
shape = SubResource("wall_bottom")

[node name="Lina" parent="World" instance=ExtResource("4_npc")]
position = Vector2({8 * T + T // 2}, {5 * T})
npc_name = "Lina"
lines = {packed(LINA)}
repeat_lines = {packed(LINA_REPEAT)}
sprite_tile = 99

[node name="Chest" parent="World" instance=ExtResource("5_interactable")]
position = Vector2({9 * T + T // 2}, {3 * T + 4})
speaker = "Baule"
lines = {packed(CHEST_LINES)}
repeat_lines = {packed(CHEST_REPEAT)}
prompt_height = 40.0

[node name="Bookshelf" parent="World" instance=ExtResource("5_interactable")]
position = Vector2({3 * T}, {3 * T + 4})
speaker = "Libreria"
lines = {packed(SHELF_LINES)}
repeat_lines = {packed(SHELF_REPEAT)}
prompt_height = 40.0

[node name="Exit" parent="World" instance=ExtResource("6_door")]
position = Vector2({RW // 2}, {RH + 2})
target_scene = "res://world/main.tscn"
target_spawn = "HouseDoor"
size = Vector2({len(EXIT) * T}, 12)

[node name="Subaru" parent="World" instance=ExtResource("3_subaru")]
position = Vector2({RW // 2}, {RH - 52})

[node name="Camera2D" type="Camera2D" parent="."]
position = Vector2({RW // 2}, {RH // 2})

[node name="Spawns" type="Node2D" parent="."]

[node name="Entrance" type="Marker2D" parent="Spawns"]
position = Vector2({RW // 2}, {RH - 52})

[node name="Effects" type="CanvasLayer" parent="."]
layer = 5

[node name="Vignette" type="ColorRect" parent="Effects"]
material = SubResource("vignette_mat")
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
mouse_filter = 2
'''
open(f"{proj}/world/house.tscn", "w", encoding="utf-8", newline="\n").write(house)
print("casa generata:", len(floor), "pavimento,", len(walls), "muri,", len(objects), "mobili")
