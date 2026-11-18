class_name BattleVfx
extends Node
## Gli effetti visivi del combattimento: scintille, scosse, stelle d'impatto, lampi,
## onde d'urto, scie. Qui non si decide niente del combattimento (danni, turni):
## si disegna e basta. Lo crea battle.gd in _ready() e lo chiama come "vfx".
##
##     vfx.impact(punto, 2.0)
##     vfx.shake(5.0, 0.25)

const IMPACT_SHEET := preload("res://assets/effects/vfx_impact.png")
const SLASH_SHEET := preload("res://assets/effects/vfx_slash.png")
const HIT_FLASH := preload("res://effects/hit_flash.gdshader")
const SHOCKWAVE := preload("res://effects/shockwave.gdshader")
const SMOKE := preload("res://assets/kenney_particle_pack/smoke_04.png")
## Il ghiaccio di Emilia (Scaglie di gelo).
const FROST_SHEET := preload("res://assets/effects/frost_burst.png")
const ICE_SHARD := preload("res://assets/effects/ice_shard.png")
const ICE_BLOCK := preload("res://assets/effects/ice_block.png")
const SNOWFLAKE := preload("res://assets/effects/snowflake.png")
const ICE_COLOR := Color(0.65, 0.9, 1.0)

## Dove si disegnano gli effetti (il palco del combattimento) e la sua posizione
## normale, a cui torna dopo una scossa.
var stage: Control
var stage_home := Vector2.ZERO
## I due sprite che lampeggiano quando vengono colpiti.
var hero: AnimatedSprite2D
var enemy: Sprite2D
## Il rettangolo a tutto schermo che disegna l'onda d'urto.
var shockwave: ColorRect
## I dadi degli effetti. Sono separati da quelli del combattimento (Battle.rng):
## così girare una stella o scuotere lo schermo non cambia i danni del colpo dopo,
## e i test con il seme fisso tirano sempre gli stessi numeri.
var rng := RandomNumberGenerator.new()

## Le animazioni degli effetti, costruite una volta sola dalle spritesheet.
var _frames := {}


## Collega gli effetti alla battaglia. "layer" è il CanvasLayer del combattimento,
## "below" il nodo sotto cui mettere l'onda d'urto (il lampo a tutto schermo).
func setup(stage_node: Control, hero_sprite: AnimatedSprite2D, enemy_sprite: Sprite2D, layer: Node, below: Node) -> void:
	stage = stage_node
	hero = hero_sprite
	enemy = enemy_sprite
	rng.randomize()
	# Il lampo bianco: ognuno ha il SUO materiale, se no lampeggerebbero insieme.
	for sprite: CanvasItem in [hero, enemy]:
		var mat := ShaderMaterial.new()
		mat.shader = HIT_FLASH
		sprite.material = mat
	shockwave = ColorRect.new()
	shockwave.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shockwave.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var wave := ShaderMaterial.new()
	wave.shader = SHOCKWAVE
	shockwave.material = wave
	shockwave.visible = false
	# Lo "screen texture" viene copiato una volta sola, al primo shader che lo usa:
	# qui è lo sfondo sfocato, PRIMA che la battaglia sia disegnata. Senza una nuova
	# copia l'onda deformerebbe la mappa vecchia e coprirebbe tutto il resto.
	var copy := BackBufferCopy.new()
	copy.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
	layer.add_child(copy)
	layer.move_child(copy, below.get_index())
	layer.add_child(shockwave)
	layer.move_child(shockwave, below.get_index())   # sopra la battaglia, sotto il lampo
	_frames = {
		"impact": _frames_from_sheet(IMPACT_SHEET, 24.0),
		"slash": _frames_from_sheet(SLASH_SHEET, 26.0),
		"frost": _frames_from_sheet(FROST_SHEET, 20.0),
	}


