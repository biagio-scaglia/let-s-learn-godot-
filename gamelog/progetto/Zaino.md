---
tags:
  - progetto
  - ui
aliases:
  - Inventario
  - InventoryMenu
  - inventory_menu.tscn
---

# Zaino

← [[Gamelog]]

L'inventario: si apre con **Tab** o **I** in qualsiasi livello. È un [[Autoload]] chiamato `InventoryMenu`.

![[zaino.png|500]]

## Com'è fatto

- 12 caselle (6×2), create dal codice. Ognuna è un `Button` con la variazione `SlotButton` del [[Theme]]: bordo crema, che diventa **dorato** quando è selezionata.
- In ogni casella: l'icona dell'[[Oggetti|oggetto]] e, se sono più di uno, la quantità in basso a destra.
- Sotto: nome (dorato) e descrizione dell'oggetto selezionato.
- Si sceglie con le frecce o con il mouse ([[Menu e focus]]).
- Come il [[Menu di pausa]]: mette il gioco in [[Pausa]] e sfoca lo sfondo.
- Si chiude con Tab, I o Esc.

## Da dove prende i dati

Da [[Inventory]] (`Inventory.items`, un [[Dizionari|dizionario]] id → quantità). Quando cambia, `Inventory` manda il [[Segnali|segnale]] `changed` e lo zaino si aggiorna.

Si apre solo se `Game.can_open_menu()` lo permette: la stessa regola del [[Menu di pausa]].

## Usare gli oggetti

Con **Invio** (o un clic) sulla casella selezionata l'oggetto si usa: per ora solo le cure, come la pozione. Le regole stanno in `Inventory.use()`; lo zaino decide solo cosa scrivere ("Hai recuperato 12 punti salute", "Sei già in piena forma", "Non si può usare qui"). In basso si vedono sempre i PS di Subaru, presi da [[Statistiche|Stats]].
