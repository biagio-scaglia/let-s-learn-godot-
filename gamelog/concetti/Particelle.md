---
tags:
  - concetto
  - nodo
  - grafica
aliases:
  - CPUParticles2D
  - GPUParticles2D
  - Particelle
---

# Particelle

← [[godot-basi|Basi di Godot]]

Un nodo di particelle crea **tanti piccoli elementi** che nascono, si muovono e spariscono: polvere, fumo, scintille, pioggia. In 2D ci sono `CPUParticles2D` (semplice, lo usiamo noi) e `GPUParticles2D` (per tantissime particelle).

| Proprietà | Cosa fa |
|---|---|
| `emitting` | Accende o spegne l'emissione |
| `amount`, `lifetime` | Quante particelle e quanto vivono |
| `emission_shape` | Da dove nascono (punto, rettangolo, cerchio…) |
| `direction`, `spread`, `initial_velocity` | Dove vanno e quanto veloci |
| `gravity` | Una spinta costante (anche verso l'alto) |
| `color_ramp` | Il colore lungo la vita, per farle **sfumare** |
| `scale_amount_curve` | La grandezza lungo la vita |
| `local_coords = false` | Restano nel mondo invece di seguire il nodo |
| `preprocess` | Le fa partire "già avviate" |

Senza texture ogni particella è un quadratino: per la [[Pixel art]] va benissimo.

## Nel progetto

- **Polvere** ai piedi di [[Subaru]] quando corre: `emitting = moving and running`.
- **Pollini** che fluttuano nell'aria, figli della [[Camera2D]] così coprono sempre lo schermo.

Vedi [[Effetti visivi]].

## Vedi anche

- [[Effetti visivi]] · [[Tween]]
