"""Genera il TileSet e la mappa di prova (world/tileset.tres e world/main.tscn).

Uso (dalla cartella del repository):
    python tools/genera_mappa.py

ATTENZIONE: sovrascrive world/main.tscn. Se hai già modificato la mappa
nell'editor di Godot, quelle modifiche andranno perse.

I numeri dei tile sono quelli di gamelog/assets/tiny_town_numerata.png
(numero = riga * 12 + colonna).
"""
import os, sys, struct, random

proj = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), "..", "let's-learn-godot")
random.seed(7)
W, H = 40, 24          # dimensioni della mappa in tile
T = 32                 # un tile da 16 px, ingrandito x2
A = lambda n: (n % 12, n // 12)

# ---------- Tile usati ----------
GRASS = [0, 1, 2]
DIRT = [12, 13, 14, 24, 25, 26, 36, 37, 38, 39, 40, 41, 42]
DECOR = [17, 29]                       # germoglio, funghi: si attraversano
TALL_TREES = [(4, 16), (3, 15), (5, 16)]   # (chioma, tronco): alberi alti due tile
SMALL_TREES = [27, 28]                 # alberelli da un tile
FENCE = [44, 45, 46]
SIGN = 83

# La casa: 5 tile di larghezza, 3 di altezza (due di tetto rosso, uno di muro con porta).
HOUSE_X, HOUSE_Y = 6, 3            # cella in alto a sinistra
HOUSE = [
    [52, 53, 55, 53, 54],          # tetto, parte alta (55 = abbaino)
    [64, 65, 67, 65, 66],          # tetto, parte bassa (67 = timpano sopra la porta)
    [72, 84, 87, 84, 75],          # muro: bordo, finestra, porta, finestra, bordo
]
DOOR_X, DOOR_Y = HOUSE_X + 2, HOUSE_Y + 2
HOUSE_WALL = set(HOUSE[2])

rect = lambda x0, y0, x1, y1: f"PackedVector2Array({x0}, {y0}, {x1}, {y0}, {x1}, {y1}, {x0}, {y1})"
COLL = {t: rect(-6, 0, 6, 8) for t in [15, 16] + SMALL_TREES}   # solo il tronco
COLL.update({44: rect(-6, -1, 8, 5), 45: rect(-8, -1, 8, 5), 46: rect(-8, -1, 6, 5), SIGN: rect(-4, 2, 4, 8)})
COLL.update({t: rect(-8, 0, 8, 8) for t in HOUSE_WALL})        # il muro della casa blocca
# Y-sort origin: il punto "dei piedi" di ogni oggetto. La chioma usa la base del
# tronco, che sta nel tile sotto (16 px più in basso), così l'albero si ordina tutto insieme.
# Lo stesso per il tetto: si ordina con la base del muro, uno o due tile più in basso.
YSORT = {t: 6 for t in list(COLL) + DECOR}
YSORT.update({top: 16 + 6 for top, _ in TALL_TREES})
YSORT.update({t: 8 for t in HOUSE[2]})
YSORT.update({t: 16 + 8 for t in HOUSE[1]})
YSORT.update({t: 32 + 8 for t in HOUSE[0]})

# ---------- TileSet ----------
lines = []
for t in sorted(set(GRASS + DIRT + DECOR + FENCE + SMALL_TREES + [SIGN]) | {t for p in TALL_TREES for t in p} | {t for row in HOUSE for t in row}):
    x, y = A(t)
    lines.append(f"{x}:{y}/0 = 0")
    if t in YSORT:
        lines.append(f"{x}:{y}/0/y_sort_origin = {YSORT[t]}")
    if t in COLL:
        lines.append(f"{x}:{y}/0/physics_layer_0/polygon_0/points = {COLL[t]}")
tileset = f'''[gd_resource type="TileSet" load_steps=5 format=3]

[ext_resource type="Texture2D" path="res://assets/kenney_tiny_town/tilemap_packed.png" id="1_atlas"]
[ext_resource type="Texture2D" path="res://assets/effects/shadow_tree.png" id="2_shadow"]

[sub_resource type="TileSetAtlasSource" id="TileSetAtlasSource_town"]
texture = ExtResource("1_atlas")
{chr(10).join(lines)}

[sub_resource type="TileSetAtlasSource" id="TileSetAtlasSource_shadows"]
texture = ExtResource("2_shadow")
0:0/0 = 0

[resource]
physics_layer_0/collision_layer = 1
sources/0 = SubResource("TileSetAtlasSource_town")
sources/1 = SubResource("TileSetAtlasSource_shadows")
'''
open(f"{proj}/world/tileset.tres", "w", encoding="utf-8", newline="\n").write(tileset)

# ---------- Terreno: erba e sentieri ----------
dirt = [[False] * W for _ in range(H)]
def fill(x0, y0, x1, y1):
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1): dirt[y][x] = True
fill(3, 11, 36, 13)    # sentiero orizzontale
fill(19, 3, 21, 20)    # sentiero verticale
fill(15, 9, 25, 15)    # piazza
fill(DOOR_X - 1, DOOR_Y + 1, DOOR_X + 1, 10)   # vialetto dalla porta di casa al sentiero
D = lambda x, y: 0 <= x < W and 0 <= y < H and dirt[y][x]

