---
tags:
  - concetto
aliases:
  - Risorse
  - Resource
  - tres
---

# Risorsa

← [[godot-basi|Basi di Godot]]

Un **dato riutilizzabile**: un'immagine, un suono, un insieme di animazioni, una forma di collisione… I [[Nodo|nodi]] *usano* le risorse.

- Si salvano come file **`.tres`** (testo), oppure nascono dall'importazione di un file (un `.png` diventa una texture, vedi [[File import e uid]]).
- Più nodi possono usare **la stessa risorsa**: se la modifichi, cambia per tutti. Se ti serve una copia separata, nell'Inspector c'è *Rendi unico*.
- Una risorsa può anche vivere *dentro* una scena, senza un file suo (si chiama *sub-resource*).

## Risorse usate finora

| Risorsa | File | Cosa contiene |
|---|---|---|
| [[SpriteFrames]] | `subaru_frames.tres` | Le animazioni di [[Subaru]] |
| [[AtlasTexture]] | dentro `subaru_frames.tres` | I ritagli dei singoli frame |
| [[TileSet]] | `world/tileset.tres` | I tile di [[Tiny Town]] |
| `RectangleShape2D` | dentro le scene | Le forme delle [[Collisioni]] |

## Vedi anche

- [[Nodo]] · [[Percorsi res]]
