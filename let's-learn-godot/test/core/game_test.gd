# Test di Game: ricordi e "chi può fare cosa".
# Usa l'autoload vero, quindi rimette tutto a posto dopo ogni test.
extends GdUnitTestSuite


func before_test() -> void:
	Game.flags.clear()
	Game.in_cutscene = false
	Game.changing_scene = false


func after_test() -> void:
	before_test()


func test_ricordi() -> void:
	assert_bool(Game.has_flag(FlagKeys.CHEST_OPEN)).is_false()
	Game.set_flag(FlagKeys.CHEST_OPEN)
	assert_bool(Game.has_flag(FlagKeys.CHEST_OPEN)).is_true()


func test_le_chiavi_dei_ricordi_restano_quelle_dei_salvataggi() -> void:
	assert_str(FlagKeys.INTRO_SEEN).is_equal("intro_vista")
	assert_str(FlagKeys.CHEST_OPEN).is_equal("baule_aperto")


func test_chiavi_per_nodo_diverse_per_parlare_e_raccogliere() -> void:
	# Il nodo deve stare nell'albero: le chiavi usano il suo percorso.
	var node := auto_free(Node.new()) as Node
	add_child(node)
	assert_str(FlagKeys.talked(node)).starts_with("talked:")
	assert_str(FlagKeys.picked(node)).starts_with("preso:")


func test_durante_una_cutscene_il_giocatore_non_si_muove() -> void:
	assert_bool(Game.player_can_move()).is_true()
	Game.in_cutscene = true
	assert_bool(Game.player_can_move()).is_false()


func test_durante_un_cambio_di_scena_il_giocatore_non_si_muove() -> void:
	Game.changing_scene = true
	assert_bool(Game.player_can_move()).is_false()


func test_fuori_da_un_livello_niente_menu() -> void:
	# Durante i test la scena attuale è quella di gdUnit, non un livello.
	assert_bool(Game.can_open_menu()).is_false()
