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


func test_emilia_indica_il_passo_giusto() -> void:
	var runner := await _village()
	var emilia := runner.scene().get_node("World/Emilia/Interactable") as Interactable
	emilia.interacted.emit()
	assert_str("\n".join(emilia.override_lines)).contains("Saggio")
	Inventory.add(Inventory.PAGE)
	emilia.interacted.emit()
	assert_str("\n".join(emilia.override_lines)).contains("biblioteca")


func test_l_archivista_legge_la_pagina() -> void:
	Inventory.add(Inventory.PAGE)
	var runner := await _library()
	var archivista := runner.scene().get_node("World/Archivista/Interactable") as Interactable
	archivista.interacted.emit()
	assert_bool(Game.has_flag(FlagKeys.PAGE_READ)).is_true()
	assert_str("\n".join(archivista.override_lines)).contains("Spettro")


func test_senza_la_lacrima_il_libro_resta_muto() -> void:
	Game.set_flag(FlagKeys.PAGE_READ)
	Inventory.add(Inventory.PAGE)
	var runner := await _library()
	var book := runner.scene().get_node("World/BlackBook") as Interactable
	book.interacted.emit()
	assert_array(Array(book.override_lines)).is_empty()
	assert_bool(Inventory.has(Inventory.PAGE)).is_true()


func test_pagina_e_lacrima_sul_libro_nero() -> void:
	Game.set_flag(FlagKeys.PAGE_READ)
	Inventory.add(Inventory.PAGE)
	Inventory.add(Inventory.TEAR)
	var runner := await _library()
	var book := runner.scene().get_node("World/BlackBook") as Interactable
	book.interacted.emit()
	assert_str("\n".join(book.override_lines)).contains("Erbalta ricomincia")
	# Pagina e lacrima restano nel libro.
	assert_bool(Inventory.has(Inventory.PAGE)).is_false()
	assert_bool(Inventory.has(Inventory.TEAR)).is_false()
	# Il ricordo arriva quando il dialogo del libro finisce.
	Dialogue.finished.emit()
	await runner.simulate_frames(1)
	assert_bool(Game.has_flag(FlagKeys.BOOK_READ)).is_true()
	assert_bool(Dialogue.is_active).is_true()   # Subaru commenta


func test_raccontarlo_a_emilia_chiude_l_atto() -> void:
	Game.set_flag(FlagKeys.BOOK_READ)
	var runner := await _village()
	var emilia := runner.scene().get_node("World/Emilia/Interactable") as Interactable
	emilia.interacted.emit()
	assert_bool(Game.in_cutscene).is_true()
	# La prima battuta la direbbe il dialogo normale: qui la "chiudiamo" a mano.
	Dialogue.finished.emit()
	for i in 10:
		if Game.has_flag(FlagKeys.ACT2_DONE):
			break
		await runner.simulate_frames(2)
		await _close_dialogue()
	assert_bool(Game.has_flag(FlagKeys.ACT2_DONE)).is_true()
	assert_bool(Game.in_cutscene).is_false()
	assert_str(Objective.current()).is_equal(Objective.FOREST)
