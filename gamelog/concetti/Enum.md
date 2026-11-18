---
tags:
  - concetto
aliases:
  - enum
  - Enumerazione
---

# Enum

← [[godot-basi|Basi di Godot]]

Un `enum` dà un **nome** a una lista di numeri interi. Invece di ricordarsi che la posa "attacco" è la numero 3, si scrive `Pose.ATTACK`.

## Come si usa

```gdscript
enum Pose { IDLE, IDLE_2, WINDUP, ATTACK, HURT }
# IDLE = 0, IDLE_2 = 1, WINDUP = 2, ATTACK = 3, HURT = 4

sprite.frame = Pose.ATTACK      # = 3
Pose.size()                      # 5: quanti nomi ci sono
```

- I numeri partono da 0 e salgono di uno, nell'ordine scritto. Si possono anche scegliere: `enum { A = 1, B = 10 }`.
- Un enum con un nome (`enum Pose {...}`) dentro una classe con `class_name` si usa da fuori come `EnemyData.Pose.HURT`.
- Con `@export var pose: Pose` nell'Inspector compare un menu a tendina con i nomi.

> [!tip] Perché non i numeri?
> `frame = 3` non dice niente a chi legge. `frame = EnemyData.Pose.ATTACK` sì. E se un giorno l'ordine delle pose nel foglio cambia, si cambia una riga sola.

Le [[Costanti]] fanno lo stesso per una cosa sola (`const KEY := "chiave"`); un enum per un gruppo di valori che vanno insieme.

## Nel progetto

- `EnemyData.Pose` (`enemies/enemy_data.gd`): le 5 pose del foglio dei [[Nemici]], usate dal [[Combattimento]] e dalla mappa.

## Vedi anche

- [[Costanti]] · [[GDScript]] · [[Spritesheet]] · [[2026-11-18-atto-2]]
