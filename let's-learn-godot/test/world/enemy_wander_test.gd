# Test: i nemici sulla mappa gironzolano attorno a casa, senza attraversare i muri.
extends GdUnitTestSuite


func before_test() -> void:
	Game.load_flags({FlagKeys.INTRO_SEEN: true})
	Game.spawn_point = ""
	Game.spawn_position = null
	Game.in_cutscene = false


func after_test() -> void:
	before_test()


func test_un_passo_nel_vuoto_si_fa() -> void:
	var runner := scene_runner("res://world/main.tscn")
	await runner.simulate_frames(2)
	var melma := runner.scene().get_node("World/Melma")
	var start: Vector2 = melma.global_position
	assert_bool(melma.step_towards(start + Vector2(0, 30))).is_true()
	await runner.simulate_frames(90, 20)
	assert_float(melma.global_position.distance_to(start + Vector2(0, 30))).is_less(1.0)


func test_contro_un_muro_resta_fermo() -> void:
	var runner := scene_runner("res://world/main.tscn")
	await runner.simulate_frames(2)
	var melma := runner.scene().get_node("World/Melma")
	var start: Vector2 = melma.global_position
	# Il bordo invisibile della mappa è a destra, oltre x = 1216: un passo lì dentro non si fa.
	assert_bool(melma.step_towards(Vector2(1260, start.y))).is_false()
	assert_vector(melma.global_position).is_equal(start)


func test_gironzola_vicino_a_casa() -> void:
	var runner := scene_runner("res://world/main.tscn")
	await runner.simulate_frames(2)
	var melma := runner.scene().get_node("World/Melma")
	var home: Vector2 = melma.global_position
	for i in 6:
		melma._wander()
		await runner.simulate_frames(60, 20)
	assert_float(melma.global_position.distance_to(home)).is_less_equal(melma.wander_radius + 1.0)
