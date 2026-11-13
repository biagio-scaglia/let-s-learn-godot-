---
tags:
  - progetto
aliases:
  - salvataggio.cfg
  - Continua
---

# Salvataggio

← [[Gamelog]]

- **Salvare:** [[Menu di pausa]] → *Salva*. Si sente un accordo e compare l'[[Avvisi|avviso]] "Partita salvata".
- **Riprendere:** nella [[Schermata iniziale]] compare **Continua**, già selezionato, con sotto luogo e data.

![[titolo_continua.png|500]]

## Cosa c'è nel file

Se ne occupa l'[[Autoload]] **`SaveSystem`** (`core/save_system.gd`): `save_game()`, `continue_game()`, `has_save()`, `save_info()`.

`user://salvataggio.cfg` ([[ConfigFile]]), sezione `[partita]`:

| Chiave | Contenuto |
|---|---|
| `scena` | Es. `res://world/house.tscn` |
| `posizione`, `direzione` | Dove sta e verso dove guarda [[Subaru]] |
| `data` | Data e ora, mostrate nel titolo |
| `zaino` | `Inventory.items` |
| `ricordi` | `Game.flags` |

Come funziona, spiegato in generale: [[Salvare la partita]].

## Da sapere

- C'è **un solo** salvataggio: salvare di nuovo lo sovrascrive.
- *Nuova partita* non cancella il salvataggio: lo sostituisce solo quando salvi di nuovo.
- Il file sta in `%APPDATA%\Godot\app_userdata\let's learn godot\`.
