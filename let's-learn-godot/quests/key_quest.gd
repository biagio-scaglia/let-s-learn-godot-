extends Node
## La missione della chiave, nella casa di Lina.
##
## 1. Lina ha perso la chiave del baule (vicino alla staccionata, nel villaggio).
## 2. Se torni da lei con la chiave, ti ringrazia e ti dice di aprire il baule.
## 3. Il baule, con la chiave, si apre: dentro pozioni e monete.
##
## Lo script non sta dentro Lina o il baule: li "ascolta" (segnale interacted) e
## decide cosa dicono, in base a zaino e ricordi (Game.inventory, Game.flags).

const CHEST_CELL := Vector2i(9, 2)        # dove sta il baule nel livello Objects
const OPEN_CHEST_TILE := Vector2i(7, 7)   # tile 91 di Tiny Dungeon: baule aperto

@export var lina: Interactable
@export var chest: Interactable
@export var objects: TileMapLayer


func _ready() -> void:
	lina.interacted.connect(_on_lina)
	chest.interacted.connect(_on_chest)
	if Game.flags.get("baule_aperto", false):
		objects.set_cell(CHEST_CELL, 0, OPEN_CHEST_TILE)


func _on_lina() -> void:
	if Game.flags.get("baule_aperto", false):
		lina.override_lines = [
			"Ti sono piaciute le pozioni? Erano del nonno: dice che fanno miracoli.",
		]
	elif Game.has_item("chiave"):
		lina.override_lines = [
			"La mia chiave! L'hai trovata tu?",
			"Grazie, Subaru! Apri pure il baule: quello che c'è dentro è tuo.",
		]


func _on_chest() -> void:
	if Game.flags.get("baule_aperto", false):
		chest.override_lines = ["Il baule è vuoto."]
	elif Game.has_item("chiave"):
		chest.override_lines = [
			"La chiave gira nella serratura... clic!",
			"Dentro ci sono due pozioni rosse e qualche moneta d'oro.",
		]
		# Il baule si apre quando il dialogo finisce (una volta sola).
		Dialogue.finished.connect(_open_chest, CONNECT_ONE_SHOT)


func _open_chest() -> void:
	Game.flags["baule_aperto"] = true
	Game.remove_item("chiave")
	objects.set_cell(CHEST_CELL, 0, OPEN_CHEST_TILE)
	Game.ui_sound("chest_open")
	Game.add_item("pozione", 2)
	Game.add_item("moneta", 5)
