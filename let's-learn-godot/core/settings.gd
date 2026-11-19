extends Node
## Le opzioni del gioco, salvate su file. È un autoload chiamato "Settings".

## Emesso quando cambia una qualunque opzione (chi mostra i valori si aggiorna).
signal changed

## Le lingue del gioco: il codice per TranslationServer e il nome da mostrare
## (scritto nella sua lingua, così lo riconosce anche chi non capisce l'altra).
const LANGUAGES := {"en": "English", "it": "Italiano"}
## Velocità del testo dei dialoghi: caratteri al secondo (0 = tutto subito).
const TEXT_SPEEDS := [25.0, 40.0, 70.0, 0.0]
const TEXT_SPEED_NAMES := ["Lenta", "Normale", "Veloce", "Istantanea"]

## Dove sta il file. Una variabile, così i test possono usarne un altro.
var path := "user://impostazioni.cfg"

## Volume da 0 a 1.
var volume := 0.8
var fullscreen := false
## La lingua: inglese se il giocatore non ha mai scelto.
var language := "en"
## Indice in TEXT_SPEEDS.
var text_speed := 1
## Accessibilità: lo schermo trema nei colpi forti?
var screen_shake := true
## Accessibilità: lampi a tutto schermo attenuati (per chi è sensibile alla luce).
var reduce_flashes := false


func _ready() -> void:
	var config := ConfigFile.new()
	if config.load(path) == OK:
		volume = config.get_value("audio", "volume", volume)
		fullscreen = config.get_value("video", "fullscreen", fullscreen)
		language = config.get_value("game", "language", language)
		text_speed = config.get_value("game", "text_speed", text_speed)
		screen_shake = config.get_value("accessibility", "screen_shake", screen_shake)
		reduce_flashes = config.get_value("accessibility", "reduce_flashes", reduce_flashes)
	if not LANGUAGES.has(language):
		language = "en"
	text_speed = clampi(text_speed, 0, TEXT_SPEEDS.size() - 1)
	_apply()


func set_volume(value: float) -> void:
	volume = clampf(value, 0.0, 1.0)
	_apply()
	_save()


func set_fullscreen(on: bool) -> void:
	fullscreen = on
	_apply()
	_save()


## Cambia lingua: tutte le Label con un testo traducibile si aggiornano da sole.
func set_language(code: String) -> void:
	if not LANGUAGES.has(code):
		return
	language = code
	_apply()
	_save()


func set_text_speed(index: int) -> void:
	text_speed = clampi(index, 0, TEXT_SPEEDS.size() - 1)
	_save()
	changed.emit()


func set_screen_shake(on: bool) -> void:
	screen_shake = on
	_save()
	changed.emit()


func set_reduce_flashes(on: bool) -> void:
	reduce_flashes = on
	_save()
	changed.emit()


## Caratteri al secondo per i dialoghi (0 = la frase compare tutta insieme).
func chars_per_second() -> float:
	return TEXT_SPEEDS[text_speed]


## Quanto forte tremano le cose: 0 se lo scuotimento è spento.
func shake_amount() -> float:
	return 1.0 if screen_shake else 0.0


## Quanto si vedono i lampi a tutto schermo (si moltiplica per la loro trasparenza).
func flash_amount() -> float:
	return 0.3 if reduce_flashes else 1.0


func _save() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "volume", volume)
	config.set_value("video", "fullscreen", fullscreen)
	config.set_value("game", "language", language)
	config.set_value("game", "text_speed", text_speed)
	config.set_value("accessibility", "screen_shake", screen_shake)
	config.set_value("accessibility", "reduce_flashes", reduce_flashes)
	config.save(path)


func _apply() -> void:
	# Il volume si imposta sul bus "Master", cioè su tutti i suoni del gioco.
	# Gli altoparlanti ragionano in decibel: linear_to_db converte da 0..1.
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(volume, 0.0001)))
	AudioServer.set_bus_mute(0, volume <= 0.0)
	# La lingua: i testi sono scritti in italiano, locale/en.po ha l'inglese.
	# In italiano non c'è una traduzione da caricare: si vede il testo originale.
	TranslationServer.set_locale(language)
	# Sul web (itch.io, Game Jolt) è il browser a decidere lo schermo intero.
	if OS.has_feature("web"):
		changed.emit()
		return
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	if DisplayServer.window_get_mode() != mode:
		DisplayServer.window_set_mode(mode)
	changed.emit()
