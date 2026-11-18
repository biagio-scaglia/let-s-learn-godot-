# Test dell'enigma del bosco: gli occhi di pietra, la nebbia e gli obiettivi.
extends GdUnitTestSuite


func before_test() -> void:
	_clean_state()


func after_test() -> void:
	for i in 10:
		if Dialogue.is_active:
			await Dialogue._close()
	_clean_state()


func _clean_state() -> void:
	Game.load_flags({FlagKeys.INTRO_SEEN: true, FlagKeys.ACT2_DONE: true, FlagKeys.FOREST_ARRIVED: true})
	Inventory.reset()
	Stats.reset()
	Game.spawn_point = ""
	Game.spawn_position = null
	Game.in_cutscene = false


func _forest() -> GdUnitSceneRunner:
	var runner := scene_runner(Game.FOREST_SCENE)
	await runner.simulate_frames(3)
	return runner


## Va avanti con i dialoghi (e le attese della regia) finché succede "done".
func _play_until(runner: GdUnitSceneRunner, done: Callable) -> void:
	for i in 80:
		if done.call():
			return
		await runner.simulate_frames(3, 30)
		if Dialogue.is_active:
			await Dialogue._close()
