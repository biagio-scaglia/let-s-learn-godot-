# Test di scena: dopo una morte, chi parla con Subaru nota che qualcosa non va.
extends GdUnitTestSuite

var runner: GdUnitSceneRunner
var saggio: Interactable


func before_test() -> void:
	_clean_state()
	Game.set_flag(FlagKeys.INTRO_SEEN)
	runner = scene_runner("res://world/main.tscn")
	await runner.simulate_frames(2)
	saggio = runner.scene().get_node("World/Npc/Interactable")


func after_test() -> void:
	_clean_state()


func _clean_state() -> void:
	Game.load_flags()
	Game.spawn_point = ""
	Game.spawn_position = null
	Game.in_cutscene = false
	Game.deaths = 0
	Inventory.reset()


func test_senza_morti_nessuna_frase_in_piu() -> void:
	saggio.interacted.emit()
	assert_array(saggio.extra_lines).is_empty()


func test_dopo_una_morte_il_saggio_aggiunge_due_frasi() -> void:
	Game.deaths = 1
	saggio.interacted.emit()
	assert_array(saggio.extra_lines).has_size(2)
	assert_bool(Game.has_flag(FlagKeys.death_noticed("saggio"))).is_true()


func test_dalla_terza_morte_il_saggio_dice_altro() -> void:
	Game.deaths = 1
	saggio.interacted.emit()
	var first := saggio.extra_lines
	Game.load_flags({FlagKeys.INTRO_SEEN: true})   # come dopo un Ritorno: lui non ricorda
	Game.deaths = 3
	saggio.interacted.emit()
	assert_array(saggio.extra_lines).has_size(2)
	assert_array(saggio.extra_lines).is_not_equal(first)


func test_emilia_lo_nota_per_conto_suo() -> void:
	Game.deaths = 1
	saggio.interacted.emit()
	var emilia: Interactable = runner.scene().get_node("World/Emilia/Interactable")
	emilia.interacted.emit()
	assert_array(emilia.extra_lines).is_not_empty()
