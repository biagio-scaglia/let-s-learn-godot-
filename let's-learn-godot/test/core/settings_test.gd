# Test delle opzioni. Usa un file suo, e rimette il volume com'era.
extends GdUnitTestSuite

const TEST_PATH := "user://test_impostazioni.cfg"

var _real_path: String
var _real_volume: float


func before_test() -> void:
	_real_path = Settings.path
	_real_volume = Settings.volume
	Settings.path = TEST_PATH


func after_test() -> void:
	Settings.path = _real_path
	Settings.volume = _real_volume
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
