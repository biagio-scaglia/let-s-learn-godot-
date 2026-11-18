# Test di scena dell'atto 2: chi dice cosa, e quali ricordi lascia.
# Invece di premere E vicino ai personaggi, emettiamo direttamente il loro segnale
# "interacted": è quello che ascolta VoicesQuest.
extends GdUnitTestSuite


func before_test() -> void:
	_clean_state()


func after_test() -> void:
	await _close_dialogue()
	_clean_state()


func _clean_state() -> void:
	Game.load_flags({FlagKeys.INTRO_SEEN: true})
	Inventory.reset()
	Game.spawn_point = ""
	Game.spawn_position = null
	Game.in_cutscene = false


## Chiude la finestra di dialogo se è aperta (emette anche "finished").
func _close_dialogue() -> void:
	if Dialogue.is_active:
		await Dialogue._close()


func _village() -> GdUnitSceneRunner:
	var runner := scene_runner("res://world/main.tscn")
	await runner.simulate_frames(2)
	return runner


func _library() -> GdUnitSceneRunner:
	var runner := scene_runner("res://world/library.tscn")
	await runner.simulate_frames(2)
	return runner


func test_il_saggio_non_ricorda() -> void:
	var runner := await _village()
	var saggio := runner.scene().get_node("World/Npc/Interactable") as Interactable
	saggio.interacted.emit()
	assert_bool(Game.has_flag(FlagKeys.SAGE_FORGETS)).is_true()
	assert_str("\n".join(saggio.override_lines)).contains("Non me lo ricordo")
	# La prima volta si presenta anche.
	assert_str(saggio.override_lines[0]).contains("Io sono il Saggio")
