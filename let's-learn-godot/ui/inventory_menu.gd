extends CanvasLayer
## Lo zaino. È un autoload chiamato "InventoryMenu": si apre con Tab o I nei livelli.
## Mostra gli oggetti di Inventory.items in una griglia di caselle; la casella
## selezionata mostra nome e descrizione sotto. Con Invio l'oggetto selezionato si usa
## (per ora solo le cure, come la pozione).

const SLOTS := 12   # 6 colonne x 2 righe

@onready var blur: ColorRect = $Blur
@onready var panel: Control = $Panel
@onready var grid: GridContainer = %Grid
@onready var item_name: Label = %ItemName
@onready var item_description: Label = %ItemDescription
@onready var hint: Label = %Hint

var is_open := false
var _slots: Array[Button] = []
var _ids: Array[String] = []   # l'id dell'oggetto in ogni casella ("" = vuota)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	for i in SLOTS:
		_slots.append(_make_slot(i))
	Inventory.changed.connect(_refresh)
	Stats.changed.connect(_refresh_hint)


## Una casella: un bottone con l'icona al centro e la quantità in basso a destra.
func _make_slot(index: int) -> Button:
	var slot := Button.new()
	slot.theme_type_variation = &"SlotButton"
	slot.custom_minimum_size = Vector2(44, 44)
	slot.focus_mode = Control.FOCUS_ALL

	var icon := TextureRect.new()
	icon.name = "Icon"
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.position = Vector2(6, 6)   # centrata nella casella da 44
	icon.size = Vector2(32, 32)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(icon)

	var count := Label.new()
	count.name = "Count"
	count.theme_type_variation = &"HintLabel"
	count.add_theme_color_override("font_color", Color(0.96, 0.9, 0.77))
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	count.position = Vector2(2, 24)
	count.size = Vector2(39, 18)
	count.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(count)

	slot.focus_entered.connect(_on_slot_focused.bind(index))
	slot.pressed.connect(_use.bind(index))
	slot.mouse_entered.connect(slot.grab_focus)
	grid.add_child(slot)
	return slot


func _refresh() -> void:
	_ids.clear()
	for id in Inventory.items:
		_ids.append(id)
	for i in SLOTS:
		var slot := _slots[i]
		var id := _ids[i] if i < _ids.size() else ""
		var icon: TextureRect = slot.get_node("Icon")
		var count: Label = slot.get_node("Count")
		icon.texture = Inventory.item(id).icon if id != "" else null
		var amount: int = Inventory.items.get(id, 0)
		count.text = str(amount) if amount > 1 else ""


func _on_slot_focused(index: int) -> void:
	if is_open:
		Sfx.play(Sfx.MOVE)
	var id := _ids[index] if index < _ids.size() else ""
	if id == "":
		item_name.text = ""
		item_description.text = "Lo zaino è vuoto." if _ids.is_empty() else ""
	else:
		item_name.text = Inventory.item(id).name
		item_description.text = Inventory.item(id).description


## Usa l'oggetto di una casella. Le regole stanno in Inventory.use(): qui si decide
## solo cosa dire al giocatore.
func _use(index: int) -> void:
	var id := _ids[index] if index < _ids.size() else ""
	if id == "":
		return
	var healed := Inventory.use(id)
	if healed > 0:
		Sfx.play(Sfx.HEAL)
		# Lo zaino è cambiato: la casella ora può contenere un altro oggetto, o niente.
		_on_slot_focused(index)
		item_description.text = "Hai recuperato %d punti salute." % healed
	elif Inventory.item(id).heal > 0:
		item_description.text = "Sei già in piena forma."
	else:
		item_description.text = "Non si può usare qui."


func _refresh_hint() -> void:
	hint.text = "PS %d/%d  ·  Invio per usare  ·  Tab per chiudere" % [Stats.hp, Stats.max_hp]


func _unhandled_input(event: InputEvent) -> void:
	if is_open:
		if event.is_action_pressed("inventory") or event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel"):
			get_viewport().set_input_as_handled()
			close()
	elif event.is_action_pressed("inventory") and Game.can_open_menu():
		get_viewport().set_input_as_handled()
		open()


func open() -> void:
	is_open = true
	get_tree().paused = true
	_refresh()
	_refresh_hint()
	visible = true
	Sfx.play(Sfx.CONFIRM)
	panel.pivot_offset = panel.size / 2.0
	panel.scale = Vector2(0.92, 0.92)
	panel.modulate.a = 0.0
	var t := create_tween().set_parallel()
	t.tween_method(_set_blur, 0.0, 1.0, 0.2)
	t.tween_property(panel, "modulate:a", 1.0, 0.18)
	t.tween_property(panel, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_slots[0].grab_focus()
	_on_slot_focused(0)


func close() -> void:
	Sfx.play(Sfx.BACK)
	var t := create_tween().set_parallel()
	t.tween_method(_set_blur, 1.0, 0.0, 0.15)
	t.tween_property(panel, "modulate:a", 0.0, 0.15)
	await t.finished
	visible = false
	is_open = false
	get_tree().paused = false


func _set_blur(value: float) -> void:
	blur.material.set_shader_parameter("amount", value)
