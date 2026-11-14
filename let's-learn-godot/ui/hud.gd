extends CanvasLayer
## Quello che sta sopra il gioco. È un autoload chiamato "Hud".
## - Avvisi a comparsa in alto ("Hai trovato: Chiave", "Partita salvata"):
##   quelli arrivati insieme si mostrano uno alla volta.
## - L'obiettivo attuale, in alto a sinistra (il testo lo decide Objective).

@onready var toast: Control = $Toast
@onready var icon: TextureRect = %Icon
@onready var label: Label = %Text
@onready var objective: Control = $Objective
@onready var objective_text: Label = %ObjectiveText

var _queue: Array[Dictionary] = []
var _busy := false
var _shown_y := 0.0
## L'obiettivo mostrato adesso ("" = riquadro nascosto).
var _objective_shown := ""
var _objective_x := 0.0
var _objective_tween: Tween


func _ready() -> void:
	# Funziona anche in pausa (es. "Partita salvata" dal menu di pausa).
	process_mode = Node.PROCESS_MODE_ALWAYS
	_shown_y = toast.position.y
	toast.visible = false
	# Lo zaino non sa che esiste l'avviso: è l'avviso che ascolta lo zaino.
	Inventory.item_added.connect(show_item)

	# L'obiettivo si ricalcola quando cambia qualcosa da cui dipende: i ricordi o
	# una cutscene (Game), lo zaino, la scena. Niente controlli a ogni frame.
	_objective_x = objective.position.x
	objective.visible = false
	Game.state_changed.connect(_refresh_objective)
	Inventory.changed.connect(_refresh_objective)
	get_tree().scene_changed.connect(_refresh_objective)


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


# ---------- Obiettivo ----------

## L'obiettivo da mostrare adesso. Vuoto fuori dai livelli (titolo) e nelle cutscene.
func _objective_now() -> String:
	var scene := get_tree().current_scene
	if scene == null or not scene.is_in_group("level") or Game.in_cutscene:
		return Objective.NONE
	return Objective.current()


func _refresh_objective() -> void:
	var text := _objective_now()
	if text == _objective_shown:
		return
	_objective_shown = text
	if _objective_tween:
		_objective_tween.kill()
	_objective_tween = create_tween()
	if text == Objective.NONE:
		_objective_tween.tween_property(objective, "modulate:a", 0.0, 0.3)
		_objective_tween.tween_callback(objective.hide)
		return
	# Nuovo obiettivo: entra da sinistra, e per un attimo è dorato per farsi notare.
	objective_text.text = text
	objective.reset_size()
	objective.visible = true
	objective.position.x = _objective_x - 24.0
	objective.modulate = Color(1.0, 0.85, 0.4, 0.0)
	_objective_tween.tween_property(objective, "position:x", _objective_x, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_objective_tween.parallel().tween_property(objective, "modulate:a", 1.0, 0.25)
	_objective_tween.tween_property(objective, "modulate", Color.WHITE, 0.9)
