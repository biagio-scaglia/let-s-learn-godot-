---
tags:
  - concetto
  - codice
  - animazione
aliases:
  - Tween
  - create_tween
---

# Tween

← [[godot-basi|Basi di Godot]]

Un **Tween** cambia una proprietà poco alla volta, da un valore a un altro, in un certo tempo. È il modo più veloce per animare qualcosa dal codice, senza preparare un'animazione.

```gdscript
var t := create_tween()
t.tween_property(prompt, "position:y", -63.0, 0.45).set_trans(Tween.TRANS_SINE)
t.tween_property(prompt, "position:y", -60.0, 0.45)
t.set_loops()   # ripete all'infinito
```

| Funzione | Cosa fa |
|---|---|
| `tween_property(nodo, "proprietà", valore, secondi)` | Anima una proprietà |
| `tween_method(funzione, da, a, secondi)` | Chiama una funzione con un valore che cresce |
| `set_parallel()` | Le animazioni partono insieme invece che una dopo l'altra |
| `set_loops()` | Ripete |
| `set_trans()` / `set_ease()` | La "curva": lineare, morbida (`SINE`), con rimbalzo… |
| `kill()` | Ferma il tween |

## Nel progetto

| Effetto | Dove |
|---|---|
| Il [[Saggio]] "respira" (si schiaccia e torna) | `npc.gd` |
| La nuvoletta sopra la testa sale e scende | [[Interactable]] |
| Lo schermo compare dal nero | [[Dissolvenza]] |
| La finestra entra ed esce sfumando | [[Finestra di dialogo]] |
| Il testo compare lettera per lettera (`tween_method`) | [[Finestra di dialogo]] |
| La freccia "continua" saltella | [[Finestra di dialogo]] |

Tutti fanno parte degli [[Effetti visivi]].

## Vedi anche

- [[Segnali]] (un tween manda `finished` quando ha finito) · [[AnimatedSprite2D]]