## Rimette tutto a posto alla fine di un combattimento.
func reset() -> void:
	shockwave.visible = false
	set_flash(hero, 0.0)
	set_flash(enemy, 0.0)
	stage.position = stage_home
	stage.scale = Vector2.ONE


# ---------- Sprite animati ----------

## La stella del colpo, girata a caso perché due colpi non sembrino identici.
func impact(pos: Vector2, size: float) -> void:
	_play("impact", pos, size, rng.randi_range(0, 3) * PI / 8.0)


## Il fendente del calcio: un arco di luce che passa sul nemico.
func slash(pos: Vector2) -> void:
	_play("slash", pos, 2.5, PI)


## Da una spritesheet con celle quadrate in fila a un'animazione che non si ripete.
## Si scorre la larghezza a passi di una cella: ogni passo è un frame.
func _frames_from_sheet(sheet: Texture2D, fps: float) -> SpriteFrames:
	var cell := sheet.get_height()
	var frames := SpriteFrames.new()
	frames.set_animation_loop(&"default", false)
	frames.set_animation_speed(&"default", fps)
	for x in range(0, sheet.get_width(), cell):
		var atlas := AtlasTexture.new()
		atlas.atlas = sheet
		atlas.region = Rect2(x, 0, cell, cell)
		frames.add_frame(&"default", atlas)
	return frames


## Fa partire un effetto disegnato in "pos" e lo cancella quando finisce.
## Il blend "additivo" somma la luce: su uno sfondo scuro sembra brillare.
func _play(kind: String, pos: Vector2, size: float, angle := 0.0) -> AnimatedSprite2D:
	var fx := AnimatedSprite2D.new()
	fx.sprite_frames = _frames[kind]
	fx.position = pos
	fx.scale = Vector2(size, size)
	fx.rotation = angle
	fx.material = _additive()
	stage.add_child(fx)
	fx.play()
	fx.animation_finished.connect(fx.queue_free)
	return fx


func _additive() -> CanvasItemMaterial:
	var add := CanvasItemMaterial.new()
	add.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return add


# ---------- Lampi, bagliori, scosse ----------

## Quanto è "bianco" uno sprite: 0 = normale, 1 = solo la sagoma, tutta bianca.
func set_flash(target: CanvasItem, amount: float) -> void:
	var mat := target.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("amount", amount)


## Lo sprite diventa bianco di colpo e torna normale in "time" secondi.
func flash_white(target: CanvasItem, time: float, delay := 0.0) -> void:
	set_flash(target, 1.0)
	create_tween().tween_method(func(v: float) -> void: set_flash(target, v), 1.0, 0.0, time).set_delay(delay)


## Un bagliore colorato che va e viene (la cura, la difesa).
func glow(target: CanvasItem, color: Color) -> void:
	var t := create_tween()
	t.tween_property(target, "modulate", color, 0.15)
	t.tween_property(target, "modulate", Color.WHITE, 0.35)


## Un piccolo "salto" di grandezza: per l'icona dello scudo o una debolezza scoperta.
func bump(control: Control) -> void:
	control.pivot_offset = control.size / 2.0
	control.scale = Vector2(1.8, 1.8)
	create_tween().tween_property(control, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Scuote la scena: tanti piccoli spostamenti casuali che si smorzano.
func shake(strength: float, time: float) -> void:
	var t := create_tween()
	var steps := int(time / 0.03)
	for i in steps:
		var fade := 1.0 - float(i) / steps
		var offset := Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1)) * strength * fade
		t.tween_property(stage, "position", stage_home + offset, 0.03)
	t.tween_property(stage, "position", stage_home, 0.03)


