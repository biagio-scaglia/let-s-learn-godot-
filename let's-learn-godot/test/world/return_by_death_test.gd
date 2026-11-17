# Test di scena: i confini del villaggio e la morte.
extends GdUnitTestSuite

var runner: GdUnitSceneRunner
var player: Node2D
var edge: Node


func before_test() -> void:
	_clean_state()
	# Intro già vista: si parte giocando, in piazza.
	Game.set_flag(FlagKeys.INTRO_SEEN)
	runner = scene_runner("res://world/main.tscn")
	await runner.simulate_frames(2)
	player = runner.scene().get_node("World/Subaru")
	edge = runner.scene().get_node("VillageEdge")


func after_test() -> void:
	_clean_state()


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


func test_in_piazza_nessun_pericolo() -> void:
	await await_millis(300)
	assert_float(edge.danger).is_equal(0.0)
	assert_bool(ReturnByDeath.is_active).is_false()


func test_vicino_al_bordo_batte_il_cuore() -> void:
	player.global_position = Vector2(1170, 400)
	await await_millis(1000)
	assert_float(edge.danger).is_greater(0.3)
	assert_bool(edge.heartbeat_slow.playing or edge.heartbeat_fast.playing).is_true()
	assert_bool(ReturnByDeath.is_active).is_false()


func test_sul_bordo_si_muore() -> void:
	player.global_position = Vector2(1210, 400)
	await runner.simulate_frames(3)
	assert_bool(ReturnByDeath.is_active).is_true()
	assert_int(Game.deaths).is_equal(1)
	assert_bool(Game.player_can_move()).is_false()


func test_si_muore_una_volta_sola() -> void:
	player.global_position = Vector2(1210, 400)
	await runner.simulate_frames(10)
	assert_int(Game.deaths).is_equal(1)


func test_durante_una_cutscene_il_bordo_non_uccide() -> void:
	# Come nell'intro, quando Subaru arriva da sotto il bordo della mappa.
	Game.in_cutscene = true
	player.global_position = Vector2(656, 760)
	await runner.simulate_frames(5)
	assert_bool(ReturnByDeath.is_active).is_false()


func test_morendo_subaru_cade_a_terra() -> void:
	player.global_position = Vector2(1210, 400)
	await runner.simulate_frames(3)
	var sprite := player.get_node("AnimatedSprite2D") as AnimatedSprite2D
	assert_str(sprite.animation).is_equal("collapse")


func test_il_villaggio_ha_la_sua_musica_in_loop() -> void:
	var music := runner.scene().get_node("Music") as AudioStreamPlayer
	assert_bool(music.playing).is_true()
	assert_int((music.stream as AudioStreamWAV).loop_mode).is_equal(AudioStreamWAV.LOOP_FORWARD)


func test_vicino_al_bordo_la_musica_si_abbassa() -> void:
	var music := runner.scene().get_node("Music") as AudioStreamPlayer
	var normal := music.volume_db
	player.global_position = Vector2(1170, 400)
	await await_millis(1000)
	assert_float(music.volume_db).is_less(normal - 3.0)


func test_morendo_la_musica_si_spegne_e_qualcuno_ride() -> void:
	var music := runner.scene().get_node("Music") as AudioStreamPlayer
	player.global_position = Vector2(1210, 400)
	await await_millis(3200)   # caduta, nebbia, poi il pannello del game over
	assert_float(music.volume_db).is_less(-40.0)
	assert_bool(ReturnByDeath.laugh.playing).is_true()
	assert_bool(ReturnByDeath.game_over_music.playing).is_true()
