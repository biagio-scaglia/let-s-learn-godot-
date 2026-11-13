---
data: 2026-11-13
tags:
  - gamelog
  - codice
  - test
stato: funzionante
aliases:
  - Test con gdUnit
---

# 2026-11-13 — I test entrano nel progetto, con gdUnit4

← [[Gamelog]] · Voce precedente: [[2026-11-13-riordino-del-codice|Riordino del codice]]

## Obiettivo

Fino a oggi i test erano script temporanei, tenuti **fuori** dal repository ([[Strumenti archiviati]]). La revisione del codice lo aveva segnato come punto debole: ogni modifica andava riverificata da capo. Ora i test stanno **nel progetto**, scritti con **gdUnit4**, e si rilanciano con un comando.

## Come provarlo

- Nell'editor: pannello **GdUnit** → ▶.
- Da terminale, nella cartella `let's-learn-godot`:

```
test.cmd --godot_binary C:\Users\…\Godot_v4.7.2-stable_win64.exe
```

Risultato atteso: **27 test, 0 errori, 0 fallimenti**, in circa 15 secondi.

## Cosa è stato fatto

| Pezzo | Note |
|---|---|
| Plugin gdUnit4 6.2.3 in `addons/gdUnit4/` | Attivato in `project.godot`. La 6.2.3 corregge un errore proprio con Godot 4.7 |
| 7 suite, 27 test in `test/` | `test/core/` (unitari) e `test/world/` (di scena) |
| `test.cmd` | Lancia tutti i test |
| `reports/` nel `.gitignore` | I report si ricreano a ogni esecuzione |
| `SaveSystem.path` e `Settings.path` diventano variabili | Così i test usano file propri |

| Suite | Cosa controlla |
|---|---|
| `facing_test` | Le direzioni, e che i valori restino quelli dei salvataggi |
| `inventory_test` | Aggiungere, togliere, segnali, copia dei dati, ogni oggetto completo |
| `game_test` | Ricordi, chiavi dei ricordi, chi può muoversi, menu fuori dai livelli |
| `save_system_test` | Nessun file, nessun giocatore, un **vecchio salvataggio** si legge ancora |
| `settings_test` | Volume applicato e salvato, sempre tra 0 e 1 |
| `intro_test` | La cutscene parte alla prima partita, non riparte, non parte arrivando da una porta |
| `key_quest_test` | La missione della chiave **premendo i tasti**: senza chiave il baule resta chiuso, con la chiave si apre e dà 2 pozioni e 5 monete, Lina si ricorda di te |

## Decisioni e perché

- **Cambia la regola "niente script di supporto nel repository"** ([[2026-11-12-pulizia]]): quella regola riguardava generatori e test usa e getta. I test di gdUnit fanno parte del progetto come il codice, e servono a ogni modifica.
- **Lo zaino si prova su un'istanza nuova, non sull'autoload:** così il test non fa comparire avvisi e non sporca la partita.
- **I test degli autoload rimettono tutto a posto** in `after_test()`: gli autoload sopravvivono tra un test e l'altro.

## Problemi incontrati

- **"Cannot get path of node as it is not in a scene tree":** un test chiedeva la chiave di un ricordo per un nodo mai aggiunto alla scena. Le chiavi usano il percorso del nodo: bisogna prima fare `add_child()`. Il test passava lo stesso, ma stampava un errore: corretto.
- **Gli errori sulla "remote port"** quando si lancia `test.cmd` sono **voluti**: lo script di gdUnit usa una porta finta per evitare che Godot si blocchi aspettando comandi.

## Verifica

- 27 test su 27 passano, sia da `test.cmd` sia lanciando gdUnit direttamente. Nessun errore stampato.
- **Prova del contrario:** ho rotto apposta lo zaino (ogni oggetto aggiunto contava doppio). **6 test sono falliti**, compreso quello della missione: i test se ne accorgono davvero. Poi il codice è stato rimesso com'era.
- Il salvataggio vero dell'utente non è stato toccato (stessa data di stamattina).

## Concetti nuovi

- [[Test con gdUnit4]]
