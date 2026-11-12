extends Node
## Stato del gioco che deve sopravvivere ai cambi di scena. È un autoload chiamato "Game".
##
## Quando si cambia scena, la vecchia viene distrutta con tutti i suoi nodi e le loro
## variabili. Quello che va ricordato (con chi hai parlato, dove comparire…) sta qui.

## In quale Marker2D (figlio di "Spawns") far comparire il giocatore nella prossima scena.
var spawn_point := ""
## Verso dove deve guardare il giocatore all'arrivo ("down", "up", "left", "right").
var spawn_facing := ""
## I ricordi del gioco: quante volte hai parlato con qualcuno, e in futuro porte, oggetti…
var flags := {}
## True durante un cambio di scena.
var changing_scene := false

var _door_sound: AudioStreamPlayer


func _ready() -> void:
	_door_sound = AudioStreamPlayer.new()
	_door_sound.stream = load("res://assets/effects/door.wav")
	_door_sound.volume_db = -4.0
	add_child(_door_sound)


## Il giocatore può muoversi? No durante un dialogo o un cambio di scena.
func player_can_move() -> bool:
	return not changing_scene and not Dialogue.is_active


## Passa a un'altra scena con la dissolvenza, e fa comparire il giocatore in "spawn".
func change_scene(path: String, spawn: String, facing := "") -> void:
	if changing_scene:
		return
	changing_scene = true
	spawn_point = spawn
	spawn_facing = facing
	_door_sound.play()
	await Fade.fade_out()
	get_tree().change_scene_to_file(path)
	# La nuova scena viene aggiunta alla fine del frame: aspettiamo che sia pronta.
	await get_tree().process_frame
	await get_tree().process_frame
	changing_scene = false
	await Fade.fade_in()