ground = {}
for y in range(H):
    for x in range(W):
        if not dirt[y][x]:
            ground[(x, y)] = random.choices(GRASS, [85, 10, 5])[0]
            continue
        # Sceglie il bordo giusto del sentiero guardando le celle vicine.
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

# ---------- Oggetti ----------
objects = {}
free = lambda x, y: 0 <= x < W and 0 <= y < H and (x, y) not in objects and not D(x, y)

def tall_tree(x, y):
    """Albero alto: chioma in (x, y-1), tronco in (x, y)."""
    top, trunk = random.choice(TALL_TREES)
    objects[(x, y - 1)] = top
    objects[(x, y)] = trunk

# Casa, staccionata e cartello per primi, così gli alberi non ci finiscono sopra.
for dy, row in enumerate(HOUSE):
    for dx, t in enumerate(row):
        objects[(HOUSE_X + dx, HOUSE_Y + dy)] = t
# Intorno alla casa lasciamo un tile di prato libero.
near_house = lambda x, y: HOUSE_X - 1 <= x <= HOUSE_X + 5 and HOUSE_Y - 1 <= y <= HOUSE_Y + 3
# Staccionata in due pezzi, con il varco per il vialetto.
for x0, x1 in [(4, DOOR_X - 2), (DOOR_X + 2, 12)]:
    for x in range(x0, x1 + 1):
        objects[(x, 8)] = 44 if x == x0 else 46 if x == x1 else 45
objects[(14, 10)] = SIGN

# Bordo: due file di alberi alti tutto intorno (righe a coppie: chioma sopra, tronco sotto).
for y in range(0, H, 2):
    for x in range(W):
        if x < 2 or x >= W - 2 or y < 2 or y >= H - 2:
            tall_tree(x, y + 1)

# Alberi e decorazioni sparsi, lontani dal sentiero.
near_dirt = lambda x, y: any(D(x+dx, y+dy) for dx in (-1, 0, 1) for dy in (-1, 0, 1))
for y in range(3, H - 2):
    for x in range(2, W - 2):
        if not free(x, y) or near_dirt(x, y) or near_house(x, y) or near_house(x, y - 1):
            continue
        r = random.random()
        if r < 0.05 and free(x, y - 1):
            tall_tree(x, y)
        elif r < 0.07:
            objects[(x, y)] = random.choice(SMALL_TREES)
        elif r < 0.10:
            objects[(x, y)] = random.choice(DECOR)

# Controllo: ogni chioma deve avere il suo tronco subito sotto.
tops = {top: trunk for top, trunk in TALL_TREES}
for (x, y), t in objects.items():
    if t in tops and objects.get((x, y + 1)) not in tops.values():
        sys.exit(f"Chioma senza tronco in {(x, y)}")

# Ombre: sotto ogni tronco e ogni alberello (sorgente 1 del TileSet, tile 0).
SHADOW = -1
shadows = {pos: SHADOW for pos, t in objects.items() if t in (15, 16, 27, 28)}

