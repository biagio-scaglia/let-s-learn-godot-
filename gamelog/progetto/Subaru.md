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

![[subaru_v2_charset_3x.png|250]]

*La versione 2, dal suo [[Charset]]. La prima versione è in [[2026-11-12-subaru]].*

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
| `subaru_charset.png`, 4×4 celle da 32×48 px | [[Charset]], [[Pixel art]] |
| `subaru_sheet.png`, 6×4 celle da 32×48 px, generato dal charset | [[Spritesheet]], [[Generatore di Subaru]] |
| `subaru_frames.tres`, 8 animazioni | [[SpriteFrames]], [[AtlasTexture]] |
| Sprite con origine ai piedi | [[AnimatedSprite2D]], [[Y-sort]] |
| Movimento | [[CharacterBody2D]], [[Ciclo di gioco]] |
| Tasti | [[Input Map]] |
| Velocità regolabili | [[Export e Inspector]] |
| Collisione sui piedi | [[Collisioni]] |
| Ombra e polvere | [[Sprite2D]], [[Particelle]], [[Effetti visivi]] |
| Il [[Saggio]] lo riconosce | [[Gruppi]] (`player`) |
| Fermo durante i dialoghi | [[Autoload]] (`Dialogue.is_active`) |
| Si gira verso chi parla | `look_at_point()`, chiamata da [[Interactable]] |
| Cammina da solo nelle cutscene | `walk_to()`, un [[Tween]] sulla posizione: vedi [[Intro]] |
| Passi sonori | [[Audio]], [[Segnali]] (`frame_changed`) |

## Numeri

| Cosa | Valore |
|---|---|
| Camminata | 80 px/s, animazione 8 fps |
| Corsa (Shift) | 150 px/s, animazione ×1,8 |
| Idle | "respiro" a 2 frame, 2 fps |
| Altezza | circa 47 px, come [[Emilia]] |

## Storia

- [[2026-11-12-subaru]]: dalla spritesheet originale alla pixel art, animazioni rifatte.
- [[2026-11-12-mappa-e-corsa]]: dentro il progetto Godot, nella [[Mappa principale]], con la corsa.
- [[2026-11-12-primo-dialogo]]: ombra, polvere, e il primo dialogo con il [[Saggio]].
- [[2026-11-12-interazioni-e-rifiniture]]: i passi, e via la vecchia spritesheet HD.
- [[2026-11-12-subaru-v2]]: nuova spritesheet, con una vera camminata e la vera direzione destra.

File: `let's-learn-godot/characters/subaru/`
