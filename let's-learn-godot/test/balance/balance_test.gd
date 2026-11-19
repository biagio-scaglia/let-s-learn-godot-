# Test di bilanciamento: ogni combattimento della storia, giocato con il simulatore
# (battle_sim.gd) e con i dadi nel caso peggiore. Stampa anche una tabella dei risultati.
extends GdUnitTestSuite

const SIM := preload("res://test/balance/battle_sim.gd")
const MELMA := preload("res://enemies/melma.tres")
const SPETTRO := preload("res://enemies/spettro.tres")
const OCCHIO := preload("res://enemies/occhio_errante.tres")
const MANO := preload("res://enemies/mano_ombra.tres")
const GUARDIANO := preload("res://enemies/guardiano_rovi.tres")
const BOSS := preload("res://enemies/colui_che_guarda.tres")
## Le pozioni che si possono avere: due dal baule di Lina.
const POTIONS := 2


func _sim(level: int, emilia := false, combo := false, worst := true) -> SIM:
	var sim := SIM.new()
	sim.set_level(level)
	sim.with_emilia = emilia
	sim.combo_unlocked = combo
	sim.hero_roll = -1 if worst else 0
	sim.enemy_roll = 1 if worst else 0
	return sim


func _report(title: String, sim: SIM) -> void:
	prints("[bilanciamento]", title, "| lv", sim.level, "| vinto:", sim.won, "| round:", sim.rounds,
		"| PS rimasti:", "%d/%d" % [maxi(sim.hp, 0), sim.max_hp], "| pozioni:", sim.potions_used)


## Il villaggio, a livello 1, senza pozioni: la Melma e lo Spettro si battono anche
## con i dadi peggiori, ma non in un colpo solo.
func test_i_nemici_del_villaggio_a_livello_1() -> void:
	for enemy: EnemyData in [MELMA, SPETTRO]:
		var sim := _sim(1)
		assert_bool(sim.fight(enemy)).override_failure_message("%s batte Subaru a livello 1" % enemy.name).is_true()
		_report(enemy.name, sim)
		assert_int(sim.rounds).is_between(2, 8)


## Il bosco al livello più basso possibile (solo lo Spettro: livello 2), con Emilia.
## Ogni nemico si batte senza pozioni, e nessuno muore al primo colpo.
func test_i_nemici_del_bosco_al_livello_minimo() -> void:
	var level := SIM.level_for_xp(SPETTRO.xp)
	assert_int(level).is_equal(2)
	for enemy: EnemyData in [OCCHIO, MANO, GUARDIANO]:
		var sim := _sim(level, true)
		assert_bool(sim.fight(enemy)).override_failure_message("%s batte Subaru a livello %d" % [enemy.name, level]).is_true()
		_report(enemy.name, sim)
		assert_int(sim.rounds).is_between(1, 8)


## Il boss chiede di aver combattuto un po' nel bosco. Con lo Spettro e il Guardiano
## dei rovi (quello che "sorveglia i sentieri") si è al livello 4: col trucco dello
## Shamac e le due pozioni si vince anche con i dadi peggiori.
## (Saltando tutto il bosco, a livello 2, si perde: ma morendo si torna nel bosco,
## dove i nemici non battuti aspettano ancora. Nessuno resta bloccato.)
func test_il_boss_si_batte_dopo_il_guardiano() -> void:
	var level := SIM.level_for_xp(SPETTRO.xp + GUARDIANO.xp)
	var sim := _sim(level, true, true)
	sim.potions = POTIONS
	var won := sim.fight(BOSS)
	_report("Colui che guarda (col trucco, dopo il Guardiano)", sim)
	prints("[bilanciamento]   ", ", ".join(sim.log))
	assert_bool(won).override_failure_message("Il boss è imbattibile al livello %d anche col trucco" % level).is_true()


