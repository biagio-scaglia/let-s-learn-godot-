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
