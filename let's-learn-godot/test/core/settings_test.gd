# Test delle opzioni. Usa un file suo, e rimette il volume com'era.
extends GdUnitTestSuite

const TEST_PATH := "user://test_impostazioni.cfg"

var _real_path: String
var _real_volume: float
var _real_language: String
var _real_speed: int
var _real_shake: bool
var _real_flashes: bool


func before_test() -> void:
	_real_path = Settings.path
	_real_volume = Settings.volume
	_real_language = Settings.language
	_real_speed = Settings.text_speed
	_real_shake = Settings.screen_shake
	_real_flashes = Settings.reduce_flashes
	Settings.path = TEST_PATH


func after_test() -> void:
	Settings.path = _real_path
	Settings.volume = _real_volume
	Settings.language = _real_language
	TranslationServer.set_locale(_real_language)
	Settings.text_speed = _real_speed
	Settings.screen_shake = _real_shake
	Settings.reduce_flashes = _real_flashes
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(_real_volume, 0.0001)))
	AudioServer.set_bus_mute(0, _real_volume <= 0.0)
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)


func test_il_volume_viene_applicato_e_salvato() -> void:
	Settings.set_volume(0.5)
	assert_float(AudioServer.get_bus_volume_db(0)).is_equal_approx(linear_to_db(0.5), 0.01)
	var config := ConfigFile.new()
	assert_int(config.load(TEST_PATH)).is_equal(OK)
	assert_float(config.get_value("audio", "volume")).is_equal_approx(0.5, 0.001)


func test_il_volume_resta_tra_0_e_1() -> void:
	Settings.set_volume(3.0)
	assert_float(Settings.volume).is_equal(1.0)
	Settings.set_volume(-1.0)
	assert_float(Settings.volume).is_equal(0.0)
	assert_bool(AudioServer.is_bus_mute(0)).is_true()


func test_la_lingua_cambia_i_testi() -> void:
	Settings.set_language("en")
	assert_str(tr("Nuova partita")).is_equal("New game")
	assert_str(tr("%s appare!") % tr("Melma verde")).is_equal("Green Slime appears!")
	Settings.set_language("it")
	assert_str(tr("Nuova partita")).is_equal("Nuova partita")
	var config := ConfigFile.new()
	assert_int(config.load(TEST_PATH)).is_equal(OK)
	assert_str(config.get_value("game", "language")).is_equal("it")


func test_una_lingua_sconosciuta_non_cambia_niente() -> void:
	Settings.set_language("en")
	Settings.set_language("klingon")
	assert_str(Settings.language).is_equal("en")


func test_accessibilita() -> void:
	Settings.set_screen_shake(false)
	assert_float(Settings.shake_amount()).is_equal(0.0)
	Settings.set_reduce_flashes(true)
	assert_float(Settings.flash_amount()).is_less(1.0)
	Settings.set_text_speed(99)
	assert_int(Settings.text_speed).is_equal(Settings.TEXT_SPEEDS.size() - 1)
	assert_float(Settings.chars_per_second()).is_equal(0.0)   # istantanea


## Ogni frase di en.po ha la sua traduzione, e i segnaposto (%s, %d) coincidono:
## se no, "frase % valori" in inglese darebbe un errore.
func test_la_traduzione_inglese_e_completa() -> void:
	var po := FileAccess.get_file_as_string("res://locale/en.po")
	var ids := RegEx.create_from_string('msgid "(.*)"\\nmsgstr "(.*)"')
	var placeholders := RegEx.create_from_string("%[0-9]*[sd]")
	var count := 0
	for m in ids.search_all(po):
		if m.get_string(1).is_empty():
			continue   # l'intestazione
		count += 1
		assert_str(m.get_string(2)).is_not_empty()
		var it := placeholders.search_all(m.get_string(1)).map(func(x: RegExMatch) -> String: return x.get_string())
		var en := placeholders.search_all(m.get_string(2)).map(func(x: RegExMatch) -> String: return x.get_string())
		assert_array(en).override_failure_message("Segnaposto diversi: " + m.get_string(1)).is_equal(it)
	assert_int(count).is_greater(400)
