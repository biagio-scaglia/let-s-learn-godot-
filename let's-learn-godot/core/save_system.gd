extends Node
## Salvare e riprendere la partita. È un autoload chiamato "SaveSystem".
##
## Il formato del file non è cambiato da quando tutto stava in Game:
## i vecchi salvataggi si caricano ancora.

## Dove sta il file. È una variabile (non una costante) così i test possono usare
## un file loro e non toccare mai il salvataggio vero.
var path := "user://salvataggio.cfg"

## Il nome dei luoghi, da mostrare nel titolo accanto a "Continua".
const PLACE_NAMES := {
	"res://world/main.tscn": "Villaggio di Erbalta",
	"res://world/house.tscn": "Casa di Lina",
}


func has_save() -> bool:
	return FileAccess.file_exists(path)


## Salva la partita: scena, posizione, direzione, ricordi e zaino.
func save_game() -> bool:
	var scene := get_tree().current_scene
	var player := get_tree().get_first_node_in_group("player")
	if scene == null or player == null:
		return false
	var config := ConfigFile.new()
	config.set_value("partita", "scena", scene.scene_file_path)
	config.set_value("partita", "posizione", player.global_position)
	config.set_value("partita", "direzione", player.facing)
	config.set_value("partita", "data", Time.get_datetime_string_from_system(false, true))
	config.set_value("partita", "ricordi", Game.flags)
	config.set_value("partita", "zaino", Inventory.items)
	config.set_value("partita", "morti", Game.deaths)
	# Salvare fissa anche il punto di ritorno.
	Game.set_checkpoint()
	return config.save(path) == OK


## Luogo e data dell'ultimo salvataggio, per il titolo. Vuoto se non c'è.
func save_info() -> Dictionary:
	var config := ConfigFile.new()
	if config.load(path) != OK:
		return {}
	var scene: String = config.get_value("partita", "scena", "")
	return {
		"luogo": PLACE_NAMES.get(scene, "?"),
		"data": config.get_value("partita", "data", ""),
	}


## Riprende la partita salvata.
func continue_game() -> void:
	var config := ConfigFile.new()
	if config.load(path) != OK:
		return
	Game.load_flags(config.get_value("partita", "ricordi", {}))
	Inventory.reset(config.get_value("partita", "zaino", {}))
	Game.spawn_position = config.get_value("partita", "posizione", null)
	Game.deaths = config.get_value("partita", "morti", 0)   # i vecchi salvataggi non ce l'hanno
	var scene: String = config.get_value("partita", "scena", Game.FIRST_LEVEL)
	await Game.change_scene(scene, "", config.get_value("partita", "direzione", Facing.DOWN), false)
	# Si riparte da qui: è il nuovo punto di ritorno.
	Game.set_checkpoint()
