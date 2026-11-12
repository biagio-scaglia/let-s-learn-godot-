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
Subaru (CharacterBody2D, gruppo "player")   + subaru.gd
├── Shadow (Sprite2D)           ← ombra ai piedi
├── Dust (CPUParticles2D)       ← polvere quando corre
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
| Ombra e polvere | [[Sprite2D]], [[Particelle]], [[Effetti visivi]] |
| Il [[Saggio]] lo riconosce | [[Gruppi]] (`player`) |
| Fermo durante i dialoghi | [[Autoload]] (`Dialogue.is_active`) |
| Si gira verso chi parla | `look_at_point()`, chiamata dal [[Saggio]] |

## Numeri

| Cosa | Valore |
|---|---|
| Camminata | 80 px/s, animazione 8 fps |
| Corsa (Shift) | 150 px/s, animazione ×1,8 |
| Idle | "respiro" a 2 frame, 2 fps |

## Storia

- [[2026-11-12-subaru]]: dalla spritesheet originale alla pixel art, animazioni rifatte.
- [[2026-11-12-mappa-e-corsa]]: dentro il progetto Godot, nella [[Mappa principale]], con la corsa.
- [[2026-11-12-primo-dialogo]]: ombra, polvere, e il primo dialogo con il [[Saggio]].

File: `let's-learn-godot/characters/subaru/`