## Un'onda d'urto che parte da "pos" (coordinate dello Stage) e deforma lo schermo.
func shockwave_at(pos: Vector2, size: float, time := 0.45) -> void:
	var mat := shockwave.material as ShaderMaterial
	# Lo shader lavora in coordinate dello schermo da 0 a 1: convertiamo.
	var on_screen := stage.get_global_transform_with_canvas() * pos
	mat.set_shader_parameter("center", on_screen / stage.get_viewport().get_visible_rect().size)
	mat.set_shader_parameter("max_radius", size)
	shockwave.visible = true
	var t := create_tween()
	t.tween_method(func(v: float) -> void: mat.set_shader_parameter("progress", v), 0.0, 1.0, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	t.tween_callback(shockwave.hide)


## Il numero salta su, ricade con un piccolo rimbalzo, resta un attimo e svanisce.
func pop_number(at: Vector2, text: String, color: Color, height: float, font_size := 32) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.05, 0.03, 0.1))
	label.add_theme_constant_override("outline_size", 6)
	stage.add_child(label)
	var base_y := at.y + height
	label.position = Vector2(at.x - label.get_minimum_size().x / 2.0, base_y)
	var t := create_tween()
	t.tween_property(label, "position:y", base_y - 16.0, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(label, "position:y", base_y, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.tween_property(label, "position:y", base_y - 5.0, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(label, "position:y", base_y, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.tween_interval(0.45)
	t.tween_property(label, "modulate:a", 0.0, 0.25)
	t.tween_callback(label.queue_free)


## La scia: copie di Subaru, azzurre e trasparenti, lasciate indietro mentre scatta.
func afterimages(time: float) -> void:
	var copies := 4
	for i in copies:
		if not hero.is_visible_in_tree():
			return   # il combattimento è finito nel frattempo
		var ghost := Sprite2D.new()
		ghost.texture = hero.sprite_frames.get_frame_texture(hero.animation, hero.frame)
		ghost.position = hero.position
		ghost.scale = hero.scale
		ghost.offset = hero.offset
		ghost.flip_h = hero.flip_h
		ghost.modulate = Color(0.5, 0.75, 1.0, 0.55)
		stage.add_child(ghost)
		stage.move_child(ghost, hero.get_index())   # dietro a Subaru
		var t := create_tween()
		t.tween_property(ghost, "modulate:a", 0.0, 0.22)
		t.tween_callback(ghost.queue_free)
		await get_tree().create_timer(time / copies).timeout


# ---------- Particelle ----------

## Una manciata di scintille che esplodono da "pos" e ricadono. Si cancellano da sole.
func sparks(pos: Vector2, color: Color, amount: int, speed: float) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.one_shot = true
	p.explosiveness = 1.0
	p.amount = amount
	p.lifetime = 0.5
	p.spread = 180.0
	p.initial_velocity_min = speed * 0.4
	p.initial_velocity_max = speed
	p.gravity = Vector2(0, 300)
	p.damping_min = 40.0
	p.damping_max = 80.0
	p.scale_amount_min = 2.0
	p.scale_amount_max = 3.0
	p.color = color
	p.color_ramp = _fade_ramp()
	p.position = pos
	stage.add_child(p)
	p.emitting = true
	get_tree().create_timer(1.0).timeout.connect(p.queue_free)
	return p


## Le scintille arancioni che salgono attorno a Subaru mentre carica.
## Restano accese finché chi le ha chieste non le spegne.
func aura() -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.amount = 30
	p.lifetime = 0.6
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(22, 6)
	p.direction = Vector2(0, -1)
	p.spread = 10.0
	p.gravity = Vector2(0, -120)
	p.initial_velocity_min = 20.0
	p.initial_velocity_max = 60.0
	p.scale_amount_min = 2.0
	p.scale_amount_max = 3.0
	p.color = Color(1, 0.7, 0.3)
	p.color_ramp = _fade_ramp()
	p.position = hero.position + Vector2(0, -4)
	stage.add_child(p)
	stage.move_child(p, hero.get_index())   # dietro a Subaru, non sopra
	return p


## La nebbia nera di Shamac sul nemico.
func mist(pos: Vector2) -> void:
	var p := CPUParticles2D.new()
	p.one_shot = true
	p.explosiveness = 0.6
	p.amount = 18
	p.lifetime = 1.1
	p.texture = SMOKE
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = 26.0
	p.spread = 180.0
	p.gravity = Vector2.ZERO
	p.initial_velocity_min = 8.0
	p.initial_velocity_max = 24.0
	p.angular_velocity_min = -60.0
	p.angular_velocity_max = 60.0
	p.scale_amount_min = 0.8
	p.scale_amount_max = 1.4
	var ramp := Gradient.new()
	ramp.set_color(0, Color(0.25, 0.05, 0.35, 0.0))
	ramp.set_color(1, Color(0.02, 0.0, 0.05, 0.0))
	ramp.add_point(0.25, Color(0.15, 0.02, 0.25, 0.9))
	ramp.add_point(0.7, Color(0.05, 0.0, 0.1, 0.8))
	p.color_ramp = ramp
	p.position = pos
	stage.add_child(p)
	p.emitting = true
	get_tree().create_timer(1.5).timeout.connect(p.queue_free)


## Due sbuffi di polvere ai piedi, uno per lato, quando qualcuno atterra.
func landing_dust(feet: Vector2) -> void:
	for side in [-1.0, 1.0]:
		var p := sparks(feet + Vector2(side * 10.0, -2.0), Color(0.85, 0.8, 0.9, 0.7), 8, 70.0)
		p.direction = Vector2(side, -0.3)
		p.spread = 25.0
		p.gravity = Vector2(0, -20)
		p.scale_amount_min = 3.0
		p.scale_amount_max = 5.0


## Il passaggio di livello: una colonna di luce che sale da Subaru e una stella.
func level_up_burst() -> void:
	var base := hero.position
	var p := CPUParticles2D.new()
	p.one_shot = true
	p.explosiveness = 0.3
	p.amount = 40
	p.lifetime = 0.9
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(26, 4)
	p.direction = Vector2(0, -1)
	p.spread = 6.0
	p.gravity = Vector2(0, -160)
	p.initial_velocity_min = 40.0
	p.initial_velocity_max = 110.0
	p.scale_amount_min = 2.0
	p.scale_amount_max = 4.0
	var ramp := Gradient.new()
	ramp.set_color(0, Color(1, 1, 0.85, 1))
	ramp.set_color(1, Color(1, 0.75, 0.3, 0))
	p.color_ramp = ramp
	p.material = _additive()
	p.position = base
	stage.add_child(p)
	p.emitting = true
	get_tree().create_timer(1.5).timeout.connect(p.queue_free)
	impact(base + Vector2(0, -36), 3.0)
	glow(hero, Color(1.5, 1.4, 0.9))


func _fade_ramp() -> Gradient:
	var ramp := Gradient.new()
	ramp.set_color(0, Color.WHITE)
	ramp.set_color(1, Color(1, 1, 1, 0))
	return ramp


# ---------- Ghiaccio (Scaglie di gelo, con Emilia) ----------

## Un fiocco di gelo che esplode: raggi a sei punte che si allargano e svaniscono.
func frost_burst(pos: Vector2, size: float) -> void:
	_play("frost", pos, size, rng.randf_range(0.0, PI / 3.0))


## Neve su tutta la scena, finché chi l'ha chiesta non la spegne (emitting = false).
func snowfall() -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.amount = 60
	p.lifetime = 2.6
	p.preprocess = 0.6
	p.texture = SNOWFLAKE
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(330, 10)
	p.direction = Vector2(-0.3, 1)
	p.spread = 15.0
	p.gravity = Vector2(0, 30)
	p.initial_velocity_min = 40.0
	p.initial_velocity_max = 90.0
	p.angular_velocity_min = -120.0
	p.angular_velocity_max = 120.0
	p.scale_amount_min = 0.6
	p.scale_amount_max = 1.4
	p.color_ramp = _fade_ramp()
	p.material = _additive()
	p.position = Vector2(0, -190)
	stage.add_child(p)
	return p


## Emilia arriva alle spalle di Subaru: scivola dentro dal bordo, avvolta da una luce
## fredda e da qualche scintilla di brina. Si aspetta con await.
func emilia_appears(emilia: Sprite2D, home: Vector2) -> void:
	emilia.visible = true
	emilia.position = home + Vector2(60, 0)
	emilia.modulate = Color(1.6, 1.9, 2.2, 0.0)
	var t := create_tween().set_parallel()
	t.tween_property(emilia, "position", home, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(emilia, "modulate", Color(1.15, 1.25, 1.4, 1.0), 0.35)
	sparks(home + Vector2(0, -60), ICE_COLOR, 14, 110.0)
	await t.finished


func emilia_leaves(emilia: Sprite2D) -> void:
	var t := create_tween().set_parallel()
	t.tween_property(emilia, "modulate:a", 0.0, 0.4)
	t.tween_property(emilia, "position:x", emilia.position.x + 40.0, 0.4)
	await t.finished
	emilia.visible = false


## Le scaglie compaiono a ventaglio sopra "center", una dopo l'altra, e brillano.
func ice_shards(center: Vector2, count: int) -> Array[Sprite2D]:
	var shards: Array[Sprite2D] = []
	for i in count:
		var s := Sprite2D.new()
		s.texture = ICE_SHARD
		s.material = _additive()
		var a := lerpf(-2.6, -0.55, i / maxf(1.0, count - 1.0))   # un arco sopra la testa
		s.position = center + Vector2.from_angle(a) * Vector2(70, 46)
		s.rotation = PI   # punte verso sinistra, verso il nemico
		s.scale = Vector2.ZERO
		stage.add_child(s)
		var t := create_tween()
		t.tween_interval(i * 0.05)
		t.tween_property(s, "scale", Vector2(2.4, 2.4), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		shards.append(s)
	return shards


## Una scaglia parte verso "target" lasciando una scia di brina; all'arrivo chiama on_hit.
func fire_shard(shard: Sprite2D, target: Vector2, time: float, on_hit: Callable) -> void:
	shard.rotation = (target - shard.position).angle()
	var trail := CPUParticles2D.new()
	trail.amount = 16
	trail.lifetime = 0.25
	trail.local_coords = false
	trail.gravity = Vector2.ZERO
	trail.spread = 180.0
	trail.initial_velocity_max = 15.0
	trail.scale_amount_min = 1.5
	trail.scale_amount_max = 2.5
	trail.color = ICE_COLOR
	trail.color_ramp = _fade_ramp()
	shard.add_child(trail)
	var t := create_tween()
	t.tween_property(shard, "position", target, time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.tween_callback(on_hit)
	t.tween_callback(shard.queue_free)


## Il nemico chiuso in un blocco di ghiaccio, che poi va in frantumi.
func ice_block(feet: Vector2) -> void:
	var b := Sprite2D.new()
	b.texture = ICE_BLOCK
	b.position = feet + Vector2(0, -44)
	b.scale = Vector2(0.2, 0.2)
	b.modulate = Color(1, 1, 1, 0.0)
	stage.add_child(b)
	var t := create_tween()
	t.tween_property(b, "scale", Vector2(2.4, 2.4), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(b, "modulate:a", 1.0, 0.12)
	t.tween_interval(0.45)
	t.tween_callback(func():
		var shards := sparks(b.position, ICE_COLOR, 34, 320.0)
		shards.scale_amount_min = 3.0
		shards.scale_amount_max = 6.0
		frost_burst(b.position, 4.0))
	t.tween_property(b, "scale", Vector2(2.9, 2.9), 0.1)
	t.parallel().tween_property(b, "modulate:a", 0.0, 0.1)
	t.tween_callback(b.queue_free)
