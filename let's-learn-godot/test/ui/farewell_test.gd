# Test del congedo. Qui la finestra resta DENTRO il gioco (i test non possono aprirne
# sul desktop) e al posto di chiudere tutto ci segniamo che si sarebbe chiuso.
extends GdUnitTestSuite

var quit_called := 0


func before_test() -> void:
	quit_called = 0
	Farewell.separate_window = false
	Farewell.speed = 0.05
	Farewell.patience = 9.0
	Farewell.quit_action = func() -> void: quit_called += 1


func after_test() -> void:
	Farewell._close_window()
	Farewell.leaving = false
	Farewell.separate_window = true
	Farewell.speed = 1.0
	Farewell.patience = 9.0
	Farewell.quit_action = func() -> void: Farewell.get_tree().quit()
	ReturnByDeath.is_active = false


## Aspetta che "condition" diventi vera, al massimo 3 secondi.
func _wait_until(condition: Callable) -> bool:
	for i in 150:
		if condition.call():
			return true
		await await_millis(20)
	return false


# ---------- Le parti "pure" ----------

func test_il_nome_viene_dal_login() -> void:
	assert_str(Farewell.name_from_login("biagio.scaglia")).is_equal("Biagio")
	assert_str(Farewell.name_from_login("MARIO_ROSSI")).is_equal("Mario")
	assert_str(Farewell.name_from_login("  anna  ")).is_equal("Anna")
	assert_str(Farewell.name_from_login("")).is_equal("straniero")


func test_la_frase_d_addio_dipende_da_te() -> void:
	# Le regole, dalla più forte: game over, notte, appena arrivato, morti, normale.
	assert_str(Farewell.goodbye_line("Ada", 3, 3, 12, 50, true)).is_equal("Scappi proprio adesso, Ada?")
	assert_str(Farewell.goodbye_line("Ada", 3, 3, 7, 50, false)).is_equal("Sono le 3:07, Ada. Dovresti dormire.")
	assert_str(Farewell.goodbye_line("Ada", 3, 15, 0, 1, false)).is_equal("Te ne vai già, Ada?")
	assert_str(Farewell.goodbye_line("Ada", 1, 15, 0, 50, false)).is_equal("Sei morto una volta. Tornerai, Ada.")
	assert_str(Farewell.goodbye_line("Ada", 4, 15, 0, 50, false)).is_equal("Sei morto 4 volte. Tornerai, Ada.")
	assert_str(Farewell.goodbye_line("Ada", 0, 15, 0, 50, false)).is_equal("Ci rivedremo, Ada.")


# ---------- La finestra ----------

func test_la_x_della_finestra_non_chiude_subito() -> void:
	assert_bool(get_tree().auto_accept_quit).is_false()


func test_prima_sembra_una_finestra_normale() -> void:
	Farewell.leave()
	assert_str(Farewell.title_label.text).is_equal(Farewell.TITLE)
	assert_str(Farewell.message.text).is_equal(Farewell.QUESTION)
	assert_bool(Farewell.no_button.has_focus()).is_true()   # la scelta prudente
	Farewell.choose("no")
	await _wait_until(func() -> bool: return not Farewell.leaving)


func test_se_aspetti_ti_chiama_per_nome() -> void:
	Farewell.leave()
	var name := Farewell.user_name
	assert_bool(await _wait_until(func() -> bool: return Farewell.message.text.begins_with(name))).is_true()
	assert_str(Farewell.title_label.text).is_equal("???")
	Farewell.choose("no")
	await _wait_until(func() -> bool: return not Farewell.leaving)


func test_si_e_il_gioco_si_chiude() -> void:
	Farewell.leave()
	Farewell.yes_button.pressed.emit()
	assert_bool(await _wait_until(func() -> bool: return quit_called > 0)).is_true()
	assert_int(quit_called).is_equal(1)
	assert_bool(Farewell.goodbye.visible).is_true()


