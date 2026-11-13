extends Node
## Stato del gioco che deve sopravvivere ai cambi di scena. È un autoload chiamato "Game".
##
## Quando si cambia scena, la vecchia viene distrutta con tutti i suoi nodi e le loro
## variabili. Quello che va ricordato (con chi hai parlato, dove comparire, le opzioni…)
## sta qui.

const TITLE_SCENE := "res://ui/title_screen.tscn"
const FIRST_LEVEL := "res://world/main.tscn"
const SETTINGS_PATH := "user://impostazioni.cfg"
const SAVE_PATH := "user://salvataggio.cfg"

## Tutti gli oggetti del gioco, per id. Nei salvataggi e nell'inventario si usa l'id.
const ITEMS := {
	"chiave": preload("res://items/chiave.tres"),
	"pozione": preload("res://items/pozione.tres"),
	"moneta": preload("res://items/moneta.tres"),
}
## Il nome dei luoghi, da mostrare nel titolo accanto a "Continua".
const PLACE_NAMES := {
	"res://world/main.tscn": "Villaggio di Erbalta",
	"res://world/house.tscn": "Casa di Lina",
}

## Emesso quando l'inventario cambia (lo ascolta lo zaino).
signal inventory_changed

## In quale Marker2D (figlio di "Spawns") far comparire il giocatore nella prossima scena.
var spawn_point := ""
## Oppure una posizione esatta (quando si carica un salvataggio). null = non usata.
var spawn_position: Variant = null
## Verso dove deve guardare il giocatore all'arrivo ("down", "up", "left", "right").
var spawn_facing := ""
## I ricordi del gioco: con chi hai parlato, oggetti raccolti, bauli aperti…
var flags := {}
## Lo zaino: id dell'oggetto → quantità.
var inventory := {}
## True durante un cambio di scena.
var changing_scene := false

## Opzioni (salvate su file): volume da 0 a 1, schermo intero.
var volume := 0.8
var fullscreen := false

var _door_sound: AudioStreamPlayer
var _ui_sounds := {}


func _ready() -> void:
	# Deve funzionare anche a gioco in pausa: i suoni dei menu di pausa passano da qui.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_door_sound = _make_player("res://assets/effects/door.wav", -4.0)
	for sound in ["move", "confirm", "back"]:
		_ui_sounds[sound] = _make_player("res://assets/ui/menu_%s.wav" % sound, -6.0)
	for sound in ["pickup", "chest_open", "save"]:
		_ui_sounds[sound] = _make_player("res://assets/effects/%s.wav" % sound, -4.0)
	load_settings()


func _make_player(path: String, volume_db: float) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.stream = load(path)
	player.volume_db = volume_db
	add_child(player)
	return player


## Il giocatore può muoversi? No durante un dialogo o un cambio di scena.
func player_can_move() -> bool:
	return not changing_scene and not Dialogue.is_active


## Suono dei menu e degli eventi: "move", "confirm", "back", "pickup", "chest_open", "save".
func ui_sound(sound: String) -> void:
	_ui_sounds[sound].play()


## Comincia una partita nuova: dimentica tutto e va al primo livello.
func new_game() -> void:
	flags.clear()
	inventory.clear()
	spawn_position = null
	change_scene(FIRST_LEVEL, "", "", false)


# ---------- Inventario ----------

func item(id: String) -> Item:
	return ITEMS[id]


func has_item(id: String) -> bool:
	return inventory.get(id, 0) > 0


## Aggiunge un oggetto allo zaino e mostra l'avviso "Hai trovato…".
func add_item(id: String, amount := 1) -> void:
	inventory[id] = inventory.get(id, 0) + amount
	inventory_changed.emit()
	Hud.show_item(item(id), amount)


func remove_item(id: String, amount := 1) -> void:
	inventory[id] = inventory.get(id, 0) - amount
	if inventory[id] <= 0:
		inventory.erase(id)
	inventory_changed.emit()


# ---------- Salvataggio ----------

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


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
	config.set_value("partita", "ricordi", flags)
	config.set_value("partita", "zaino", inventory)
	return config.save(SAVE_PATH) == OK


## Luogo e data dell'ultimo salvataggio, per il titolo. Vuoto se non c'è.
func save_info() -> Dictionary:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return {}
	var scene: String = config.get_value("partita", "scena", "")
	return {
		"luogo": PLACE_NAMES.get(scene, "?"),
		"data": config.get_value("partita", "data", ""),
	}


## Riprende la partita salvata.
func continue_game() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	# duplicate(): copie nuove, così modificarle non tocca i dati appena letti.
	flags = config.get_value("partita", "ricordi", {}).duplicate(true)
	inventory = config.get_value("partita", "zaino", {}).duplicate(true)
	spawn_position = config.get_value("partita", "posizione", null)
	var scene: String = config.get_value("partita", "scena", FIRST_LEVEL)
	change_scene(scene, "", config.get_value("partita", "direzione", "down"), false)


## Passa a un'altra scena con la dissolvenza, e fa comparire il giocatore in "spawn".
func change_scene(path: String, spawn: String, facing := "", door_sound := true) -> void:
	if changing_scene:
		return
	changing_scene = true
	spawn_point = spawn
	spawn_facing = facing
	if door_sound:
		_door_sound.play()
	await Fade.fade_out()
	get_tree().paused = false
	get_tree().change_scene_to_file(path)
	# La nuova scena viene aggiunta alla fine del frame: aspettiamo che sia pronta.
	await get_tree().process_frame
	await get_tree().process_frame
	changing_scene = false
	await Fade.fade_in()


# ---------- Opzioni ----------

func set_volume(value: float) -> void:
	volume = clampf(value, 0.0, 1.0)
	_apply_settings()
	save_settings()


func set_fullscreen(on: bool) -> void:
	fullscreen = on
	_apply_settings()
	save_settings()


func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		volume = config.get_value("audio", "volume", volume)
		fullscreen = config.get_value("video", "fullscreen", fullscreen)
	_apply_settings()


func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "volume", volume)
	config.set_value("video", "fullscreen", fullscreen)
	config.save(SETTINGS_PATH)


func _apply_settings() -> void:
	# Il volume si imposta sul bus "Master", cioè su tutti i suoni del gioco.
	# Gli altoparlanti ragionano in decibel: linear_to_db converte da 0..1.
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(volume, 0.0001)))
	AudioServer.set_bus_mute(0, volume <= 0.0)
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	if DisplayServer.window_get_mode() != mode:
		DisplayServer.window_set_mode(mode)
