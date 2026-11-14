# Test dell'obiettivo: il testo giusto per ogni momento della missione della chiave.
extends GdUnitTestSuite


func before_test() -> void:
	Game.load_flags()
	Inventory.reset()


func after_test() -> void:
	before_test()


func test_all_inizio_si_esplora() -> void:
	assert_str(Objective.current()).is_equal(Objective.EXPLORE)


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


func test_a_baule_aperto_nessun_obiettivo() -> void:
	Game.set_flag(FlagKeys.KEY_QUEST_STARTED)
	Game.set_flag(FlagKeys.CHEST_OPEN)
	assert_str(Objective.current()).is_equal(Objective.NONE)


func test_un_vecchio_salvataggio_a_missione_finita() -> void:
	# I salvataggi di prima non hanno i ricordi nuovi, solo "baule_aperto".
	Game.load_flags({"baule_aperto": true})
	assert_str(Objective.current()).is_equal(Objective.NONE)


func test_i_ricordi_avvisano_quando_cambiano() -> void:
	# false = non liberare Game a fine test: è un autoload, serve a tutti gli altri test!
	monitor_signals(Game, false)
	Game.set_flag(FlagKeys.KEY_QUEST_STARTED)
	await assert_signal(Game).is_emitted("state_changed")
