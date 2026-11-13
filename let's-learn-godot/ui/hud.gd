extends CanvasLayer
## Avvisi a comparsa in alto ("Hai trovato: Chiave", "Partita salvata").
## È un autoload chiamato "Hud". Gli avvisi arrivati insieme si mostrano uno alla volta.

@onready var toast: Control = $Toast
@onready var icon: TextureRect = %Icon
@onready var label: Label = %Text

var _queue: Array[Dictionary] = []
var _busy := false
var _shown_y := 0.0


func _ready() -> void:
	# Funziona anche in pausa (es. "Partita salvata" dal menu di pausa).
	process_mode = Node.PROCESS_MODE_ALWAYS
	_shown_y = toast.position.y
	toast.visible = false
	# Lo zaino non sa che esiste l'avviso: è l'avviso che ascolta lo zaino.
	Inventory.item_added.connect(show_item)


## "Hai trovato: Pozione rossa x2"
func show_item(item: Item, amount := 1) -> void:
	var text := "Hai trovato: " + item.name
	if amount > 1:
		text += " x%d" % amount
	show_message(text, item.icon)


func show_message(text: String, texture: Texture2D = null) -> void:
	_queue.append({"text": text, "icon": texture})
	if not _busy:
		_next()


func _next() -> void:
	if _queue.is_empty():
		_busy = false
		return
	_busy = true
	var data: Dictionary = _queue.pop_front()
	label.text = data.text
	icon.texture = data.icon
	icon.visible = data.icon != null

	# Entra scendendo dall'alto, resta un po', esce risalendo.
	toast.visible = true
	toast.reset_size()
	toast.position.x = (get_viewport().get_visible_rect().size.x - toast.size.x) / 2.0
	toast.position.y = _shown_y - 40.0
	toast.modulate.a = 0.0
	var t := create_tween()
	t.tween_property(toast, "position:y", _shown_y, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(toast, "modulate:a", 1.0, 0.2)
	t.tween_interval(1.8)
	t.tween_property(toast, "position:y", _shown_y - 40.0, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(toast, "modulate:a", 0.0, 0.25)
	t.tween_callback(func(): toast.visible = false)
	t.tween_callback(_next)
