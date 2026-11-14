---
data: 2026-11-14
tags:
  - gamelog
  - codice
  - ui
  - storia
stato: funzionante
aliases:
  - Ottimizzazioni e obiettivo
---

# 2026-11-14 — Più veloce, un obiettivo, e un mondo che nota

← [[Gamelog]] · Voce precedente: [[2026-11-14-ritorno-dalla-morte|Il Ritorno dalla Morte]]

## Obiettivo

Carta bianca: *ottimizza, migliora e implementa*. Tre cose scelte perché danno molto senza stravolgere il progetto.

![[obiettivo.png]]

## Come provarlo

1. *Nuova partita*: dopo l'intro, in alto a sinistra compare **Obiettivo: Esplora il villaggio**.
2. Leggi il cartello: sotto c'è una riga nuova.
3. Parla con Lina, trova la chiave, torna da lei: l'obiettivo cambia a ogni passo, e sparisce a baule aperto.
4. Muori (esci dal villaggio) e ritorna. Poi parla con il Saggio e con Emilia.

## Cosa è stato fatto

### 1. Ottimizzare

| Cosa | Prima | Dopo |
|---|---|---|
| Nebbia e buio della schermata di morte | Sempre disegnati, trasparenti: lo shader della nebbia girava a schermo intero a ogni frame | Nascosti (`visible = false`) finché non si muore |
| Confini del villaggio | Cercavano Subaru e reimpostavano audio e shader a ogni frame | Subaru cercato una volta; se niente cambia escono subito; spenti nello sfondo del titolo |

**Misurato**: nel villaggio, in gioco normale, da circa **245** a circa **330-370 FPS** (sincronia verticale spenta, medie su 5 secondi, più giri). La misura oscilla, ma la differenza è netta. Vedi [[Ottimizzazione]].

### 2. Migliorare: il mondo dimentica, Subaru no

- Dopo un [[Ritorno dalla Morte]], il [[Saggio]] ed [[Emilia]] **notano** che Subaru ha qualcosa che non va, e aggiungono due frasi in coda a quelle normali. Dalla terza morte il Saggio dice altro.
- Lo dicono una volta per "linea temporale": il ricordo torna indietro con il ritorno, quindi dopo ogni morte lo notano di nuovo, senza sapere di averlo già detto.
- Il [[Cartello]] ha una riga in più, incisa "con mano tremante": un avvertimento *prima* della prima morte.
- Per farlo, [[Interactable]] ha una novità: `extra_lines`, frasi **aggiunte** a quelle normali (prima si poteva solo sostituirle tutte con `override_lines`).

### 3. Implementare: l'obiettivo

Il riquadro in alto a sinistra: [[Obiettivo]].

## Decisioni e perché

- **L'obiettivo si ricava, non si ricorda.** Nessuna variabile da tenere aggiornata: si guarda lo stato del mondo. Dopo un ritorno dalla morte è giusto da solo.
- **Un segnale al posto di un controllo continuo.** `Game.state_changed` avvisa quando cambia un ricordo o una cutscene. Per questo i ricordi ora si scrivono solo con `set_flag()` e `load_flags()`, e `in_cutscene` ha un *setter* che avvisa.
- **Le reazioni alle morti stanno in uno script a parte** (`quests/death_memory.gd`), come la missione della chiave: ascolta i personaggi, non li modifica.

## Problemi incontrati

- **Un test ha "ucciso" `Game`.** In gdUnit, `monitor_signals(oggetto)` **libera l'oggetto** a fine test. Usato su un autoload, lo ha distrutto, e i test successivi fallivano con *"previously freed"*. Si corregge con `monitor_signals(Game, false)`. Annotato in [[Test con gdUnit4]].
- **Uno script di prova non trovava `Game`** dentro `Objective`: lanciato con `-s`, veniva compilato prima che gli autoload esistessero. Nel gioco e in gdUnit non succede.

## Verifica

- **Test visivo temporaneo, 17 controlli, tutti ok:** niente obiettivo nel titolo e nell'intro; i quattro testi nell'ordine giusto; il cartello avverte; il Saggio non nota niente prima della morte; da morto l'obiettivo sparisce; dopo il ritorno torna quello del punto di ritorno; Saggio ed Emilia lo notano una volta sola, in coda alle frasi normali; a baule aperto nessun obiettivo.
- **gdUnit: 44 test su 44** (12 nuovi: `objective_test`, `death_memory_test`).
- Passano ancora i test completi precedenti (30, 18 e 14 controlli). Il salvataggio vero non è stato toccato.

## Concetti nuovi

- [[Ottimizzazione]]: misurare, invisibile non è trasparente, non rifare a ogni frame
