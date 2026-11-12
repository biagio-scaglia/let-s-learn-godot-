---
tags:
  - progetto
  - personaggio
aliases:
  - Subaru Natsuki
  - Personaggio
---

# Subaru

← [[Gamelog]]

Il primo personaggio del gioco: un [[CharacterBody2D]] che cammina e corre in 4 direzioni.

![[subaru_sheet_4x.png|300]]

## Com'è fatto

```
Subaru (CharacterBody2D)        + subaru.gd
├── AnimatedSprite2D            ← animazioni da subaru_frames.tres
└── CollisionShape2D            ← rettangolo 16×8 sui piedi
```

| Pezzo | Concetto |
|---|---|
| `subaru_sheet.png`, 6×4 celle da 42×58 px | [[Spritesheet]], [[Pixel art]] |
| `subaru_frames.tres`, 8 animazioni | [[SpriteFrames]], [[AtlasTexture]] |
| Sprite con origine ai piedi | [[AnimatedSprite2D]], [[Y-sort]] |
| Movimento | [[CharacterBody2D]], [[Ciclo di gioco]] |
| Tasti | [[Input Map]] |
| Velocità regolabili | [[Export e Inspector]] |
| Collisione sui piedi | [[Collisioni]] |

## Numeri

| Cosa | Valore |
|---|---|
| Camminata | 80 px/s, animazione 8 fps |
| Corsa (Shift) | 150 px/s, animazione ×1,8 |
| Idle | "respiro" a 2 frame, 2 fps |

## Storia

- [[2026-11-12-subaru]]: dalla spritesheet originale alla pixel art, animazioni rifatte.
- [[2026-11-12-mappa-e-corsa]]: dentro il progetto Godot, nella [[Mappa principale]], con la corsa.

File: `let's-learn-godot/characters/subaru/`
