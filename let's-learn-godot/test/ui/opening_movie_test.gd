# Test del filmato iniziale: quali tasti lo saltano.
extends GdUnitTestSuite

const MOVIE := preload("res://ui/opening_movie.gd")


func _key(keycode: Key, pressed := true) -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.pressed = pressed
	return event


func test_un_tasto_normale_salta() -> void:
	assert_bool(MOVIE.is_skip_input(_key(KEY_ENTER))).is_true()
	assert_bool(MOVIE.is_skip_input(_key(KEY_A))).is_true()


func test_il_volume_non_salta() -> void:
	for keycode: Key in [KEY_VOLUMEUP, KEY_VOLUMEDOWN, KEY_VOLUMEMUTE, KEY_MEDIAPLAY, KEY_SHIFT]:
		assert_bool(MOVIE.is_skip_input(_key(keycode))).is_false()


func test_conta_solo_quando_premi() -> void:
	assert_bool(MOVIE.is_skip_input(_key(KEY_ENTER, false))).is_false()


func test_clic_si_rotella_no() -> void:
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	assert_bool(MOVIE.is_skip_input(click)).is_true()
	var wheel := InputEventMouseButton.new()
	wheel.button_index = MOUSE_BUTTON_WHEEL_DOWN
	wheel.pressed = true
	assert_bool(MOVIE.is_skip_input(wheel)).is_false()
