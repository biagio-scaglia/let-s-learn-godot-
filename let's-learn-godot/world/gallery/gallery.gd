extends Node2D
## La Galleria: una sala della biblioteca dove stanno tutti i personaggi e i mostri
## del gioco, ognuno con il suo libro. Si apre dal titolo dopo aver finito la storia.
##
## Non è un livello della storia (non è nel gruppo "level"): niente menu di pausa,
## niente salvataggi, niente obiettivo. Esc o la porta in basso riportano al titolo.

@onready var reader: BookReader = $Reader
@onready var place_name: Control = %PlaceName
@onready var hint: Label = %Hint


func _ready() -> void:
	Progress.see_gallery()   # da ora nel titolo non è più "Nuova!"
	for exhibit in find_children("*", "Node2D"):
		if exhibit is Exhibit:
			exhibit.book_opened.connect(reader.open)
	_show_place_name()


## Il nome della sala compare in alto, resta un po' e sparisce.
func _show_place_name() -> void:
	place_name.modulate.a = 0.0
	var t := create_tween()
	t.tween_interval(0.6)
	t.tween_property(place_name, "modulate:a", 1.0, 0.6)
	t.tween_interval(2.4)
	t.tween_property(place_name, "modulate:a", 0.0, 0.8)
