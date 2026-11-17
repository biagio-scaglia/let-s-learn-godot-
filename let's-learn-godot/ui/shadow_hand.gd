class_name ShadowHand
extends Node2D
## Una mano d'ombra con il suo braccio. Il braccio parte da "origin" (di solito fuori
## dallo schermo) e arriva a "tip", dove c'è la mano. Muovendo "tip" con un Tween
## la mano si allunga o si ritira; il braccio ondeggia da solo, come fumo.
##
##     var hand := ShadowHand.new()
##     add_child(hand)
##     hand.setup(Vector2(-30, 200), Vector2(-30, 200))
##     await hand.reach(Vector2(220, 180), 0.3)
##     hand.grip()

## Le pose della mano, nell'ordine della spritesheet.
enum Pose { OPEN, CLAWS, CLOSING, FIST }

const SHEET := preload("res://assets/effects/shadow_hand.png")
const SHADER := preload("res://effects/shadow.gdshader")
const SMOKE := preload("res://assets/kenney_particle_pack/smoke_04.png")
## Una cella della spritesheet: il polso è sul bordo sinistro, a metà altezza.
const CELL := Vector2(40, 28)

const CORE_COLOR := Color(0.063, 0.027, 0.086)
const RIM_COLOR := Color(0.42, 0.17, 0.58)

## Da dove parte il braccio e dove sta il polso.
var origin := Vector2.ZERO
var tip := Vector2.ZERO
## Quanto ondeggia il braccio, in pixel.
var sway := 6.0

var _rim: Line2D
var _arm: Line2D
var _hand: Sprite2D
var _atlas: AtlasTexture
var _smoke: CPUParticles2D
var _time := 0.0
## Ogni mano ondeggia a modo suo.
var _phase := randf() * TAU


func _init() -> void:
	# Il braccio sono due linee: una più larga e viola (il bordo) sotto una scura.
	_rim = _make_line(16.0, RIM_COLOR)
	_arm = _make_line(12.0, CORE_COLOR)
	_atlas = AtlasTexture.new()
	_atlas.atlas = SHEET
	_hand = Sprite2D.new()
	_hand.texture = _atlas
	_hand.centered = false
	_hand.offset = Vector2(-2, -CELL.y / 2.0)   # il polso cade proprio su "tip"
	_hand.scale = Vector2(1.6, 1.6)
	var mat := ShaderMaterial.new()
	mat.shader = SHADER
	_hand.material = mat
	add_child(_hand)
	_smoke = _make_smoke()
	add_child(_smoke)
	set_pose(Pose.OPEN)


## Mette il braccio al punto di partenza, con la mano già in "at".
func setup(from: Vector2, at: Vector2) -> void:
	origin = from
	tip = at
	_update_arm()


## La mano scatta verso "to" a dita aperte. Si può aspettare.
func reach(to: Vector2, time: float) -> void:
	set_pose(Pose.CLAWS)
	_smoke.emitting = true
	var t := create_tween()
	t.tween_property(self, "tip", to, time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await t.finished
	_smoke.emitting = false


## Le dita si chiudono: prima a metà, poi il pugno.
func grip() -> void:
	set_pose(Pose.CLOSING)
	await get_tree().create_timer(0.05).timeout
	if is_inside_tree():
		set_pose(Pose.FIST)


## Lascia la presa, si ritira verso "origin" e intanto si scioglie. Poi si cancella.
func retract(time := 0.35) -> void:
	set_pose(Pose.OPEN)
	_smoke.emitting = true
	var t := create_tween().set_parallel()
	t.tween_property(self, "tip", origin, time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.tween_method(_set_dissolve, 0.0, 1.0, time)
	t.tween_property(self, "modulate:a", 0.0, time).set_delay(time * 0.5)
	await t.finished
	queue_free()


func set_pose(pose: Pose) -> void:
	_atlas.region = Rect2(Vector2(pose * CELL.x, 0), CELL)


func _set_dissolve(value: float) -> void:
	(_hand.material as ShaderMaterial).set_shader_parameter("dissolve", value)


func _process(delta: float) -> void:
	_time += delta
	_update_arm()


## Ridisegna il braccio: una linea da origin a tip, piegata da un'onda che scorre.
## L'onda è zero alle due estremità (sin(t * PI)), così il braccio resta attaccato.
func _update_arm() -> void:
	var dir := tip - origin
	var normal := dir.orthogonal().normalized()
	var points := PackedVector2Array()
	var count := 14
	for i in count + 1:
		var t := float(i) / count
		var wave := sin(t * PI * 2.2 - _time * 3.0 + _phase) * sway * sin(t * PI)
		points.append(origin + dir * t + normal * wave)
	_rim.points = points
	_arm.points = points
	# La mano segue la direzione dell'ultimo pezzo di braccio.
	_hand.position = tip
	_hand.rotation = (points[count] - points[count - 2]).angle()
	_smoke.position = tip


func _make_line(width: float, color: Color) -> Line2D:
	var line := Line2D.new()
	line.width = width
	line.default_color = color
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.antialiased = false
	# Più grosso alla spalla, più sottile al polso.
	var curve := Curve.new()
	curve.add_point(Vector2(0, 1.0))
	curve.add_point(Vector2(1, 0.75))
	line.width_curve = curve
	add_child(line)
	return line


## Fumo nero che si stacca dalla mano mentre si muove.
func _make_smoke() -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.emitting = false
	p.amount = 14
	p.lifetime = 0.6
	p.local_coords = false   # il fumo resta dov'è nato: lascia una scia
	p.texture = SMOKE
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = 6.0
	p.gravity = Vector2(0, -20)
	p.initial_velocity_min = 4.0
	p.initial_velocity_max = 14.0
	p.angular_velocity_min = -90.0
	p.angular_velocity_max = 90.0
	p.scale_amount_min = 0.15
	p.scale_amount_max = 0.3
	var ramp := Gradient.new()
	ramp.set_color(0, Color(0.2, 0.06, 0.3, 0.7))
	ramp.set_color(1, Color(0.02, 0.0, 0.05, 0.0))
	p.color_ramp = ramp
	return p
