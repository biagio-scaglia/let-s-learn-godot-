---
tags:
  - concetto
  - nodo
  - ui
aliases:
  - Barra della salute
---

# ProgressBar

← [[godot-basi|Basi di Godot]]

Un [[Nodo]] dell'[[Interfaccia (Control)|interfaccia]] che disegna una barra piena in proporzione a un valore. Perfetto per la salute.

## Come si usa

| Proprietà | Cosa fa |
|---|---|
| `min_value`, `max_value` | Gli estremi (di solito 0 e la salute massima) |
| `value` | Quanto è piena adesso |
| `show_percentage` | Se scrivere "75%" sopra la barra. Noi lo spegniamo: il numero lo scrive una `Label` accanto |

```gdscript
hp_bar.max_value = Stats.max_hp
hp_bar.value = Stats.hp
```

Non serve calcolare percentuali: con `max_value = 20` e `value = 15` la barra è piena per tre quarti.

## L'aspetto

Una ProgressBar è fatta di due [[StyleBox]]: `background` (il fondo) e `fill` (la parte piena). Nel progetto sono due `StyleBoxFlat` messi come *override* sul nodo: fondo scuro, riempimento verde per Subaru e rosso per il nemico.

## Farla scendere piano

Cambiare `value` di colpo fa "saltare" la barra. Con un [[Tween]] scivola:

```gdscript
create_tween().tween_property(enemy_bar, "value", enemy_hp, 0.3)
```

## Nel progetto

- Le due barre del [[Combattimento]].
- La barra nella [[Scheda del personaggio]].

## Vedi anche

- [[Interfaccia (Control)]] · [[StyleBox]] · [[Tween]] · [[Statistiche]]
