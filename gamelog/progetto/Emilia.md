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
| Stessa scala di pixel di Subaru | Sprite a ×1, niente ingrandimenti |

## Cosa dice

| Quando | Frasi |
|---|---|
| La prima volta | Saluta Subaru, parla del villaggio e di [[Lina]] |
| Dalla seconda volta | Propone di riposarsi in piazza |

## Da sapere

La spritesheet l'ha fornita l'autore del progetto: è una fan art di un personaggio di *Re:Zero*, come quella di Subaru. Va bene per imparare; se un giorno il gioco diventasse pubblico, andrebbero sostituiti entrambi con personaggi originali. Vedi `CREDITS.md`.

Storia: [[2026-11-12-emilia]]
