---
tags:
  - concetto
  - grafica
aliases:
  - Charset RPG Maker
  - hframes
---

# Charset

← [[godot-basi|Basi di Godot]]

Un **charset** è una [[Spritesheet]] di un personaggio nel formato reso famoso da *RPG Maker*: tante sprite di personaggi online usano questo formato.

| | Colonna 0 | Colonna 1 | Colonna 2 | Colonna 3 |
|---|---|---|---|---|
| **Riga 0** | giù, fermo | giù, passo | giù, fermo | giù, altro passo |
| **Riga 1** | sinistra… | | | |
| **Riga 2** | destra… | | | |
| **Riga 3** | su… | | | |

La camminata è quindi già pronta: 0 → 1 → 2 → 3.

## In Godot, senza AtlasTexture

Un [[Sprite2D]] sa già dividere un'immagine a griglia:

```gdscript
sprite.texture = charset
sprite.hframes = 4      # colonne
sprite.vframes = 4      # righe
sprite.frame = riga * 4 + colonna
```

Più semplice di uno [[SpriteFrames]] quando serve solo scegliere un frame alla volta.

## Nel progetto

[[Emilia]] e [[Subaru]] (dalla versione 2) usano charset con celle da 32×48 px. `npc.gd` sceglie la riga in base a dove si trova [[Subaru]], così lei si gira verso di lui. Subaru invece, che è il giocatore, passa dal charset a uno [[SpriteFrames]] con il [[Generatore di Subaru]].

## Vedi anche

- [[Spritesheet]] · [[Sprite2D]] · [[AnimatedSprite2D]]
