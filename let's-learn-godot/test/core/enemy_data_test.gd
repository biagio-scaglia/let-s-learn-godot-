# Test dei dati dei nemici: le pose del foglio e un equilibrio giocabile.
extends GdUnitTestSuite

const MELMA := preload("res://enemies/melma.tres")
const SPETTRO := preload("res://enemies/spettro.tres")


func test_i_nemici_hanno_tutte_le_pose() -> void:
	for data: EnemyData in [MELMA, SPETTRO]:
		assert_bool(data.animated()).is_true()
		# Il foglio è largo esattamente "frames" celle quadrate.
		assert_int(data.texture.get_width()).is_equal(int(data.cell_size()) * data.frames)


func test_il_ritratto_e_solo_la_prima_posa() -> void:
	var face := SPETTRO.portrait() as AtlasTexture
	assert_object(face).is_not_null()
	assert_vector(face.region.size).is_equal(Vector2(32, 32))
	assert_vector(face.region.position).is_equal(Vector2.ZERO)


func test_senza_immagine_una_cella_da_16() -> void:
	var data := EnemyData.new()
	assert_float(data.cell_size()).is_equal(16.0)
	assert_bool(data.animated()).is_false()
	assert_object(data.portrait()).is_null()


func test_lo_spettro_si_puo_battere_al_primo_livello() -> void:
	# Quanti colpi servono a Subaru (livello 1, pugno base) e quanti allo Spettro.
	var hero_hits := ceili(SPETTRO.max_hp / float(Stats.damage(Stats.BASE.attack, SPETTRO.defense)))
	var spectre_hits := ceili(Stats.BASE.max_hp / float(Stats.damage(SPETTRO.attack, Stats.BASE.defense)))
	# Senza debolezze né pozioni deve bastare: Subaru vince prima di cadere.
	assert_int(hero_hits).is_less(spectre_hits)
