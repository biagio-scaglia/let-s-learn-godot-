---
tags:
  - concetto
  - codice
aliases:
  - Custom Resource
  - class_name Resource
---

# Risorse personalizzate

← [[godot-basi|Basi di Godot]]

Oltre alle [[Risorsa|risorse]] di Godot (texture, suoni, SpriteFrames…) se ne possono creare di **proprie**: uno script che estende `Resource`, con delle variabili `@export`.

```gdscript
class_name Item
extends Resource

@export var id := ""
@export var name := ""
@export_multiline var description := ""
@export var icon: Texture2D
```

Da quel momento, nel pannello *FileSystem*: tasto destro → *Nuovo* → *Risorsa…* → **Item**. Si crea un file `.tres` che si compila nell'Inspector, come una scheda.

## Perché è comodo

- I **dati** stanno nei file, il **codice** non cambia: per un oggetto nuovo basta un `.tres` nuovo.
- L'Inspector mostra i campi giusti (testo, testo su più righe, immagine…).
- Il codice può usare il tipo: `func item(id) -> Item`.

## Nel progetto

`items/item.gd` e tre oggetti: `chiave.tres`, `pozione.tres`, `moneta.tres`. Vedi [[Oggetti]]. Le icone sono [[AtlasTexture]] ritagliate dai tileset di [[Kenney]].

## Vedi anche

- [[Risorsa]] · [[Classi globali]] · [[Export e Inspector]]
