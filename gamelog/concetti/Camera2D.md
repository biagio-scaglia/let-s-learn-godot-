---
tags:
  - concetto
  - nodo
aliases:
  - Camera
---

# Camera2D

← [[godot-basi|Basi di Godot]]

Un [[Nodo]] che decide **quale parte del mondo si vede**. Se è figlia di un personaggio, lo segue.

| Proprietà | Cosa fa |
|---|---|
| `limit_left/top/right/bottom` | La camera non mostra oltre questi bordi |
| `position_smoothing_enabled` | La camera arriva con un leggero ritardo, il movimento è più morbido |
| `zoom` | Ingrandisce o rimpicciolisce la vista |

## Nel progetto

Nella [[Mappa principale]] la camera è figlia dell'[[Istanza]] di [[Subaru]], con i limiti sui bordi della mappa (1280×768 px).

Effetto collaterale imparato: con lo smoothing, se Subaru viene "teletrasportato", la camera ci mette un attimo a raggiungerlo.

## Vedi anche

- [[Viewport e stretch]]
