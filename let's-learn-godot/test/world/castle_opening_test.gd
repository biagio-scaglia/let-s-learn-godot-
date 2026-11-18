# Test di scena: la partenza dal castello e la camminata di Emilia.
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


func test_la_partita_nuova_parte_dal_castello() -> void:
	assert_str(Game.OPENING_SCENE).is_equal("res://world/castle.tscn")
	assert_bool(ResourceLoader.exists(Game.OPENING_SCENE)).is_true()


func test_al_castello_parte_la_cutscene() -> void:
	var runner := scene_runner(Game.OPENING_SCENE)
	await runner.simulate_frames(2)
	assert_bool(Game.in_cutscene).is_true()
	assert_bool(Game.player_can_move()).is_false()
	assert_object(runner.scene().get_node_or_null("CastleOpening")).is_not_null()
	# Il castello non è un livello: niente menu di pausa.
	assert_bool(runner.scene().is_in_group("level")).is_false()


func test_emilia_e_subaru_escono_dal_portone() -> void:
	var runner := scene_runner(Game.OPENING_SCENE)
	var emilia := runner.scene().get_node("World/Emilia") as Node2D
	var subaru := runner.scene().get_node("World/Subaru") as Node2D
	var start_y := subaru.global_position.y
	await runner.simulate_frames(200, 33)   # circa 6 secondi e mezzo
	# Sono scesi verso sud, oltre il ponte, e si fermano a parlare.
	assert_float(subaru.global_position.y).is_greater(start_y + 100)
	assert_float(emilia.global_position.y).is_greater(start_y + 100)
	assert_bool(Dialogue.is_active).is_true()


func test_emilia_cammina_e_si_ferma() -> void:
	# Intro già vista: nessuna cutscene muove Emilia al posto nostro.
	Game.set_flag(FlagKeys.INTRO_SEEN)
	var runner := scene_runner("res://world/main.tscn")
	await runner.simulate_frames(2)
	var emilia := runner.scene().get_node("World/Emilia")
	var target: Vector2 = emilia.global_position + Vector2(-40, 0)
	await emilia.walk_to(target, 200.0)
	assert_vector(emilia.global_position).is_equal(target)
	assert_str(emilia.facing).is_equal(Facing.LEFT)
	# Fermo: di nuovo il frame "in piedi" della riga di sinistra.
	assert_int(emilia.sprite.frame).is_equal(4)
