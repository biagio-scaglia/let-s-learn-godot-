extends Node
## Quello che il giocatore ha sbloccato, per sempre. È un autoload chiamato "Progress".
##
## Diverso dal salvataggio (SaveSystem): una partita nuova cancella i ricordi di Game,
## ma non questo. Finita la storia una volta, la Galleria resta aperta, anche
## ricominciando da capo. Sta in un file suo, come le opzioni (Settings).

## Dove sta il file. Una variabile, così i test possono usarne un altro.
var path := "user://progressi.cfg"

## La storia è stata finita almeno una volta: si apre la Galleria nel titolo.
var story_finished := false
## La Galleria è stata vista dopo lo sblocco (finché è false, nel titolo è "Nuova!").
var gallery_seen := false


func _ready() -> void:
	load_progress()
