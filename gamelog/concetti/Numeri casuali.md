---
tags:
  - concetto
  - codice
aliases:
  - RandomNumberGenerator
  - Seme
  - randi_range
---

# Numeri casuali

← [[godot-basi|Basi di Godot]]

Un po' di fortuna: il danno che cambia a ogni colpo, la fuga che riesce una volta su due.

## Due modi

**Le funzioni globali**, comode per le cose che non contano:

```gdscript
steps.pitch_scale = randf_range(0.85, 1.15)   # ogni passo suona un po' diverso
```

**Un `RandomNumberGenerator` tutto tuo**, quando i tiri fanno parte delle regole:

```gdscript
var rng := RandomNumberGenerator.new()
rng.randomize()                 # parte da un punto a caso
rng.randi_range(-1, 1)          # un intero: -1, 0 oppure 1
rng.randf()                     # un decimale tra 0 e 1
```

| Funzione | Cosa dà |
|---|---|
| `randi_range(a, b)` | Un intero tra `a` e `b`, compresi |
| `randf_range(a, b)` | Un decimale tra `a` e `b` |
| `randf()` | Un decimale tra 0 e 1 |

## "Una volta su due"

```gdscript
if rng.randf() < flee_chance:   # flee_chance = 0.5
	# riuscito
```

`randf()` cade sotto 0,5 metà delle volte. Con 0,25 sarebbe una volta su quattro; con 1,0 sempre; con 0,0 mai.

## Il seme

I numeri "casuali" di un computer sono una lunga fila calcolata a partire da un numero, il **seme** (*seed*). Stesso seme, stessa fila.

- `rng.randomize()` sceglie un seme a caso: ogni partita è diversa.
- `rng.seed = 1234` lo fissa: i tiri sono sempre gli stessi.

Questo è il motivo per avere un generatore proprio: nei [[Test con gdUnit4|test]] un combattimento con tiri veri a volte passerebbe e a volte no. Fissando il seme il test è sempre uguale.

## Nel progetto

- `Battle.rng` nel [[Combattimento]]: il tiro del danno (`randi_range(-1, 1)`) e la fuga (`randf()`). I test fanno `Battle.rng.seed = 1234`, e per la fuga mettono `flee_chance` a 1 o a 0 per decidere loro come va.
- Le funzioni globali: il tono dei passi di [[Subaru]], del testo nella [[Finestra di dialogo]], la scossa della camera nel [[Ritorno dalla Morte]]. Lì un numero diverso non cambia niente.

## Vedi anche

- [[Statistiche]] · [[Rumore]] (casualità "morbida", per nuvole e nebbia)
