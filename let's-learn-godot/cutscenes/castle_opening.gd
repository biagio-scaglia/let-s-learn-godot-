extends Cutscene
## La primissima scena di una partita nuova: è notte, Subaru ed Emilia escono dalla
## Rocca d'Argento e partono verso il villaggio di Erbalta. Poi si passa al villaggio,
## dove la cutscene "intro" li fa arrivare all'alba.
##
## Il castello non è un livello: non ci si gioca, si guarda soltanto.

## Dove si fermano a parlare, appena passato il ponte, tra le prime due torce.
const SUBARU_STOP := Vector2(370, 330)
const EMILIA_STOP := Vector2(400, 334)
## Fin dove camminano alla fine (fuori dallo schermo, in fondo al sentiero).
const EXIT_Y := 660.0
## Passo tranquillo: è notte, e la strada è lunga.
const SPEED := 55.0

@onready var camera: Camera2D = get_parent().get_node("Camera2D")


func _ready() -> void:
	var player := get_tree().get_first_node_in_group("player")
	var emilia := get_parent().get_node_or_null("World/Emilia")
	if player == null or emilia == null:
		queue_free()
		return
	# Subito, durante _ready: così Game.change_scene lascia a noi il compito di togliere il nero.
	Game.in_cutscene = true
	_play(player, emilia)


func _play(player: Node2D, emilia: Node2D) -> void:
	_show_bars_now()
	player.face(Facing.DOWN)
	emilia.face(Facing.DOWN)

	# 1. Dal nero compare il castello di notte, con il suo nome.
	await _wait(0.4)
	Fade.fade_in(2.0)
	await _wait(0.8)
	_show_place_card()
	await _wait(2.2)

	# 2. Escono dal portone e attraversano il ponte; la camera scende con loro.
	_pan_camera(Vector2(camera.position.x, 300), 3.0)
	emilia.walk_to(EMILIA_STOP, SPEED)
	await player.walk_to(SUBARU_STOP, SPEED)

	# 3. Via le bande (coprirebbero la finestra di dialogo), poi due parole alla luce delle torce.
	emilia.face(Facing.LEFT)
	player.face(Facing.RIGHT)
	await _hide_bars()
	await _say("Emilia", [
		"Ecco, siamo fuori. Il villaggio di Erbalta è a sud, oltre il bosco.",
		"Se camminiamo tutta la notte, arriveremo all'alba.",
	])
	await _say("Subaru", ["Una gita al chiaro di luna con Emilia-tan! E... cosa ci andiamo a fare, esattamente?"])
	await _say("Emilia", [
		"Da qualche giorno da Erbalta arrivano voci strane. Sembra che nessuno voglia più lasciare il villaggio.",
		"Io resterò in piazza a tenere d'occhio le cose. Tu invece parlerai con la gente: sei bravo, in questo.",
	])
	await _say("Subaru", ["Bravissimo! Lascia fare a me, Emilia-tan!"])
	await _say("Emilia", ["...Il \"-tan\" non serve, Subaru."])

	# 4. Si rimettono in cammino verso sud, e la scena sfuma sul villaggio.
	await _wait(0.3)
	_pan_camera(Vector2(camera.position.x, 420), 4.0)
	emilia.walk_to(Vector2(EMILIA_STOP.x, EXIT_Y), SPEED)
	player.walk_to(Vector2(SUBARU_STOP.x, EXIT_Y), SPEED)
	await _wait(3.2)
	# Al villaggio, dal sentiero a sud (niente punto d'arrivo, niente suono di porta):
	# lì parte la cutscene dell'arrivo.
	Game.change_scene(Game.FIRST_LEVEL, "", "", false)


func _pan_camera(to: Vector2, seconds: float) -> void:
	create_tween().tween_property(camera, "position", to, seconds) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