func test_no_e_si_resta() -> void:
	Farewell.leave()
	Farewell.no_button.pressed.emit()
	assert_bool(await _wait_until(func() -> bool: return not Farewell.leaving)).is_true()
	assert_int(quit_called).is_equal(0)
	assert_object(Farewell.window).is_null()
	# E si può chiedere di nuovo di uscire.
	Farewell.leave()
	assert_bool(Farewell.leaving).is_true()
	Farewell.choose("no")
	await _wait_until(func() -> bool: return not Farewell.leaving)


func test_se_non_rispondi_decide_lei() -> void:
	Farewell.patience = 0.5
	Farewell.leave()
	assert_bool(await _wait_until(func() -> bool: return quit_called > 0)).is_true()


func test_chiudere_due_volte_non_rifa_tutto() -> void:
	Farewell.leave()
	var first := Farewell.window
	Farewell.leave()
	assert_object(Farewell.window).is_same(first)
	Farewell.choose("yes")
	await _wait_until(func() -> bool: return quit_called > 0)
	await await_millis(100)
	assert_int(quit_called).is_equal(1)


func test_nel_game_over_ha_una_frase_sua() -> void:
	ReturnByDeath.is_active = true
	Farewell.leave()
	Farewell.choose("yes")
	await _wait_until(func() -> bool: return quit_called > 0)
	assert_str(Farewell.goodbye.text).starts_with("Scappi proprio adesso")


func test_la_x_vera_apre_il_congedo() -> void:
	# Come fa Godot quando clicchi la X: la notifica "gira" per i nodi. Mentre gira
	# non si possono aggiungere figli, quindi il congedo deve partire un istante dopo.
	Farewell.propagate_notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)
	await await_idle_frame()
	assert_bool(is_instance_valid(Farewell.window)).is_true()
	assert_bool(Farewell.window.is_inside_tree()).is_true()
	Farewell.choose("yes")
	assert_bool(await _wait_until(func() -> bool: return quit_called > 0)).is_true()


func test_dal_game_over_si_puo_uscire() -> void:
	var quit_button: MenuItem = ReturnByDeath.quit_button
	assert_str(quit_button.text).is_equal("Esci dal gioco")
	quit_button.pressed.emit()
	await await_idle_frame()
	assert_bool(Farewell.leaving).is_true()
	Farewell.choose("no")
	await _wait_until(func() -> bool: return not Farewell.leaving)


func test_un_clic_su_si_viene_sentito() -> void:
	Farewell.leave()
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	click.position = Farewell.yes_button.get_rect().get_center()
	Farewell._on_screen_input(click)
	assert_bool(await _wait_until(func() -> bool: return quit_called > 0)).is_true()


func test_esc_vuol_dire_no() -> void:
	Farewell.leave()
	var esc := InputEventAction.new()
	esc.action = "ui_cancel"
	esc.pressed = true
	Farewell._on_window_input(esc)
	assert_bool(await _wait_until(func() -> bool: return not Farewell.leaving)).is_true()
	assert_int(quit_called).is_equal(0)


func test_con_il_si_arrivano_lei_lo_strappo_e_l_occhio() -> void:
	Farewell.leave()
	Farewell.choose("yes")
	assert_bool(await _wait_until(func() -> bool: return Farewell.goodbye.visible)).is_true()
	# Lei, nella sua finestra accanto.
	assert_bool(is_instance_valid(Farewell._figure)).is_true()
	# La finestra del congedo è strappata del tutto...
	var mat := Farewell._screen.material as ShaderMaterial
	assert_float(mat.get_shader_parameter("tear")).is_equal_approx(1.0, 0.01)
	# ...e nello strappo l'occhio è aperto.
	assert_float(Farewell._eye.scale.y).is_greater(0.9)
	assert_bool(await _wait_until(func() -> bool: return quit_called > 0)).is_true()
