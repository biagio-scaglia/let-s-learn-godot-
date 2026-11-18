class_name BookReader
extends CanvasLayer
## Il libro aperto della Galleria. A sinistra il ritratto, il nome, il sottotitolo e
## (per i mostri) i numeri; a destra la storia, una pagina alla volta.
## Frecce: sfoglia. E, Invio o Esc: chiudi.
##
## Tutta l'interfaccia è costruita da codice in _build(): pannelli con StyleBoxFlat
## (un rettangolo col bordo, senza immagini), Label e un TextureRect per il ritratto.

signal closed

const PAPER := Color(0.95, 0.89, 0.74)
const PAPER_DARK := Color(0.82, 0.72, 0.55)
const LEATHER := Color(0.36, 0.18, 0.16)
const INK := Color(0.24, 0.14, 0.1)
const INK_SOFT := Color(0.45, 0.3, 0.22)
const BOOK_SIZE := Vector2(540, 290)

var is_open := false
var _pages: Array = []
var _page := 0
var _dim: ColorRect
var _book: Control
var _portrait: TextureRect
var _name: Label
var _role: Label
var _stats: GridContainer
var _text: Label
var _page_number: Label
var _prev: Label
var _next: Label
var _tween: Tween


func _ready() -> void:
	layer = 7
	_build()
	visible = false


## Apre il libro con questo id (vedi GalleryBooks).
func open(book_id: String) -> void:
	var book := GalleryBooks.entry(book_id)
	if book.is_empty():
		return
	_portrait.texture = Portraits.of(book_id)
	_name.text = book.get("name", book_id)
	_role.text = book.get("role", "")
	_fill_stats(book.get("stats", []))
	_pages = book.get("pages", [])
	_page = 0
	_show_page()
	is_open = true
	visible = true
	Game.in_cutscene = true   # Subaru resta fermo mentre legge
	Sfx.play(Sfx.CONFIRM)
	_book.pivot_offset = BOOK_SIZE / 2.0
	_book.scale = Vector2(0.9, 0.9)
	_animate(1.0)
	_tween.parallel().tween_property(_book, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func close() -> void:
	is_open = false
	Sfx.play(Sfx.BACK)
	_animate(0.0)
	await _tween.finished
	visible = false
	Game.in_cutscene = false
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not is_open:
		return
	if event.is_action_pressed("move_right") or event.is_action_pressed("ui_right"):
		_turn(1)
	elif event.is_action_pressed("move_left") or event.is_action_pressed("ui_left"):
		_turn(-1)
	elif event.is_action_pressed("interact") or event.is_action_pressed("pause") \
			or event.is_action_pressed("ui_cancel"):
		close()
	else:
		return
	get_viewport().set_input_as_handled()


## Sfoglia avanti (+1) o indietro (-1): la pagina di destra sparisce e ricompare.
func _turn(direction: int) -> void:
	var page := clampi(_page + direction, 0, _pages.size() - 1)
	if page == _page:
		return
	_page = page
	Sfx.play(Sfx.MOVE)
	var t := create_tween()
	t.tween_property(_text, "modulate:a", 0.0, 0.08)
	t.tween_callback(_show_page)
	t.tween_property(_text, "modulate:a", 1.0, 0.15)


func _show_page() -> void:
	_text.text = _pages[_page] if _page < _pages.size() else ""
	_page_number.text = "%d / %d" % [_page + 1, maxi(_pages.size(), 1)]
	_prev.modulate.a = 1.0 if _page > 0 else 0.0
	_next.modulate.a = 1.0 if _page < _pages.size() - 1 else 0.0


func _fill_stats(stats: Array) -> void:
	for child in _stats.get_children():
		child.queue_free()
	_stats.visible = not stats.is_empty()
	for row in stats:
		_stats.add_child(_ink_label(row[0] + ":", INK_SOFT))
		_stats.add_child(_ink_label(row[1], INK))
