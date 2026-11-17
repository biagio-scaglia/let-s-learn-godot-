# Test di scena: la biblioteca. Le porte portano dove devono e i dialoghi partono.
extends GdUnitTestSuite

var runner: GdUnitSceneRunner


func before_test() -> void:
	_clean_state()
	runner = scene_runner("res://world/library.tscn")
	await runner.simulate_frames(5)


func after_test() -> void:
	_clean_state()


func _clean_state() -> void:
	Game.flags.clear()
	Game.spawn_point = ""
	Game.spawn_position = null
	Game.in_cutscene = false


func test_l_uscita_porta_alla_porta_della_biblioteca() -> void:
	var exit := runner.scene().get_node("World/Exit")
	assert_str(exit.target_scene).is_equal("res://world/main.tscn")
	# Il punto d'arrivo deve esistere davvero nel villaggio.
	var village := (load("res://world/main.tscn") as PackedScene).instantiate()
	assert_object(village.get_node_or_null("Spawns/" + exit.target_spawn)).is_not_null()
	# E la porta del villaggio riporta qui, all'ingresso.
	var door := village.get_node("World/LibraryDoor")
	assert_str(door.target_scene).is_equal("res://world/library.tscn")
	assert_object(runner.scene().get_node_or_null("Spawns/" + door.target_spawn)).is_not_null()
	village.free()
