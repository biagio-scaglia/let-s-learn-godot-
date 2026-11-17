# Test delle mani d'ombra della schermata iniziale, con due bottoni finti.
# Gli eventi "da soli" (occhi, mani che tastano) sono spenti: qui si prova solo
# quello che succede quando si sceglie una voce.
extends GdUnitTestSuite

var screen: Control
var menu: VBoxContainer
var first: Button
var second: Button
var hands: ShadowHands


func before_test() -> void:
	screen = auto_free(Control.new())
	screen.size = Vector2(640, 360)
	add_child(screen)
	menu = VBoxContainer.new()
	menu.position = Vector2(250, 180)
	screen.add_child(menu)
	for text in ["Prima", "Seconda"]:
		var button := Button.new()
		button.text = text
		menu.add_child(button)
	first = menu.get_child(0)
	second = menu.get_child(1)
	hands = ShadowHands.new()
	hands.idle_events = false
	hands.idle_min = 999.0
	hands.idle_max = 999.0
	screen.add_child(hands)
	hands.watch(menu.get_children())
	await await_idle_frame()


## Aspetta (al massimo 2 secondi) che "condition" diventi vera.
func _wait_for(condition: Callable) -> bool:
	for i in 100:
		if condition.call():
			return true
		await await_millis(20)
	return false


func test_scegliere_una_voce_la_fa_afferrare() -> void:
	var rest := first.position.x
	first.grab_focus()
	assert_object(hands.held).is_same(first)
	assert_bool(await _wait_for(func() -> bool: return first.position.x < rest - 3.0)).is_true()
	assert_bool(is_instance_valid(hands.hand)).is_true()


func test_cambiando_voce_la_prima_torna_al_suo_posto() -> void:
	var rest := first.position.x
	first.grab_focus()
	await _wait_for(func() -> bool: return first.position.x < rest - 3.0)
	# L'id e non la mano: una lambda non può tenere un oggetto che verrà cancellato.
	var old_hand := hands.hand.get_instance_id()
	second.grab_focus()
	assert_object(hands.held).is_same(second)
	assert_bool(await _wait_for(func() -> bool: return is_equal_approx(first.position.x, rest))).is_true()
	# La vecchia mano si ritira e si cancella da sola.
	assert_bool(await _wait_for(func() -> bool: return not is_instance_id_valid(old_hand))).is_true()


func test_confermando_la_voce_viene_trascinata_via() -> void:
	first.grab_focus()
	await hands.seize(first)
	assert_bool(hands.seizing).is_true()
	assert_float(first.modulate.a).is_equal_approx(0.0, 0.01)
	# Mentre trascina, cambiare voce non fa partire altre mani.
	second.grab_focus()
	assert_object(hands.held).is_same(first)


func test_spente_lasciano_la_presa() -> void:
	first.grab_focus()
	hands.set_active(false)
	assert_bool(hands.visible).is_false()
	assert_object(hands.held).is_null()
	second.grab_focus()
	assert_object(hands.held).is_null()
