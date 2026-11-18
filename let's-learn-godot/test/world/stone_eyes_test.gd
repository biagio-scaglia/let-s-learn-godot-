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


func test_chiudere_un_occhio_insegna_la_combinata() -> void:
	var runner := await _forest()
	var eye := runner.scene().get_node("World/StoneEyeOvest") as StoneEye
	eye.interactable.interacted.emit()
	await _play_until(runner, func(): return Game.has_flag(FlagKeys.COMBO_UNLOCKED) and not Game.in_cutscene)
	assert_bool(Game.has_flag(FlagKeys.eye_closed("ovest"))).is_true()
	assert_bool(Game.has_flag(FlagKeys.COMBO_UNLOCKED)).is_true()
	assert_bool(eye.is_closed).is_true()
	assert_str(Objective.current()).is_equal(Objective.CLOSE_EYES % 1)
	# Il bagliore corrispondente nella nebbia si è spento.
	var gate := runner.scene().get_node("World/FogGate")
	assert_bool(gate.get_node("EyeOvest").visible).is_false()


func test_l_occhio_chiuso_resta_chiuso() -> void:
	Game.set_flag(FlagKeys.eye_closed("est"))
	var runner := await _forest()
	var eye := runner.scene().get_node("World/StoneEyeEst") as StoneEye
	assert_bool(eye.is_closed).is_true()
	assert_bool(eye.gaze.visible).is_false()
	assert_bool(runner.scene().get_node("World/FogGate/EyeEst").visible).is_false()


func test_con_tre_occhi_chiusi_la_nebbia_si_apre() -> void:
	Game.set_flag(FlagKeys.COMBO_UNLOCKED)
	Game.set_flag(FlagKeys.eye_closed("ovest"))
	Game.set_flag(FlagKeys.eye_closed("est"))
	var runner := await _forest()
	var gate := runner.scene().get_node("World/FogGate")
	runner.scene().get_node("World/StoneEyeSud").interactable.interacted.emit()
	await _play_until(runner, func(): return not is_instance_valid(gate) and not Game.in_cutscene)
	assert_bool(is_instance_valid(gate)).is_false()
	assert_str(Objective.current()).is_equal(Objective.ENTER_CLEARING)


func test_tornando_a_nebbia_aperta_non_c_e_piu() -> void:
	for id in FlagKeys.STONE_EYES:
		Game.set_flag(FlagKeys.eye_closed(id))
	var runner := await _forest()
	assert_object(runner.scene().get_node_or_null("World/FogGate")).is_null()


func test_se_l_occhio_ti_vede_torni_indietro() -> void:
	Stats.hp = Stats.max_hp
	var runner := await _forest()
	var eye := runner.scene().get_node("World/StoneEyeSud") as StoneEye
	var subaru := runner.scene().get_node("World/Subaru") as Node2D
	eye._sweep_tween.kill()
	eye.gaze.rotation_degrees = 0.0
	subaru.global_position = eye.gaze.global_position + Vector2(90, 16)
	await _play_until(runner, func(): return Game.has_flag(FlagKeys.EYE_SEEN) and not Game.in_cutscene)
	assert_vector(subaru.global_position).is_equal(eye.respawn)
	assert_int(Stats.hp).is_equal(Stats.max_hp - eye.sight_damage)


func test_gli_obiettivi_del_bosco() -> void:
	assert_str(Objective.current()).is_equal(Objective.CROSS_FOREST)
	Game.set_flag(FlagKeys.FOG_SEEN)
	assert_str(Objective.current()).is_equal(Objective.CLOSE_EYES % 0)
	Game.set_flag(FlagKeys.eye_closed("sud"))
	assert_str(Objective.current()).is_equal(Objective.CLOSE_EYES % 1)
