class_name StoneEye
extends StaticBody2D
## Un occhio di pietra del Bosco Senza Tempo (atto 3). Spazza il terreno con un cono
## di luce viola: se Subaru ci entra, lo vede, e un lampo lo respinge indietro.
## Arrivandoci alle spalle (o mentre guarda altrove) si può chiudere premendo E.
## Chiuso, manda un raggio alla nebbia viola che sbarra la radura (vedi FogGate).

## Emesso quando l'occhio si chiude, con il suo id ("ovest", "est" o "sud").
signal closed(id: String)

## Quale occhio è: decide il ricordo (FlagKeys.eye_closed) e quale bagliore spegne.
@export var eye_id := "ovest"
## Verso dove guarda al centro della spazzata, in gradi (0 = destra, 90 = giù).
@export var base_angle := 0.0
## Di quanti gradi gira a destra e a sinistra del centro.
@export var sweep := 60.0
## Quanto ci mette ad andare da un lato all'altro, in secondi.
@export var sweep_time := 2.6
## Fin dove vede, in pixel.
@export var sight := 170.0
## Quanto è largo il cono, in gradi (metà a destra, metà a sinistra).
@export var cone := 40.0
## Dove rimandarlo quando ti vede: un punto del mondo, lontano dal cono.
@export var respawn := Vector2.ZERO
## Quanti PS costa farsi vedere (non si muore mai, al massimo resta 1 PS).
@export var sight_damage := 2

@onready var sprite: Sprite2D = $Sprite2D
@onready var gaze: Node2D = $Gaze
@onready var cone_shape: Polygon2D = $Gaze/Cone
@onready var glow: PointLight2D = $Glow
@onready var implode: CPUParticles2D = $Implode
@onready var interactable: Interactable = $Interactable

enum Lids { OPEN, HALF, SHUT }

var is_closed := false
var _sweep_tween: Tween
var _player: Node2D
## Mentre lo respinge o si chiude, non controlla di nuovo.
var _busy := false


func _ready() -> void:
	add_to_group("stone_eyes")
	_player = get_tree().get_first_node_in_group("player") as Node2D
	_build_cone()
	interactable.interacted.connect(_on_interacted)
	if Game.has_flag(FlagKeys.eye_closed(eye_id)):
		_show_closed()
		return
	gaze.rotation_degrees = base_angle - sweep
	_sweep_tween = create_tween().set_loops()
	_sweep_tween.tween_property(gaze, "rotation_degrees", base_angle + sweep, sweep_time) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_sweep_tween.tween_property(gaze, "rotation_degrees", base_angle - sweep, sweep_time) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
