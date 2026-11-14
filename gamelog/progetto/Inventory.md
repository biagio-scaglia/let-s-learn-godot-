---
tags:
  - progetto
  - autoload
  - inventario
aliases:
  - inventory.gd
---

# Inventory

← [[Gamelog]]

L'[[Autoload]] **`Inventory`** (`core/inventory.gd`): **cosa c'è nello zaino**. Il menu che lo mostra è un'altra cosa: lo [[Zaino]].

## Cosa contiene

| Cosa | Note |
|---|---|
| `items` | Un [[Dizionari\|dizionario]] id → quantità (`{"pozione": 2}`) |
| `ITEMS` | Tutti gli [[Oggetti]] del gioco, id → risorsa `Item` |
| `KEY`, `POTION`, `COIN` | Gli id usati nel codice, come [[Costanti]] |

## Cosa fa

```gdscript
Inventory.add(Inventory.POTION, 2)
Inventory.has(Inventory.KEY)        # true / false
Inventory.remove(Inventory.KEY)
Inventory.item("chiave").name       # "Chiave"
```

`item()` con un id sbagliato **ferma il gioco** con il messaggio "Oggetto sconosciuto: …", invece di dare un errore strano più avanti.

## Segnali

| Segnale | Chi lo ascolta |
|---|---|
| `changed` | Il menu dello [[Zaino]], per ridisegnare le caselle |
| `item_added(item, amount)` | Gli [[Avvisi]]: "Hai trovato: …" |

`Inventory` **non sa** che esistono gli avvisi. Prima era `Game` a chiamare `Hud.show_item()`: ora è l'avviso che si mette in ascolto. Così lo zaino si può usare (e provare) anche senza avvisi. Vedi [[Segnali]] e [[Responsabilità]].

## Usare un oggetto

`use(id)` cura Subaru di `item(id).heal` punti e toglie l'oggetto dallo zaino. Restituisce quanti PS sono tornati; **0** se non è servito (non è una cura, non ce l'hai, sei già in piena forma), e in quel caso l'oggetto resta. Lo usano sia lo [[Zaino]] sia il [[Combattimento]]: la regola è scritta una volta sola. Vedi [[Statistiche]].

## Vedi anche

- [[Zaino]] · [[Oggetti]] · [[Salvataggio]] · [[Game]]
