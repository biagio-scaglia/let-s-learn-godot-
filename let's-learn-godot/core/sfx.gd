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
const SWING := "swing"
const KICK := "kick"
const WEAK := "weak"
const BREAK := "break"
const GUARD := "guard"
const CHARGE := "charge"
const SHAMAC := "shamac"
const BATTLE_START := "battle_start"
const ICE_CAST := "ice_cast"
const ICE_HIT := "ice_hit"
const ICE_SHATTER := "ice_shatter"
const SKILL_UNLOCK := "skill_unlock"
const EYE_CLOSE := "eye_close"
const EYE_ALERT := "eye_alert"
const FOG_DISSOLVE := "fog_dissolve"
const GAZE_CHARGE := "gaze_charge"
const GAZE_BEAM := "gaze_beam"
const BOSS_ROAR := "boss_roar"
const ULT_CUTIN := "ultimate_cutin"
const ULT_CRYSTAL := "ultimate_crystal"
const ULT_FINALE := "ultimate_finale"

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
	SWING: ["res://assets/effects/swing.wav", -8.0],
	KICK: ["res://assets/effects/kick.wav", -3.0],
	WEAK: ["res://assets/effects/weak.wav", -6.0],
	BREAK: ["res://assets/effects/break.wav", -3.0],
	GUARD: ["res://assets/effects/guard.wav", -8.0],
	CHARGE: ["res://assets/kenney_sci_fi_sounds/forceField_001.ogg", -6.0],
	BATTLE_START: ["res://assets/effects/battle_start.wav", -4.0],
	SHAMAC: ["res://assets/kenney_interface_sounds/glitch_002.ogg", -4.0],
	ICE_CAST: ["res://assets/effects/ice_cast.wav", -5.0],
	ICE_HIT: ["res://assets/effects/ice_hit.wav", -8.0],
	ICE_SHATTER: ["res://assets/effects/ice_shatter.wav", -3.0],
	SKILL_UNLOCK: ["res://assets/effects/skill_unlock.wav", -4.0],
	EYE_CLOSE: ["res://assets/forest/eye_close.wav", -3.0],
	EYE_ALERT: ["res://assets/forest/eye_alert.wav", -5.0],
	FOG_DISSOLVE: ["res://assets/forest/fog_dissolve.wav", -3.0],
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
