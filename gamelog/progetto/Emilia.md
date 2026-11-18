---
tags:
  - progetto
  - personaggio
aliases:
  - Emily
---

# Emilia

← [[Gamelog]]

Un personaggio con cui parlare, nella piazza della [[Mappa principale]], a sud-ovest del [[Saggio]].

![[emilia_charset_3x.png|200]]

## Com'è fatta

È un'[[Istanza]] della stessa scena del Saggio e di [[Lina]] (`npc.tscn`), ma invece di un tile di [[Tiny Dungeon]] usa un **[[Charset]]**: il file `characters/emilia/emilia_charset.png`.

| Cosa | Come |
|---|---|
| Si gira verso [[Subaru]] in 4 direzioni | Sceglie la riga del charset in base a dove si trova Subaru |
| Respira | [[Tween]], come gli altri PNG |
| Parla | [[Interactable]] e [[Finestra di dialogo]] |
| Stessa scala di pixel di Subaru | Sprite a ×1, niente ingrandimenti; da [[2026-11-12-subaru-v2\|Subaru v2]] anche la stessa grandezza |

## Camminare nelle cutscene

Da [[2026-11-18-castello]] anche i PNG con un charset sanno camminare: `walk_to(punto, velocità)` e `face(direzione)`, gli stessi nomi di [[Subaru]]. La camminata è un [[Tween]] sulla posizione più un Tween in loop che passa le 4 colonne della riga del charset (un passo ogni 0,15 s). Mentre una [[Cutscene]] è in corso Emilia non si gira più da sola verso Subaru.

Nella storia parte con Subaru dalla [[Rocca d'Argento]], arriva con lui a Erbalta e **si apposta in piazza** (vedi [[Intro]]).

## Ti segue

Nel [[Bosco Senza Tempo]] Emilia cammina dietro a [[Subaru]]. Lo fa un nodo figlio, `Follower` (`characters/npc/follower.gd`):

1. Subaru lascia una **scia di briciole**: la sua posizione, ogni 3 pixel di cammino (al massimo 80, le vecchie si buttano).
2. A ogni frame si cerca il punto della scia che sta **34 pixel dietro** a lui, misurati lungo la scia.
3. Emilia ci va con `move_toward`, più veloce se è lontana, e `npc.step(direzione)` fa avanzare i passi del charset. Arrivata, `stand()`.

Mentre segue ha `collision_layer = 0`: non fa da muro. Durante una cutscene si ferma, e quando riparte la scia ricomincia da capo (altrimenti correrebbe verso punti vecchi). Arrivando nel bosco da un salvataggio o dopo una morte, si mette subito dietro di lui.

## Il punto di riferimento

Nell'[[Atto 2]] Emilia resta in piazza e, a ogni passo, ti dice dove andare (le sue frasi le sceglie `VoicesQuest`). Alla fine Subaru le racconta quello che ha letto nel libro nero, in una conversazione a due voci, e decidono di partire all'alba per il bosco a nord. Quando le riparli, si parte: è l'inizio dell'[[Atto 3]].

## Cosa dice

| Quando | Frasi |
|---|---|
| La prima volta | Chiede a Subaru se ha già fatto un giro, parla del villaggio e di [[Lina]] |
| Dalla seconda volta | Propone di riposarsi in piazza |

## Da sapere

La spritesheet l'ha fornita l'autore del progetto: è una fan art di un personaggio di *Re:Zero*, come quella di Subaru. Va bene per imparare; se un giorno il gioco diventasse pubblico, andrebbero sostituiti entrambi con personaggi originali. Vedi `CREDITS.md`.

Storia: [[2026-11-12-emilia]]
