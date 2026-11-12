---
tags:
  - godot
  - appunti
aliases:
  - Basi di Godot
---

# Basi di Godot

← [[Gamelog]]

Appunti sui concetti incontrati finora, con esempi presi dal progetto. Si riferiscono a **Godot 4**.

## Nodi e scene

- Tutto in Godot è un **nodo**. Ogni tipo di nodo sa fare una cosa: disegnare uno sprite, gestire una collisione, riprodurre un suono…
- I nodi si organizzano ad **albero**: un nodo padre con i suoi figli.
- Una **scena** è un albero di nodi salvato in un file `.tscn`. Si può riusare quante volte si vuole, anche dentro altre scene.

> [!example] Esempio: `characters/subaru/subaru.tscn` (vedi [[2026-11-12-subaru|Subaru]])
> ```
> Subaru (CharacterBody2D)        ← il "corpo" che si muove e urta le cose
> ├── AnimatedSprite2D            ← disegna le animazioni
> └── CollisionShape2D            ← la forma usata per gli urti (solo i piedi)
> ```

## Risorse

- Una **risorsa** è un dato riutilizzabile: un'immagine, un suono, una forma di collisione, un insieme di animazioni…
- Si salvano come file `.tres` (testo) o vengono create dall'importazione (per esempio i `.png`).
- **SpriteFrames** (`subaru_frames.tres`) contiene le animazioni: per ognuna ha nome, velocità in fps, loop sì/no e la lista dei frame.
- **AtlasTexture** è "un ritaglio di un'immagine più grande". Ogni frame dello SpriteFrames è un AtlasTexture che punta a un rettangolo (`Rect2`) della spritesheet.

## Percorsi del progetto

- `res://` è la cartella principale del progetto, quella che contiene `project.godot`.
- `res://characters/subaru/subaru_sheet.png` vuol dire "il file `subaru_sheet.png` nella cartella `characters/subaru` del progetto".

> [!tip] Spostare i file
> Se sposti o rinomini i file **dall'editor di Godot**, i riferimenti si aggiornano da soli. Se lo fai da Esplora file, no.

## Cartelle ignorate

- Un file vuoto chiamato `.gdignore` dentro una cartella dice a Godot di non importarla.
- Il vault (`gamelog/`) ne ha uno. Oggi il vault sta fuori dalla cartella del progetto Godot (`let's-learn-godot/`), quindi Godot non lo vedrebbe comunque, ma il file resta utile se un giorno le cartelle cambiano.

## Pixel art nitida

Di default Godot sfuma le immagini quando le ingrandisce: per la pixel art serve il filtro **Nearest**.

- Per tutto il progetto: *Project Settings → Rendering → Textures → Default Texture Filter = Nearest*.
- Per un singolo nodo: proprietà `texture_filter` (nella scena di Subaru è già impostata).

## AnimatedSprite2D

- Mostra le animazioni di uno SpriteFrames.
- `play("walk_down")` avvia un'animazione. Se è già in corso non riparte da capo, quindi si può chiamare a ogni frame senza problemi.
- `offset` sposta il disegno rispetto alla posizione del nodo. Per Subaru vale `(0, -29)`: così l'origine del nodo è ai piedi.
- `flip_h` specchia lo sprite in orizzontale (comodo quando manca una direzione).

## CharacterBody2D e movimento

Il CharacterBody2D è il nodo adatto ai personaggi controllati dal giocatore.

Lo script `characters/subaru/subaru.gd`, in breve:

```gdscript
func _physics_process(_delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var running := Input.is_action_pressed("run")
	velocity = input * (run_speed if running else walk_speed)
	move_and_slide()
```

- `_physics_process` viene chiamata a ogni passo della fisica (di default 60 volte al secondo).
- `Input.get_vector(...)` legge quattro azioni e restituisce una direzione (`Vector2`) di lunghezza massima 1: in diagonale non si va più veloci.
- `Input.is_action_pressed("run")` è vero finché il tasto dell'azione è tenuto premuto.
- `a if condizione else b` è il "se in una riga" di GDScript: vale `a` se la condizione è vera, altrimenti `b`.
- `velocity` è la velocità in pixel al secondo; `move_and_slide()` muove il corpo e lo fa scivolare lungo i muri invece di bloccarlo.
- `motion_mode = Floating` (nella scena) serve per i giochi visti dall'alto: non c'è gravità né "pavimento".
- `@export var walk_speed` rende la variabile modificabile dall'Inspector senza toccare il codice.
- `@onready var sprite = $AnimatedSprite2D` prende il nodo figlio quando la scena è pronta. `$Nome` è la scorciatoia per trovare un figlio per nome.
- `sprite.speed_scale` moltiplica la velocità dell'animazione: la corsa usa la camminata a 1,8×.

