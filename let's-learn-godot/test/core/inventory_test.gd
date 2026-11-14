# Test dello zaino. Usa un Inventory nuovo, non l'autoload: così non tocca la partita
# e non fa comparire avvisi (nessuno ascolta i suoi segnali).
extends GdUnitTestSuite

const InventoryScript := preload("res://core/inventory.gd")

var inventory: Node


func before_test() -> void:
	inventory = auto_free(InventoryScript.new())


func test_all_inizio_e_vuoto() -> void:
	assert_dict(inventory.items).is_empty()
	assert_bool(inventory.has(Inventory.KEY)).is_false()


func test_aggiungere_somma_le_quantita() -> void:
	inventory.add(Inventory.POTION, 2)
	inventory.add(Inventory.POTION)
	assert_int(inventory.items[Inventory.POTION]).is_equal(3)
	assert_bool(inventory.has(Inventory.POTION)).is_true()


func test_togliere_fino_a_zero_cancella_l_oggetto() -> void:
	inventory.add(Inventory.KEY)
	inventory.remove(Inventory.KEY)
	assert_bool(inventory.has(Inventory.KEY)).is_false()
	assert_dict(inventory.items).not_contains_keys([Inventory.KEY])


func test_aggiungere_manda_i_segnali() -> void:
	monitor_signals(inventory)
	inventory.add(Inventory.COIN, 5)
	await assert_signal(inventory).is_emitted("changed")
	await assert_signal(inventory).is_emitted("item_added", [inventory.item(Inventory.COIN), 5])


func test_reset_copia_i_dati() -> void:
	var data := {Inventory.POTION: 2}
	inventory.reset(data)
	inventory.add(Inventory.POTION)
	# La copia è cambiata, l'originale no.
	assert_int(inventory.items[Inventory.POTION]).is_equal(3)
	assert_int(data[Inventory.POTION]).is_equal(2)


func test_ogni_oggetto_ha_id_nome_e_icona() -> void:
	for id in Inventory.ITEMS:
		var item: Item = inventory.item(id)
		assert_str(item.id).is_equal(id)
		assert_str(item.name).is_not_empty()
		assert_object(item.icon).is_not_null()


func test_usare_una_pozione_cura_e_la_consuma() -> void:
	Stats.reset()
	Stats.take_damage(15)
	inventory.add(Inventory.POTION, 2)
	assert_int(inventory.use(Inventory.POTION)).is_equal(12)
	assert_int(Stats.hp).is_equal(17)
	assert_int(inventory.items[Inventory.POTION]).is_equal(1)
	Stats.reset()


func test_in_piena_forma_la_pozione_resta_nello_zaino() -> void:
	Stats.reset()
	inventory.add(Inventory.POTION)
	assert_int(inventory.use(Inventory.POTION)).is_equal(0)
	assert_bool(inventory.has(Inventory.POTION)).is_true()


func test_la_chiave_non_si_usa() -> void:
	Stats.reset()
	Stats.take_damage(5)
	inventory.add(Inventory.KEY)
	assert_int(inventory.use(Inventory.KEY)).is_equal(0)
	assert_bool(inventory.has(Inventory.KEY)).is_true()
	Stats.reset()
