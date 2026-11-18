# Test del boss: Colui che guarda, lo Sguardo, il ricordo che sopravvive alla morte,
# le fasi e l'ultimate di Subaru ed Emilia.
extends GdUnitTestSuite

const BOSS := preload("res://enemies/colui_che_guarda.tres")

var result := ""
var _message_time := 0.0
var _transition_time := 0.0


func before_test() -> void:
	_clean_state()
	_message_time = Battle.message_time
	Battle.message_time = 0.02
	_transition_time = Battle.transition_time
	Battle.transition_time = 0.05
	Battle.rng.seed = 7
	Battle.finished.connect(_on_finished)


func after_test() -> void:
	Battle.finished.disconnect(_on_finished)
	Battle.message_time = _message_time
	Battle.transition_time = _transition_time
	_clean_state()


func _on_finished(battle_result: String) -> void:
	result = battle_result


func _clean_state() -> void:
	ReturnByDeath.is_active = false
	ReturnByDeath._reset()
	Game.load_flags({FlagKeys.FOREST_ARRIVED: true})   # Emilia nel party
	Game.memories = {}
	Game.in_cutscene = false
	Game.checkpoint = {}
	Inventory.reset()
	Stats.reset()
	Stats.gain_xp(100)   # livello 5, come arrivando al boss
	result = ""


func _wait_turn() -> void:
	for i in 400:
		if Battle.commands.menu.visible or not Battle.is_active:
			return
		await await_millis(20)


## Fa finire un turno (di Subaru o di Emilia) difendendosi, senza toccare il boss.
func _pass_turn() -> void:
	Battle.commands.defend_button.pressed.emit()
	await await_millis(60)
	await _wait_turn()


func _finish_with_ultimate() -> void:
	Battle.enemy_hp = 1
	Battle.behavior.phase = 3
	await _wait_turn()
	Battle.commands.ultimate_button.pressed.emit()
	for i in 400:
		if not Battle.is_active:
			return
		await await_millis(20)


func test_il_boss_e_fatto_bene() -> void:
	assert_bool(BOSS.behavior != null).is_true()
	assert_bool(BOSS.music != null).is_true()
	assert_float(BOSS.battle_scale).is_greater(1.5)
	assert_bool(BOSS.weaknesses.has("ombra")).is_true()
	assert_int(BOSS.texture.get_width()).is_equal(96 * BOSS.frames)


func test_da_colui_che_guarda_non_si_scappa() -> void:
	Battle.start(BOSS)
	await _wait_turn()
	var hp := Battle.enemy_hp
	Battle.flee_chance = 1.0
	Battle.commands.flee_button.pressed.emit()
	await await_millis(60)
	await _wait_turn()
	assert_bool(Battle.is_active).is_true()
	assert_int(Battle.enemy_hp).is_equal(hp)
	Battle.flee_chance = 0.5
	await _finish_with_ultimate()


func test_lo_sguardo_si_carica_e_poi_colpisce_forte() -> void:
	Battle.start(BOSS)
	await _wait_turn()
	# Turno 1: attacco normale. Turno 2: carica.
	await _pass_turn()
	await _pass_turn()
	await _pass_turn()
	await _pass_turn()
	assert_bool((Battle.behavior as WatcherBehavior).charging).is_true()
	assert_int(Battle.enemy_sprite.frame).is_equal(EnemyData.Pose.WINDUP)
	# Al turno dopo parte lo Sguardo: con la difesa toglie metà del 70%.
	var hp := Stats.hp
	await _pass_turn()
	await _pass_turn()
	assert_bool((Battle.behavior as WatcherBehavior).charging).is_false()
	var expected := ceili(ceili(Stats.max_hp * WatcherBehavior.GAZE_RATIO) / 2.0)
	assert_int(hp - Stats.hp).is_equal(expected)
	await _finish_with_ultimate()


func test_lo_shamac_mentre_carica_lo_acceca() -> void:
	Battle.start(BOSS)
	await _wait_turn()
	var watcher := Battle.behavior as WatcherBehavior
	watcher.charging = true
	Battle.commands.shamac_button.pressed.emit()
	await await_millis(60)
	await _wait_turn()
	assert_bool(watcher.charging).is_false()
	assert_bool(Battle.enemy_broken).is_true()
	assert_bool(Battle.revealed.has("ombra")).is_true()
	# Subaru non lo dimenticherà più.
	assert_bool(Game.remembers(WatcherBehavior.MEMORY_GAZE)).is_true()
	await _finish_with_ultimate()
