# Test della Galleria e dei suoi libri, e dei titoli di coda che la sbloccano.
extends GdUnitTestSuite

const TEST_PROGRESS := "user://test_progressi_galleria.cfg"

var _real_progress: String


func before_test() -> void:
	_real_progress = Progress.path
	Progress.path = TEST_PROGRESS
	Progress.load_progress()
	Game.load_flags({FlagKeys.INTRO_SEEN: true})
	Game.in_cutscene = false


func after_test() -> void:
	Game.in_cutscene = false
	if FileAccess.file_exists(TEST_PROGRESS):
		DirAccess.remove_absolute(TEST_PROGRESS)
	Progress.path = _real_progress
	Progress.load_progress()
