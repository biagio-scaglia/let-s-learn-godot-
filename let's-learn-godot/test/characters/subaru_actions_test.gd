# Test di scena: le azioni di Subaru (esultanza, caduta, risveglio), nel villaggio.
extends GdUnitTestSuite

var runner: GdUnitSceneRunner
var player: CharacterBody2D
var sprite: AnimatedSprite2D


func before_test() -> void:
	_clean_state()
	# Intro già vista: si parte giocando, in piazza.
	Game.set_flag(FlagKeys.INTRO_SEEN)
	runner = scene_runner("res://world/main.tscn")
	await runner.simulate_frames(2)
	player = runner.scene().get_node("World/Subaru")
	sprite = player.get_node("AnimatedSprite2D")


func after_test() -> void:
	_clean_state()


func _clean_state() -> void:
	Game.flags.clear()
	Game.spawn_point = ""
	Game.spawn_position = null
	Game.in_cutscene = false
	Inventory.reset()


func test_le_animazioni_delle_azioni_esistono() -> void:
	for animation in ["cheer", "collapse", "lying", "wake_up"]:
		assert_bool(sprite.sprite_frames.has_animation(animation)).is_true()
		# Non si ripetono: finiscono, e animation_finished arriva.
		assert_bool(sprite.sprite_frames.get_animation_loop(animation)).is_false()


func test_esulta_e_poi_torna_fermo() -> void:
	player.cheer()
	await runner.simulate_frames(2)
	assert_str(sprite.animation).is_equal("cheer")
	await await_millis(1800)
	assert_str(sprite.animation).is_equal("idle_down")
	assert_bool(player._scripted).is_false()


func test_raccogliere_la_chiave_lo_fa_esultare() -> void:
	var key := runner.scene().get_node("World/Key") as Node2D
	player.global_position = key.global_position + Vector2(0, 14)
	await await_millis(150)   # il tempo di entrare nell'area dell'Interactable
	runner.simulate_action_pressed("interact")
	await await_millis(150)
	assert_bool(Inventory.has(Inventory.KEY)).is_true()
	assert_str(sprite.animation).is_equal("cheer")


func test_crolla_e_resta_a_terra() -> void:
	await player.collapse()
	assert_str(sprite.animation).is_equal("collapse")
	assert_int(sprite.frame).is_equal(2)   # l'ultimo: steso
	await await_millis(300)
	assert_str(sprite.animation).is_equal("collapse")


func test_verso_sinistra_le_azioni_si_specchiano() -> void:
	player.face(Facing.LEFT)
	player.collapse()
	await runner.simulate_frames(2)
	assert_bool(sprite.flip_h).is_true()


func test_una_caduta_interrompe_l_esultanza() -> void:
	player.cheer()
	await runner.simulate_frames(2)
	await player.collapse()
	# L'esultanza, finendo, non deve rimetterlo in piedi.
	await await_millis(300)
	assert_str(sprite.animation).is_equal("collapse")
	assert_bool(player._scripted).is_true()


func test_da_steso_si_rialza() -> void:
	player.lie_down()
	assert_str(sprite.animation).is_equal("lying")
	await player.wake_up()
	assert_str(sprite.animation).is_equal("idle_down")
	assert_bool(sprite.flip_h).is_false()
	assert_bool(player._scripted).is_false()
