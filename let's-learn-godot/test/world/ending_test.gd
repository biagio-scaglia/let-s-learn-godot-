# Test del finale: i saluti agli abitanti, l'obiettivo, e la partenza dal sentiero a sud.
extends GdUnitTestSuite

const TEST_PROGRESS := "user://test_progressi_finale.cfg"

var _real_progress: String


func before_test() -> void:
	_real_progress = Progress.path
	Progress.path = TEST_PROGRESS
	_clean_state()


func after_test() -> void:
	if Dialogue.is_active:
		await Dialogue._close()
	_clean_state()
	if FileAccess.file_exists(TEST_PROGRESS):
		DirAccess.remove_absolute(TEST_PROGRESS)
	Progress.path = _real_progress
	Progress.load_progress()


func _clean_state() -> void:
	Game.load_flags({FlagKeys.INTRO_SEEN: true, FlagKeys.SAGE_FORGETS: true, FlagKeys.ACT2_DONE: true,
		FlagKeys.FOREST_ARRIVED: true, FlagKeys.BOSS_DEFEATED: true})
	Inventory.reset()
	Game.spawn_point = ""
	Game.spawn_position = null
	Game.in_cutscene = false


func _greet_everyone() -> void:
	for who in FlagKeys.VILLAGERS:
		Game.set_flag(FlagKeys.greeted(who))


func _village() -> GdUnitSceneRunner:
	var runner := scene_runner(Game.FIRST_LEVEL)
	await runner.simulate_frames(3)
	return runner


func test_l_obiettivo_conta_i_saluti() -> void:
	Game.set_flag(FlagKeys.HOME_AGAIN)
	assert_str(Objective.current()).is_equal(Objective.GREET_VILLAGE % 0)
	Game.set_flag(FlagKeys.greeted("lina"))
	assert_str(Objective.current()).is_equal(Objective.GREET_VILLAGE % 1)
	_greet_everyone()
	assert_str(Objective.current()).is_equal(Objective.LEAVE_SOUTH)
	Game.set_flag(FlagKeys.GAME_FINISHED)
	assert_str(Objective.current()).is_equal(Objective.NONE)


func test_il_saggio_saluta_e_se_ne_ricorda() -> void:
	var runner := await _village()
	var saggio := runner.scene().get_node("World/Npc/Interactable") as Interactable
	saggio.interacted.emit()
	assert_bool(Game.has_flag(FlagKeys.greeted("saggio"))).is_true()
	assert_str("\n".join(saggio.override_lines)).contains("alberi")
	# La seconda volta parla della partenza.
	saggio.interacted.emit()
	assert_str("\n".join(saggio.override_lines)).contains("sentiero a sud")


func test_l_archivista_legge_la_storia_nuova() -> void:
	var runner := scene_runner("res://world/library.tscn")
	await runner.simulate_frames(2)
	var archivista := runner.scene().get_node("World/Archivista/Interactable") as Interactable
	archivista.interacted.emit()
	assert_bool(Game.has_flag(FlagKeys.greeted("archivista"))).is_true()
	assert_str("\n".join(archivista.override_lines)).contains("storia nuova")


func test_lina_saluta_e_regala_due_pozioni() -> void:
	var runner := scene_runner("res://world/house.tscn")
	await runner.simulate_frames(2)
	var lina := runner.scene().get_node("World/Lina/Interactable") as Interactable
	lina.interacted.emit()
	assert_bool(Game.has_flag(FlagKeys.greeted("lina"))).is_true()
	Dialogue.finished.emit()   # il regalo arriva a fine dialogo
	assert_int(Inventory.items.get(Inventory.POTION, 0)).is_equal(2)
	# Una volta sola: la seconda volta niente pozioni.
	lina.interacted.emit()
	assert_str("\n".join(lina.override_lines)).contains("Promesso")
