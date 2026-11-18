# Test dell'obiettivo: il testo giusto per ogni passo dell'atto 2 ("Le voci di Erbalta").
extends GdUnitTestSuite


func before_test() -> void:
	Game.load_flags()
	Inventory.reset()


func after_test() -> void:
	before_test()


func test_all_inizio_si_va_dal_saggio() -> void:
	assert_str(Objective.current()).is_equal(Objective.ASK_SAGE)


func test_dopo_il_saggio_si_va_da_lina() -> void:
	Game.set_flag(FlagKeys.SAGE_FORGETS)
	assert_str(Objective.current()).is_equal(Objective.VISIT_LINA)


func test_dopo_aver_parlato_con_lina_si_cerca_la_chiave() -> void:
	Game.set_flag(FlagKeys.KEY_QUEST_STARTED)
	assert_str(Objective.current()).is_equal(Objective.FIND_KEY)


func test_con_la_chiave_la_si_porta_a_lina() -> void:
	Game.set_flag(FlagKeys.KEY_QUEST_STARTED)
	Inventory.reset({Inventory.KEY: 1})
	assert_str(Objective.current()).is_equal(Objective.BRING_KEY)


func test_chiave_trovata_per_caso_senza_aver_parlato_con_lina() -> void:
	# Si può raccogliere la chiave prima di conoscere Lina: l'obiettivo ha senso lo stesso.
	Inventory.reset({Inventory.KEY: 1})
	assert_str(Objective.current()).is_equal(Objective.BRING_KEY)


func test_dopo_averla_mostrata_si_apre_il_baule() -> void:
	Inventory.reset({Inventory.KEY: 1})
	Game.set_flag(FlagKeys.KEY_SHOWN)
	assert_str(Objective.current()).is_equal(Objective.OPEN_CHEST)


func test_con_la_pagina_si_va_dall_archivista() -> void:
	Game.set_flag(FlagKeys.CHEST_OPEN)
	Inventory.reset({Inventory.PAGE: 1})
	assert_str(Objective.current()).is_equal(Objective.SHOW_PAGE)


func test_un_vecchio_salvataggio_a_baule_aperto_senza_pagina() -> void:
	# I salvataggi di prima dell'atto 2 hanno solo "baule_aperto": la pagina va ripresa.
	Game.load_flags({"baule_aperto": true})
	assert_str(Objective.current()).is_equal(Objective.CHECK_CHEST)


func test_letta_la_pagina_si_cerca_lo_spettro() -> void:
	Game.set_flag(FlagKeys.PAGE_READ)
	Inventory.reset({Inventory.PAGE: 1})
	assert_str(Objective.current()).is_equal(Objective.DEFEAT_SPECTRE)


func test_con_la_lacrima_si_legge_il_libro() -> void:
	Game.set_flag(FlagKeys.PAGE_READ)
	Inventory.reset({Inventory.PAGE: 1, Inventory.TEAR: 1})
	assert_str(Objective.current()).is_equal(Objective.READ_BOOK)


func test_letto_il_libro_si_torna_da_emilia() -> void:
	Game.set_flag(FlagKeys.BOOK_READ)
	assert_str(Objective.current()).is_equal(Objective.TELL_EMILIA)


func test_a_fine_atto_si_parte_con_emilia() -> void:
	Game.set_flag(FlagKeys.BOOK_READ)
	Game.set_flag(FlagKeys.ACT2_DONE)
	assert_str(Objective.current()).is_equal(Objective.DEPART)


func test_i_ricordi_avvisano_quando_cambiano() -> void:
	# false = non liberare Game a fine test: è un autoload, serve a tutti gli altri test!
	monitor_signals(Game, false)
	Game.set_flag(FlagKeys.KEY_QUEST_STARTED)
	await assert_signal(Game).is_emitted("state_changed")
