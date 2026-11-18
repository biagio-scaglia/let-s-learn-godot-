extends Cutscene
## L'arrivo nel Bosco Senza Tempo, all'alba (atto 3). Subaru ed Emilia salgono dal
## sentiero a sud, si guardano intorno, un corvo rompe il silenzio. Poi Emilia
## comincia a seguire Subaru (vedi Follower).

const START := Vector2(598, 1180)
const STOP := Vector2(598, 900)
const EMILIA_OFFSET := Vector2(34, 6)

@onready var crow: AudioStreamPlayer = get_parent().get_node_or_null("Sounds/Crow")


func _ready() -> void:
	var player := get_tree().get_first_node_in_group("player")
	var emilia := get_parent().get_node_or_null("World/Emilia")
	# Solo la prima volta, e non quando si torna qui da un salvataggio o da una morte.
	if player == null or emilia == null or Game.has_flag(FlagKeys.FOREST_ARRIVED) \
			or Game.spawn_point != "" or Game.spawn_position != null:
		queue_free()
		return
	Game.in_cutscene = true
	_play(player, emilia)


func _play(player: Node2D, emilia: Node2D) -> void:
	_show_bars_now()
	player.global_position = START
	emilia.global_position = START + EMILIA_OFFSET
	player.face(Facing.UP)
	emilia.face(Facing.UP)
	player.reset_physics_interpolation()
	emilia.reset_physics_interpolation()
	var camera := player.get_node("Camera2D") as Camera2D
	camera.reset_smoothing.call_deferred()

	# 1. Dal nero, il bosco all'alba. Salgono piano, insieme.
	_fade_in_later(0.4, 2.2)
	var speed: float = player.walk_speed * 0.75
	emilia.walk_to(STOP + EMILIA_OFFSET, speed)
	await player.walk_to(STOP, speed)

	# 2. Il nome del luogo; Subaru si guarda intorno.
	_show_place_card()
	await _wait(0.8)
	player.face(Facing.LEFT)
	await _wait(0.9)
	player.face(Facing.RIGHT)
	await _wait(0.9)
	await _hide_bars()

	# 3. Il silenzio, il corvo, e la regola del bosco: restare vicini.
	player.face(Facing.RIGHT)
	emilia.face(Facing.LEFT)
	await _say("Emilia", [
		"Gli alberi... non hanno nemmeno una foglia.",
		"E non si sente niente. Né il vento tra i rami, né un uccello.",
	])
	if crow:
		crow.play()
	await _wait(1.6)
	await _say("Subaru", ["...A parte quello. Grazie, corvo. Molto rassicurante."])
	await _say("Emilia", [
		"Restiamo vicini, d'accordo? Io ti seguo: tu guarda dove metti i piedi.",
		"E se vedi degli occhi tra i rovi... non fissarli troppo a lungo.",
	])
	await _say("Subaru", ["Bosco Senza Tempo, eh? Speriamo almeno che abbia un'uscita."])

	Game.set_flag(FlagKeys.FOREST_ARRIVED)
	Game.in_cutscene = false
	# Da qui si riparte, se si muore nel bosco.
	Game.set_checkpoint()
	queue_free()
