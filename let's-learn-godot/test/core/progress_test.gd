# Test di Progress: quello che resta sbloccato per sempre (la Galleria).
# Usa un file suo, come i test delle opzioni, e rimette tutto com'era.
extends GdUnitTestSuite

const TEST_PATH := "user://test_progressi.cfg"

var _real_path: String


func before_test() -> void:
	_real_path = Progress.path
	Progress.path = TEST_PATH
	_remove_file()
	Progress.load_progress()


func after_test() -> void:
	_remove_file()
	Progress.path = _real_path
	Progress.load_progress()


func _remove_file() -> void:
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)