def pack(cells):
    """Formato di tile_map_data: 2 byte di versione, poi 12 byte per cella."""
    b = bytearray(struct.pack("<H", 0))
    for (x, y), t in sorted(cells.items(), key=lambda kv: (kv[0][1], kv[0][0])):
        source, (ax, ay) = (1, (0, 0)) if t == SHADOW else (0, A(t))
        b += struct.pack("<hhHHHH", x, y, source, ax, ay, 0)
    return "PackedByteArray(" + ", ".join(map(str, b)) + ")"

# ---------- Scena ----------
BW = 2 * T   # spessore dei muri invisibili: le due file di alberi del bordo

# Le frasi del Saggio (si possono cambiare anche dall'Inspector, selezionando il nodo Npc).
NPC_LINES = [
    "Oh, un volto nuovo! Benvenuto in questo piccolo villaggio.",
    "Io sono il Saggio. Passo le giornate a guardare crescere gli alberi.",
    "Se hai fretta, tieni premuto Shift per correre... ma qui nessuno ha fretta.",
    "Torna a trovarmi quando vuoi. Avrò altre storie da raccontarti!",
]
NPC_REPEAT = [
    "Ancora qui? Gli alberi non crescono più in fretta se li guardiamo in due!",
    "Hai letto il cartello vicino alla piazza? Lo ha scritto mio nonno.",
    "E se passi dalla casa col tetto rosso, saluta mia nipote Lina.",
]
SIGN_LINES = [
    "Villaggio di Erbalta.",
    "A nord: il bosco. A est e a ovest: la strada maestra.",
]
SIGN_REPEAT = ['Sotto, piccolo piccolo: "Il Saggio sa tutto. Chiedete a lui."']

def packed(strings):
    """Scrive una lista di frasi come PackedStringArray, con le virgolette protette."""
    return "PackedStringArray(" + ", ".join('"' + s.replace('"', '\\"') + '"' for s in strings) + ")"

EMILIA_LINES = [
    "Subaru! Eccoti, finalmente.",
    "Questo villaggio è così tranquillo... Il Saggio dice che qui gli alberi crescono più felici.",
    "Hai già conosciuto Lina? Abita nella casa col tetto rosso, a nord-ovest.",
]
EMILIA_REPEAT = ["Se ti stanchi, riposiamo un po' qui in piazza. Non c'è nessuna fretta, no?"]

