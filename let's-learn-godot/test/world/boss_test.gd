# Test del boss: Colui che guarda, lo Sguardo, il ricordo che sopravvive alla morte,
# le fasi e l'ultimate di Subaru ed Emilia.
extends GdUnitTestSuite

const BOSS := preload("res://enemies/colui_che_guarda.tres")

var result := ""
var _message_time := 0.0
var _transition_time := 0.0


func before_test() -> void:
	_clean_state()
	_message_time = Battle.message_time
	Battle.message_time = 0.02
	_transition_time = Battle.transition_time
	Battle.transition_time = 0.05
	Battle.rng.seed = 7
	Battle.finished.connect(_on_finished)


func after_test() -> void:
	Battle.finished.disconnect(_on_finished)
	Battle.message_time = _message_time
	Battle.transition_time = _transition_time
	_clean_state()


func _on_finished(battle_result: String) -> void:
	result = battle_result


func _clean_state() -> void:
	ReturnByDeath.is_active = false
	ReturnByDeath._reset()
	Game.load_flags({FlagKeys.FOREST_ARRIVED: true})   # Emilia nel party
	Game.memories = {}
	Game.in_cutscene = false
	Game.checkpoint = {}
	Inventory.reset()
	Stats.reset()
	Stats.gain_xp(100)   # livello 5, come arrivando al boss
	result = ""


func _wait_turn() -> void:
	for i in 400:
		if Battle.commands.menu.visible or not Battle.is_active:
			return
		await await_millis(20)


## Fa finire un turno (di Subaru o di Emilia) difendendosi, senza toccare il boss.
func _pass_turn() -> void:
	Battle.commands.defend_button.pressed.emit()
	await await_millis(60)
	await _wait_turn()


func _finish_with_ultimate() -> void:
	Battle.enemy_hp = 1
	Battle.behavior.phase = 3
	await _wait_turn()
	Battle.commands.ultimate_button.pressed.emit()
	for i in 400:
		if not Battle.is_active:
			return
		await await_millis(20)
