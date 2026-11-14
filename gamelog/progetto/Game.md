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

L'[[Autoload]] **`Game`** (`core/game.gd`): lo **stato della partita** che deve sopravvivere ai cambi di scena. Ha un solo compito: ricordare *dove sei* e *cosa è successo*, e decidere *cosa puoi fare adesso*.

> [!info] Diviso il 2026-11-13
> Prima `Game` faceva tutto: zaino, salvataggio, opzioni, suoni. Ora ognuna di queste cose ha il suo autoload. Vedi [[2026-11-13-riordino-del-codice]] e [[Responsabilità]].

## Cosa ricorda

| Variabile | Cosa contiene |
|---|---|
| `flags` | I ricordi: con chi hai parlato, oggetti raccolti, baule aperto, cutscene vista. Le chiavi sono in `FlagKeys` (vedi [[Costanti]]) |
| `spawn_point`, `spawn_position`, `spawn_facing` | Dove far comparire il giocatore nella prossima scena, e verso dove guarda |
| `changing_scene` | Vero durante un cambio di scena |
| `in_cutscene` | Vero durante una [[Cutscene]] (es. l'[[Intro]]): niente comandi né menu |
| `checkpoint` | Il punto di ritorno del [[Ritorno dalla Morte]]: scena, posizione, direzione, ricordi e zaino |
| `deaths` | Quante volte Subaru è morto. Il ritorno non lo azzera |

## Cosa fa

- `has_flag(chiave)`, `set_flag(chiave)`: leggere e scrivere un ricordo.
- `player_can_move()`: no durante un dialogo, un cambio di scena o una [[Cutscene]]. La usano [[Subaru]] e gli [[Interactable]].
- `can_open_menu()`: la **sola** regola per aprire il [[Menu di pausa]] e lo [[Zaino]]. Solo in un livello, quando il giocatore potrebbe muoversi e il gioco non è già in [[Pausa]].
- `new_game()`: dimentica tutto (ricordi, zaino, punto di ritorno, morti) e va al villaggio.
- `set_checkpoint()`, `return_to_checkpoint()`: fissare il punto di ritorno e tornarci. Vedi [[Ritorno dalla Morte]].
- `change_scene(path, spawn, facing)`: suono della porta, [[Dissolvenza]] al nero, [[Cambio di scena]], dissolvenza dal nero. Aspetta il segnale `scene_changed` per sapere quando la nuova scena è pronta. Il giocatore resta fermo (`changing_scene`) finché lo schermo non si è schiarito.

## Gli altri autoload

| Autoload | File | Cosa fa | Nota |
|---|---|---|---|
| `Inventory` | `core/inventory.gd` | Lo zaino: oggetti e quantità | [[Inventory]] |
| `SaveSystem` | `core/save_system.gd` | Salvare e riprendere la partita | [[Salvataggio]] |
| `Settings` | `core/settings.gd` | Volume e schermo intero, su file | [[Opzioni]] |
| `Sfx` | `core/sfx.gd` | I suoni dei menu e degli eventi | [[Sfx]] |

## Perché serve

Quando entri nella [[Casa di Lina]], il villaggio viene distrutto, e con lui il [[Saggio]] e la sua memoria. Uscendo viene ricreato da zero. Senza `Game`, il Saggio ti accoglierebbe ogni volta come uno sconosciuto.

## Vedi anche

- [[Autoload]] · [[Responsabilità]] · [[Costanti]]
