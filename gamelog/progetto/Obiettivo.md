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
| Appena arrivato | Esplora il villaggio |
| Lina ti ha chiesto la chiave | Trova la chiave di Lina, a ovest della piazza |
| Hai la chiave | Porta la chiave a Lina |
| L'hai mostrata a Lina | Apri il baule di Lina |
| Baule aperto | *(il riquadro sparisce)* |

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
