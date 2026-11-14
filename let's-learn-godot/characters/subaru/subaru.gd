extends CharacterBody2D

## Velocità in pixel al secondo.
@export var walk_speed := 80.0
@export var run_speed := 150.0
## Quanto più veloce va l'animazione quando corre.
@export var run_anim_scale := 1.8

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dust: CPUParticles2D = $Dust
@onready var steps: AudioStreamPlayer2D = $Steps
var facing := Facing.DOWN
## Quanti passi ha fatto (utile nei test).
var step_count := 0
## True quando lo muove uno script (cutscene, morte, un'azione): i tasti non contano.
var _scripted := false
## Cresce a ogni azione (esultanza, caduta, risveglio): chi aspetta la fine della
## propria animazione capisce così se nel frattempo ne è partita un'altra.
var _action_id := 0


func _ready() -> void:
	sprite.frame_changed.connect(_on_frame_changed)


## I frame 0 e 2 della camminata sono quelli con il piede a terra: lì suona il passo.
func _on_frame_changed() -> void:
	if sprite.animation.begins_with("walk_") and sprite.frame in [0, 2]:
		steps.pitch_scale = randf_range(0.85, 1.15)
		steps.play()
		step_count += 1


func _physics_process(_delta: float) -> void:
	if _scripted:
		return   # lo muove walk_to(), non i tasti
	# Durante un dialogo o un cambio di scena Subaru resta fermo.
	if not Game.player_can_move():
		velocity = Vector2.ZERO
		dust.emitting = false
		_play_idle()
		return

	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var running := Input.is_action_pressed("run")

	velocity = input * (run_speed if running else walk_speed)
	move_and_slide()

	var moving := input != Vector2.ZERO
	# Nuvolette di polvere ai piedi solo quando corre.
	dust.emitting = moving and running

	if moving:
		facing = Facing.from_vector(input)
		_play_walk(run_anim_scale if running else 1.0)
	else:
		_play_idle()


## Fa camminare Subaru da solo fino a "point", in linea retta (per le cutscene).
## Si può aspettare: await subaru.walk_to(...). Attraversa i muri: serve solo per le scene scritte.
func walk_to(point: Vector2, speed := walk_speed) -> void:
	_scripted = true
	facing = Facing.from_vector(point - global_position)
	_play_walk()
	var t := create_tween()
	t.tween_property(self, "global_position", point, global_position.distance_to(point) / speed)
	await t.finished
	_scripted = false
	_play_idle()


## Subaru crolla a terra: barcolla, cade e si scurisce. Per il Ritorno dalla Morte.
## Resta steso finché la scena non viene ricaricata.
func collapse() -> void:
	sprite.modulate = Color.WHITE
	create_tween().tween_property(sprite, "modulate", Color(0.45, 0.35, 0.55), 0.8)
	await _play_action("collapse")


## Subaru esulta: due pugni al cielo e il segno di vittoria. Quando raccoglie un oggetto.
func cheer() -> void:
	if _scripted:
		return   # sta già facendo altro (una cutscene, una caduta)
	if await _play_action("cheer"):
		_scripted = false
		_play_idle()


## Mette subito Subaru steso a terra, a occhi aperti (il risveglio dopo il Ritorno).
func lie_down() -> void:
	_start_action("lying")


## Da steso si rimette in piedi: in ginocchio, a occhi chiusi, poi di nuovo lui.
func wake_up() -> void:
	if await _play_action("wake_up"):
		_scripted = false
		facing = Facing.DOWN   # l'ultima posa guarda verso di noi
		_play_idle()


## Fa partire un'animazione "d'azione" (quelle di subaru_actions.png) e aspetta che finisca.
## Restituisce false se nel frattempo ne è cominciata un'altra: in quel caso chi
## chiamava non deve rimettere Subaru in piedi.
func _play_action(animation: String) -> bool:
	var id := _start_action(animation)
	await sprite.animation_finished
	return id == _action_id


func _start_action(animation: String) -> int:
	_action_id += 1
	_scripted = true
	velocity = Vector2.ZERO
	dust.emitting = false
	# Le azioni sono disegnate verso destra: a sinistra si specchiano.
	sprite.flip_h = facing == Facing.LEFT
	sprite.speed_scale = 1.0
	sprite.play(animation)
	return _action_id


## Gira Subaru verso un punto (per esempio chi gli sta parlando).
func look_at_point(point: Vector2) -> void:
	face(Facing.from_vector(point - global_position))


## Gira Subaru in una direzione: Facing.DOWN, UP, LEFT o RIGHT.
func face(direction: String) -> void:
	facing = direction
	_play_idle()


func _play_idle() -> void:
	sprite.flip_h = false
	sprite.play("idle_" + facing)
	sprite.speed_scale = 1.0


func _play_walk(speed := 1.0) -> void:
	sprite.flip_h = false
	sprite.play("walk_" + facing)
	sprite.speed_scale = speed

