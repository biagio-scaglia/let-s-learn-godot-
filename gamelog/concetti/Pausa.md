---
tags:
  - concetto
aliases:
  - paused
  - process_mode
  - Mettere in pausa
---

# Pausa

← [[godot-basi|Basi di Godot]]

Per fermare il gioco basta una riga:

```gdscript
get_tree().paused = true
```

Da quel momento tutti i nodi smettono di "vivere": niente `_process`, niente fisica, niente animazioni, niente [[Tween]].

## Chi deve continuare a funzionare

Ogni nodo ha un **`process_mode`** che dice cosa fare durante la pausa:

| process_mode | Durante la pausa |
|---|---|
| `Inherit` (di default) | Fa come il genitore |
| `Pausable` | Si ferma |
| `When Paused` | Funziona **solo** in pausa |
| `Always` | Funziona sempre |

Nel progetto sono `Always`:

| Nodo | Perché |
|---|---|
| Il [[Menu di pausa]] | Deve rispondere ai tasti mentre il gioco è fermo |
| [[Game]] | Fa suonare i suoni dei menu |
| La [[Dissolvenza]] | "Torna al titolo" sfuma al nero mentre il gioco è in pausa: se la dissolvenza fosse ferma, resterebbe tutto bloccato |

I [[Tween]] creati da un nodo `Always` continuano anche loro, e `create_timer(tempo, true, false, true)` crea un timer che va avanti in pausa (l'ultimo `true`).

## Vedi anche

- [[Menu di pausa]] · [[Autoload]] · [[Ciclo di gioco]]
