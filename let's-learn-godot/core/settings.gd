extends Node
## Le opzioni del gioco, salvate su file. È un autoload chiamato "Settings".

const PATH := "user://impostazioni.cfg"

## Volume da 0 a 1.
var volume := 0.8
var fullscreen := false


func _ready() -> void:
	var config := ConfigFile.new()
	if config.load(PATH) == OK:
		volume = config.get_value("audio", "volume", volume)
		fullscreen = config.get_value("video", "fullscreen", fullscreen)
	_apply()


func set_volume(value: float) -> void:
	volume = clampf(value, 0.0, 1.0)
	_apply()
	_save()


func set_fullscreen(on: bool) -> void:
	fullscreen = on
	_apply()
	_save()


func _save() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "volume", volume)
	config.set_value("video", "fullscreen", fullscreen)
	config.save(PATH)


func _apply() -> void:
	# Il volume si imposta sul bus "Master", cioè su tutti i suoni del gioco.
	# Gli altoparlanti ragionano in decibel: linear_to_db converte da 0..1.
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(volume, 0.0001)))
	AudioServer.set_bus_mute(0, volume <= 0.0)
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	if DisplayServer.window_get_mode() != mode:
		DisplayServer.window_set_mode(mode)
