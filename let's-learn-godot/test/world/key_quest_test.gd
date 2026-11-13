# Test di scena: la missione della chiave, nella casa di Lina, con i tasti simulati.
extends GdUnitTestSuite

var runner: GdUnitSceneRunner


func before_test() -> void:
	_clean_state()
	runner = scene_runner("res://world/house.tscn")
	await runner.simulate_frames(5)


func after_test() -> void:
	_clean_state()


func _clean_state() -> void:
	Game.flags.clear()
	Game.spawn_point = ""
	Game.spawn_position = null
	Game.in_cutscene = false
	Inventory.reset()


## Porta Subaru vicino a un nodo, preme E e va avanti finché il dialogo non si chiude.
func _talk_to(path: String) -> void:
	var target := runner.scene().get_node(path) as Node2D
	var player := runner.scene().get_node("World/Subaru") as Node2D
	player.global_position = target.global_position + Vector2(0, 20)
	await await_millis(150)   # il tempo di entrare nell'area dell'Interactable
	runner.simulate_action_pressed("interact")
	await await_millis(100)
	for i in 20:
		if not Dialogue.is_active:
			break
		runner.simulate_action_pressed("interact")
		await await_millis(150)
	await await_millis(200)


func test_senza_chiave_il_baule_resta_chiuso() -> void:
	await _talk_to("World/Chest")
	assert_bool(Game.has_flag(FlagKeys.CHEST_OPEN)).is_false()
	assert_dict(Inventory.items).is_empty()


func test_con_la_chiave_il_baule_si_apre() -> void:
	Inventory.add(Inventory.KEY)
	await _talk_to("World/Lina")
	await _talk_to("World/Chest")
	assert_bool(Game.has_flag(FlagKeys.CHEST_OPEN)).is_true()
	assert_bool(Inventory.has(Inventory.KEY)).is_false()
	assert_dict(Inventory.items).is_equal({Inventory.POTION: 2, Inventory.COIN: 5})


func test_parlare_con_lina_viene_ricordato() -> void:
	await _talk_to("World/Lina")
	var lina_memory := FlagKeys.talked(runner.scene().get_node("World/Lina/Interactable"))
	assert_int(Game.flags.get(lina_memory, 0)).is_equal(1)
