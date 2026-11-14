class_name Item
extends Resource
## Un oggetto che si può avere nello zaino. Ogni oggetto è un file .tres in items/:
## si crea dall'editor con "Nuova risorsa → Item" e si compila nell'Inspector.

## Il nome "tecnico", usato nel codice e nei salvataggi (es. "chiave").
@export var id := ""
## Il nome che vede il giocatore.
@export var name := ""
## La descrizione nello zaino.
@export_multiline var description := ""
## Quanti punti salute rimette, se usato. 0 = non è una cura.
@export var heal := 0
## L'icona (16x16).
@export var icon: Texture2D
