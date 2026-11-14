---
tags:
  - progetto
  - combattimento
  - codice
aliases:
  - Stats
  - stats.gd
  - Punti salute
  - Esperienza
---

# Statistiche

← [[Gamelog]]

I numeri di [[Subaru]]: `core/stats.gd`, un [[Autoload]] chiamato `Stats`.

| Statistica | Livello 1 | A ogni livello | A cosa serve |
|---|---|---|---|
| Salute massima (`max_hp`) | 20 | +5 | Quanti colpi regge |
| Salute (`hp`, i "PS") | 20 | torna al massimo | A zero si muore |
| Attacco (`attack`) | 5 | +1 | Quanto fa male un suo pugno |
| Difesa (`defense`) | 2 | +1 | Quanto toglie ai colpi che riceve |
| Esperienza (`xp`) | 0 | riparte | Si guadagna vincendo |

## La formula del danno

```gdscript
static func damage(attacker_attack: int, target_defense: int, roll := 0) -> int:
	return maxi(1, attacker_attack - target_defense + roll)
```

- **Attacco meno difesa:** per questo salire di livello conta due volte, fai più male e ne ricevi meno.
- **Il tiro** (`roll`, da −1 a +1) lo mette il [[Combattimento]]: un po' di fortuna, così due colpi non sono mai uguali.
- **Mai meno di 1:** un colpo andato a segno fa sempre qualcosa, anche contro una difesa altissima.
- È `static`: non usa nessuna variabile di `Stats`, solo i numeri che riceve. Vale per Subaru **e** per i nemici.

| Chi colpisce chi | Conto | Danno |
|---|---|---|
| Subaru Lv 1 → Melma | 5 − 1 ± 1 | 3–5 |
| Melma → Subaru Lv 1 | 5 − 2 ± 1 | 2–4 |
| Subaru Lv 1 → Spettro | 5 − 3 ± 1 | 1–3 |
| Spettro → Subaru Lv 1 | 8 − 2 ± 1 | 5–7 |
| Subaru Lv 2 → Spettro | 6 − 3 ± 1 | 2–4 |
| Spettro → Subaru Lv 2 | 8 − 3 ± 1 | 4–6 |

## Livelli

Per passare al livello successivo servono `livello × 10` punti: 10 per il 2, altri 20 per il 3, altri 30 per il 4. L'esperienza in più non si perde: passa al livello dopo. `gain_xp()` usa un `while`, così tanta esperienza in un colpo solo fa salire anche di due livelli.

## Chi ascolta

`Stats` manda il [[Segnali|segnale]] `changed` a ogni cambiamento (e `leveled_up` quando si sale). Lo ascoltano la [[Scheda del personaggio]], lo [[Zaino]] e il [[Combattimento]]. È lo stesso schema di [[Inventory]]: chi tiene i dati non sa chi li mostra.

## Dove finiscono

- Nel [[Salvataggio]], sotto `statistiche` (`to_dict()` e `reset()`). Un salvataggio vecchio, senza, riparte dal livello 1.
- Nel punto di ritorno del [[Ritorno dalla Morte]]: livello ed esperienza tornano com'erano, la salute al massimo.

## Vedi anche

- [[Combattimento]] · [[Nemici]] · [[Scheda del personaggio]] · [[Game]]
