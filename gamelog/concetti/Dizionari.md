---
tags:
  - concetto
  - codice
aliases:
  - Dictionary
  - Dizionario
---

# Dizionari

← [[godot-basi|Basi di Godot]]

Un **dizionario** (`Dictionary`) associa delle **chiavi** a dei **valori**, come una rubrica: nome → numero.

```gdscript
var zaino := {}                  # vuoto
zaino["pozione"] = 2             # aggiunge o cambia
zaino.get("chiave", 0)           # legge; 0 se la chiave non c'è
zaino.erase("pozione")           # toglie
for id in zaino:                 # scorre le chiavi
	print(id, zaino[id])
```

- `get(chiave, predefinito)` evita errori quando la chiave manca.
- `duplicate(true)` fa una **copia** completa: modificare la copia non tocca l'originale.

## Nel progetto

| Dizionario | Chiavi → valori |
|---|---|
| `Inventory.items` | id dell'oggetto → quantità (`"pozione": 2`) |
| `Game.flags` | ricordo → valore (`"baule_aperto": true`, `"talked:…": 3`) |
| `Inventory.ITEMS` | id → risorsa [[Risorse personalizzate\|Item]] |

Tutti e due finiscono nel [[Salvare la partita|salvataggio]] così come sono.

## Vedi anche

- [[GDScript]] · [[Game]]
