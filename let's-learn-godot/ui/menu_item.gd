class_name MenuItem
extends Button
## Una voce dei menu. Quando è selezionata compare la freccia (che oscilla), il testo
## diventa dorato (lo decide il Theme) e si sente un "tic". Funziona con tastiera e mouse.

const CURSOR := preload("res://assets/ui/cursor_arrow.png")

var _cursor: TextureRect
var _bob: Tween
var _silent := false


func _ready() -> void:
	alignment = HORIZONTAL_ALIGNMENT_LEFT
	focus_mode = Control.FOCUS_ALL

	# La freccia è un figlio del bottone, a sinistra del testo.
	_cursor = TextureRect.new()
	_cursor.texture = CURSOR
	_cursor.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	# La freccia è grande in proporzione al testo: 6x9 pixel ogni 16 di font.
	_cursor.size = Vector2(6, 9) * (get_theme_font_size("font_size") / 16.0)
	_cursor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cursor.visible = false
	add_child(_cursor)

	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	mouse_entered.connect(grab_focus)
	pressed.connect(Game.ui_sound.bind("confirm"))


## Seleziona questa voce senza il "tic" (per esempio quando un menu si apre).
func focus_silently() -> void:
	_silent = true
	grab_focus()
	_silent = false


func _on_focus_entered() -> void:
	if not _silent:
		Game.ui_sound("move")
	var x := -_cursor.size.x - 10.0
	_cursor.position = Vector2(x, (size.y - _cursor.size.y) / 2.0)
	_cursor.visible = true
	_bob = create_tween().set_loops()
	_bob.tween_property(_cursor, "position:x", x + 4.0, 0.3).set_trans(Tween.TRANS_SINE)
	_bob.tween_property(_cursor, "position:x", x, 0.3).set_trans(Tween.TRANS_SINE)


func _on_focus_exited() -> void:
	if _bob:
		_bob.kill()
	_cursor.visible = false
