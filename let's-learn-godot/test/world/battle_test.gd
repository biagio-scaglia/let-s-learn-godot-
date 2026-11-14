# Test del combattimento a turni. I nemici sono EnemyData fatti apposta, e i messaggi
# durano pochissimo: così ogni test finisce in fretta.
extends GdUnitTestSuite

var result := ""
var _message_time := 0.0
var _gauge_time := 0.0


func before_test() -> void:
	_clean_state()
	_message_time = Battle.message_time
	Battle.message_time = 0.02
	_gauge_time = Battle.gauge_time
	Battle.gauge_time = 0.02
	Battle.rng.seed = 1234   # stessi tiri a ogni esecuzione
	result = ""
	Battle.finished.connect(_on_finished)


func after_test() -> void:
	Battle.finished.disconnect(_on_finished)
	Battle.message_time = _message_time
	Battle.gauge_time = _gauge_time
	Battle.flee_chance = 0.5
	_clean_state()


func _on_finished(battle_result: String) -> void:
	result = battle_result


func _clean_state() -> void:
	ReturnByDeath.is_active = false
	ReturnByDeath._reset()
	Game.flags.clear()
	Game.spawn_point = ""
	Game.spawn_position = null
	Game.in_cutscene = false
	Game.deaths = 0
	Game.checkpoint = {}
	Inventory.reset()
	Stats.reset()


func _enemy(hp: int, attack: int, defense := 0, xp := 4) -> EnemyData:
	var data := EnemyData.new()
	data.name = "Fantoccio"
	data.max_hp = hp
	data.attack = attack
	data.defense = defense
	data.xp = xp
	return data


## Aspetta che tocchi a Subaru (il menu compare) o che il combattimento finisca.
func _wait_turn() -> void:
	for i in 200:
		if Battle.menu.visible or not Battle.is_active:
			return
		await await_millis(20)


func test_durante_il_combattimento_non_ci_si_muove() -> void:
	Battle.start(_enemy(50, 1))
	await _wait_turn()
	assert_bool(Battle.is_active).is_true()
	assert_bool(Game.player_can_move()).is_false()
	assert_int(Battle.enemy_hp).is_equal(50)
	Battle.flee_chance = 1.0
	Battle.flee_button.pressed.emit()
	await _wait_turn()


func test_un_pugno_toglie_salute_al_nemico_che_poi_risponde() -> void:
	Battle.start(_enemy(50, 4))
	await _wait_turn()
	Battle.attack_button.pressed.emit()
	await _wait_turn()
	# Attacco 5 contro difesa 0, con un tiro da -1 a +1: da 4 a 6 danni.
	assert_int(Battle.enemy_hp).is_between(44, 46)
	# Attacco 4 contro difesa 2: da 1 a 3 danni.
	assert_int(Stats.hp).is_between(17, 19)
	assert_bool(Battle.is_active).is_true()
	Battle.flee_chance = 1.0
	Battle.flee_button.pressed.emit()
	await _wait_turn()


func test_vincere_da_esperienza_e_livello() -> void:
	Battle.start(_enemy(3, 1, 0, 10))
	await _wait_turn()
	Battle.attack_button.pressed.emit()
	await _wait_turn()
	assert_str(result).is_equal(Battle.WIN)
	assert_bool(Battle.is_active).is_false()
	assert_int(Stats.level).is_equal(2)
	assert_bool(Game.player_can_move()).is_true()
	assert_bool(ReturnByDeath.is_active).is_false()


func test_perdere_e_morire() -> void:
	Battle.start(_enemy(50, 99))
	await _wait_turn()
	Battle.attack_button.pressed.emit()
	await _wait_turn()
	assert_str(result).is_equal(Battle.LOSE)
	assert_int(Stats.hp).is_equal(0)
	assert_bool(ReturnByDeath.is_active).is_true()
	assert_int(Game.deaths).is_equal(1)


func test_la_pozione_cura_e_costa_il_turno() -> void:
	Stats.take_damage(10)
	Inventory.add(Inventory.POTION)
	Battle.start(_enemy(50, 4))
	await _wait_turn()
	Battle.potion_button.pressed.emit()
	await _wait_turn()
	assert_bool(Inventory.has(Inventory.POTION)).is_false()
	# 10 + 10 curati (il massimo è 20), poi il nemico risponde con 1-3 danni.
	assert_int(Stats.hp).is_between(17, 19)
	assert_int(Battle.enemy_hp).is_equal(50)
	Battle.flee_chance = 1.0
	Battle.flee_button.pressed.emit()
	await _wait_turn()


