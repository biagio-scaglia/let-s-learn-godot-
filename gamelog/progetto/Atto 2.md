---
tags:
  - progetto
  - storia
aliases:
  - Le voci di Erbalta
  - VoicesQuest
---

# Atto 2 — Le voci di Erbalta

← [[Gamelog]]

Il cuore del gioco: dopo l'arrivo a Erbalta ([[Intro]]), [[Subaru]] indaga sulle voci strane di cui parlava [[Emilia]] alla [[Rocca d'Argento]]. Diario: [[2026-11-18-atto-2]].

## La trama, passo per passo

| # | Dove | Cosa succede | Ricordo / oggetto | Obiettivo dopo |
|---|---|---|---|---|
| 1 | Piazza | Emilia ti manda dal Saggio | — | Chiedi al Saggio delle voci strane |
| 2 | Est della piazza | Il [[Saggio]] non ricorda da quanto tempo è lì; ti manda da Lina | `saggio_dimentica` | Vai da Lina |
| 3 | [[Casa di Lina]] | [[Lina]] ha perso la chiave del baule della nonna | `missione_chiave` | Trova la chiave |
| 4 | Staccionata a ovest | Trovi la chiave, la mostri a Lina | 🔑 | Apri il baule |
| 5 | Casa di Lina | Nel baule: pozioni, monete e una **pagina strappata** | 📄 `pagina` | Porta la pagina all'Archivista |
| 6 | [[Biblioteca]] | L'Archivista: la pagina viene dal libro nero, parla dello Spettro | `pagina_letta` | Sconfiggi lo Spettro |
| 7 | Nord-est della piazza | Lo Spettro, sconfitto, lascia una **lacrima d'ombra** | 💧 `lacrima` | Leggi il libro nero |
| 8 | Biblioteca | Il libro nero rivela la verità | `libro_letto` | Racconta tutto a Emilia |
| 9 | Piazza | Subaru ed Emilia decidono: domani all'alba, il bosco a nord | `atto2_finito` | All'alba, il bosco a nord |

I passi 3-5 sono la vecchia [[Missione della chiave]], che ora ha uno scopo.

## La verità (il libro nero)

> "Erbalta non invecchia. Erbalta ricomincia."
> "Ogni alba è la stessa alba. Chi vive qui la vive per sempre, e non se ne accorge."
> "Solo chi torna dalla morte ricorda."
> "Colui che guarda dorme nel bosco a nord, dove gli alberi non crescono. Finché i suoi occhi resteranno aperti, nessuno lascerà il villaggio."
> E con la calligrafia di Subaru: *"Questa volta, portala via di qui."*

Tutto quello che il gioco aveva seminato trova un posto: il cartello *"Non lasciate il villaggio"*, il bordo della mappa che uccide, il Saggio che guarda gli stessi alberi, le stelle ferme alla finestra della biblioteca, il registro dei prestiti di cent'anni fa, gli occhi che ti guardano nel titolo. E il [[Ritorno dalla Morte]]: Subaru ricorda perché è l'unico che torna.

## Come funziona

`quests/voices_quest.gd` (`class_name VoicesQuest`), come la [[Missione della chiave]], **ascolta** i personaggi (segnale `interacted` di [[Interactable]]) e sceglie le loro frasi con `override_lines`. Ce ne sono due istanze:

| Scena | Campi collegati |
|---|---|
| [[Mappa principale]] | `saggio`, `emilia` |
| [[Biblioteca]] | `archivista`, `black_book`, `book_glow` |

L'obiettivo in alto a sinistra lo calcola [[Obiettivo]] dagli stessi ricordi, senza sapere niente di `VoicesQuest`.

### La conversazione finale

Emilia dice la prima battuta con il dialogo normale; poi `_final_talk()` alterna le voci:

```gdscript
await _then("Subaru", ["Erbalta non invecchia, Emilia. Ricomincia.", ...])
await _then("Emilia", ["Un villaggio che ricomincia sempre lo stesso giorno...", ...])

func _then(speaker: String, lines: PackedStringArray) -> void:
	await Dialogue.finished          # aspetta che l'altro abbia finito
	Dialogue.start(speaker, lines)
```

Durante la conversazione `Game.in_cutscene` è vero: nessuno la interrompe. Alla fine si fissa il punto di ritorno (`Game.set_checkpoint()`).

### Il libro che si sveglia

Quando il libro parla, la luce viola sopra il leggio si gonfia e torna a tremolare. La luce ha `flicker.gd`, che a ogni frame riscrive `energy`: per questo il [[Tween]] anima `_base_energy`, il valore da cui parte il tremolio.

## Dopo l'atto 2

L'obiettivo resta *All'alba, il bosco a nord (atto 3 in arrivo)*. Ogni personaggio ha una frase per questo momento.

## Vedi anche

- [[Obiettivo]] · [[Missione della chiave]] · [[Nemici]] · [[Biblioteca]] · [[Emilia]] · [[2026-11-18-atto-2]]
