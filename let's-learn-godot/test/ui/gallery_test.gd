# Test della Galleria e dei suoi libri, e dei titoli di coda che la sbloccano.
extends GdUnitTestSuite

const TEST_PROGRESS := "user://test_progressi_galleria.cfg"

var _real_progress: String


func before_test() -> void:
	_real_progress = Progress.path
	Progress.path = TEST_PROGRESS
	Progress.load_progress()
	Game.load_flags({FlagKeys.INTRO_SEEN: true})
	Game.in_cutscene = false


func after_test() -> void:
	Game.in_cutscene = false
	if FileAccess.file_exists(TEST_PROGRESS):
		DirAccess.remove_absolute(TEST_PROGRESS)
	Progress.path = _real_progress
	Progress.load_progress()


func test_ogni_libro_ha_ritratto_nome_e_pagine() -> void:
	for id in GalleryBooks.all_ids():
		var book := GalleryBooks.entry(id)
		assert_str(book.get("name", "")).override_failure_message("nome mancante: " + id).is_not_empty()
		assert_bool(book.get("pages", []).is_empty()).override_failure_message("pagine mancanti: " + id).is_false()
		assert_object(Portraits.of(id)).override_failure_message("ritratto mancante: " + id).is_not_null()


func test_i_mostri_prendono_i_numeri_dal_loro_file() -> void:
	var book := GalleryBooks.entry("spettro")
	assert_str(book.name).is_equal("Spettro")
	var stats: Array = book.stats
	assert_str(stats[0][1]).is_equal("16")             # PS
	assert_str(stats[-1][1]).is_equal("Calcio, Ombra")  # debolezze


func test_un_libro_che_non_esiste_e_vuoto() -> void:
	assert_bool(GalleryBooks.entry("nessuno").is_empty()).is_true()


func test_nella_galleria_c_e_una_vetrina_per_ogni_libro() -> void:
	var runner := scene_runner(Game.GALLERY_SCENE)
	await runner.simulate_frames(2)
	var ids: Array[String] = []
	for node in runner.scene().find_children("*", "Node2D"):
		if node is Exhibit:
			ids.append(node.book_id)
	ids.sort()
	var expected := GalleryBooks.all_ids()
	expected.sort()
	assert_array(ids).is_equal(expected)
	# Entrare nella Galleria la segna come vista (non più "Nuova!").
	assert_bool(Progress.gallery_seen).is_true()


func test_il_libro_si_apre_e_si_chiude() -> void:
	var runner := scene_runner(Game.GALLERY_SCENE)
	await runner.simulate_frames(2)
	var reader := runner.scene().get_node("Reader") as BookReader
	var exhibit := runner.scene().get_node("World/EmiliaBook") as Exhibit
	exhibit.book_opened.emit("emilia")
	assert_bool(reader.is_open).is_true()
	assert_bool(Game.in_cutscene).is_true()   # Subaru resta fermo mentre legge
	assert_str(reader._name.text).is_equal("Emilia")
	reader._turn(1)
	assert_int(reader._page).is_equal(1)
	reader._turn(-1)
	reader._turn(-1)
	assert_int(reader._page).is_equal(0)      # non si va prima della prima pagina
	await reader.close()
	assert_bool(Game.in_cutscene).is_false()
