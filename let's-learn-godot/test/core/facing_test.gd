# Test di Facing: da un vettore alla direzione in cui guardare.
extends GdUnitTestSuite


func test_quattro_direzioni() -> void:
	assert_str(Facing.from_vector(Vector2.RIGHT)).is_equal(Facing.RIGHT)
	assert_str(Facing.from_vector(Vector2.LEFT)).is_equal(Facing.LEFT)
	assert_str(Facing.from_vector(Vector2.UP)).is_equal(Facing.UP)
	assert_str(Facing.from_vector(Vector2.DOWN)).is_equal(Facing.DOWN)


func test_diagonali_scelgono_l_asse_dominante() -> void:
	assert_str(Facing.from_vector(Vector2(3, 1))).is_equal(Facing.RIGHT)
	assert_str(Facing.from_vector(Vector2(-1, -5))).is_equal(Facing.UP)


func test_i_valori_restano_quelli_dei_salvataggi() -> void:
	# Se qualcuno cambia queste stringhe, i vecchi salvataggi si rompono: il test lo dice.
	assert_array([Facing.DOWN, Facing.UP, Facing.LEFT, Facing.RIGHT]) \
		.contains_exactly(["down", "up", "left", "right"])
