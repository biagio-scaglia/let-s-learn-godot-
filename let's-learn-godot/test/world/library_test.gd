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


func test_l_archivista_parla() -> void:
	var archivista := runner.scene().get_node("World/Archivista") as Node2D
	var player := runner.scene().get_node("World/Subaru") as Node2D
	player.global_position = archivista.global_position + Vector2(0, 20)
	await await_millis(150)
	runner.simulate_action_pressed("interact")
	await await_millis(100)
	assert_bool(Dialogue.is_active).is_true()
	for i in 20:
		if not Dialogue.is_active:
			break
		runner.simulate_action_pressed("interact")
		await await_millis(150)
	var memory := FlagKeys.talked(archivista.get_node("Interactable"))
	assert_int(Game.flags.get(memory, 0)).is_equal(1)


func test_le_luci_delle_fiamme_tremolano() -> void:
	# Ogni fiamma deve usare flicker.gd, se no resta una luce ferma.
	var flames := runner.scene().get_node("Flames").get_children()
	assert_int(flames.size()).is_greater(3)
	for light in flames:
		assert_object(light.get_script()).is_equal(load("res://effects/flicker.gd"))
