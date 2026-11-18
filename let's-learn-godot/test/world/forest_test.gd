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


func test_la_prima_volta_parte_l_arrivo() -> void:
	var runner := scene_runner(Game.FOREST_SCENE)
	await runner.simulate_frames(2)
	assert_bool(Game.in_cutscene).is_true()
	assert_object(runner.scene().get_node_or_null("ForestArrival")).is_not_null()


func test_gia_arrivati_niente_cutscene() -> void:
	Game.set_flag(FlagKeys.FOREST_ARRIVED)
	var runner := scene_runner(Game.FOREST_SCENE)
	await runner.simulate_frames(2)
	assert_bool(Game.in_cutscene).is_false()
	assert_object(runner.scene().get_node_or_null("ForestArrival")).is_null()
	assert_str(Objective.current()).is_equal(Objective.CROSS_FOREST)
