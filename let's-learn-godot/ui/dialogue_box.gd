extends CanvasLayer
## Finestra di dialogo. È un autoload chiamato "Dialogue": qualsiasi script
## può scrivere Dialogue.start("Nome", righe) per far parlare qualcuno.

signal finished

@onready var box: Control = $Box
@onready var name_label: Label = $Box/NameTag/Name
@onready var text_label: Label = $Box/Panel/Text
@onready var arrow: TextureRect = $Box/Panel/Arrow
@onready var blip: AudioStreamPlayer = $Blip

## True mentre la finestra è aperta: il giocatore non si muove.
var is_active := false

var _lines: PackedStringArray = []
var _index := 0
var _closing := false
var _typing: Tween
var _arrow_bob: Tween
var _arrow_y := 0.0


func _ready() -> void:
	box.visible = false
	_arrow_y = arrow.position.y


func start(speaker: String, lines: PackedStringArray) -> void:
	if is_active or lines.is_empty():
		return
	is_active = true
	_lines = lines
	_index = 0
	# I testi arrivano in italiano: tr() li traduce nella lingua scelta (locale/en.po).
	name_label.text = tr(speaker)

	# Entrata: la finestra sale un poco e compare.
	box.visible = true
	box.modulate.a = 0.0
	box.position.y = 10.0
	var t := create_tween().set_parallel()
	t.tween_property(box, "modulate:a", 1.0, 0.15)
	t.tween_property(box, "position:y", 0.0, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_show_line()


func _show_line() -> void:
	_stop_typing()
	text_label.text = tr(_lines[_index])
	text_label.visible_characters = 0
	_stop_arrow()
	var count := text_label.get_total_character_count()
	# La velocità la sceglie il giocatore nelle opzioni (0 = tutta la frase subito).
	var speed := Settings.chars_per_second() if Settings.chars_per_second() > 0.0 else 100000.0
	_typing = create_tween()
	_typing.tween_method(_type_to, 0, count, count / speed)
	_typing.finished.connect(_on_line_typed)


func _type_to(n: int) -> void:
	if n == text_label.visible_characters:
		return
	text_label.visible_characters = n
	# Un "blip" ogni due lettere, con un tono leggermente diverso ogni volta.
	if n % 2 == 0 and text_label.text[n - 1] != " ":
		blip.pitch_scale = randf_range(0.9, 1.15)
		blip.play()


func _on_line_typed() -> void:
	text_label.visible_characters = -1
	arrow.visible = true
	_arrow_bob = create_tween().set_loops()
	_arrow_bob.tween_property(arrow, "position:y", _arrow_y + 2.0, 0.3)
	_arrow_bob.tween_property(arrow, "position:y", _arrow_y, 0.3)


## Ferma la scrittura della frase precedente, se è ancora in corso: altrimenti
## continuerebbe a scrivere lettere della frase vecchia su quella nuova.
func _stop_typing() -> void:
	if _typing:
		_typing.kill()
		_typing = null


func _stop_arrow() -> void:
	if _arrow_bob:
		_arrow_bob.kill()
	arrow.visible = false
	arrow.position.y = _arrow_y


func _unhandled_input(event: InputEvent) -> void:
	if not is_active or _closing or not event.is_action_pressed("interact"):
		return
	get_viewport().set_input_as_handled()

	if _typing and _typing.is_running():
		# Premere durante la scrittura mostra subito tutta la frase.
		_typing.kill()
		_on_line_typed()
	elif _index < _lines.size() - 1:
		_index += 1
		_show_line()
	else:
		_close()


func _close() -> void:
	_closing = true
	_stop_typing()
	_stop_arrow()
	var t := create_tween().set_parallel()
	t.tween_property(box, "modulate:a", 0.0, 0.12)
	t.tween_property(box, "position:y", 10.0, 0.12)
	await t.finished
	box.visible = false
	_closing = false
	is_active = false
	finished.emit()
