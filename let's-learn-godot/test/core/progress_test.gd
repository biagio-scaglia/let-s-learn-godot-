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


func test_all_inizio_la_galleria_e_chiusa() -> void:
	assert_bool(Progress.gallery_unlocked()).is_false()
	assert_bool(Progress.gallery_seen).is_false()


func test_finire_la_storia_apre_la_galleria_per_sempre() -> void:
	Progress.finish_story()
	assert_bool(Progress.gallery_unlocked()).is_true()
	# "Per sempre": rileggendo il file (come a un nuovo avvio) è ancora aperta.
	Progress.story_finished = false
	Progress.load_progress()
	assert_bool(Progress.gallery_unlocked()).is_true()


func test_una_partita_nuova_non_richiude_la_galleria() -> void:
	Progress.finish_story()
	Game.load_flags()   # come fa Game.new_game()
	assert_bool(Progress.gallery_unlocked()).is_true()
