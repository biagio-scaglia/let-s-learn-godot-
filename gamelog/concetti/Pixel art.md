---
tags:
  - concetto
  - grafica
aliases:
  - Pixel-art
---

# Pixel art

← [[godot-basi|Basi di Godot]]

Grafica disegnata **pixel per pixel**, con pochi colori e senza sfumature automatiche.

Per farla apparire bene in Godot servono due cose:

1. Il [[Filtro Nearest]], così i pixel ingranditi restano quadrati e nitidi.
2. Una risoluzione bassa ingrandita di un numero intero di volte (×2, ×3…), vedi [[Viewport e stretch]].

## Cose imparate

- Un'immagine che *sembra* pixel art può non esserlo: la spritesheet originale di [[Subaru]] era ingrandita in modo irregolare e aveva 69.000 colori. L'abbiamo riportata a 1x con 22 colori: [[2026-11-12-subaru]].
- Mescolare pixel di grandezze diverse si nota: i tile di [[Tiny Town]] sono ingranditi ×2, quindi i loro "pixel" sono il doppio di quelli di Subaru.

## Tile che si ripetono

Un tile che si mette uno accanto all'altro non deve far vedere le "cuciture". Le regole usate per il tileset della [[Biblioteca]]:

- **Il motivo deve stare dentro 16 pixel.** Le assi del pavimento sono alte 4 pixel: 16 / 4 = 4 assi esatte, e il tile sotto continua il disegno.
- **Varianti** con dettagli diversi (nodi del legno, giunture in punti diversi) per non far notare la ripetizione.
- **Pezzi da comporre**: un tappeto 3×3 (4 angoli, 4 bordi, un centro che si ripete) diventa grande quanto si vuole; uno scaffale *inizio, centro, fine* diventa lungo quanto si vuole.
- **Contrasto prima dei dettagli**: il pavimento più scuro dei mobili, così i mobili si leggono subito.

## Vedi anche

- [[Spritesheet]] · [[Filtro Nearest]] · [[Viewport e stretch]]
