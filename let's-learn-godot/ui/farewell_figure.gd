class_name FarewellFigure
extends Window
## Lei: una figura alta, d'ombra, che compare sul desktop accanto alla finestra del
## congedo. Una finestra a sé, senza bordi e trasparente: si vede solo la figura.
## Si "materializza" a pixel, ondeggia come fumo, gli occhi pulsano, e allunga un
## braccio d'ombra fino al bordo della finestra accanto.

const BODY := preload("res://assets/effects/watcher_tall.png")
const EYES := preload("res://assets/effects/watcher_tall_eyes.png")
const SHADOW := preload("res://effects/shadow.gdshader")
## La sua finestra, in pixel "finti" (ingrandita come quella del congedo).
const VIEW := Vector2i(130, 160)
## Quanto la sua finestra si sovrappone a quella del congedo (pixel finti): lì sopra c'è la sua mano.
const OVERLAP := 14

var _body: Sprite2D
var _eyes: Sprite2D
var _arm: ShadowHand
## Da che parte sta la finestra del congedo: 1 = a destra di lei, -1 = a sinistra.
var _toward := 1


## Prepara la finestra. "zoom" come quella del congedo; "toward" da che parte allunga il braccio.
func setup(zoom: int, toward: int) -> void:
	_toward = toward
	title = "..."
	borderless = true
	unresizable = true
	always_on_top = true
	transparent = true
	transparent_bg = true
	unfocusable = true   # non ti ruba la tastiera: i tasti restano alla finestra del congedo
	size = VIEW * zoom
	content_scale_size = VIEW
	content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST

	_body = Sprite2D.new()
	_body.texture = BODY
	# Lei sta dal lato lontano dalla finestra del congedo: il resto è spazio per il braccio.
	_body.position = Vector2(34.0 if toward > 0 else VIEW.x - 34.0, VIEW.y - BODY.get_height() / 2.0)
	_body.flip_h = toward < 0
	var mat := ShaderMaterial.new()
	mat.shader = SHADOW
	mat.set_shader_parameter("dissolve", 1.0)   # all'inizio non c'è
	mat.set_shader_parameter("wobble_speed", 3.0)
	_body.material = mat
	add_child(_body)
	_eyes = Sprite2D.new()
	_eyes.texture = EYES
	_eyes.position = _body.position
	_eyes.flip_h = _body.flip_h
	_eyes.modulate.a = 0.0
	var glow := CanvasItemMaterial.new()
	glow.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_eyes.material = glow
	add_child(_eyes)


## Compare: si materializza pixel per pixel (lo scioglimento al contrario),
## poi gli occhi si accendono e pulsano. Si può aspettare.
func appear(time: float) -> void:
	var t := create_tween()
	t.tween_method(_set_dissolve, 1.0, 0.0, time)
	t.tween_property(_eyes, "modulate:a", 1.0, time * 0.3)
	await t.finished
	var pulse := create_tween().set_loops()
	pulse.tween_property(_eyes, "modulate:a", 0.55, 0.6).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(_eyes, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE)


## Il braccio d'ombra parte dalla spalla e arriva al bordo, verso la finestra del
## congedo: sembra che la tocchi.
func reach(time: float) -> void:
	var shoulder := _body.position + Vector2(10 * _toward, -BODY.get_height() / 2.0 + 40)
	# Il bordo verso la finestra del congedo, dentro la parte che le sta sopra.
	var edge := Vector2(VIEW.x - OVERLAP / 2.0 if _toward > 0 else OVERLAP / 2.0, shoulder.y + 18)
	_arm = ShadowHand.new()
	add_child(_arm)
	_arm.set_size_factor(0.55)
	_arm.setup(shoulder, shoulder)
	await _arm.reach(edge - Vector2(22 * _toward, 0), time)
	if is_instance_valid(_arm):
		_arm.grip()


## Se ne va: si scioglie.
func vanish(time: float) -> void:
	var t := create_tween().set_parallel()
	t.tween_method(_set_dissolve, 0.0, 1.0, time)
	t.tween_property(_eyes, "modulate:a", 0.0, time * 0.5)
	if is_instance_valid(_arm):
		t.tween_property(_arm, "modulate:a", 0.0, time)
	await t.finished


func _set_dissolve(value: float) -> void:
	(_body.material as ShaderMaterial).set_shader_parameter("dissolve", value)
