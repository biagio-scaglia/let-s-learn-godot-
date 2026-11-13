extends CanvasLayer
## La cutscene d'apertura, solo alla prima partita: schermo nero, si sentono dei passi,
## poi sorge il sole e Subaru arriva a piedi nel villaggio dal sentiero a sud.
##
## È una "regia" scritta in codice: una riga dopo l'altra, con await per aspettare
## che ogni azione finisca prima di passare alla successiva.

## Da dove parte Subaru (fuori dallo schermo, in fondo al sentiero) e dove si ferma.
const START := Vector2(656, 820)
const STOP := Vector2(656, 416)
## Altezza delle bande nere "da film", in pixel.
const BAR_HEIGHT := 36.0
## I colori dell'alba: prima il blu della notte che finisce, poi l'arancio del sole basso.
const NIGHT_TINT := Color(0.5, 0.52, 0.8)
const DAWN_TINT := Color(1.0, 0.76, 0.62)
## Quanto sono forti i raggi di sole nel momento più bello dell'alba.
const DAWN_RAYS := 0.9

@onready var top_bar: ColorRect = $TopBar
@onready var bottom_bar: ColorRect = $BottomBar
@onready var place_card: Control = $PlaceCard
@onready var place_line: ColorRect = $PlaceCard/Line


func _ready() -> void:
	var player := get_tree().get_first_node_in_group("player")
	# Niente cutscene se: siamo nello sfondo del titolo (lì Subaru non c'è), l'abbiamo
	# già vista, o arriviamo da una porta / da un salvataggio.
	if player == null or Game.has_flag(FlagKeys.INTRO_SEEN) \
			or Game.spawn_point != "" or Game.spawn_position != null:
		queue_free()
		return
	# Va detto subito, durante _ready: così Game.change_scene non toglie il nero da solo.
	Game.in_cutscene = true
	_play(player)


func _play(player: Node2D) -> void:
	# Le bande nere sono già al loro posto quando l'immagine compare.
	# Sono ancorate ai bordi: basta dire quanto sporgono verso il centro.
	top_bar.offset_bottom = BAR_HEIGHT
	bottom_bar.offset_top = -BAR_HEIGHT

	player.global_position = START
	player.face(Facing.UP)
	# La camera deve partire già su Subaru, senza scivolare dal centro della mappa.
	var camera := player.get_node("Camera2D") as Camera2D
	camera.reset_smoothing.call_deferred()

	# 1. Buio: si sentono solo i passi. Intanto prepariamo l'alba.
	_sunrise()
	await _wait(0.5)
	_fade_in_later(1.6, 1.8)
	# 2. Subaru cammina fino alla piazza (await: aspetta che sia arrivato).
	await player.walk_to(STOP)

	# 3. Compare il nome del luogo, e intanto Subaru si guarda intorno.
	_show_place_card()
	await _wait(0.6)
	player.face(Facing.LEFT)
	await _wait(0.8)
	player.face(Facing.RIGHT)
	await _wait(0.8)
	player.face(Facing.DOWN)
	await _wait(0.9)

	# 4. Via le bande, poi un pensiero ad alta voce.
	await _hide_bars()
	Dialogue.start("Subaru", [
		"...Dove sono finito?",
		"Un villaggio. Magari qui qualcuno sa dirmi qualcosa.",
	])
	await Dialogue.finished

	# 5. Fine: il giocatore riprende i comandi. il ricordo finisce nel salvataggio.
	Game.set_flag(FlagKeys.INTRO_SEEN)
	Game.in_cutscene = false
	queue_free()


## L'alba: la luce del mondo (Tint) passa dal blu all'arancio al colore normale,
## e i raggi di sole si accendono forti per poi calmarsi.
func _sunrise() -> void:
	var tint := get_parent().get_node_or_null("Tint") as CanvasModulate
	var rays := get_parent().get_node_or_null("Effects/SunRays") as ColorRect
	if tint == null or rays == null:
		return
	var day_tint := tint.color
	var rays_mat := rays.material as ShaderMaterial
	var day_rays: float = rays_mat.get_shader_parameter("intensity")

	tint.color = NIGHT_TINT
	rays_mat.set_shader_parameter("intensity", 0.0)

	var t := create_tween()
	t.tween_interval(2.0)   # nel buio non si vede: aspettiamo che lo schermo si schiarisca
	t.tween_property(tint, "color", DAWN_TINT, 2.2).set_trans(Tween.TRANS_SINE)
	t.tween_property(tint, "color", day_tint, 2.8).set_trans(Tween.TRANS_SINE)
	# I raggi vanno in parallelo: un Tween separato con i suoi tempi.
	var r := create_tween()
	r.tween_interval(2.4)
	r.tween_method(_set_rays.bind(rays_mat), 0.0, DAWN_RAYS, 2.4).set_trans(Tween.TRANS_SINE)
	r.tween_method(_set_rays.bind(rays_mat), DAWN_RAYS, day_rays, 3.0).set_trans(Tween.TRANS_SINE)


func _set_rays(value: float, mat: ShaderMaterial) -> void:
	mat.set_shader_parameter("intensity", value)


## "Villaggio di Erbalta": la scritta scende un poco e compare, la linea dorata si allarga
## dal centro, poi tutto sparisce.
func _show_place_card() -> void:
	var y := place_card.position.y
	place_card.position.y = y - 8.0
	place_line.scale.x = 0.0
	var t := create_tween()
	t.tween_property(place_card, "modulate:a", 1.0, 0.6)
	t.parallel().tween_property(place_card, "position:y", y, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(place_line, "scale:x", 1.0, 0.9).set_delay(0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_interval(1.4)
	t.tween_property(place_card, "modulate:a", 0.0, 0.7)


## Toglie il nero dopo "delay" secondi, in "seconds" secondi, senza fermare la cutscene.
func _fade_in_later(delay: float, seconds: float) -> void:
	await _wait(delay)
	Fade.fade_in(seconds)


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


func _hide_bars() -> void:
	var t := create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	t.tween_property(top_bar, "offset_bottom", 0.0, 0.4)
	t.tween_property(bottom_bar, "offset_top", 0.0, 0.4)
	await t.finished
