---
tags:
  - concetto
  - grafica
aliases:
  - PointLight2D
  - Luci
  - FastNoiseLite
---

# Luci 2D

← [[godot-basi|Basi di Godot]]

In 2D una luce è un nodo **`PointLight2D`**: illumina un'area intorno a sé con la forma della sua `texture`.

| Proprietà | Cosa fa |
|---|---|
| `texture` | La forma della luce: di solito un cerchio sfumato |
| `texture_scale` | Quanto è grande |
| `color`, `energy` | Colore e intensità |

Le luci si vedono bene solo se intorno è **buio**: per questo si usa un [[CanvasModulate]] scuro, e le luci "tolgono" il buio dove arrivano.

## Il cerchio sfumato senza immagini

Non serve disegnare la texture: un **`GradientTexture2D`** con `fill = Radial` crea un cerchio che va dal bianco al trasparente.

## La fiamma che tremola

Lo script `effects/flicker.gd` cambia continuamente `energy` e `texture_scale` usando un **`FastNoiseLite`**: un generatore di "rumore" che produce numeri casuali ma che cambiano in modo **morbido**. Con numeri del tutto a caso la luce sfarfallerebbe; con il rumore sembra una fiamma vera.

## Nel progetto

Nella [[Casa di Lina]]:

| Luce | Colore | Tremola |
|---|---|---|
| Torcia sul muro | Arancione caldo | Sì |
| Finestra | Azzurro freddo | No |

Il contrasto tra caldo e freddo rende la stanza più interessante. Vedi [[Effetti visivi]].

Nella [[Biblioteca]] lo stesso contrasto, più in grande: otto fiamme calde che tremolano, la luna fredda dalle finestre e una luce viola lentissima sul libro nero (`flicker.gd` con `speed = 1.2` e `amount = 0.45`: invece di tremolare, "respira").

## Raggi di luce senza texture

I raggi di luna della [[Biblioteca]] non sono immagini: sono **`Polygon2D`**, trapezi con un colore **per ogni vertice** (`vertex_colors`). Ai due vertici in alto azzurro semitrasparente, ai due in basso trasparente: Godot sfuma da solo nel mezzo.

| Proprietà del materiale (`CanvasItemMaterial`) | Perché |
|---|---|
| `blend_mode = Add` | Il colore si **somma** a quello sotto: schiarisce, come una luce vera |
| `light_mode = Unshaded` | Il buio del [[CanvasModulate]] non lo tocca, altrimenti il raggio sparirebbe |

Dentro ogni raggio c'è un po' di polvere ([[Particelle]]) con lo stesso materiale: brilla solo dove c'è il raggio.

## Vedi anche

- [[CanvasModulate]] · [[Effetti visivi]]
