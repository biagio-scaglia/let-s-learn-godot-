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


func _animate(target: float) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween().set_parallel()
	_tween.tween_property(_dim, "color:a", 0.6 * target, 0.2)
	_tween.tween_property(_book, "modulate:a", target, 0.2)


# ---------- Costruzione ----------

func _build() -> void:
	_dim = ColorRect.new()
	_dim.color = Color(0.04, 0.02, 0.06, 0.0)
	_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_dim)

	# Il libro, centrato nello schermo di 640x360.
	_book = Control.new()
	_book.size = BOOK_SIZE
	_book.position = (Vector2(640, 360) - BOOK_SIZE) / 2.0 - Vector2(0, 8)
	_book.modulate.a = 0.0
	add_child(_book)
	_book.add_child(_panel(Rect2(Vector2.ZERO, BOOK_SIZE), LEATHER, Color(0.16, 0.07, 0.07), 3))
	var half := (BOOK_SIZE.x - 28) / 2.0
	var left := _panel(Rect2(10, 8, half, BOOK_SIZE.y - 16), PAPER, PAPER_DARK, 2)
	var right := _panel(Rect2(18 + half, 8, half, BOOK_SIZE.y - 16), PAPER, PAPER_DARK, 2)
	_book.add_child(left)
	_book.add_child(right)
	# La piega in mezzo: una striscia più scura.
	var fold := ColorRect.new()
	fold.color = Color(0.55, 0.42, 0.3, 0.6)
	fold.position = Vector2(10 + half - 2, 8)
	fold.size = Vector2(12, BOOK_SIZE.y - 16)
	_book.add_child(fold)

	# Pagina sinistra: ritratto, nome, sottotitolo, numeri.
	var lv := VBoxContainer.new()
	lv.position = Vector2(14, 10)
	lv.size = left.size - Vector2(28, 20)
	lv.add_theme_constant_override("separation", 2)
	left.add_child(lv)
	_portrait = TextureRect.new()
	_portrait.custom_minimum_size = Vector2(0, 104)
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	lv.add_child(_portrait)
	_name = _ink_label("", INK)
	_name.add_theme_font_size_override("font_size", 24)
	_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lv.add_child(_name)
	_role = _ink_label("", INK_SOFT)
	_role.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_role.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lv.add_child(_role)
	_stats = GridContainer.new()
	_stats.columns = 2
	_stats.add_theme_constant_override("h_separation", 8)
	_stats.add_theme_constant_override("v_separation", -2)
	lv.add_child(_stats)

	# Pagina destra: il testo, il numero di pagina e le frecce.
	_text = _ink_label("", INK)
	_text.position = Vector2(14, 14)
	_text.size = right.size - Vector2(28, 44)
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.add_child(_text)
	_page_number = _ink_label("", INK_SOFT)
	_page_number.position = Vector2(0, right.size.y - 26)
	_page_number.size = Vector2(right.size.x, 20)
	_page_number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	right.add_child(_page_number)
	_prev = _ink_label("<", INK)
	_prev.position = Vector2(right.size.x / 2.0 - 46, right.size.y - 26)
	right.add_child(_prev)
	_next = _ink_label(">", INK)
	_next.position = Vector2(right.size.x / 2.0 + 38, right.size.y - 26)
	right.add_child(_next)

	# Sotto il libro, i comandi.
	var hint := Label.new()
	hint.theme_type_variation = &"HintLabel"
	hint.text = "Frecce: sfoglia - E: chiudi"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.position = Vector2(0, BOOK_SIZE.y + 4)
	hint.size = Vector2(BOOK_SIZE.x, 20)
	_book.add_child(hint)


## Un rettangolo pieno col bordo (StyleBoxFlat), alla posizione e misura date.
func _panel(rect: Rect2, fill: Color, border: Color, border_width: int) -> Panel:
	var panel := Panel.new()
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(3)
	panel.add_theme_stylebox_override("panel", style)
	panel.position = rect.position
	panel.size = rect.size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return panel
