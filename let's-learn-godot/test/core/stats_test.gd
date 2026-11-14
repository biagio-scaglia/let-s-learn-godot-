# Test delle statistiche. Usa uno Stats nuovo, non l'autoload: così non tocca la partita.
extends GdUnitTestSuite

const StatsScript := preload("res://core/stats.gd")

var stats: Node


func before_test() -> void:
	stats = auto_free(StatsScript.new())


func test_si_parte_dal_livello_uno() -> void:
	assert_dict(stats.to_dict()).is_equal(StatsScript.BASE)


func test_il_danno_e_attacco_meno_difesa() -> void:
	assert_int(StatsScript.damage(5, 2)).is_equal(3)
	assert_int(StatsScript.damage(5, 2, 1)).is_equal(4)
	assert_int(StatsScript.damage(5, 2, -1)).is_equal(2)


func test_un_colpo_fa_sempre_almeno_un_danno() -> void:
	assert_int(StatsScript.damage(1, 10)).is_equal(1)
	assert_int(StatsScript.damage(3, 3, -1)).is_equal(1)


func test_la_salute_non_scende_sotto_zero() -> void:
	stats.take_damage(7)
	assert_int(stats.hp).is_equal(13)
	stats.take_damage(100)
	assert_int(stats.hp).is_equal(0)


func test_la_cura_non_supera_il_massimo() -> void:
	stats.take_damage(5)
	assert_int(stats.heal(12)).is_equal(5)   # ne servivano solo 5
	assert_int(stats.hp).is_equal(20)
	assert_int(stats.heal(12)).is_equal(0)


func test_l_esperienza_si_accumula() -> void:
	assert_int(stats.gain_xp(4)).is_equal(0)
	assert_int(stats.xp).is_equal(4)
	assert_int(stats.level).is_equal(1)


func test_salire_di_livello_migliora_tutto_e_cura() -> void:
	stats.take_damage(15)
	assert_int(stats.gain_xp(12)).is_equal(1)
	assert_int(stats.level).is_equal(2)
	assert_int(stats.xp).is_equal(2)             # l'esperienza in più non si perde
	assert_int(stats.max_hp).is_equal(25)
	assert_int(stats.hp).is_equal(25)
	assert_int(stats.attack).is_equal(6)
	assert_int(stats.defense).is_equal(3)
	assert_int(stats.xp_to_next()).is_equal(20)  # il prossimo livello costa di più


func test_tanta_esperienza_fa_salire_piu_livelli() -> void:
	# 10 per il livello 2, altri 20 per il livello 3.
	assert_int(stats.gain_xp(30)).is_equal(2)
	assert_int(stats.level).is_equal(3)
	assert_int(stats.xp).is_equal(0)


func test_salire_di_livello_manda_il_segnale() -> void:
	var levels := []
	stats.leveled_up.connect(func(new_level: int) -> void: levels.append(new_level))
	stats.gain_xp(10)
	assert_array(levels).is_equal([2])


func test_reset_riparte_o_ricarica() -> void:
	stats.gain_xp(10)
	var saved: Dictionary = stats.to_dict()
	stats.reset()
	assert_int(stats.level).is_equal(1)
	stats.reset(saved)
	assert_int(stats.level).is_equal(2)
	assert_int(stats.max_hp).is_equal(25)


func test_un_vecchio_salvataggio_senza_statistiche() -> void:
	stats.gain_xp(10)
	stats.reset({})   # come un salvataggio di prima che esistessero
	assert_dict(stats.to_dict()).is_equal(StatsScript.BASE)
