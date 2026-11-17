# Test del congedo. Qui la finestra resta DENTRO il gioco (i test non possono aprirne
# sul desktop) e al posto di chiudere tutto ci segniamo che si sarebbe chiuso.
extends GdUnitTestSuite

var quit_called := 0


func before_test() -> void:
	quit_called = 0
	Farewell.separate_window = false
	Farewell.speed = 0.05
	Farewell.quit_action = func() -> void: quit_called += 1


func after_test() -> void:
	if is_instance_valid(Farewell.window):
		Farewell.window.queue_free()
	Farewell.leaving = false
	Farewell.separate_window = true
	Farewell.speed = 1.0
	Farewell.quit_action = func() -> void: Farewell.get_tree().quit()


func test_la_x_della_finestra_non_chiude_subito() -> void:
	assert_bool(get_tree().auto_accept_quit).is_false()


func test_chiede_sei_sicuro_e_poi_chiude() -> void:
	Farewell.leave()
	assert_bool(is_instance_valid(Farewell.window)).is_true()
	assert_str(Farewell.label.text).is_equal("Sei sicuro?")
	for i in 100:
		if quit_called > 0:
			break
		await await_millis(20)
	assert_int(quit_called).is_equal(1)
	assert_float(Farewell.label.visible_ratio).is_equal_approx(1.0, 0.01)


func test_chiudere_due_volte_non_rifa_tutto() -> void:
	Farewell.leave()
	var first := Farewell.window
	Farewell.leave()
	assert_object(Farewell.window).is_same(first)
	for i in 100:
		if quit_called > 0:
			break
		await await_millis(20)
	await await_millis(100)
	assert_int(quit_called).is_equal(1)


func test_la_x_vera_apre_il_congedo() -> void:
	# Come fa Godot quando clicchi la X: la notifica "gira" per i nodi. Mentre gira
	# non si possono aggiungere figli, quindi il congedo deve partire un istante dopo.
	Farewell.propagate_notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)
	await await_idle_frame()
	assert_bool(is_instance_valid(Farewell.window)).is_true()
	assert_bool(Farewell.window.is_inside_tree()).is_true()
	for i in 100:
		if quit_called > 0:
			break
		await await_millis(20)
	assert_int(quit_called).is_equal(1)
