extends Node
## La missione della chiave, nella casa di Lina.
##
## 1. Lina ha perso la chiave del baule (vicino alla staccionata, nel villaggio).
## 2. Se torni da lei con la chiave, ti ringrazia e ti dice di aprire il baule.
## 3. Il baule, con la chiave, si apre: dentro pozioni e monete.
##
## Lo script non sta dentro Lina o il baule: li "ascolta" (segnale interacted) e
## decide cosa dicono, in base a zaino e ricordi (Inventory, Game.flags).

const CHEST_CELL := Vector2i(9, 2)        # dove sta il baule nel livello Objects
const OPEN_CHEST_TILE := Vector2i(7, 7)   # tile 91 di Tiny Dungeon: baule aperto

@export var lina: Interactable
@export var chest: Interactable
@export var objects: TileMapLayer


func _ready() -> void:
	lina.interacted.connect(_on_lina)
	chest.interacted.connect(_on_chest)
	if Game.has_flag(FlagKeys.CHEST_OPEN):
		objects.set_cell(CHEST_CELL, 0, OPEN_CHEST_TILE)


func _on_lina() -> void:
	if Game.has_flag(FlagKeys.CHEST_OPEN):
		lina.override_lines = [
			"Ti sono piaciute le pozioni? Erano del nonno: dice che fanno miracoli.",
		]
	elif Inventory.has(Inventory.KEY):
		lina.override_lines = [
			"La mia chiave! L'hai trovata tu?",
			"Grazie, Subaru! Apri pure il baule: quello che c'è dentro è tuo.",
		]
		Game.set_flag(FlagKeys.KEY_SHOWN)
	else:
		# Le sue frasi normali: è qui che chiede di trovare la chiave.
		Game.set_flag(FlagKeys.KEY_QUEST_STARTED)


func _on_chest() -> void:
	if Game.has_flag(FlagKeys.CHEST_OPEN):
		chest.override_lines = ["Il baule è vuoto."]
	elif Inventory.has(Inventory.KEY):
		chest.override_lines = [
			"La chiave gira nella serratura... clic!",
			"Dentro ci sono due pozioni rosse e qualche moneta d'oro.",
		]
		# Il baule si apre quando il dialogo finisce (una volta sola).
		Dialogue.finished.connect(_open_chest, CONNECT_ONE_SHOT)


func _open_chest() -> void:
	Game.set_flag(FlagKeys.CHEST_OPEN)
	Inventory.remove(Inventory.KEY)
	objects.set_cell(CHEST_CELL, 0, OPEN_CHEST_TILE)
	Sfx.play(Sfx.CHEST_OPEN)
	Inventory.add(Inventory.POTION, 2)
	Inventory.add(Inventory.COIN, 5)
