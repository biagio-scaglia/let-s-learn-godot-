---
tags:
  - concetto
  - codice
aliases:
  - const
  - Stringhe magiche
  - Facing
  - FlagKeys
---

# Costanti

← [[godot-basi|Basi di Godot]]

Una **costante** (`const`) è un valore con un nome che non cambia mai. Serve soprattutto a evitare le **stringhe magiche**: testi scritti a mano in tanti punti del codice.

## Il problema

```gdscript
Game.flags["baule_aperto"] = true          # in key_quest.gd
if Game.flags.get("baule_aprto", false):   # da un'altra parte, con un errore di battitura
```

Godot non si lamenta: `"baule_aprto"` è una stringa valida. Semplicemente il baule risulta sempre chiuso, e scoprire perché fa perdere tempo.

## La soluzione

```gdscript
class_name FlagKeys
const CHEST_OPEN := "baule_aperto"
```

```gdscript
Game.set_flag(FlagKeys.CHEST_OPEN)
if Game.has_flag(FlagKeys.CHES_OPEN):   # errore! Godot lo segna subito in rosso
```

Il valore resta la stessa stringa (quindi i **vecchi salvataggi funzionano ancora**), ma nel codice si usa il nome. Un errore di battitura diventa un errore che l'editor mostra prima ancora di avviare il gioco.

## Classi di sole costanti

Con [[Classi globali|`class_name`]] uno script diventa un tipo raggiungibile da ovunque, anche senza essere un [[Autoload]] o un [[Nodo]]. Può contenere solo costanti e funzioni `static`:

```gdscript
class_name Facing
const DOWN := "down"
const UP := "up"
...
static func from_vector(dir: Vector2) -> String:   # si chiama senza creare niente
	...
```

`Facing.from_vector(v)` sostituisce due funzioni quasi uguali che stavano in [[Subaru]] e nell'NPC: un solo posto da correggere.

> [!tip] E gli `enum`?
> `enum Facing { DOWN, UP, LEFT, RIGHT }` sarebbe ancora più rigido, ma i valori sono numeri: nei salvataggi e nelle [[Porta|porte]] (dove si sceglie la direzione nell'Inspector) le stringhe sono più leggibili e già usate. Per questo qui abbiamo scelto costanti stringa.

## Nel progetto

| Classe o autoload | Costanti |
|---|---|
| `Facing` (`core/facing.gd`) | `DOWN`, `UP`, `LEFT`, `RIGHT` + `from_vector()` |
| `FlagKeys` (`core/flag_keys.gd`) | `INTRO_SEEN`, `CHEST_OPEN` + `talked(nodo)`, `picked(nodo)` |
| [[Inventory]] | `KEY`, `POTION`, `COIN` |
| [[Sfx]] | `MOVE`, `CONFIRM`, `BACK`, `PICKUP`, `CHEST_OPEN`, `SAVE`, `DOOR` |

## Vedi anche

- [[GDScript]] · [[Classi globali]] · [[Dizionari]] · [[Responsabilità]]
