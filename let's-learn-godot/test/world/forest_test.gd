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


func test_emilia_segue_subaru() -> void:
	Game.set_flag(FlagKeys.FOREST_ARRIVED)
	var runner := scene_runner(Game.FOREST_SCENE)
	await runner.simulate_frames(3)
	var subaru := runner.scene().get_node("World/Subaru") as Node2D
	var emilia := runner.scene().get_node("World/Emilia") as Node2D
	# All'arrivo (senza cutscene) si mette subito dietro di lui.
	assert_float(emilia.global_position.distance_to(subaru.global_position)).is_less(40.0)
	# Subaru va verso nord: lei lo segue, restando un po' indietro.
	subaru.set("_scripted", true)
	await subaru.walk_to(subaru.global_position + Vector2(0, -160), 200.0)
	await runner.simulate_frames(40)
	var gap := emilia.global_position.distance_to(subaru.global_position)
	assert_float(gap).is_between(10.0, 60.0)
	# E non fa da muro: il giocatore non ci sbatte contro.
	assert_int(emilia.collision_layer).is_equal(0)


func test_la_nebbia_sbarra_la_radura() -> void:
	Game.set_flag(FlagKeys.FOREST_ARRIVED)
	var runner := scene_runner(Game.FOREST_SCENE)
	await runner.simulate_frames(2)
	var gate := runner.scene().get_node("World/FogGate") as StaticBody2D
	var shape := gate.get_node("CollisionShape2D") as CollisionShape2D
	assert_object(shape.shape).is_not_null()
	assert_bool(shape.disabled).is_false()
	# Il varco copre tutta l'apertura nei rovi: niente spazio per passarci accanto.
	assert_float((shape.shape as RectangleShape2D).size.x).is_greater_equal(256.0)
