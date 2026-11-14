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
| `subaru_sheet.png`, 6×4 celle da 32×48 px, generato dal suo [[Charset]] (ora solo nella cronologia di git) | [[Spritesheet]], [[Pixel art]], [[Generatore di Subaru]] |
| `subaru_actions.png`, 4×4 celle da 64×48 px | [[#Le azioni]] |
| `subaru_frames.tres`, 16 animazioni | [[SpriteFrames]], [[AtlasTexture]] |
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
| Crolla quando muore | `collapse()`: barcolla, cade a terra e si scurisce. Vedi [[Ritorno dalla Morte]] |
| Si risveglia dopo il Ritorno | `lie_down()` e `wake_up()`: steso, in ginocchio, in piedi |
| Esulta quando trova un oggetto | `cheer()`, chiamata dall'[[Oggetto da raccogliere]] |
| Passi sonori | [[Audio]], [[Segnali]] (`frame_changed`) |

## Le azioni

![[subaru_azioni_3x.png|500]]

`subaru_actions.png` ha 16 pose, una per cella (64×48), centrate e con i piedi sul fondo. Sono disegnate verso destra: se Subaru guarda a sinistra si specchiano (`flip_h`).

| Animazione | Pose (riga, colonna) | Quando |
|---|---|---|
| `cheer` | Pugno al cielo ×2 (1,2 e 1,3), poi vittoria (1,4) | Raccoglie un oggetto |
| `collapse` | Colpito (3,1), sviene (4,1), steso (4,3) | Muore |
| `lying` | Steso a occhi aperti (4,4) | Appena tornato dalla morte |
| `wake_up` | Steso (4,4), in ginocchio (3,3), occhi chiusi (4,2), in piedi (1,1) | Si rialza dopo il Ritorno |
| `guard` | In guardia (2,1) | Nel [[Combattimento]], in attesa |
| `punch` | Guardia, pugno, pugno a segno (2,1 → 2,3) | Attacca |
| `hurt` | Colpito (3,1) | Il nemico lo colpisce |
| `weak` | In ginocchio (3,3) | Combattimento, con meno di un quarto della salute |
| *nessuna, per ora* | Guardia di spalle (2,4), volo all'indietro (3,2), camminata triste (3,4) | Pronte per dopo |

Nessuna si ripete (*loop* spento): finiscono, e lo script aspetta `animation_finished`. Mentre un'azione è in corso i tasti non contano (`_scripted`). Se ne parte un'altra a metà (muore mentre esulta), la prima se ne accorge da `_action_id` e non rimette Subaru in piedi.

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
- [[2026-11-14-azioni-di-subaru]]: la spritesheet delle azioni: caduta, risveglio, esultanza.

File: `let's-learn-godot/characters/subaru/`
