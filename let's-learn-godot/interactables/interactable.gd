class_name Interactable
extends Area2D
## Qualsiasi cosa con cui il giocatore può interagire: un personaggio, un cartello…
## Quando il giocatore è vicino mostra la nuvoletta; premendo "interact" apre il dialogo.

## Emesso quando il giocatore interagisce (prima che il dialogo si apra).
signal interacted

## Il nome nella finestra di dialogo.
@export var speaker := "???"
## Le frasi della prima volta.
@export_multiline var lines: PackedStringArray = []
## Le frasi dalla seconda volta in poi. Se vuoto, ripete "lines".
@export_multiline var repeat_lines: PackedStringArray = []
## Altezza della nuvoletta sopra l'oggetto, in pixel.
@export var prompt_height := 60.0

@onready var prompt: Sprite2D = $Prompt

## Il giocatore, quando è abbastanza vicino. Altrimenti null.
var player: Node2D = null
## Quante volte il giocatore ha già interagito.
var times := 0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	prompt.visible = false
	prompt.position.y = -prompt_height

	# La nuvoletta sale e scende.
	var bob := create_tween().set_loops()
	bob.tween_property(prompt, "position:y", -prompt_height - 3.0, 0.45).set_trans(Tween.TRANS_SINE)
	bob.tween_property(prompt, "position:y", -prompt_height, 0.45).set_trans(Tween.TRANS_SINE)


func _process(_delta: float) -> void:
	prompt.visible = player != null and not Dialogue.is_active


func _unhandled_input(event: InputEvent) -> void:
	if player == null or Dialogue.is_active or not event.is_action_pressed("interact"):
		return
	# Segna il tasto come "usato", così la finestra di dialogo non lo riceve
	# subito anche lei e non salta la prima frase.
	get_viewport().set_input_as_handled()

	if player.has_method("look_at_point"):
		player.look_at_point(global_position)
	interacted.emit()
	var text := repeat_lines if times > 0 and not repeat_lines.is_empty() else lines
	times += 1
	Dialogue.start(speaker, text)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body


func _on_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
