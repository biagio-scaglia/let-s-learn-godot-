---
tags:
  - progetto
  - interfaccia
aliases:
  - Galleria di Erbalta
---

# Galleria

← [[Gamelog]]

Una sala che si apre dal titolo **dopo aver finito la storia** ([[Progressi permanenti]]). Comandi Subaru tra tutti i personaggi e i mostri del gioco; accanto a ognuno c'è un leggio con il suo libro.

![[galleria.png|500]]

## Com'è fatta

| Pezzo | Cosa fa |
|---|---|
| `world/gallery.tscn` | La sala: tile della [[Biblioteca]] (scala 2), passatoia rossa, candelabri, le vetrine, Subaru, la porta verso il titolo |
| `world/gallery/gallery.gd` | Collega le vetrine al lettore, mostra il nome della sala, Esc → titolo |
| `world/gallery/exhibit.gd` (`Exhibit`) | Una vetrina: piedistallo, figura, leggio, collisione. Tutto da un `book_id` |
| `world/gallery/book_reader.gd` (`BookReader`) | Il libro aperto: ritratto, nome, numeri, pagine |
| `world/gallery/gallery_books.gd` (`GalleryBooks`) | I testi dei libri. Per i mostri nome e numeri vengono dal loro [[Risorse personalizzate\|EnemyData]] |
| `ui/portraits.gd` (`Portraits`) | Il ritratto di chiunque, da un id: lo usano anche i [[Titoli di coda]] |

## Le vetrine

Ogni vetrina è un `Node2D` con `exhibit.gd` e un id. In `_ready()` costruisce:

- il **piedistallo**, disegnato con `_draw()` (due rettangoli di pietra): vedi [[Disegnare con _draw]];
- la **figura**: Subaru è una **statua** (è lui il giocatore!), Emilia, il Saggio, Lina e l'Archivista sono i **PNG veri** (`npc.tscn`) con due battute nuove, i mostri sono il loro foglio di sprite che alterna le due pose di riposo;
- il **leggio** (una casella del tileset della biblioteca) con un [[Interactable]] senza frasi: il suo segnale `interacted` diventa `book_opened(book_id)`.

Così aggiungere un libro vuol dire: un dizionario in `GalleryBooks`, un nodo in più nella scena.

## Il libro

![[galleria_libro_emilia.png|480]] ![[galleria_libro_boss.png|480]]

Tutta l'interfaccia è costruita da codice ([[Interfaccia da codice]]): la copertina e le due pagine sono `Panel` con uno [[StyleBox|StyleBoxFlat]] (colore, bordo, angoli arrotondati), le scritte sono `Label` col colore dell'inchiostro. Mentre leggi `Game.in_cutscene` è vero, così Subaru non si muove. Frecce: sfoglia. E, Invio, Esc: chiudi.

## Non è un livello

La Galleria non entra nel gruppo `level`: niente menu di pausa, niente salvataggio, niente obiettivo. Ci si entra con `Game.open_gallery()`, che svuota i ricordi (non è una partita).

## Vedi anche

- [[2026-11-18-finale]] · [[Schermata iniziale]] · [[Progressi permanenti]]
