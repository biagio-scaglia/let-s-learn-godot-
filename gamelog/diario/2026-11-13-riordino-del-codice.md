---
data: 2026-11-13
tags:
  - gamelog
  - codice
  - refactoring
stato: completato
aliases:
  - Riordino del codice
  - Refactoring
---

# 2026-11-13 — Riordino del codice

← [[Gamelog]] · Voce precedente: [[2026-11-13-sole-e-nuvole|Sole e nuvole]]

## Obiettivo

Una revisione del codice gli aveva dato **7/10**. Questa sessione sistema i punti deboli trovati, **senza cambiare niente di quello che vede il giocatore**.

| Problema | Soluzione |
|---|---|
| `Game` faceva tutto ("oggetto dio") | Diviso in 5 autoload: [[Game]], [[Inventory]], [[Salvataggio\|SaveSystem]], [[Opzioni\|Settings]], [[Sfx]] |
| Stringhe scritte a mano ovunque (`"baule_aperto"`, `"down"`, `"confirm"`) | [[Costanti]]: `FlagKeys`, `Facing`, `Inventory.KEY`, `Sfx.CONFIRM` |
| Gli autoload si chiamavano tutti fra loro | Lo zaino annuncia `item_added`, l'avviso ascolta ([[Segnali]]) |
| Regola "si può aprire un menu?" scritta due volte | Una sola: `Game.can_open_menu()` |
| Cambio di scena: "aspetta due frame e speriamo" | `await get_tree().scene_changed` |
| Il titolo cercava Subaru con il percorso `World/Subaru` | Lo cerca per [[Gruppi\|gruppo]] (`player`) |
| Due funzioni uguali per la direzione (Subaru e NPC) | Una: `Facing.from_vector()` |

## Cosa è stato fatto

- **Nuovi file in `core/`:** `inventory.gd`, `save_system.gd`, `settings.gd`, `sfx.gd` (autoload) e `facing.gd`, `flag_keys.gd` (classi di sole costanti).
- **`game.gd`** da 217 a 88 righe: ricordi, scene, "chi può fare cosa".
- **Errori chiari:** `Inventory.item()` e `Sfx.play()` con un nome sbagliato fermano il gioco dicendo quale nome, invece di fallire in silenzio.
- Aggiornati tutti gli script che usavano `Game`: menu, opzioni, zaino, avvisi, oggetti, missione, cutscene, personaggi.

## Decisioni e perché

- **Costanti stringa e non `enum`:** i valori finiscono nei salvataggi e nell'Inspector delle porte. Con le stringhe di prima, i **vecchi salvataggi si caricano ancora** (provato con quello vero di stamattina).
- **I nuovi autoload stanno in cima alla lista** in `project.godot`: gli autoload partono in ordine, e l'avviso (`Hud`) si collega a `Inventory` già nel suo `_ready()`. Vedi [[Autoload]].
- **Niente test nel repository:** come deciso in [[Strumenti archiviati]], il test resta fuori.
- **La cutscene resta scritta in codice:** con una sola scena un sistema più grande sarebbe esagerato. Se ne arriveranno altre, si valuterà l'AnimationPlayer ([[Cutscene]]).

## Problemi incontrati

Nessuno di grave: tutte le sostituzioni sono state controllate cercando nel codice i vecchi nomi (`Game.ui_sound`, `Game.add_item`, `_can_open`…), che non compaiono più.

## Verifica

Un test temporaneo (fuori dal repository) ha ripercorso **tutto il gioco** con **30 controlli**, tutti ok: titolo senza Subaru, opzioni salvate e volume applicato, cutscene, menu bloccati durante la cutscene, pausa e zaino che si escludono a vicenda, chiave raccolta con l'avviso, cambio di scena, Lina e il baule, 2 pozioni e 5 monete, salvataggio, *Continua* nella stessa posizione con zaino e ricordi, ritorno al titolo. Il test della cutscene (14 controlli) passa ancora. Salvataggio e opzioni dell'utente sono stati copiati prima e rimessi a posto dopo.

## Concetti nuovi

- [[Responsabilità]]: un compito per script, e chi conosce chi
- [[Costanti]]: niente stringhe magiche
