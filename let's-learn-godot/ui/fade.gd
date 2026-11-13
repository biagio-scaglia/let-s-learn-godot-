extends CanvasLayer
## Dissolvenza a nero. È un autoload chiamato "Fade".
## All'avvio il gioco compare dal nero; per cambiare scena:
##     await Fade.fade_out()
##     get_tree().change_scene_to_file(...)
##     await Fade.fade_in()

## Durata della dissolvenza, in secondi.
@export var duration := 0.4

@onready var rect: ColorRect = $Black


func _ready() -> void:
	# Deve funzionare anche a gioco in pausa (es. "Torna al titolo" dal menu di pausa).
	process_mode = Node.PROCESS_MODE_ALWAYS
	rect.color.a = 1.0
	fade_in()


## Dal nero all'immagine. "seconds" < 0 vuol dire: usa la durata normale.
func fade_in(seconds := -1.0) -> void:
	var t := create_tween()
	t.tween_property(rect, "color:a", 0.0, duration if seconds < 0 else seconds).set_trans(Tween.TRANS_SINE)
	await t.finished


## Dall'immagine al nero.
func fade_out() -> void:
	var t := create_tween()
	t.tween_property(rect, "color:a", 1.0, duration).set_trans(Tween.TRANS_SINE)
	await t.finished
