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


func test_l_occhio_vede_solo_davanti_a_se() -> void:
	var runner := await _forest()
	var eye := runner.scene().get_node("World/StoneEyeOvest") as StoneEye
	eye._sweep_tween.kill()
	eye.gaze.rotation_degrees = 0.0   # guarda a destra
	var origin := eye.gaze.global_position
	assert_bool(eye.sees(origin + Vector2(100, 0))).is_true()
	assert_bool(eye.sees(origin + Vector2(-100, 0))).is_false()   # alle spalle
	assert_bool(eye.sees(origin + Vector2(0, 100))).is_false()    # di lato
	assert_bool(eye.sees(origin + Vector2(400, 0))).is_false()    # troppo lontano


func test_chiudere_un_occhio_insegna_il_gelo() -> void:
	var runner := await _forest()
	var eye := runner.scene().get_node("World/StoneEyeOvest") as StoneEye
	eye.interactable.interacted.emit()
	await _play_until(runner, func(): return Game.has_flag(FlagKeys.ICE_UNLOCKED) and not Game.in_cutscene)
	assert_bool(Game.has_flag(FlagKeys.eye_closed("ovest"))).is_true()
	assert_bool(Game.has_flag(FlagKeys.ICE_UNLOCKED)).is_true()
	assert_bool(eye.is_closed).is_true()
	assert_str(Objective.current()).is_equal(Objective.CLOSE_EYES % 1)
	# Il bagliore corrispondente nella nebbia si è spento.
	var gate := runner.scene().get_node("World/FogGate")
	assert_bool(gate.get_node("EyeOvest").visible).is_false()
