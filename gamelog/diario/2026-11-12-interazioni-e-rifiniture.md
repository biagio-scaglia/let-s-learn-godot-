---
data: 2026-11-12
tags:
  - gamelog
  - ottimizzazione
  - interazione
  - audio
stato: funzionante
aliases:
  - Interazioni e rifiniture
---

# 2026-11-12 — Interazioni riutilizzabili e rifiniture

← [[Gamelog]] · Voce precedente: [[2026-11-12-primo-dialogo|Primo dialogo]]

## Obiettivo

"Migliora ancora e ottimizza": rendere il codice più riutilizzabile, il gioco più nitido e il mondo un po' più vivo, senza aggiungere sistemi grandi.

![[cartello.png]]

## Ottimizzazioni

| Cosa | Perché |
|---|---|
| **Scala intera** (`stretch/scale_mode = integer`) | Se la finestra viene ridimensionata, il gioco si ingrandisce solo ×2, ×3…: i pixel restano quadrati e nitidi. Vedi [[Viewport e stretch]] |
| **Aggancio al pixel** (`snap_2d_transforms_to_pixel`) | Le posizioni vengono arrotondate al pixel: niente tremolii quando la camera si muove piano |
| **Rimossa la spritesheet HD** | 780 KB inutilizzati, che Godot importava comunque |
| **Componente [[Interactable]]** | La logica "avvicinati e premi E" era dentro il Saggio. Ora è un pezzo unico, riusato da Saggio e cartello. Vedi [[Composizione]] |

## Miglioramenti

- **Il [[Cartello]] si legge:** un [[Interactable]] sopra il tile del cartello.
- **Il [[Saggio]] si ricorda di te:** dalla seconda volta dice frasi diverse (`repeat_lines`).
- **Passi:** un suono a ogni passo di [[Subaru]], sincronizzato con i frame dell'animazione in cui il piede tocca terra (0 e 2). Correndo l'animazione è più veloce, quindi i passi sono più fitti da soli. Il suono è generato dal [[Generatore degli effetti]]. Vedi [[Audio]].
- **[[Dissolvenza]] dal nero all'avvio:** un nuovo autoload `Fade`, già pronto per il cambio di scena.

## Cose imparate

- **[[Segnali]] dell'AnimatedSprite2D:** `frame_changed` avvisa a ogni cambio di frame, utile per sincronizzare suoni ed effetti con l'animazione.
- **`class_name`** rende uno script un tipo usabile ovunque. Con una trappola negli script di test: vedi [[Classi globali]].
- **`await`** aspetta la fine di qualcosa (un tween, un timer) prima di continuare: lo usa la [[Dissolvenza]].

## Problemi incontrati

- **Test che non compilava:** il test dichiarava una variabile di tipo `Interactable`, ma negli script `-s` l'autoload `Dialogue` non esiste ancora quando si compila. Risolto usando il tipo `Area2D` nel test. Spiegato in [[Classi globali]].
- **Uno screenshot "sbagliato":** una volta la finestra di dialogo è uscita quasi trasparente nello screenshot, anche se il gioco era nello stato giusto (abbiamo stampato i valori per verificarlo). Ripetendo il test lo screenshot era corretto: era il momento della cattura, non un difetto del gioco.

## Verifica

- [[Test del dialogo]]: **17 controlli**, tutti ok (aggiunti cartello, seconda conversazione e passi).
- [[Test automatico]] della corsa: ok.
- Avvio normale del gioco per 180 frame: nessun errore.

Passo successivo: [[2026-11-12-casa-di-lina]].

## Collegamenti

- **Progetto:** [[Interactable]] · [[Cartello]] · [[Saggio]] · [[Subaru]] · [[Dissolvenza]] · [[Effetti visivi]] · [[Mappa principale]]
- **Strumenti:** [[Generatore degli effetti]] · [[Generatore della mappa]] · [[Test del dialogo]]
- **Concetti:** [[Composizione]] · [[Classi globali]] · [[Viewport e stretch]] · [[Audio]] · [[Segnali]] · [[Autoload]] · [[Area2D]] · [[Tween]]
