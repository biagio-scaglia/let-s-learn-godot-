extends Node
## Lo zaino. È un autoload chiamato "Inventory".
##
## Non sa niente di avvisi o finestre: quando cambia manda dei segnali, e chi è
## interessato (l'avviso in alto, il menu dello zaino) li ascolta.

## Gli id degli oggetti usati nel codice. Sono le chiavi di ITEMS e dei salvataggi.
const KEY := "chiave"
const POTION := "pozione"
const COIN := "moneta"

## Tutti gli oggetti del gioco, per id.
const ITEMS := {
	KEY: preload("res://items/chiave.tres"),
	POTION: preload("res://items/pozione.tres"),
	COIN: preload("res://items/moneta.tres"),
}

## Emesso a ogni cambiamento (lo ascolta il menu dello zaino).
signal changed
## Emesso quando il giocatore trova qualcosa (lo ascolta l'avviso "Hai trovato…").
signal item_added(item: Item, amount: int)

## id dell'oggetto → quantità.
var items := {}


## La risorsa Item di un id. Un id sbagliato ferma il gioco con un errore chiaro.
func item(id: String) -> Item:
	assert(ITEMS.has(id), "Oggetto sconosciuto: " + id)
	return ITEMS[id]


func has(id: String) -> bool:
	return items.get(id, 0) > 0


func add(id: String, amount := 1) -> void:
	items[id] = items.get(id, 0) + amount
	changed.emit()
	item_added.emit(item(id), amount)


func remove(id: String, amount := 1) -> void:
	items[id] = items.get(id, 0) - amount
	if items[id] <= 0:
		items.erase(id)
	changed.emit()


## Svuota lo zaino, oppure lo riempie con quello letto da un salvataggio.
func reset(data := {}) -> void:
	# duplicate(): una copia nuova, così modificarla non tocca i dati di partenza.
	items = data.duplicate(true)
	changed.emit()
