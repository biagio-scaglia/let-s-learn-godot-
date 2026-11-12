---
tags:
  - concetto
  - input
aliases:
  - Azioni
  - Input
  - Mappa degli input
---

# Input Map

← [[godot-basi|Basi di Godot]]

Un'**azione** è un nome (`run`, `move_left`…) collegato a uno o più tasti. Il codice controlla l'azione, non il tasto: così i tasti si possono cambiare, o si può aggiungere un controller, senza toccare il codice.

Si configurano in **Impostazioni progetto → Mappa degli input**: scrivi il nome, *Aggiungi*, poi **+** per assegnare un tasto.

## Funzioni utili

| Funzione | Cosa restituisce |
|---|---|
| `Input.get_vector(sx, dx, su, giù)` | Una direzione `Vector2` lunga al massimo 1 (in diagonale non si va più veloci) |
| `Input.is_action_pressed("run")` | `true` finché il tasto è premuto |
| `Input.is_action_just_pressed("x")` | `true` solo nel frame in cui il tasto viene premuto |
| `Input.action_press("run")` | *Finge* che sia premuto: utile nei test, vedi [[Test automatico]] |

## Nel progetto

| Azione | Tasti |
|---|---|
| `move_left` / `move_right` / `move_up` / `move_down` | Frecce, WASD |
| `run` | Shift |

Le azioni `ui_left`, `ui_right`… esistono già, ma sono pensate per i menu.

## Vedi anche

- [[CharacterBody2D]] · [[Subaru]]
