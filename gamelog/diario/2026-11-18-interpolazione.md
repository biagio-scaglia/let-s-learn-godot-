---
data: 2026-11-18
tags:
  - gamelog
  - grafica
stato: funzionante
aliases:
  - Lo scatto della camera
---

# 2026-11-18 — Lo scatto della camera e l'interpolazione della fisica

← [[Gamelog]] · Voce precedente: [[2026-11-18-occhi-e-gelo|Gli occhi di pietra ed Emilia nel party]]

## Obiettivo

Un giocatore ha segnalato: *Subaru si muove in `_physics_process` a 60 Hz, mentre la camera con lo smoothing si aggiorna a ogni immagine: su schermi a 120/144 Hz scatta, e l'aggancio ai pixel lo rende più visibile. Attivare l'interpolazione della fisica sistema tutte e tre le camere.* Aveva ragione.

## Cosa è stato fatto

| Pezzo | Nota |
|---|---|
| `project.godot`: `physics/common/physics_interpolation=true` | [[Interpolazione della fisica]] |
| Le Camera2D di villaggio, casa, biblioteca, castello, bosco e titolo: `process_callback = Physics` | [[Camera2D]] |
| I Tween che muovono cose nel mondo: `set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)` | [[Tween]] |
| `reset_physics_interpolation()` dopo ogni teletrasporto | [[Interpolazione della fisica#Come si usa]] |
| Interfaccia esclusa: `Game.SCREEN_AUTOLOADS`, cutscene, titolo | [[Interpolazione della fisica#Come si usa]] |
| Un test (raccogliere la chiave) reso stabile: frame contati invece di millisecondi | [[Test con gdUnit4]] |

## Come l'abbiamo verificato

Prima di cambiare, una misura: uno script fa camminare Subaru e, immagine per immagine, guarda di quanto scorre lo sfondo, con la fisica abbassata a 10 passi al secondo (come consiglia la documentazione, per rendere visibile il problema).

- **Senza interpolazione** lo sfondo scorreva a strappi: 6, 12, 6, 9, 6, 12 pixel.
- **Con l'interpolazione** scorre regolare: l'alternanza 6/9 è solo l'arrotondamento ai pixel ingranditi ×3.
- Godot stesso, con l'interpolazione accesa e la camera ancora "a ogni immagine", avvisa: *Camera2D overridden to physics process mode*. Ora le camere sono già impostate così, e l'avviso non c'è più.

Uno schermo a 144 Hz da qui non si può provare: la prova vera è giocarlo su uno schermo veloce.

## Problemi incontrati

- **Un test cadeva sempre, anche sul codice di prima.** Per capirlo: messo da parte il lavoro (`git stash`), rilanciato sul codice già salvato, fallisce lo stesso: non era colpa dell'interpolazione. Una stampa di prova ha mostrato che la chiave non "vedeva" Subaru: il test aspettava 150 millisecondi di orologio, e se in quel momento la fisica non gira abbastanza l'area non se ne accorge. Ora aspetta 10 frame simulati, e il tasto E lo consegna direttamente all'oggetto.
- **Un BOM in `project.godot`.** Un comando PowerShell di prova ha salvato il file con un carattere invisibile all'inizio. Tolto subito.
- **Resta un test instabile**, che ogni tanto fallisce e al giro dopo passa; non si è ripresentato in quattro giri di fila. Da indagare.

## Concetti nuovi

- [[Interpolazione della fisica]]