## A livello 3, con dadi normali, il boss si batte ancora (di misura).
func test_il_boss_a_livello_3_e_al_limite() -> void:
	var sim := _sim(3, true, true, false)
	sim.potions = POTIONS
	assert_bool(sim.fight(BOSS)).is_true()
	_report("Colui che guarda (livello 3, dadi normali)", sim)


## Il Guardiano dei rovi è un mini-boss: al livello minimo del bosco serve più di un round.
func test_il_guardiano_non_cade_subito() -> void:
	var sim := _sim(SIM.level_for_xp(SPETTRO.xp), true, false, false)
	assert_bool(sim.fight(GUARDIANO)).is_true()
	assert_int(sim.rounds).is_greater_equal(2)


## Il boss, al livello di chi ha battuto tutto: il trucco resta importante, ma senza
## è comunque una battaglia lunga e dura (lo Sguardo toglie il 70% della vita).
func test_il_boss_a_livello_pieno() -> void:
	var total := MELMA.xp + SPETTRO.xp + 2 * OCCHIO.xp + 2 * MANO.xp + GUARDIANO.xp
	var level := SIM.level_for_xp(total)
	var with_trick := _sim(level, true, true)
	with_trick.potions = POTIONS
	assert_bool(with_trick.fight(BOSS)).is_true()
	_report("Colui che guarda (col trucco, livello pieno)", with_trick)
	# Al primo tentativo non si sa niente e si continua ad attaccare: si perde.
	# È la lezione del Ritorno dalla Morte.
	var naive := _sim(level, true, true)
	naive.potions = POTIONS
	naive.knows_gaze_trick = false
	naive.defends_on_charge = false
	naive.fight(BOSS)
	_report("Colui che guarda (primo tentativo, non sa niente)", naive)
	assert_bool(naive.won).override_failure_message("Al primo tentativo il boss si batte senza sapere niente").is_false()
	# Chi si difende quando lo schermo diventa rosso, ma non sa dello Shamac: solo informazione.
	var careful := _sim(level, true, true)
	careful.potions = POTIONS
	careful.knows_gaze_trick = false
	careful.fight(BOSS)
	_report("Colui che guarda (si difende, senza Shamac)", careful)


## Il boss non deve finire in due colpi: è lo scontro finale.
func test_il_boss_dura_abbastanza() -> void:
	var sim := _sim(5, true, true, false)
	sim.potions = POTIONS
	sim.fight(BOSS)
	assert_int(sim.rounds).is_greater_equal(5)


## Una tabella per vedere tutto: ogni nemico a ogni livello da 1 a 6, dadi peggiori.
func test_tabella() -> void:
	for worst in [true, false]:
		prints("[tabella]", "dadi peggiori" if worst else "dadi normali", "(V = vinto, P = perso, r = round, PS = vita rimasta)")
		for enemy: EnemyData in [MELMA, SPETTRO, OCCHIO, MANO, GUARDIANO, BOSS]:
			var row := PackedStringArray()
			for level in range(1, 7):
				var emilia := enemy not in [MELMA, SPETTRO]
				var sim := _sim(level, emilia, emilia, worst)
				sim.potions = POTIONS if enemy == BOSS else 0
				var won := sim.fight(enemy)
				row.append("lv%d %s r%d PS%d" % [level, "V" if won else "P", sim.rounds, maxi(sim.hp, 0)])
			prints("[tabella]", enemy.name, "|", " | ".join(row))


## La curva dei livelli: alla fine del bosco si è tra il livello 3 e il 5.
func test_la_curva_dei_livelli() -> void:
	var total := MELMA.xp + SPETTRO.xp + 2 * OCCHIO.xp + 2 * MANO.xp + GUARDIANO.xp
	var level := SIM.level_for_xp(total)
	prints("[bilanciamento] esperienza prima del boss:", total, "-> livello", level,
		"| dopo il boss:", SIM.level_for_xp(total + BOSS.xp))
	assert_int(level).is_between(3, 5)