func test_senza_pozioni_il_turno_resta_tuo() -> void:
	Stats.take_damage(5)
	Battle.start(_enemy(50, 4))
	await _wait_turn()
	Battle.potion_button.pressed.emit()
	await _wait_turn()
	assert_int(Stats.hp).is_equal(15)   # il nemico non ha attaccato
	Battle.flee_chance = 1.0
	Battle.flee_button.pressed.emit()
	await _wait_turn()


func test_in_piena_forma_la_pozione_non_si_spreca() -> void:
	Inventory.add(Inventory.POTION)
	Battle.start(_enemy(50, 4))
	await _wait_turn()
	Battle.potion_button.pressed.emit()
	await _wait_turn()
	assert_bool(Inventory.has(Inventory.POTION)).is_true()
	assert_int(Stats.hp).is_equal(20)
	Battle.flee_chance = 1.0
	Battle.flee_button.pressed.emit()
	await _wait_turn()


func test_fuggire_riuscendoci() -> void:
	Battle.flee_chance = 1.0
	Battle.start(_enemy(50, 4))
	await _wait_turn()
	Battle.flee_button.pressed.emit()
	await _wait_turn()
	assert_str(result).is_equal(Battle.FLED)
	assert_int(Stats.hp).is_equal(20)
	assert_bool(Game.player_can_move()).is_true()


func test_fuggire_senza_riuscirci_costa_il_turno() -> void:
	Battle.flee_chance = 0.0
	Battle.start(_enemy(50, 4))
	await _wait_turn()
	Battle.flee_button.pressed.emit()
	await _wait_turn()
	assert_bool(Battle.is_active).is_true()
	assert_int(Stats.hp).is_between(17, 19)
	Battle.flee_chance = 1.0
	Battle.flee_button.pressed.emit()
	await _wait_turn()


func test_la_melma_sulla_mappa_si_affronta_e_sparisce() -> void:
	Game.set_flag(FlagKeys.INTRO_SEEN)
	var runner := scene_runner("res://world/main.tscn")
	await runner.simulate_frames(2)
	var player := runner.scene().get_node("World/Subaru") as Node2D
	var melma := runner.scene().get_node("World/Melma") as Node2D
	var memory := FlagKeys.defeated(melma)
	player.global_position = melma.global_position + Vector2(0, 18)
	await await_millis(150)   # il tempo di entrare nell'area dell'Interactable
	runner.simulate_action_pressed("interact")
	await await_millis(100)
	await _wait_turn()
	assert_bool(Battle.is_active).is_true()
	assert_str(Battle.enemy.name).is_equal("Melma verde")

	Battle.enemy_hp = 1   # per non dipendere dai tiri
	Battle.attack_button.pressed.emit()
	await _wait_turn()
	assert_str(result).is_equal(Battle.WIN)
	assert_bool(Game.has_flag(memory)).is_true()
	await await_millis(700)   # il tempo di svanire
	assert_bool(is_instance_valid(melma)).is_false()


func test_oggetti_apre_il_sottomenu_ed_esc_torna_indietro() -> void:
	Inventory.add(Inventory.POTION, 2)
	Battle.start(_enemy(50, 4))
	await _wait_turn()
	Battle.items_button.pressed.emit()
	assert_bool(Battle.item_window.visible).is_true()
	assert_str(Battle.potion_button.text).contains("x2")
	var cancel := InputEventAction.new()
	cancel.action = "ui_cancel"
	cancel.pressed = true
	Battle._unhandled_input(cancel)
	assert_bool(Battle.item_window.visible).is_false()
	assert_bool(Battle.menu.visible).is_true()   # il turno è ancora tuo
	Battle.flee_chance = 1.0
	Battle.flee_button.pressed.emit()
	await _wait_turn()


func test_con_poca_salute_subaru_e_in_ginocchio() -> void:
	Stats.take_damage(16)   # 4 PS su 20
	Battle.start(_enemy(50, 1))
	await _wait_turn()
	assert_str(Battle.hero.animation).is_equal("weak")
	Battle.flee_chance = 1.0
	Battle.flee_button.pressed.emit()
	await _wait_turn()
