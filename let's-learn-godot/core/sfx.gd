extends Node
## I suoni dei menu e degli eventi. È un autoload chiamato "Sfx".
##     Sfx.play(Sfx.CONFIRM)
## Funziona anche a gioco in pausa: i menu di pausa e lo zaino suonano da qui.

const MOVE := "move"
const CONFIRM := "confirm"
const BACK := "back"
const PICKUP := "pickup"
const CHEST_OPEN := "chest_open"
const SAVE := "save"
const DOOR := "door"
const HIT := "hit"
const HEAL := "heal"
const LEVEL_UP := "level_up"

## Nome del suono → [file, volume in decibel].
const SOUNDS := {
	MOVE: ["res://assets/ui/menu_move.wav", -6.0],
	CONFIRM: ["res://assets/ui/menu_confirm.wav", -6.0],
	BACK: ["res://assets/ui/menu_back.wav", -6.0],
	PICKUP: ["res://assets/effects/pickup.wav", -4.0],
	CHEST_OPEN: ["res://assets/effects/chest_open.wav", -4.0],
	SAVE: ["res://assets/effects/save.wav", -4.0],
	DOOR: ["res://assets/effects/door.wav", -4.0],
	HIT: ["res://assets/effects/hit.wav", -3.0],
	HEAL: ["res://assets/effects/heal.wav", -6.0],
	LEVEL_UP: ["res://assets/effects/level_up.wav", -6.0],
}

var _players := {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for sound in SOUNDS:
		var player := AudioStreamPlayer.new()
		player.stream = load(SOUNDS[sound][0])
		player.volume_db = SOUNDS[sound][1]
		add_child(player)
		_players[sound] = player


func play(sound: String) -> void:
	assert(_players.has(sound), "Suono sconosciuto: " + sound)
	_players[sound].play()
