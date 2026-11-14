extends Node
## Il mondo dimentica, Subaru no. Dopo un Ritorno dalla Morte chi gli parla nota
## che qualcosa non va, e aggiunge una frase in coda a quelle normali.
##
## Come la missione della chiave, lo script non sta dentro i personaggi: li ascolta
## (segnale interacted) e usa extra_lines.

@export var saggio: Interactable
@export var emilia: Interactable


func _ready() -> void:
	saggio.interacted.connect(_on_talk.bind(saggio, "saggio", _saggio_lines))
	emilia.interacted.connect(_on_talk.bind(emilia, "emilia", _emilia_lines))


func _on_talk(who: Interactable, id: String, lines: Callable) -> void:
	# Una volta sola per "linea temporale": il ricordo torna indietro con il Ritorno,
	# quindi dopo ogni morte lo notano di nuovo. Loro non sanno di averlo già detto.
	if Game.deaths == 0 or Game.has_flag(FlagKeys.death_noticed(id)):
		return
	who.extra_lines = lines.call()
	Game.set_flag(FlagKeys.death_noticed(id))


func _saggio_lines() -> PackedStringArray:
	if Game.deaths >= 3:
		return [
			"...Ancora quello sguardo, ragazzo.",
			"Qualunque cosa tu stia cercando là fuori, non vale la tua vita.",
		]
	return [
		"...Aspetta. Hai una faccia strana, ragazzo. Come chi ha visto qualcosa che non doveva.",
		"Dammi retta: non allontanarti dal villaggio. Oltre i confini c'è qualcosa che non perdona.",
	]


func _emilia_lines() -> PackedStringArray:
	return [
		"...Subaru? Sei pallido come un fantasma. È successo qualcosa?",
		"Se non vuoi dirmelo, va bene. Ma io sono qui, d'accordo?",
	]