SX, SY = 14, 10   # cella del cartello
DOOR_PX = (DOOR_X * T + T // 2, (DOOR_Y + 1) * T)   # il bordo basso della porta, in pixel
main = f'''[gd_scene load_steps=13 format=3]

[ext_resource type="TileSet" path="res://world/tileset.tres" id="1_tiles"]
[ext_resource type="PackedScene" path="res://characters/subaru/subaru.tscn" id="2_subaru"]
[ext_resource type="PackedScene" path="res://characters/npc/npc.tscn" id="3_npc"]
[ext_resource type="Shader" path="res://effects/vignette.gdshader" id="4_vignette"]
[ext_resource type="PackedScene" path="res://interactables/interactable.tscn" id="5_interactable"]
[ext_resource type="Script" path="res://world/level.gd" id="6_level"]
[ext_resource type="PackedScene" path="res://interactables/door.tscn" id="7_door"]
[ext_resource type="Texture2D" path="res://characters/emilia/emilia_charset.png" id="8_emilia"]

[sub_resource type="ShaderMaterial" id="vignette_mat"]
shader = ExtResource("4_vignette")

[sub_resource type="Gradient" id="pollen_fade"]
offsets = PackedFloat32Array(0, 0.2, 0.8, 1)
colors = PackedColorArray(1, 0.96, 0.75, 0, 1, 0.96, 0.75, 0.75, 1, 0.96, 0.75, 0.75, 1, 0.96, 0.75, 0)

[sub_resource type="RectangleShape2D" id="bounds_h"]
size = Vector2({W * T}, {BW})

[sub_resource type="RectangleShape2D" id="bounds_v"]
size = Vector2({BW}, {H * T})

[node name="Main" type="Node2D"]
script = ExtResource("6_level")

[node name="Ground" type="TileMapLayer" parent="."]
scale = Vector2(2, 2)
tile_map_data = {pack(ground)}
tile_set = ExtResource("1_tiles")

[node name="Shadows" type="TileMapLayer" parent="."]
scale = Vector2(2, 2)
tile_map_data = {pack(shadows)}
tile_set = ExtResource("1_tiles")

[node name="Tint" type="CanvasModulate" parent="."]
color = Color(1, 0.97, 0.92, 1)

[node name="World" type="Node2D" parent="."]
y_sort_enabled = true

[node name="Objects" type="TileMapLayer" parent="World"]
y_sort_enabled = true
scale = Vector2(2, 2)
tile_map_data = {pack(objects)}
tile_set = ExtResource("1_tiles")

[node name="Bounds" type="StaticBody2D" parent="World"]

[node name="Top" type="CollisionShape2D" parent="World/Bounds"]
position = Vector2({W * T // 2}, {BW // 2})
shape = SubResource("bounds_h")

[node name="Bottom" type="CollisionShape2D" parent="World/Bounds"]
position = Vector2({W * T // 2}, {H * T - BW // 2})
shape = SubResource("bounds_h")

[node name="Left" type="CollisionShape2D" parent="World/Bounds"]
position = Vector2({BW // 2}, {H * T // 2})
shape = SubResource("bounds_v")

[node name="Right" type="CollisionShape2D" parent="World/Bounds"]
position = Vector2({W * T - BW // 2}, {H * T // 2})
shape = SubResource("bounds_v")

[node name="Npc" parent="World" instance=ExtResource("3_npc")]
position = Vector2(752, 352)
npc_name = "Saggio"
lines = {packed(NPC_LINES)}
repeat_lines = {packed(NPC_REPEAT)}

[node name="Emilia" parent="World" instance=ExtResource("3_npc")]
position = Vector2(560, 476)
npc_name = "Emilia"
lines = {packed(EMILIA_LINES)}
repeat_lines = {packed(EMILIA_REPEAT)}
charset = ExtResource("8_emilia")

[node name="Sign" parent="World" instance=ExtResource("5_interactable")]
position = Vector2({SX * T + T // 2}, {SY * T + T - 6})
speaker = "Cartello"
lines = {packed(SIGN_LINES)}
repeat_lines = {packed(SIGN_REPEAT)}
prompt_height = 42.0

[node name="HouseDoor" parent="World" instance=ExtResource("7_door")]
position = Vector2({DOOR_PX[0]}, {DOOR_PX[1] + 5})
target_scene = "res://world/house.tscn"
target_spawn = "Entrance"
arrive_facing = "up"

[node name="Spawns" type="Node2D" parent="."]

[node name="HouseDoor" type="Marker2D" parent="Spawns"]
position = Vector2({DOOR_PX[0]}, {DOOR_PX[1] + 34})

[node name="Subaru" parent="World" instance=ExtResource("2_subaru")]
position = Vector2(656, 416)

[node name="Camera2D" type="Camera2D" parent="World/Subaru"]
limit_left = 0
limit_top = 0
limit_right = {W * T}
limit_bottom = {H * T}
position_smoothing_enabled = true

[node name="Pollen" type="CPUParticles2D" parent="World/Subaru/Camera2D"]
z_index = 5
amount = 28
lifetime = 7.0
preprocess = 7.0
local_coords = false
emission_shape = 3
emission_rect_extents = Vector2(340, 200)
direction = Vector2(1, -0.3)
spread = 40.0
gravity = Vector2(0, 0)
initial_velocity_min = 4.0
initial_velocity_max = 10.0
scale_amount_min = 1.0
scale_amount_max = 2.0
color_ramp = SubResource("pollen_fade")

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
open(f"{proj}/world/main.tscn", "w", encoding="utf-8", newline="\n").write(main)
print("terreno", len(ground), "oggetti", len(objects))
