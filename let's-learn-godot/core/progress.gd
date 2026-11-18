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


## Rilegge il file (all'avvio, e nei test dopo aver cambiato "path").
func load_progress() -> void:
	var config := ConfigFile.new()
	story_finished = false
	gallery_seen = false
	if config.load(path) == OK:
		story_finished = config.get_value("storia", "finita", false)
		gallery_seen = config.get_value("galleria", "vista", false)


func gallery_unlocked() -> bool:
	return story_finished


## Chiamato dal finale: la Galleria si sblocca.
func finish_story() -> void:
	if story_finished:
		return
	story_finished = true
	_save()


## Chiamato entrando nella Galleria: non è più "Nuova!".
func see_gallery() -> void:
	if gallery_seen:
		return
	gallery_seen = true
	_save()
