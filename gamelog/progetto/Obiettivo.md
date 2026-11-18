---
tags:
  - progetto
  - ui
  - missione
aliases:
  - Objective
  - objective.gd
  - Indicatore dell'obiettivo
---

# Obiettivo

← [[Gamelog]]

Il riquadro in alto a sinistra che dice **cosa fare adesso**. Prima, dopo aver parlato con Lina, bisognava ricordarsi da soli dov'era la chiave.

![[obiettivo.png|500]]

## I testi

| Situazione | Obiettivo |
|---|---|
Dal [[2026-11-18-atto-2]] segue tutto l'[[Atto 2]]:

| Situazione | Obiettivo |
|---|---|
| Appena arrivato | Chiedi al Saggio delle voci strane |
| Il Saggio non ricorda | Vai da Lina, nella casa col tetto rosso |
| Lina ti ha chiesto la chiave | Trova la chiave di Lina, a ovest della piazza |
| Hai la chiave | Porta la chiave a Lina |
| L'hai mostrata a Lina | Apri il baule di Lina |
| Hai la pagina strappata | Porta la pagina strappata all'Archivista |
| L'Archivista l'ha letta | Sconfiggi lo Spettro, a est della piazza |
| Hai anche la lacrima | Leggi il libro nero, in biblioteca |
| Hai letto il libro | Racconta tutto a Emilia, in piazza |
| Fine dell'atto 2 | All'alba, il bosco a nord (atto 3 in arrivo) |
| *Vecchio salvataggio: baule aperto, niente pagina* | Guarda meglio nel baule di Lina |

`current()` controlla **dalla fine**: il primo passo già fatto decide cosa viene dopo.

## Com'è fatto

Due pezzi separati ([[Responsabilità]]):

- **`quests/objective.gd`** (`class_name Objective`): una sola funzione `static`, `current()`, che **ricava** il testo dai ricordi di [[Game]] e dallo zaino ([[Inventory]]). Non ricorda niente di suo.
- **L'`Hud`** ([[Avvisi]]): lo mostra, con un'entrata da sinistra e un lampo dorato quando cambia.

> [!tip] Ricavare invece di ricordare
> Non esiste una variabile "obiettivo attuale" da tenere aggiornata. Ogni volta si guarda lo stato del mondo e si decide. Per questo dopo un [[Ritorno dalla Morte]] o un *Continua* l'obiettivo è già quello giusto, senza una riga di codice in più: i ricordi sono tornati indietro, e la risposta con loro.

## Quando si aggiorna

Niente controlli a ogni frame ([[Ottimizzazione]]): l'Hud ascolta tre [[Segnali]].

| Segnale | Quando arriva |
|---|---|
| `Game.state_changed` | Un ricordo cambia, una cutscene comincia o finisce, partita nuova o ripresa |
| `Inventory.changed` | Raccogli o usi un oggetto |
| `get_tree().scene_changed` | Cambia la scena |

È nascosto nel titolo, durante le [[Cutscene]] e da morto.

Per sapere a che punto è la missione servono due ricordi nuovi, scritti dalla [[Missione della chiave]]: `KEY_QUEST_STARTED` e `KEY_SHOWN` (in `FlagKeys`, vedi [[Costanti]]).

## Vedi anche

- [[Missione della chiave]] · [[Avvisi]] · [[Game]] · [[2026-11-14-ottimizzazioni-e-obiettivo]]
