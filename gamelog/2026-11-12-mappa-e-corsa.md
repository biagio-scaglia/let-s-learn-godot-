---
data: 2026-11-12
tags:
  - gamelog
  - mappa
  - tileset
  - input
  - personaggi/subaru
stato: funzionante
aliases:
  - Mappa e corsa
---

# 2026-11-12 — Una mappa vera e Subaru che corre

← [[Gamelog]] · Voce precedente: [[2026-11-12-subaru|Subaru]] · Concetti usati: [[godot-basi|Basi di Godot]]

## Obiettivo

Mettere Subaru dentro il progetto Godot, dargli una mappa in cui muoversi con un tileset esterno e farlo **correre**.

![[mappa_subaru_fermo.png]]

*Il gioco avviato: Subaru al centro dell'incrocio. La finestra è 1280×720, ma il gioco "pensa" a 640×360 e ingrandisce tutto ×2.*

## Come avviarlo

1. Apri Godot 4.7 e importa la cartella `let's-learn-godot`.
2. Premi **F5** (avvia la scena principale).

| Tasto | Azione |
|---|---|
| Frecce o WASD | Muoversi |
| Shift (tenuto premuto) | Correre |

## Risultato verificato

Il test automatico (`tools/test_corsa.gd`, vedi [[#7. Verifica automatica]]) ha misurato:

| Cosa | Risultato |
|---|---|
| Camminata | ~80 px/s, animazione a velocità normale |
| Corsa (Shift) | ~150 px/s, animazione 1,8 volte più veloce |
| Contro alberi e bordi | Subaru si ferma (collisione) |
| Dietro un albero | L'albero copre le gambe di Subaru (Y-sort) |

---

## 1. Asset esterni: Tiny Town di Kenney

![[tiny_town_numerata.png|500]]

*Il tileset con il numero di ogni tile. I numeri sono quelli usati in `tools/genera_mappa.py`.*

- **Cos'è:** [Tiny Town](https://kenney.nl/assets/tiny-town) di Kenney, 132 tile da 16×16 px: erba, sentieri, alberi, staccionate, case.
- **Licenza:** CC0, cioè si può usare liberamente, anche in un gioco commerciale. Citare l'autore non è obbligatorio, ma l'abbiamo fatto in `CREDITS.md`.
- **Perché questo:** è pixel art pulita, ha tutto per una prima mappa all'aperto e la licenza non crea problemi.
- **Dove l'abbiamo preso:** da [OpenGameArt](https://opengameart.org/content/tiny-town). Il sito di Kenney blocca i download automatici, ma OpenGameArt ripubblica lo stesso pacchetto.
- **Cosa abbiamo tenuto:** solo `tilemap_packed.png` (tutti i tile in un'immagine, senza spazi tra uno e l'altro) e il file di licenza. Sono in `assets/kenney_tiny_town/`.

> [!tip] Dove cercare altri asset gratuiti
> - [kenney.nl](https://kenney.nl/assets): tutto CC0.
> - [OpenGameArt](https://opengameart.org): controlla sempre la licenza di ogni pacchetto (CC0, CC-BY, CC-BY-SA…).
> - [itch.io → Game assets](https://itch.io/game-assets/free): tanti pacchetti gratuiti, licenze varie.

## 2. Struttura del progetto

Subaru è stato spostato dentro il progetto Godot (con `git mv`, così la cronologia resta):

```
let's-learn-godot/
├── project.godot
├── assets/kenney_tiny_town/     ← asset esterni
├── characters/subaru/           ← il personaggio
└── world/
    ├── tileset.tres             ← quali tile esistono e quali hanno collisione
    └── main.tscn                ← la mappa (scena principale)
```

I percorsi interni sono passati da `res://subaru/...` a `res://characters/subaru/...`.

## 3. Impostazioni del progetto

Nell'editor: **Progetto → Impostazioni progetto** (attiva "Impostazioni avanzate" in alto a destra per vederle tutte).

| Impostazione | Valore | Perché |
|---|---|---|
| Application → Run → Main Scene | `res://world/main.tscn` | Cosa parte con F5 |
| Display → Window → Size → Viewport Width/Height | 640 × 360 | La risoluzione "interna" del gioco |
| Display → Window → Size → Window Width/Height Override | 1280 × 720 | La finestra reale è il doppio: tutto appare ingrandito ×2 |
| Display → Window → Stretch → Mode | `canvas_items` | Ingrandisce il gioco per riempire la finestra |
| Rendering → Textures → Default Texture Filter | Nearest | Pixel nitidi invece che sfocati |

## 4. I comandi (Input Map)

Nell'editor: **Impostazioni progetto → scheda Mappa degli input**. Scrivi il nome dell'azione, premi "Aggiungi", poi il **+** accanto all'azione per assegnare un tasto.

| Azione | Tasti |
|---|---|
| `move_left` | A, ← |
| `move_right` | D, → |
| `move_up` | W, ↑ |
| `move_down` | S, ↓ |
| `run` | Shift |

> [!info] Perché azioni e non tasti
> Lo script chiede "è premuta l'azione `run`?" e non "è premuto Shift?". Così si possono cambiare i tasti, o aggiungere un controller, senza toccare il codice.

## 5. La corsa nello script

In `characters/subaru/subaru.gd` sono cambiate poche righe:

```gdscript
@export var walk_speed := 80.0
@export var run_speed := 150.0
@export var run_anim_scale := 1.8

func _physics_process(_delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var running := Input.is_action_pressed("run")
	velocity = input * (run_speed if running else walk_speed)
	move_and_slide()
	# ...
	sprite.speed_scale = run_anim_scale if running else 1.0
```

- Non servono nuovi disegni per la corsa: si usa la stessa animazione di camminata, solo più veloce (`speed_scale`).
- Grazie a `@export`, le tre velocità si regolano dall'Inspector selezionando Subaru.

## 6. TileSet e mappa

### Nel progetto

La mappa ha due livelli **TileMapLayer**, entrambi ingranditi ×2 (`scale = (2, 2)`), così i tile da 16 px diventano 32 px e sono in proporzione con Subaru (54 px):

```
Main (Node2D)
├── Ground (TileMapLayer)          ← erba e sentiero, nessuna collisione
└── World (Node2D, Y-sort attivo)
    ├── Objects (TileMapLayer, Y-sort attivo)  ← alberi, staccionata, cartello, funghi
    ├── Bounds (StaticBody2D)      ← 4 muri invisibili sopra le file di alberi del bordo
    └── Subaru (istanza di subaru.tscn)
        └── Camera2D               ← segue Subaru, non esce dai bordi della mappa
```

- **Alberi alti due tile:** in Tiny Town molti alberi sono fatti da due tile uno sopra l'altro, la **chioma** sopra e il **tronco** sotto. Le coppie sono 4+16 (verde a punta), 3+15 (giallo) e 5+16 (verde tondo). I tile 27 e 28 invece sono alberelli da un tile solo.
- **Collisioni:** solo tronchi, staccionata e cartello, e solo nella parte bassa. Subaru può passare "dietro" le chiome con la testa.
- **Muri invisibili (`Bounds`):** tra un tronco e l'altro resta spazio, quindi senza muri Subaru potrebbe infilarsi nel bosco del bordo e uscire dalla mappa. Uno `StaticBody2D` con quattro `CollisionShape2D` rettangolari copre le due file di alberi su ogni lato.
- **Y-sort:** chi ha i piedi più in basso sullo schermo viene disegnato davanti. Per i tile il punto di riferimento è lo `y_sort_origin`: 6 px per tronchi e oggetti (vicino alla base), **22 px per le chiome** (16 + 6, cioè la base del tronco nel tile sotto). Così chioma e tronco si ordinano insieme, come un unico albero.
- **Camera2D:** è figlia di Subaru, quindi lo segue. I `limit_*` (0, 0, 1280, 768) le impediscono di mostrare il vuoto oltre la mappa. `position_smoothing` rende il movimento morbido.

![[mappa_dietro_albero.png|500]]

*A sinistra: Subaru dietro un albero. L'albero copre le gambe perché ha la base più in basso.*

### Come l'abbiamo fatto

La mappa è stata **generata con uno script Python** (`tools/genera_mappa.py`), che scrive `tileset.tres` e `main.tscn`. In questo modo è riproducibile: lo stesso script produce sempre la stessa mappa.

Lo script mette erba ovunque, disegna un incrocio di sentieri con una piazza, sceglie i bordi giusti del sentiero guardando le celle vicine, circonda la mappa con due file di alberi e sparge alberi, cespugli e funghi.

> [!warning] Lo script sovrascrive la mappa
> Da ora in poi conviene modificare la mappa **nell'editor**. Se rilanci lo script, le modifiche fatte a mano in `main.tscn` vanno perse.

### Come farlo a mano nell'editor

1. **Crea il TileSet:** aggiungi un nodo `TileMapLayer` → nell'Inspector, `Tile Set` → *Nuovo TileSet*.
2. **Aggiungi l'immagine:** apri il pannello **TileSet** in basso e trascina `tilemap_packed.png` nella lista a sinistra. Alla domanda "creare i tile automaticamente?" rispondi sì. La dimensione dei tile è già 16×16.
3. **Collisioni:** nell'Inspector del TileSet, *Physics Layers* → *Aggiungi elemento*. Poi nel pannello TileSet → scheda **Dipingi** → *Physics Layer 0* e disegna il rettangolo sui tile dei tronchi.
4. **Y-sort origin:** sempre in **Dipingi**, scegli *Y Sort Origin* e impostalo a 6 sui tronchi e sugli oggetti, a 22 sulle chiome.
5. **Alberi alti:** quando dipingi un albero da due tile, metti la chioma e subito sotto il tronco. Puoi selezionare entrambi i tile nel pannello (trascinando) e dipingerli insieme.
6. **Disegna:** seleziona il `TileMapLayer`, apri il pannello **TileMap** in basso, scegli un tile e dipingi nella vista 2D. Con il secchiello riempi un'area intera.
7. **Salva il TileSet come file** (`world/tileset.tres`) dal menu a tendina della proprietà `Tile Set`: così i due livelli possono usare lo stesso.
8. **Y-sort:** sul nodo `World` e sul livello `Objects` attiva *Ordering → Y Sort Enabled*.
9. **Muri invisibili:** aggiungi a `World` un `StaticBody2D` e, come figli, dei `CollisionShape2D` con forma *RectangleShape2D*. Trascina i rettangoli sopra i bordi della mappa.

## 7. Verifica automatica

`tools/test_corsa.gd` avvia la mappa, **simula i tasti** e salva degli screenshot. Dalla cartella `let's-learn-godot`:

```
<percorso>\Godot_v4.7.2-stable_win64.exe --path . -s ../tools/test_corsa.gd -- <cartella_screenshot>
```

- `-s` esegue uno script che estende `SceneTree` al posto del gioco normale: utile per test e strumenti.
- `Input.action_press("run")` "finge" che il tasto sia premuto.
- `root.get_texture().get_image().save_png(...)` salva quello che si vede sullo schermo.

Si apre una finestra per qualche secondo, poi si chiude da sola. Alla chiusura Godot stampa alcuni messaggi `ERROR: BUG: Unreferenced static string` e `leaked at exit`: sono normali quando si esce da uno script `-s` e non indicano problemi del gioco.

## Problemi incontrati

![[alberi_due_tile.png|300]]

*Le tre coppie chioma + tronco: 4+16, 3+15, 5+16.*

- **Alberi tagliati:** nella prima versione ogni albero era un tile solo, quindi in mappa comparivano chiome senza tronco e tronchi senza cima. In realtà molti alberi di Tiny Town sono alti due tile. Per capire quali vanno insieme abbiamo controllato i bordi di ogni tile: un bordo con il contorno scuro è "chiuso", un bordo con il colore di riempimento che arriva fino al limite è "aperto" e continua nel tile vicino. Ora lo script piazza sempre la coppia chioma + tronco e controlla che nessuna chioma resti senza tronco.
- **Alberi "vuoti":** nella prima versione la chioma verde (tile 4) era messa da sola: con il centro dello stesso colore dell'erba, si vedeva solo il contorno. Era lo stesso problema degli alberi tagliati.
- **Funghi con lo sfondo grigio:** funghi e germogli hanno lo sfondo trasparente. Messi al posto dell'erba nel livello `Ground`, sotto non c'era niente e si vedeva il colore di sfondo. Spostati nel livello `Objects`, sopra l'erba.
- **Download bloccato:** kenney.nl non permette download automatici. Risolto scaricando da OpenGameArt.
- **Screenshot "in ritardo":** con `position_smoothing` la camera raggiunge Subaru con un piccolo ritardo, quindi uno screenshot fatto subito dopo uno spostamento istantaneo non è centrato. È normale.

## Prossimi passi

- [ ] Provare a modificare la mappa a mano nell'editor
- [ ] Una casa con una porta in cui entrare (cambio scena)
- [ ] Un personaggio con cui parlare (prima finestra di dialogo)
- [ ] Animazioni di corsa dedicate, invece della camminata accelerata
