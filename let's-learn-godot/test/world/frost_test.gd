# Test delle Scaglie di gelo: la mossa con Emilia (atto 3).
extends GdUnitTestSuite

var result := ""
var _message_time := 0.0
var _transition_time := 0.0


func before_test() -> void:
	_clean_state()
	_message_time = Battle.message_time
	Battle.message_time = 0.02
	_transition_time = Battle.transition_time
	Battle.transition_time = 0.05
	Battle.rng.seed = 99
	Battle.finished.connect(_on_finished)


func after_test() -> void:
	Battle.finished.disconnect(_on_finished)
	Battle.message_time = _message_time
	Battle.transition_time = _transition_time
	Battle.flee_chance = 0.5
	_clean_state()


func _on_finished(battle_result: String) -> void:
	result = battle_result


func _clean_state() -> void:
	Game.flags.clear()
	Game.in_cutscene = false
	Inventory.reset()
	Stats.reset()
	result = ""


func _wait_turn() -> void:
	for i in 300:
		if Battle.commands.menu.visible or not Battle.is_active:
			return
		await await_millis(20)


func _escape() -> void:
	if Battle.is_active:
		Battle.flee_chance = 1.0
		Battle.commands.flee_button.pressed.emit()
		await _wait_turn()


func test_senza_emilia_la_mossa_non_c_e() -> void:
	Battle.start(load("res://enemies/occhio_errante.tres"))
	await _wait_turn()
	Battle.commands.open_skills()
	assert_bool(Battle.commands.frost_button.visible).is_false()
	Battle.commands.close_submenus()
	await _escape()


func test_dopo_l_insegnamento_di_emilia_c_e() -> void:
	Game.set_flag(FlagKeys.ICE_UNLOCKED)
	Battle.start(load("res://enemies/occhio_errante.tres"))
	await _wait_turn()
	Battle.commands.open_skills()
	assert_bool(Battle.commands.frost_button.visible).is_true()
	Battle.commands.close_submenus()
	await _escape()


func test_le_scaglie_colpiscono_e_scoprono_la_debolezza() -> void:
	Game.set_flag(FlagKeys.ICE_UNLOCKED)
	var guardian := load("res://enemies/guardiano_rovi.tres") as EnemyData
	Battle.start(guardian)
	await _wait_turn()
	var sp := Stats.sp
	Battle.commands.frost_button.pressed.emit()
	# Emilia compare durante la mossa...
	await await_millis(600)
	assert_bool(Battle.emilia_sprite.visible).is_true()
	await _wait_turn()
	# ...e alla fine se ne va.
	assert_bool(Battle.emilia_sprite.visible).is_false()
	assert_int(Stats.sp).is_equal(sp - Battle.SKILLS.gelo.cost)
	assert_int(Battle.enemy_hp).is_less(guardian.max_hp)
	assert_bool(Battle.revealed.has("ghiaccio")).is_true()
	assert_int(Battle.enemy_shield).is_equal(guardian.shield - 1)
	await _escape()


func test_i_nemici_del_bosco_temono_il_ghiaccio() -> void:
	for id in ["occhio_errante", "mano_ombra", "guardiano_rovi"]:
		var data := load("res://enemies/%s.tres" % id) as EnemyData
		assert_bool(data.weaknesses.has("ghiaccio")).is_true()
		assert_bool(data.animated()).is_true()
		assert_int(data.texture.get_width()).is_equal(32 * data.frames)


func test_il_ghiaccio_ha_la_sua_icona() -> void:
	assert_bool(BattleEnemyInfo.TYPE_ICONS.has("ghiaccio")).is_true()
	var icons := load("res://assets/ui/battle_icons.png") as Texture2D
	assert_int(icons.get_width()).is_greater_equal((BattleEnemyInfo.TYPE_ICONS.ghiaccio + 1) * 16)


# ---------- Emilia nel party ----------

func test_nel_party_emilia_ha_il_suo_turno() -> void:
	Game.set_flag(FlagKeys.FOREST_ARRIVED)   # da qui Emilia è nel party
	Game.set_flag(FlagKeys.ICE_UNLOCKED)
	Battle.start(_tough_enemy())
	await _wait_turn()
	assert_bool(Battle.with_emilia).is_true()
	assert_bool(Battle.emilia_sprite.visible).is_true()
	# Nel turno di Subaru le Scaglie di gelo non ci sono: sono di Emilia.
	assert_str(Battle.turn).is_equal(Battle.HERO)
	Battle.commands.open_skills()
	assert_bool(Battle.commands.frost_button.visible).is_false()
	Battle.commands.close_submenus()
	Battle.commands.attack_button.pressed.emit()
	await await_millis(100)
	await _wait_turn()
	# Dopo Subaru, tocca a Emilia: il suo "Attacca" è il Dardo di gelo.
	assert_str(Battle.turn).is_equal(Battle.ALLY)
	assert_str(Battle.commands.attack_button.text).is_equal(Battle.SKILLS.dardo.name)
	Battle.commands.open_skills()
	assert_bool(Battle.commands.frost_button.visible).is_true()
	assert_bool(Battle.commands.kick_button.visible).is_false()
	Battle.commands.close_submenus()
	var hp: int = Battle.enemy_hp
	Battle.commands.frost_button.pressed.emit()
	await await_millis(100)
	await _wait_turn()
	# Le Scaglie le paga Emilia, non Subaru; il ghiaccio è una debolezza.
	assert_int(Battle.ally_sp).is_equal(Battle.ALLY_MAX_SP - Battle.SKILLS.gelo.cost)
	assert_int(Battle.enemy_hp).is_less(hp)
	assert_bool(Battle.revealed.has("ghiaccio")).is_true()
	await _escape()
