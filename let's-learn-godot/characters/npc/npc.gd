extends StaticBody2D
## Un personaggio con cui parlare. Avvicinati e premi "interact" (E, Spazio o Invio).

## Il nome che compare nella finestra di dialogo.
@export var npc_name := "???"
## Le frasi, una per pagina della finestra di dialogo.
@export_multiline var lines: PackedStringArray = []

@onready var sprite: Sprite2D = $Sprite2D
@onready var prompt: Sprite2D = $Prompt
@onready var area: Area2D = $InteractArea

var _player: Node2D = null
var _prompt_y := 0.0
var _base_scale := Vector2.ONE


func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	prompt.visible = false
	_prompt_y = prompt.position.y
	_base_scale = sprite.scale

	# Respiro: lo sprite si schiaccia appena e torna, all'infinito.
	# Si deforma dai piedi perché l'origine dello sprite è in basso.
	var breathe := create_tween().set_loops()
	breathe.tween_property(sprite, "scale", _base_scale * Vector2(1.03, 0.96), 0.9) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	breathe.tween_property(sprite, "scale", _base_scale, 0.9) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# La nuvoletta sopra la testa sale e scende.
	var bob := create_tween().set_loops()
	bob.tween_property(prompt, "position:y", _prompt_y - 3.0, 0.45).set_trans(Tween.TRANS_SINE)
	bob.tween_property(prompt, "position:y", _prompt_y, 0.45).set_trans(Tween.TRANS_SINE)


func _process(_delta: float) -> void:
	prompt.visible = _player != null and not Dialogue.is_active
	if _player:
		# Guarda verso il giocatore (lo sprite originale guarda a destra).
		sprite.flip_h = _player.global_position.x < global_position.x


func _unhandled_input(event: InputEvent) -> void:
	if _player == null or Dialogue.is_active or not event.is_action_pressed("interact"):
		return
	# Segna il tasto come "usato", così la finestra di dialogo non lo riceve
	# subito anche lei e non salta la prima frase.
	get_viewport().set_input_as_handled()
	if _player.has_method("look_at_point"):
		_player.look_at_point(global_position)
	Dialogue.start(npc_name, lines)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player = body


func _on_body_exited(body: Node2D) -> void:
	if body == _player:
		_player = null
