---
tags:
  - concetto
  - risorsa
---

# AtlasTexture

← [[godot-basi|Basi di Godot]]

Una [[Risorsa]] che è **un ritaglio rettangolare di un'immagine più grande**. Si indica l'immagine (*atlas*) e il rettangolo (*region*, un `Rect2`).

```
atlas = ExtResource("1_sheet")
region = Rect2(84, 0, 42, 58)   # x, y, larghezza, altezza
```

## Nel progetto

Ogni frame di [[Subaru]] in [[SpriteFrames]] è un'AtlasTexture che ritaglia una cella da 42×58 px della [[Spritesheet]].

## Vedi anche

- [[Spritesheet]] · [[SpriteFrames]] · [[TileSet]] (che ritaglia i tile in modo simile)
