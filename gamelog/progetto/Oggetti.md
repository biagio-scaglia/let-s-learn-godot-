---
tags:
  - progetto
  - oggetti
aliases:
  - Item
  - items
---

# Oggetti

← [[Gamelog]]

Gli oggetti del gioco sono [[Risorse personalizzate|risorse]] `Item` in `items/`.

![[oggetti.png|300]]

| Oggetto | id | Icona | Dove si trova |
|---|---|---|---|
| Chiave | `chiave` | Tile 117 di [[Tiny Town]] | A terra nel villaggio, vicino alla staccionata |
| Pozione rossa | `pozione` | Tile 115 di [[Tiny Dungeon]] | Nel baule di [[Lina]] (x2) |
| Moneta d'oro | `moneta` | Tile 93 di [[Tiny Town]] | Nel baule di Lina (x5) |

Per aggiungere un oggetto:

1. Crea un `.tres` di tipo **Item** in `items/` e compilalo.
2. Aggiungilo a `Inventory.ITEMS` con il suo id (e, se lo usi nel codice, una costante come `Inventory.KEY`).
3. Mettilo nel mondo con un [[Oggetto da raccogliere]], o dallo con `Inventory.add("id")`.

Si vedono nello [[Zaino]].

## Oggetti che curano

`Item` ha il campo `heal`: quanti punti salute rimette. La pozione ne rimette 12; chiave e moneta 0 (non si usano). Si usano dallo [[Zaino]] o nel [[Combattimento]] (Oggetti), con `Inventory.use(id)`.
