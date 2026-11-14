---
tags:
  - progetto
  - combattimento
  - personaggio
aliases:
  - EnemyData
  - enemy.tscn
  - Melma verde
  - Spettro
---

# Nemici

← [[Gamelog]]

![[nemici_sulla_mappa.png|500]]

Un nemico è fatto di due pezzi separati.

## 1. Chi è: `EnemyData`

Una [[Risorse personalizzate|risorsa personalizzata]] (`enemies/enemy_data.gd`), come `Item` per gli [[Oggetti]]. Ogni tipo di nemico è un file `.tres` in `enemies/`.

| Nemico | File | PS | Attacco | Difesa | Esperienza | Aspetto |
|---|---|---|---|---|---|---|
| Melma verde | `melma.tres` | 14 | 5 | 1 | 10 | Tile 108 di [[Tiny Dungeon]] |
| Spettro | `spettro.tres` | 26 | 8 | 3 | 25 | Tile 121 di [[Tiny Dungeon]] |

La melma è fatta per essere battuta al primo colpo d'occhio, e dà giusto l'esperienza per il livello 2. Lo spettro a livello 1 è quasi impossibile: serve il livello 2 e conviene avere le pozioni del baule di [[Lina]]. I conti sono in [[Statistiche#La formula del danno]].

**Per aggiungerne uno:** nell'editor, *Nuova risorsa → EnemyData*, compila i numeri nell'Inspector e salva in `enemies/`. Nessuna riga di codice.

## 2. Dove sta: `characters/enemy/enemy.tscn`

```
Enemy (StaticBody2D)            + enemy.gd, proprietà "data" (un EnemyData)
├── Shadow (Sprite2D)
├── Sprite2D                    ← prende la texture da "data", saltella con un Tween
├── CollisionShape2D            ← non gli si passa attraverso
└── Interactable                ← senza frasi: solo "avvicinati e premi E"
```

Premendo E parte il [[Combattimento]]:

```gdscript
func _fight() -> void:
	var result: String = await Battle.start(data)
	if result != Battle.WIN:
		return
	Game.set_flag(FlagKeys.defeated(self))
	...svanisce e si toglie
```

## Non ricompare (a meno che…)

Vincendo si scrive in `Game.flags` il ricordo `"sconfitto:<percorso>"`, come per l'[[Oggetto da raccogliere]]. All'avvio, se il ricordo c'è, il nemico si toglie da solo: resta sconfitto cambiando scena e nei [[Salvataggio|salvataggi]].

Ma i ricordi tornano indietro con il [[Ritorno dalla Morte]]: se muori, i nemici battuti **dopo** il punto di ritorno sono di nuovo lì.

Nel villaggio: la Melma a est della piazza (928, 448), lo Spettro più a nord-est (1040, 352).

## Vedi anche

- [[Combattimento]] · [[Statistiche]] · [[Interactable]] · [[Mappa principale]]
