# Test di scena: la cutscene d'apertura parte solo quando deve.
extends GdUnitTestSuite


func before_test() -> void:
	_clean_state()


func after_test() -> void:
	_clean_state()


func _clean_state() -> void:
	Game.flags.clear()
	Game.spawn_point = ""
	Game.spawn_position = null
	Game.in_cutscene = false


func test_alla_prima_partita_parte() -> void:
	var runner := scene_runner("res://world/main.tscn")
	await runner.simulate_frames(2)
	assert_bool(Game.in_cutscene).is_true()
	assert_bool(Game.player_can_move()).is_false()
	assert_object(runner.scene().get_node_or_null("Intro")).is_not_null()


func test_gia_vista_non_riparte() -> void:
	Game.set_flag(FlagKeys.INTRO_SEEN)
	var runner := scene_runner("res://world/main.tscn")
	await runner.simulate_frames(2)
	assert_bool(Game.in_cutscene).is_false()
	assert_object(runner.scene().get_node_or_null("Intro")).is_null()


func test_arrivando_da_una_porta_non_parte() -> void:
	Game.spawn_point = "HouseDoor"
	var runner := scene_runner("res://world/main.tscn")
	await runner.simulate_frames(2)
	assert_bool(Game.in_cutscene).is_false()
	# E Subaru compare davanti alla porta.
	var player := runner.scene().get_node("World/Subaru") as Node2D
	var door := runner.scene().get_node("Spawns/HouseDoor") as Node2D
	assert_vector(player.global_position).is_equal(door.global_position)
