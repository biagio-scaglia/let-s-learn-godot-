# Test del finale: i saluti agli abitanti, l'obiettivo, e la partenza dal sentiero a sud.
extends GdUnitTestSuite

const TEST_PROGRESS := "user://test_progressi_finale.cfg"

var _real_progress: String


func before_test() -> void:
	_real_progress = Progress.path
	Progress.path = TEST_PROGRESS
	_clean_state()


func after_test() -> void:
	if Dialogue.is_active:
		await Dialogue._close()
	_clean_state()
	if FileAccess.file_exists(TEST_PROGRESS):
		DirAccess.remove_absolute(TEST_PROGRESS)
	Progress.path = _real_progress
	Progress.load_progress()


func _clean_state() -> void:
	Game.load_flags({FlagKeys.INTRO_SEEN: true, FlagKeys.SAGE_FORGETS: true, FlagKeys.ACT2_DONE: true,
		FlagKeys.FOREST_ARRIVED: true, FlagKeys.BOSS_DEFEATED: true})
	Inventory.reset()
	Game.spawn_point = ""
	Game.spawn_position = null
	Game.in_cutscene = false


func _greet_everyone() -> void:
	for who in FlagKeys.VILLAGERS:
		Game.set_flag(FlagKeys.greeted(who))


func _village() -> GdUnitSceneRunner:
	var runner := scene_runner(Game.FIRST_LEVEL)
	await runner.simulate_frames(3)
	return runner
