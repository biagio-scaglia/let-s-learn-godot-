---
tags:
  - progetto
  - autoload
aliases:
  - game.gd
  - Stato del gioco
---

# Game

← [[Gamelog]]

L'[[Autoload]] **`Game`** (`core/game.gd`): lo **stato del gioco** che deve sopravvivere ai cambi di scena.

## Cosa ricorda

| Variabile | Cosa contiene |
|---|---|
| `flags` | Un dizionario di ricordi. Per ora: quante volte hai interagito con ogni [[Interactable]] (chiave `"talked:<percorso>"`) |
| `spawn_point`, `spawn_facing` | Dove far comparire il giocatore nella prossima scena, e verso dove guarda |
| `changing_scene` | Vero durante un cambio di scena |

## Cosa fa

- `change_scene(path, spawn, facing)`: suono della porta, [[Dissolvenza]] al nero, [[Cambio di scena]], dissolvenza dal nero. Usa [[Await]].
- `player_can_move()`: no durante un dialogo o un cambio di scena. La usa [[Subaru]].
- `new_game()`: dimentica tutto e va al villaggio. La usa la [[Schermata iniziale]].
- **Inventario:** `inventory`, `add_item()`, `remove_item()`, `has_item()`, il segnale `inventory_changed`. Vedi [[Zaino]] e [[Oggetti]].
- **Salvataggio:** `save_game()`, `continue_game()`, `has_save()`, `save_info()`. Vedi [[Salvataggio]].
- `ui_sound()`: i suoni dei menu (spostamento, conferma, indietro).
- Le [[Opzioni]]: `volume` e `fullscreen`, salvate su file con [[ConfigFile]].
- Funziona anche in [[Pausa]] (`process_mode = Always`).

## Perché serve

Quando entri nella [[Casa di Lina]], il villaggio viene distrutto, e con lui il [[Saggio]] e la sua memoria. Uscendo viene ricreato da zero. Senza `Game`, il Saggio ti accoglierebbe ogni volta come uno sconosciuto.

Più avanti qui finiranno anche l'inventario e il salvataggio.
