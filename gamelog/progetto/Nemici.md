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

![[nemici_nuovi.png|500]]

Un nemico è fatto di due pezzi separati.

## 1. Chi è: `EnemyData`

Una [[Risorse personalizzate|risorsa personalizzata]] (`enemies/enemy_data.gd`), come `Item` per gli [[Oggetti]]. Ogni tipo di nemico è un file `.tres` in `enemies/`.

| Nemico | File | PS | Attacco | Difesa | Scudo | Debolezze | Esperienza | Lascia |
|---|---|---|---|---|---|---|---|---|
| Melma verde | `melma.tres` | 14 | 5 | 1 | 2 | pugno, calcio | 10 | — |
| Spettro | `spettro.tres` | 16 | 5 | 2 | 2 | calcio, ombra | 25 | Lacrima d'ombra ([[Atto 2]]) |
| Occhio errante | `occhio_errante.tres` | 12 | 5 | 1 | 2 | pugno, ghiaccio | 12 | — |
| Mano d'ombra | `mano_ombra.tres` | 18 | 6 | 2 | 2 | calcio, ghiaccio | 18 | — |
| Guardiano dei rovi | `guardiano_rovi.tres` | 28 | 7 | 3 | 3 | ghiaccio, ombra | 35 | — |

`shield` sono i punti scudo, `weaknesses` un `Array[String]` con i tipi di colpo che lo indeboliscono (`"pugno"`, `"calcio"`, `"ombra"`). Come funzionano: [[Combattimento#Scudi, debolezze e rottura]].

## Equilibrio

La melma è fatta per essere battuta al primo colpo d'occhio, e dà giusto l'esperienza per il livello 2. Lo Spettro all'inizio aveva 26 PS, attacco 8 e difesa 3: a livello 1 era **imbattibile** (6 danni a turno a Subaru, che gliene toglieva 2). Dal [[2026-11-18-atto-2|18 novembre]] ha 16 / 5 / 2: è più tosto della melma, ma si batte, meglio ancora con il calcio o lo Shamac (le sue debolezze) e le pozioni del baule di [[Lina]]. Un test (`enemy_data_test.gd`) controlla che a livello 1 Subaru vinca prima di cadere. I conti sono in [[Statistiche#La formula del danno]].

## L'aspetto

Dal [[2026-11-18-atto-2]] i nemici sono **disegnati apposta** (prima erano tile di [[Tiny Dungeon]] da 16 px): fogli da 5 pose di 32×32, alla stessa scala di pixel di [[Subaru]] ed [[Emilia]].

![[nemici_pose.png|600]]

![[atto3_grafica.png|600]]

I tre del bosco (dall'alto): Occhio errante (ali d'ombra, si sporge con l'iride rossa), Mano d'ombra (esce dal terreno, un occhio nel palmo), Guardiano dei rovi (una palla di spine piena d'occhi, apre le fauci).

| Posa (`EnemyData.Pose`) | Melma | Spettro |
|---|---|---|
| `IDLE`, `IDLE_2` | Respira: si schiaccia e torna | Fluttua, le code ondeggiano |
| `WINDUP` | Si acquatta, sopracciglia aggrottate | Alza la lanterna, che si accende |
| `ATTACK` | Si allunga in avanti a bocca aperta | Si sporge e urla, lanterna in avanti |
| `HURT` | Occhi a > <, bocca a onda | Occhi a X, si piega all'indietro |

`EnemyData` ha `frames` (quante celle ha il foglio), `animated()`, `cell_size()` e `portrait()` (solo la prima posa, per la barra dei turni). Come si usano in battaglia: [[Combattimento#Le pose del nemico]].

**Per aggiungerne uno:** nell'editor, *Nuova risorsa → EnemyData*, compila i numeri nell'Inspector e salva in `enemies/`. Nessuna riga di codice.

## 2. Dove sta: `characters/enemy/enemy.tscn`

```
Enemy (StaticBody2D)            + enemy.gd, proprietà "data" (un EnemyData)
├── Shadow (Sprite2D)
├── Sprite2D                    ← prende la texture da "data", respira (pose 0-1) e saltella con un Tween
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
	if data.drop != "":
		Inventory.add(data.drop)   # lo Spettro lascia la lacrima d'ombra
	...svanisce e si toglie
```

## Gironzolano

Ogni 2,5-5,5 secondi un nemico fa qualche passo in una direzione a caso, al massimo 48 pixel da dove è nato (`wander_radius`), lentamente (`wander_speed`). Prima di muoversi chiede a Godot `test_move(global_transform, spostamento)`: se sbatterebbe contro un albero, un rovo, un muro o Subaru, resta fermo ([[Collisioni#Provare prima di muoversi]]). Sta fermo anche durante dialoghi, cutscene e battaglie, e quando Subaru gli è abbastanza vicino da parlarci. Guarda dove va (`flip_h`).

## Non ricompare (a meno che…)

Vincendo si scrive in `Game.flags` il ricordo `"sconfitto:<percorso>"`, come per l'[[Oggetto da raccogliere]]. All'avvio, se il ricordo c'è, il nemico si toglie da solo: resta sconfitto cambiando scena e nei [[Salvataggio|salvataggi]].

Ma i ricordi tornano indietro con il [[Ritorno dalla Morte]]: se muori, i nemici battuti **dopo** il punto di ritorno sono di nuovo lì.

Nel villaggio: la Melma a est della piazza (928, 448), lo Spettro più a nord-est (1040, 352).

## Vedi anche

- [[Combattimento]] · [[Statistiche]] · [[Interactable]] · [[Mappa principale]]
