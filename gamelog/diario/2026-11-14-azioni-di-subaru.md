---
data: 2026-11-14
tags:
  - gamelog
  - personaggio
  - animazione
stato: funzionante
aliases:
  - Azioni di Subaru
---

# 2026-11-14 — Subaru cade, si rialza ed esulta

← [[Gamelog]] · Voce precedente: [[2026-11-14-ottimizzazioni-e-obiettivo|Più veloce, un obiettivo, e un mondo che nota]]

## Obiettivo

Una seconda spritesheet di [[Subaru]], con 16 pose "d'azione": usarla dove serve davvero, e togliere dal progetto gli asset che non servono più.

![[subaru_azioni_3x.png]]

## Come provarlo

1. Raccogli la chiave vicino alla staccionata: Subaru **esulta** (due pugni al cielo, poi il segno di vittoria).
2. Cammina fino a un bordo della mappa: Subaru **barcolla e cade a terra** (prima ruotava soltanto, come un cartonato).
3. Scegli *Ritorna*: quando il nero si toglie Subaru è **steso a terra**, poi si mette in ginocchio, si rialza e solo allora parla.
4. Muori guardando a sinistra: la caduta è specchiata.

## Cosa è stato fatto

| Pezzo | Nota |
|---|---|
| `subaru_actions.png`: 4×4 celle da 64×48, stessa palette della v2 | [[Subaru#Le azioni]], [[Spritesheet]] |
| 4 animazioni nuove in `subaru_frames.tres`: `cheer`, `collapse`, `lying`, `wake_up` | [[SpriteFrames]] |
| `collapse()` ora è un'animazione vera; nuove `cheer()`, `lie_down()`, `wake_up()` | [[Subaru]] |
| Chi raccoglie un oggetto esulta | [[Oggetto da raccogliere]] |
| Dopo il Ritorno ci si risveglia stesi a terra | [[Ritorno dalla Morte]] |
| 8 test nuovi (`test/characters/subaru_actions_test.gd` e uno in `return_by_death_test`) | [[Test con gdUnit4]] |
| Via `subaru_charset.png`; l'immagine originale va in `sorgenti/` | più sotto |

## Decisioni e perché

- **Quali pose usare.** Delle 16 ne servono 9. La riga 4 (sviene, occhi chiusi, steso) sembrava fatta apposta per il [[Ritorno dalla Morte]]; la riga 1 per festeggiare un oggetto trovato. I **pugni** (riga 2), il **volo all'indietro** e la **camminata triste** restano nel file ma senza animazione: nel gioco non c'è ancora niente da prendere a pugni. Quando arriverà un nemico sono già pronti.
- **Un secondo file, non la stessa spritesheet.** Le pose d'azione sono più larghe (da steso Subaru è lungo 55 px): celle da 64×48 invece di 32×48. Mischiare due misure di cella nello stesso file complica i ritagli; due file, ognuno con la sua griglia, no. Lo [[SpriteFrames]] resta **uno solo**: una risorsa può pescare da più immagini.
- **Ogni posa centrata e con i piedi sul fondo della cella.** Così l'`offset` dell'[[AnimatedSprite2D]] (24 px in su) va bene per tutte, e Subaru non "salta" quando cambia animazione.
- **A sinistra si specchia** (`flip_h`): le azioni sono disegnate solo verso destra. Camminata e idle rimettono `flip_h = false`, perché loro hanno i frame veri per ogni direzione.
- **Un numero per ogni azione** (`_action_id`). Se Subaru muore mentre esulta, l'esultanza "finisce" comunque (il suo `await` si sveglia) e lo rimetterebbe in piedi da morto. Ogni azione prende un numero; chi si sveglia controlla se il numero è ancora il suo, e altrimenti non tocca niente.
- **Steso prima che il nero si tolga.** `ReturnByDeath` si collega (una volta sola) a `scene_changed`: appena la scena è ricaricata, e lo schermo è ancora nero, chiama `lie_down()`. Farlo dopo la dissolvenza avrebbe mostrato Subaru in piedi per un attimo.

## Asset tolti

| File | Perché |
|---|---|
| `characters/subaru/subaru_charset.png` (+ `.import`) | Non lo usava nessuna scena: era solo il passaggio intermedio da cui era nata `subaru_sheet.png`. Resta nella cronologia di git |
| `gamelog/assets/subaru-spritesheet 2.jpg` | Non cancellata: **spostata** in `sorgenti/subaru_spritesheet_azioni.jpg`, accanto all'originale della v2. Nel vault c'è l'anteprima pulita qui sopra |

Ho controllato tutti gli altri: ogni file in `let's-learn-godot/assets/` e `characters/` è usato da una scena, uno script o una risorsa, e ogni immagine di `gamelog/assets/` è mostrata in almeno una nota. Non c'era altro da togliere.

## Problemi incontrati

- **Le pose non stanno in una griglia regolare.** Nell'immagine originale i due Subaru stesi sono sfalsati e più larghi di una cella. Invece di tagliare a griglia ho trovato ogni figura come "macchia" di pixel collegati, e l'ho rimessa al centro della sua cella nuova. Le scintille dei colpi sono macchie separate: le ho unite a mano alla figura giusta.
- **Stessi colori della v2.** La conversione sceglie una palette sua, leggermente diversa: ogni pixel è stato poi portato al colore più vicino tra quelli di `subaru_sheet.png` (differenza media 4,5 su 255, non si vede). Così passando da un'animazione all'altra la felpa non cambia tono.

## Verifica

- **gdUnit: 52 test su 52**, compresi gli 8 nuovi: le animazioni esistono e non vanno in loop; esulta e poi torna fermo; raccogliere la chiave lo fa esultare; crolla e resta a terra; a sinistra si specchia; una caduta interrompe l'esultanza; da steso si rialza; morendo sul bordo parte la caduta.
- Le pose sono state controllate guardando l'immagine impacchettata. **Non ho guardato il gioco in movimento:** tempi e posizione a terra vanno provati giocando (vedi "Come provarlo").

## Concetti nuovi

- Animazioni che non si ripetono e `animation_finished`, frame con durate diverse, più immagini nella stessa risorsa: aggiunti a [[SpriteFrames]]
