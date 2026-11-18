# Test di scena: il Bosco Senza Tempo (atto 3). L'arrivo, Emilia che segue, la nebbia.
extends GdUnitTestSuite


func before_test() -> void:
	_clean_state()


func after_test() -> void:
	if Dialogue.is_active:
		await Dialogue._close()
	_clean_state()


func _clean_state() -> void:
	Game.load_flags({FlagKeys.INTRO_SEEN: true, FlagKeys.ACT2_DONE: true})
	Inventory.reset()
	Game.spawn_point = ""
	Game.spawn_position = null
	Game.in_cutscene = false
