# Test: dopo Colui che guarda si torna a Erbalta. Il sentiero del bosco si apre, il bordo
# del villaggio non uccide più, Emilia torna con Subaru.
extends GdUnitTestSuite


func before_test() -> void:
	# Questi test leggono i testi del gioco: in italiano, la lingua in cui sono scritti.
	TranslationServer.set_locale("it")
	_clean_state()


func after_test() -> void:
	TranslationServer.set_locale(Settings.language)
	_clean_state()


func _clean_state() -> void:
	Game.load_flags({FlagKeys.INTRO_SEEN: true, FlagKeys.ACT2_DONE: true, FlagKeys.FOREST_ARRIVED: true})
	Game.spawn_point = ""
	Game.spawn_position = null
	Game.in_cutscene = false


func test_il_sentiero_del_bosco_si_apre_solo_dopo_il_boss() -> void:
	var runner := scene_runner(Game.FOREST_SCENE)
	await runner.simulate_frames(2)
	var path := runner.scene().get_node("World/VillagePath")
	assert_str(path.target_scene).is_equal(Game.FIRST_LEVEL)
	assert_str(path.required_flag).is_equal(FlagKeys.BOSS_DEFEATED)
	# E il punto d'arrivo esiste davvero, nel villaggio.
	var village := (load(Game.FIRST_LEVEL) as PackedScene).instantiate()
	assert_object(village.get_node_or_null("Spawns/" + path.target_spawn)).is_not_null()
	village.free()


func test_prima_del_boss_il_sentiero_non_porta_da_nessuna_parte() -> void:
	var runner := scene_runner(Game.FOREST_SCENE)
	await runner.simulate_frames(2)
	var path := runner.scene().get_node("World/VillagePath")
	path._on_body_entered(runner.scene().get_node("World/Subaru"))
	assert_bool(Game.changing_scene).is_false()


func test_dopo_il_boss_il_bordo_non_uccide() -> void:
	Game.set_flag(FlagKeys.BOSS_DEFEATED)
	var runner := scene_runner(Game.FIRST_LEVEL)
	await runner.simulate_frames(2)
	assert_bool(runner.scene().get_node("VillageEdge").is_processing()).is_false()


func test_tornati_a_erbalta_emilia_segue_subaru() -> void:
	Game.set_flag(FlagKeys.BOSS_DEFEATED)
	Game.spawn_point = "ForestPath"
	var runner := scene_runner(Game.FIRST_LEVEL)
	await runner.simulate_frames(4)
	var emilia := runner.scene().get_node("World/Emilia") as Node2D
	var subaru := runner.scene().get_node("World/Subaru") as Node2D
	assert_float(emilia.global_position.distance_to(subaru.global_position)).is_less(40.0)
	assert_str(Objective.current()).is_equal(Objective.GREET_VILLAGE % 0)
	# Niente nuova partenza per il bosco: Emilia ha frasi nuove.
	var talk := runner.scene().get_node("World/Emilia/Interactable") as Interactable
	talk.interacted.emit()
	assert_bool(Game.in_cutscene).is_false()
	assert_str("\n".join(talk.override_lines)).contains("aria")
