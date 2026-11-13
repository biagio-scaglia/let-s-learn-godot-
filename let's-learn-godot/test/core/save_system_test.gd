# Test del salvataggio. Usa un file suo: il salvataggio vero non viene mai toccato.
extends GdUnitTestSuite

const TEST_PATH := "user://test_salvataggio.cfg"

var _real_path: String


func before_test() -> void:
	_real_path = SaveSystem.path
	SaveSystem.path = TEST_PATH
	_delete_test_file()


func after_test() -> void:
	_delete_test_file()
	SaveSystem.path = _real_path


func _delete_test_file() -> void:
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)


## Scrive un salvataggio come lo faceva il gioco prima del riordino del codice.
func _write_old_save() -> void:
	var config := ConfigFile.new()
	config.set_value("partita", "scena", "res://world/house.tscn")
	config.set_value("partita", "posizione", Vector2(200, 150))
	config.set_value("partita", "direzione", "up")
	config.set_value("partita", "data", "2026-11-13 09:49:33")
	config.set_value("partita", "ricordi", {"baule_aperto": true})
	config.set_value("partita", "zaino", {"pozione": 2, "moneta": 5})
	config.save(TEST_PATH)


func test_senza_file_niente_salvataggio() -> void:
	assert_bool(SaveSystem.has_save()).is_false()
	assert_dict(SaveSystem.save_info()).is_empty()


func test_senza_giocatore_non_salva() -> void:
	# Nei test non c'è un livello con Subaru: save_game deve dire di no, non rompersi.
	assert_bool(SaveSystem.save_game()).is_false()
	assert_bool(SaveSystem.has_save()).is_false()


func test_info_di_un_vecchio_salvataggio() -> void:
	_write_old_save()
	assert_bool(SaveSystem.has_save()).is_true()
	assert_dict(SaveSystem.save_info()).is_equal({
		"luogo": "Casa di Lina",
		"data": "2026-11-13 09:49:33",
	})


func test_i_vecchi_salvataggi_usano_le_stesse_chiavi() -> void:
	# I valori salvati devono corrispondere alle costanti di oggi.
	_write_old_save()
	var config := ConfigFile.new()
	config.load(TEST_PATH)
	var flags: Dictionary = config.get_value("partita", "ricordi")
	var bag: Dictionary = config.get_value("partita", "zaino")
	assert_bool(flags.has(FlagKeys.CHEST_OPEN)).is_true()
	assert_bool(bag.has(Inventory.POTION) and bag.has(Inventory.COIN)).is_true()
	assert_str(config.get_value("partita", "direzione")).is_equal(Facing.UP)
