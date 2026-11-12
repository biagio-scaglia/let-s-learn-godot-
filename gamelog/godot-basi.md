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

> [!example] Esempio: `subaru/subaru.tscn` (vedi [[2026-11-12-subaru|Subaru]])
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
- `res://subaru/subaru_sheet.png` vuol dire "il file `subaru_sheet.png` nella cartella `subaru` del progetto".

> [!tip] Spostare i file
> Se sposti o rinomini i file **dall'editor di Godot**, i riferimenti si aggiornano da soli. Se lo fai da Esplora file, no.

## Cartelle ignorate

- Un file vuoto chiamato `.gdignore` dentro una cartella dice a Godot di non importarla.
- Questo vault (`gamelog/`) ne ha uno, così Godot non importa le immagini delle note.

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

Lo script `subaru/subaru.gd`, in breve:

```gdscript
func _physics_process(_delta: float) -> void:
	var input := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input * speed
	move_and_slide()
```

- `_physics_process` viene chiamata a ogni passo della fisica (di default 60 volte al secondo).
- `Input.get_vector(...)` legge quattro azioni e restituisce una direzione (`Vector2`) di lunghezza massima 1: in diagonale non si va più veloci.
- `velocity` è la velocità in pixel al secondo; `move_and_slide()` muove il corpo e lo fa scivolare lungo i muri invece di bloccarlo.
- `motion_mode = Floating` (nella scena) serve per i giochi visti dall'alto: non c'è gravità né "pavimento".
- `@export var speed` rende la variabile modificabile dall'Inspector senza toccare il codice.
- `@onready var sprite = $AnimatedSprite2D` prende il nodo figlio quando la scena è pronta. `$Nome` è la scorciatoia per trovare un figlio per nome.

## Azioni di input

- Le azioni `ui_left`, `ui_right`, `ui_up`, `ui_down` esistono già e sono collegate alle frecce.
- Le proprie azioni (per esempio WASD) si creano in *Project Settings → Input Map*.

## Glossario veloce

| Termine | Significato |
|---|---|
| Nodo | Il mattone base, un oggetto con una funzione precisa |
| Scena (`.tscn`) | Un albero di nodi salvato, riutilizzabile |
| Risorsa (`.tres`) | Un dato riutilizzabile (animazioni, forme, materiali…) |
| Spritesheet | Un'immagine con tanti frame disposti a griglia |
| Inspector | Il pannello dove si modificano le proprietà del nodo selezionato |
| GDScript | Il linguaggio di scripting di Godot, simile a Python |
