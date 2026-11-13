extends CanvasLayer
## La cutscene d'apertura, solo alla prima partita: schermo nero, si sentono dei passi,
## poi l'immagine compare e Subaru arriva a piedi nel villaggio dal sentiero a sud.
##
## È una "regia" scritta in codice: una riga dopo l'altra, con await per aspettare
## che ogni azione finisca prima di passare alla successiva.

## Da dove parte Subaru (fuori dallo schermo, in fondo al sentiero) e dove si ferma.
const START := Vector2(656, 820)
const STOP := Vector2(656, 416)
## Altezza delle bande nere "da film", in pixel.
const BAR_HEIGHT := 36.0

@onready var top_bar: ColorRect = $TopBar
@onready var bottom_bar: ColorRect = $BottomBar


func _ready() -> void:
	var player := get_tree().get_first_node_in_group("player")
	# Niente cutscene se: siamo nello sfondo del titolo (lì Subaru non c'è), l'abbiamo
	# già vista, o arriviamo da una porta / da un salvataggio.
	if player == null or Game.flags.get("intro_vista", false) \
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
	player.face("up")
	# La camera deve partire già su Subaru, senza scivolare dal centro della mappa.
	var camera := player.get_node("Camera2D") as Camera2D
	camera.reset_smoothing.call_deferred()

	# 1. Buio: si sentono solo i passi.
	await get_tree().create_timer(0.5).timeout
	_fade_in_later(1.6, 1.8)
	# 2. Subaru cammina fino alla piazza (await: aspetta che sia arrivato).
	await player.walk_to(STOP)

	# 3. Si guarda intorno.
	await _wait(0.5)
	player.face("left")
	await _wait(0.6)
	player.face("right")
	await _wait(0.6)
	player.face("down")
	await _wait(0.3)

	# 4. Via le bande, poi un pensiero ad alta voce.
	await _hide_bars()
	Dialogue.start("Subaru", [
		"...Dove sono finito?",
		"Un villaggio. Magari qui qualcuno sa dirmi qualcosa.",
	])
	await Dialogue.finished

	# 5. Fine: il giocatore riprende i comandi. "intro_vista" finisce nel salvataggio.
	Game.flags["intro_vista"] = true
	Game.in_cutscene = false
	queue_free()


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
