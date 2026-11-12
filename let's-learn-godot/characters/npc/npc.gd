extends StaticBody2D
## Un personaggio con cui parlare. La parte "avvicinati e premi E" la fa il
## figlio Interactable: qui ci sono solo l'aspetto e il comportamento.

## Il nome che compare nella finestra di dialogo.
@export var npc_name := "???"
## Le frasi della prima volta, una per pagina.
@export_multiline var lines: PackedStringArray = []
## Le frasi dalla seconda volta in poi. Se vuoto, ripete "lines".
@export_multiline var repeat_lines: PackedStringArray = []

@onready var sprite: Sprite2D = $Sprite2D
@onready var interactable: Interactable = $Interactable


func _ready() -> void:
	interactable.speaker = npc_name
	interactable.lines = lines
	interactable.repeat_lines = repeat_lines

	# Respiro: lo sprite si schiaccia appena e torna, all'infinito.
	# Si deforma dai piedi perché l'origine dello sprite è in basso.
	var base := sprite.scale
	var breathe := create_tween().set_loops()
	breathe.tween_property(sprite, "scale", base * Vector2(1.03, 0.96), 0.9) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	breathe.tween_property(sprite, "scale", base, 0.9) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _process(_delta: float) -> void:
	var player := interactable.player
	if player:
		# Guarda verso il giocatore.
		sprite.flip_h = player.global_position.x < global_position.x
