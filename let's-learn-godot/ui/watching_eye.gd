class_name WatchingEye
extends Node2D
## Un occhio grande che guarda il cursore del mouse, ovunque sia sul desktop,
## anche fuori dalla finestra. Ogni tanto sbatte le palpebre.
##
## È fatto di tre immagini una sopra l'altra: il bianco (scuro, qui), l'iride (che si
## muove) e le palpebre con le ciglia. L'iride ha uno shader (eye_mask.gdshader) che
## la ritaglia con la forma del bianco: così si vede solo dentro la mandorla.

const SCLERA := preload("res://assets/effects/big_eye_sclera.png")
const IRIS := preload("res://assets/effects/big_eye_iris.png")
const CUT := preload("res://effects/eye_mask.gdshader")
const LIDS := preload("res://assets/effects/big_eye_lids.png")
## Quanto può spostarsi l'iride dal centro, in pixel.
const REACH := Vector2(15, 4)

## Ogni quanti secondi (più o meno) sbatte le palpebre.
@export var blink_every := 2.6

var _iris: Sprite2D
var _until_blink := 0.0


func _init() -> void:
	for texture in [SCLERA, IRIS, LIDS]:
		var sprite := Sprite2D.new()
		sprite.texture = texture
		add_child(sprite)
		if texture == IRIS:
			_iris = sprite
	var mat := ShaderMaterial.new()
	mat.shader = CUT
	mat.set_shader_parameter("shape", SCLERA)
	mat.set_shader_parameter("shape_size", SCLERA.get_size())
	_iris.material = mat
	_update_cut()
	scale.y = 0.0   # chiuso: open() lo apre
	_until_blink = blink_every


## Si apre piano.
func open(time := 0.5) -> void:
	var t := create_tween()
	t.tween_property(self, "scale:y", 1.0, time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await t.finished


## Un battito di ciglia: si schiaccia e torna.
func blink() -> void:
	var t := create_tween()
	t.tween_property(self, "scale:y", 0.08, 0.07)
	t.tween_property(self, "scale:y", 1.0, 0.1)


func _process(delta: float) -> void:
	# Dove sono io e dove è il mouse, tutti e due in pixel del desktop.
	var me := Vector2(get_window().position) + get_global_transform_with_canvas().origin * _window_zoom()
	var mouse := Vector2(DisplayServer.mouse_get_position())
	var toward := (mouse - me) / 300.0   # a 300 pixel di distanza guarda già "tutto di lato"
	toward = toward.limit_length(1.0)
	var target := Vector2(toward.x * REACH.x, toward.y * REACH.y)
	_iris.position = _iris.position.lerp(target.round(), minf(1.0, delta * 10.0))
	_update_cut()
	_until_blink -= delta
	if _until_blink <= 0.0 and scale.y > 0.99:
		_until_blink = blink_every * randf_range(0.6, 1.4)
		blink()


## Dice allo shader dove sta l'iride dentro la mandorla (tutti e due sono centrati).
func _update_cut() -> void:
	var corner := _iris.position.round() + (SCLERA.get_size() - IRIS.get_size()) / 2.0
	(_iris.material as ShaderMaterial).set_shader_parameter("offset", corner)


## Quanto è ingrandita la finestra rispetto ai suoi pixel "finti" (content_scale_size).
func _window_zoom() -> float:
	var window := get_window()
	if window.content_scale_size.x <= 0:
		return 1.0
	return float(window.size.x) / window.content_scale_size.x
