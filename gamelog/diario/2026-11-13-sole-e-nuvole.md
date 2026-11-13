---
data: 2026-11-13
tags:
  - gamelog
  - grafica
  - shader
  - cutscene
stato: funzionante
aliases:
  - Sole e nuvole
---

# 2026-11-13 — Raggi di sole, ombre delle nuvole e un'alba

← [[Gamelog]] · Voce precedente: [[2026-11-13-cutscene|La prima cutscene]]

## Obiettivo

Rendere il villaggio più bello con qualche **shader**, e dare più atmosfera alla [[Intro|cutscene d'apertura]].

![[sole_e_nuvole.png]]

## Come provarlo

1. Già nella schermata iniziale si vedono i raggi e le nuvole che scorrono.
2. *Nuova partita*: il mondo esce dal nero **blu**, diventa **arancio** mentre i raggi si accendono, poi torna alla luce del giorno. Quando Subaru si ferma compare **"Villaggio di Erbalta"**.

![[cartello_erbalta.png]]

## Cosa è stato fatto

| Pezzo | Come | Nota |
|---|---|---|
| Raggi di sole (`effects/sun_rays.gdshader`) | Su un `ColorRect` in `Effects`, sopra il mondo, in modalità **additiva** | [[Shader]], [[Rumore]] |
| Ombre delle nuvole (`effects/cloud_shadows.gdshader`) | Su un `ColorRect` grande quanto la mappa, sopra a `World` | [[Shader]], [[Rumore]] |
| L'alba nella cutscene | Due [[Tween]]: uno sul colore di `Tint`, uno sull'`intensity` dei raggi | [[CanvasModulate]], [[Intro]] |
| Il nome del luogo | Una `Label` che scende e compare, e una linea dorata che si allarga dal centro | [[Tween]], [[Intro]] |

## Decisioni e perché

- **Raggi sullo schermo, nuvole sul mondo.** I raggi vengono dal sole, che "sta in cielo": devono restare fermi anche quando la camera si muove, quindi stanno in un [[CanvasLayer]]. Le ombre delle nuvole invece stanno **sul terreno**: se fossero sullo schermo, sembrerebbe che seguano Subaru. Per questo lo shader usa la posizione nel mondo (`MODEL_MATRIX` nel `vertex()`), non `UV`.
- **`blend_add` per la luce.** Sommare il colore invece di coprirlo è come funziona la luce vera: schiarisce, non nasconde.
- **Ombre "a blocchetti" di 2 pixel.** Arrotondando la posizione (`floor(p / 2) * 2`) le ombre seguono la griglia dei pixel della mappa, e non stonano con la pixel art.
- **Tutto regolabile dall'Inspector:** colore, forza, vento, grandezza delle nuvole, numero di raggi sono `uniform`.

## Problemi incontrati

- **`get_shader_parameter()` restituiva `null`:** se nel materiale un parametro non è mai stato cambiato, Godot non lo salva e usa il valore scritto nello shader, ma il codice non lo vede. Ora `intensity = 0.3` è scritto nel materiale di `Effects/SunRays`.

## Verifica

Il test temporaneo della cutscene, aggiornato ai nuovi tempi: **14 controlli**, tutti ok, compreso "dopo l'alba la luce torna normale". Screenshot controllati a ogni fase: buio blu, alba arancio, cartello, giorno.

## Concetti nuovi

- [[Rumore]]: nuvole e fasci di luce senza immagini
