# Test delle Scaglie di gelo: la mossa con Emilia (atto 3).
extends GdUnitTestSuite

var result := ""
var _message_time := 0.0
var _transition_time := 0.0


func before_test() -> void:
	_clean_state()
	_message_time = Battle.message_time
	Battle.message_time = 0.02
	_transition_time = Battle.transition_time
	Battle.transition_time = 0.05
	Battle.rng.seed = 99
	Battle.finished.connect(_on_finished)


func after_test() -> void:
	Battle.finished.disconnect(_on_finished)
	Battle.message_time = _message_time
	Battle.transition_time = _transition_time
	Battle.flee_chance = 0.5
	_clean_state()


func _on_finished(battle_result: String) -> void:
	result = battle_result


func _clean_state() -> void:
	Game.flags.clear()
	Game.in_cutscene = false
	Inventory.reset()
	Stats.reset()
	result = ""


func _wait_turn() -> void:
	for i in 300:
		if Battle.commands.menu.visible or not Battle.is_active:
			return
		await await_millis(20)


func _escape() -> void:
	if Battle.is_active:
		Battle.flee_chance = 1.0
		Battle.commands.flee_button.pressed.emit()
		await _wait_turn()