## Azioni di input (Input Map)

- Un'**azione** è un nome (`run`, `move_left`…) a cui si collegano uno o più tasti. Lo script controlla l'azione, non il tasto.
- Si creano in *Impostazioni progetto → Mappa degli input*. Le nostre: `move_left/right/up/down` (frecce + WASD) e `run` (Shift). → [[2026-11-12-mappa-e-corsa#4. I comandi (Input Map)]]
- Le azioni `ui_left`, `ui_right`, ecc. esistono già, ma servono per i menu: per il gioco è meglio usare azioni proprie.

## Risoluzione per la pixel art

- **Viewport** (640×360): la risoluzione "interna" del gioco, quella in cui si ragiona per posizioni e dimensioni.
- **Window override** (1280×720): la grandezza reale della finestra.
- **Stretch mode `canvas_items`**: ingrandisce il viewport per riempire la finestra. Qui ×2, quindi ogni pixel diventa 2×2 e resta nitido.

## TileSet e TileMapLayer

- Un **TileSet** (`world/tileset.tres`) descrive i tile disponibili: da quale immagine vengono, quanto sono grandi (16×16) e quali proprietà hanno (collisione, Y-sort origin…).
- Un **TileMapLayer** è una griglia in cui si "dipingono" i tile del TileSet. Si possono avere più livelli, uno sopra l'altro.
- Nella nostra mappa ci sono due livelli: `Ground` (erba, sentiero) e `Objects` (alberi, staccionata…).
- **Collisioni dei tile:** nel TileSet si aggiunge un *Physics Layer*, poi si disegna una forma su ogni tile che deve bloccare.
- La mappa si dipinge dal pannello **TileMap** in basso, con il `TileMapLayer` selezionato. → [[2026-11-12-mappa-e-corsa#Come farlo a mano nell'editor]]

## Y-sort

- Di solito Godot disegna i nodi nell'ordine dell'albero: chi viene dopo sta sopra.
- Con **Y Sort Enabled** su un nodo, i suoi figli vengono invece disegnati in base alla **y**: chi ha i piedi più in basso sullo schermo sta davanti.
- Per questo l'origine di Subaru è ai piedi, e i tile degli alberi hanno uno `y_sort_origin` vicino alla base.
- Serve attivarlo sia sul nodo padre (`World`) sia sul `TileMapLayer` degli oggetti.

## Camera2D

- Mostra la porzione di mondo intorno alla sua posizione. Se è figlia di Subaru, lo segue.
- `limit_left/top/right/bottom` impediscono alla camera di mostrare oltre i bordi della mappa.
- `position_smoothing_enabled` la fa arrivare con un leggero ritardo, per un movimento più morbido.

## File creati da Godot

| File | Cos'è | Va su git? |
|---|---|---|
| `.godot/` | Cache dell'editor e delle importazioni | No, si ricrea da sola |
| `*.import` | Impostazioni di importazione di un asset (es. di un `.png`) | Sì |
| `*.uid` | Identificativo unico di uno script: i riferimenti restano validi anche se il file viene spostato | Sì |

## Godot da riga di comando

- `--path <cartella>`: apre il progetto in quella cartella.
- `--headless`: senza finestra. Utile per importare gli asset o fare controlli.
- `--import`: importa gli asset e poi esce.
- `-s <script.gd>`: esegue uno script che estende `SceneTree` invece del gioco. Lo usiamo in `tools/test_corsa.gd` per simulare i tasti e salvare screenshot.
- Gli argomenti dopo `--` arrivano allo script con `OS.get_cmdline_user_args()`.

## Glossario veloce

| Termine | Significato |
|---|---|
| Nodo | Il mattone base, un oggetto con una funzione precisa |
| Scena (`.tscn`) | Un albero di nodi salvato, riutilizzabile |
| Risorsa (`.tres`) | Un dato riutilizzabile (animazioni, forme, materiali…) |
| Spritesheet | Un'immagine con tanti frame disposti a griglia |
| Inspector | Il pannello dove si modificano le proprietà del nodo selezionato |
| GDScript | Il linguaggio di scripting di Godot, simile a Python |
| Azione | Un nome (es. `run`) collegato a uno o più tasti, configurato nella Input Map |
| Tile | Un quadratino dell'immagine del tileset (qui 16×16 px) |
| TileSet | L'elenco dei tile disponibili e delle loro proprietà |
| TileMapLayer | La griglia in cui si dipingono i tile |
| Y-sort | Ordinamento di disegno in base alla y: chi è più in basso sta davanti |
| Viewport | La "tela" del gioco, con la sua risoluzione interna |
