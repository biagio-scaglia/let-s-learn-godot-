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

## Particelle create dal codice

Nel [[Combattimento]] le scintille non sono nodi della scena: le crea `battle.gd` al momento del colpo, e si cancellano da sole.

```gdscript
var p := CPUParticles2D.new()
p.one_shot = true        # una volta sola, poi si spegne
p.explosiveness = 1.0    # tutte insieme, come un'esplosione
p.amount = 16
p.spread = 180.0         # in tutte le direzioni
p.gravity = Vector2(0, 300)
p.position = punto_del_colpo
stage.add_child(p)
p.emitting = true
get_tree().create_timer(1.0).timeout.connect(p.queue_free)
```

| Effetto | Com'è fatto |
|---|---|
| Scintille dei colpi | Quadratini bianchi o arancioni, `one_shot`, ricadono |
| Schegge della rottura | Le stesse, azzurre e più grandi |
| Aura del pugno caricato | **Non** `one_shot`: emette finché Subaru carica, gravità verso l'alto. `move_child()` la mette **dietro** a Subaru |
| Nebbia di Shamac | Con la texture `smoke_04.png` di [[Kenney]], viola scuro, che ruota |
| Pulviscolo dello sfondo | Un nodo vero (`Motes`), lento, con `preprocess` per partire già pieno |

## Vedi anche

- [[Effetti visivi]] · [[Tween]]
