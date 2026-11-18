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


func test_il_ricordo_sopravvive_al_ritorno_dalla_morte() -> void:
	Game.remember(WatcherBehavior.MEMORY_GAZE)
	Game.set_flag(FlagKeys.BOOK_READ)
	Game.checkpoint = {"scene": Game.FIRST_LEVEL, "position": Vector2.ZERO, "facing": Facing.DOWN,
		"flags": {}, "inventory": {}, "stats": Stats.to_dict()}
	# Il mondo torna indietro: i ricordi del mondo spariscono, quelli di Subaru no.
	Game.load_flags(Game.checkpoint.flags)
	assert_bool(Game.has_flag(FlagKeys.BOOK_READ)).is_false()
	assert_bool(Game.remembers(WatcherBehavior.MEMORY_GAZE)).is_true()


func test_ricordandolo_la_debolezza_e_gia_scoperta() -> void:
	Game.remember(WatcherBehavior.MEMORY_GAZE)
	Battle.start(BOSS)
	await _wait_turn()
	assert_bool(Battle.revealed.has("ombra")).is_true()
	await _finish_with_ultimate()


func test_l_occhio_aperto_schiva_parte_dei_colpi() -> void:
	Battle.start(BOSS)
	await _wait_turn()
	var watcher := Battle.behavior as WatcherBehavior
	assert_int(watcher.modify_damage({}, 10)).is_equal(7)
	Battle.enemy_broken = true
	assert_int(watcher.modify_damage({}, 10)).is_equal(10)
	Battle.enemy_broken = false
	await _finish_with_ultimate()


func test_sotto_un_quarto_arriva_l_ultimate_e_vince() -> void:
	Battle.start(BOSS)
	await _wait_turn()
	assert_bool(Battle.commands.ultimate_button.visible).is_false()
	# Un colpo che lo porta sotto il 25%: al prossimo turno di Subaru c'è l'ultimate.
	Battle.enemy_hp = ceili(BOSS.max_hp * 0.25) + 1
	Battle.behavior.on_hit({"type": "pugno"})   # niente: ancora sopra il 25%
	Battle.enemy_hp = int(BOSS.max_hp * 0.2)
	Battle.behavior.on_hit({"type": "pugno"})
	Battle.behavior.on_hit({"type": "pugno"})
	assert_int((Battle.behavior as WatcherBehavior).phase).is_equal(3)
	await _pass_turn()
	await _pass_turn()
	assert_bool(Battle.commands.ultimate_button.visible).is_true()
	Battle.commands.ultimate_button.pressed.emit()
	for i in 400:
		if not Battle.is_active:
			break
		await await_millis(20)
	assert_str(result).is_equal(Battle.WIN)


func test_la_radura_dopo_la_vittoria() -> void:
	Game.set_flag(FlagKeys.BOSS_DEFEATED)
	for id in FlagKeys.STONE_EYES:
		Game.set_flag(FlagKeys.eye_closed(id))
	var runner := scene_runner(Game.FOREST_SCENE)
	await runner.simulate_frames(3)
	# Colui che guarda non c'è più, e nemmeno gli occhi nei rovi.
	assert_object(runner.scene().get_node_or_null("Watcher")).is_null()
	assert_int(runner.scene().get_tree().get_nodes_in_group("thicket_eyes").size()).is_equal(0)
	assert_str(Objective.current()).is_equal(Objective.BACK_HOME)


func test_prima_della_battaglia_il_guardiano_dorme_nella_radura() -> void:
	for id in FlagKeys.STONE_EYES:
		Game.set_flag(FlagKeys.eye_closed(id))
	var runner := scene_runner(Game.FOREST_SCENE)
	await runner.simulate_frames(3)
	var watcher := runner.scene().get_node_or_null("Watcher")
	assert_object(watcher).is_not_null()
	assert_int((watcher.get_node("Eye") as Sprite2D).frame).is_equal(EnemyData.Pose.HURT)
