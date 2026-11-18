# Test di scena: il Bosco Senza Tempo (atto 3). L'arrivo, Emilia che segue, la nebbia.
extends GdUnitTestSuite


func before_test() -> void:
	_clean_state()


func after_test() -> void:
	if Dialogue.is_active:
		await Dialogue._close()
	_clean_state()


func _clean_state() -> void:
	Game.load_flags({FlagKeys.INTRO_SEEN: true, FlagKeys.ACT2_DONE: true})
	Inventory.reset()
	Game.spawn_point = ""
	Game.spawn_position = null
	Game.in_cutscene = false


func test_la_prima_volta_parte_l_arrivo() -> void:
	var runner := scene_runner(Game.FOREST_SCENE)
	await runner.simulate_frames(2)
	assert_bool(Game.in_cutscene).is_true()
	assert_object(runner.scene().get_node_or_null("ForestArrival")).is_not_null()


func test_gia_arrivati_niente_cutscene() -> void:
	Game.set_flag(FlagKeys.FOREST_ARRIVED)
	var runner := scene_runner(Game.FOREST_SCENE)
	await runner.simulate_frames(2)
	assert_bool(Game.in_cutscene).is_false()
	assert_object(runner.scene().get_node_or_null("ForestArrival")).is_null()
	assert_str(Objective.current()).is_equal(Objective.CROSS_FOREST)


func test_emilia_segue_subaru() -> void:
	Game.set_flag(FlagKeys.FOREST_ARRIVED)
	var runner := scene_runner(Game.FOREST_SCENE)
	await runner.simulate_frames(3)
	var subaru := runner.scene().get_node("World/Subaru") as Node2D
	var emilia := runner.scene().get_node("World/Emilia") as Node2D
	# All'arrivo (senza cutscene) si mette subito dietro di lui.
	assert_float(emilia.global_position.distance_to(subaru.global_position)).is_less(40.0)
	# Subaru va verso nord: lei lo segue, restando un po' indietro.
	subaru.set("_scripted", true)
	await subaru.walk_to(subaru.global_position + Vector2(0, -160), 200.0)
	await runner.simulate_frames(40)
	var gap := emilia.global_position.distance_to(subaru.global_position)
	assert_float(gap).is_between(10.0, 60.0)
	# E non fa da muro: il giocatore non ci sbatte contro.
	assert_int(emilia.collision_layer).is_equal(0)


func test_la_nebbia_sbarra_la_radura() -> void:
	Game.set_flag(FlagKeys.FOREST_ARRIVED)
	var runner := scene_runner(Game.FOREST_SCENE)
	await runner.simulate_frames(2)
	var gate := runner.scene().get_node("World/FogGate") as StaticBody2D
	var shape := gate.get_node("CollisionShape2D") as CollisionShape2D
	assert_object(shape.shape).is_not_null()
	assert_bool(shape.disabled).is_false()
	# Il varco copre tutta l'apertura nei rovi: niente spazio per passarci accanto.
	assert_float((shape.shape as RectangleShape2D).size.x).is_greater_equal(256.0)


func test_il_bosco_ha_un_nome_nei_salvataggi() -> void:
	assert_str(SaveSystem.PLACE_NAMES.get(Game.FOREST_SCENE, "")).is_equal("Bosco Senza Tempo")


func test_la_musica_del_bosco_si_ripete() -> void:
	Game.set_flag(FlagKeys.FOREST_ARRIVED)
	var runner := scene_runner(Game.FOREST_SCENE)
	await runner.simulate_frames(2)
	var music := runner.scene().get_node("Music") as AudioStreamPlayer
	assert_bool(music.is_in_group("level_music")).is_true()
	assert_int((music.stream as AudioStreamWAV).loop_mode).is_equal(AudioStreamWAV.LOOP_FORWARD)


func test_gli_occhi_nei_rovi_si_chiudono_se_ti_avvicini() -> void:
	Game.set_flag(FlagKeys.FOREST_ARRIVED)
	var runner := scene_runner(Game.FOREST_SCENE)
	await runner.simulate_frames(2)
	var eyes := runner.scene().get_node("Canopy/Eyes1") as ThicketEyes
	var subaru := runner.scene().get_node("World/Subaru") as Node2D
	# Li apriamo a mano (di solito aspettano un momento a caso), poi Subaru si avvicina.
	subaru.global_position = eyes.global_position + Vector2(0, 400)
	eyes._open()
	await runner.simulate_frames(60)
	assert_int(eyes.frame).is_equal(ThicketEyes.Lids.OPEN)
	subaru.global_position = eyes.global_position + Vector2(0, 30)
	await runner.simulate_frames(30)
	assert_int(eyes.frame).is_equal(ThicketEyes.Lids.SHUT)


func test_a_fine_atto_2_emilia_porta_nel_bosco() -> void:
	Game.set_flag(FlagKeys.BOOK_READ)
	var runner := scene_runner("res://world/main.tscn")
	await runner.simulate_frames(2)
	var emilia := runner.scene().get_node("World/Emilia/Interactable") as Interactable
	emilia.interacted.emit()
	assert_bool(Game.in_cutscene).is_true()
	assert_str("\n".join(emilia.override_lines)).contains("Andiamo")


func test_davanti_a_un_nemico_e_non_parla_emilia() -> void:
	Game.set_flag(FlagKeys.FOREST_ARRIVED)
	var runner := scene_runner(Game.FOREST_SCENE)
	await runner.simulate_frames(3)
	var subaru := runner.scene().get_node("World/Subaru") as Node2D
	var emilia := runner.scene().get_node("World/Emilia/Interactable") as Interactable
	var enemy := runner.scene().get_node("World/OcchioErrante1")
	enemy.wander_radius = 0.0
	# Subaru davanti al nemico, Emilia (che lo segue) subito dietro di lui.
	subaru.global_position = enemy.global_position + Vector2(0, 24)
	runner.scene().get_node("World/Emilia").global_position = subaru.global_position + Vector2(0, 18)
	await runner.simulate_frames(6)
	var fight := enemy.get_node("Interactable") as Interactable
	assert_object(fight.player).is_not_null()
	assert_object(emilia.player).is_not_null()
	assert_bool(fight._is_first_choice()).is_true()
	assert_bool(emilia._is_first_choice()).is_false()
	# Lontano da tutto il resto, con Emilia si parla come sempre.
	subaru.global_position = Vector2(598, 930)
	runner.scene().get_node("World/Emilia").global_position = subaru.global_position + Vector2(0, 18)
	await runner.simulate_frames(6)
	assert_bool(emilia._is_first_choice()).is_true()
