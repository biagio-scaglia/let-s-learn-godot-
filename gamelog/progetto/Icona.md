---
tags:
  - progetto
  - grafica
aliases:
  - Icona del gioco
---

# Icona

← [[Gamelog]]

![[icona.png|600]]

Un occhio viola nel cielo notturno che guarda una collina con un albero solo e una casetta: il tema del gioco ("qualcuno nel buio ti guarda") in un quadratino. È **originale**, disegnata con Python + Pillow come i [[Nemici]], quindi si può usare ovunque (Game Jolt, store) senza problemi di fan art.

## Le misure

Disegnata in pixel art a 64×64, più due versioni semplificate per le misure piccole: a 32 px meno dettagli, a 16 px **solo l'occhio** (il resto diventerebbe una macchia). Poi ingrandita senza sfumature ([[Filtro Nearest]]).

| File (`assets/icon/`) | A cosa serve |
|---|---|
| `icon.png` (256) | L'icona del progetto: `application/config/icon` |
| `icon.ico` (16, 32, 48, 64, 128, 256) | L'eseguibile di Windows: `application/config/windows_native_icon` |
| `icon_1024.png` | iOS, store, pagina di Game Jolt |
| `icon_android_192.png` | Android, icona classica |
| `icon_android_foreground.png`, `_background.png`, `_monochrome.png` (432) | Android "adaptive": sfondo e primo piano separati, il sistema li ritaglia a cerchio o goccia. Il disegno sta nel 66% centrale, la zona sempre visibile |

I file per Android e iOS si collegano nel preset di esportazione, quando lo creeremo.

## Vedi anche

- [[Pixel art]] · [[Nemici]] · [[2026-11-18-icona]]
