extends Cutscene
## L'arrivo a Erbalta, alla prima partita (subito dopo la cutscene del castello):
## schermo nero, si sentono dei passi, poi sorge il sole e Subaru ed Emilia arrivano
## a piedi dal sentiero a sud. Emilia si apposta in piazza, Subaru va in giro.
##
## È una "regia" scritta in codice: una riga dopo l'altra, con await per aspettare
## che ogni azione finisca prima di passare alla successiva.

## Da dove parte Subaru (fuori dallo schermo, in fondo al sentiero) e dove si ferma.
const START := Vector2(656, 820)
const STOP := Vector2(656, 416)
## Emilia gli cammina accanto, sulla destra, e alla fine va al suo posto in piazza.
const EMILIA_OFFSET := Vector2(36, 6)
## I colori dell'alba: prima il blu della notte che finisce, poi l'arancio del sole basso.
const NIGHT_TINT := Color(0.5, 0.52, 0.8)
const DAWN_TINT := Color(1.0, 0.76, 0.62)
## Quanto sono forti i raggi di sole nel momento più bello dell'alba.
const DAWN_RAYS := 0.9


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
	_show_bars_now()
	# Emilia c'è sempre nella scena, al suo posto in piazza: la portiamo in fondo al
	# sentiero, accanto a Subaru. Se un giorno non ci fosse, la cutscene va avanti lo stesso.
	var emilia := get_parent().get_node_or_null("World/Emilia")
	var emilia_post := Vector2.ZERO
	if emilia:
		emilia_post = emilia.global_position
		emilia.global_position = START + EMILIA_OFFSET
		emilia.face(Facing.UP)

	player.global_position = START
	player.face(Facing.UP)
	# La camera deve partire già su Subaru, senza scivolare dal centro della mappa.
	var camera := player.get_node("Camera2D") as Camera2D
	camera.reset_smoothing.call_deferred()

	# 1. Buio: si sentono solo i passi. Intanto prepariamo l'alba.
	_sunrise()
	await _wait(0.5)
	_fade_in_later(1.6, 1.8)
	# 2. Camminano fino alla piazza, fianco a fianco: Emilia parte senza await
	#    (così vanno insieme), si aspetta solo Subaru. Stessa velocità, stessa strada.
	if emilia:
		emilia.walk_to(STOP + EMILIA_OFFSET, player.walk_speed)
	await player.walk_to(STOP)

	# 3. Compare il nome del luogo, e intanto Subaru si guarda intorno.
	_show_place_card()
	await _wait(0.6)
	player.face(Facing.LEFT)
	await _wait(0.8)
	player.face(Facing.RIGHT)
	await _wait(0.8)
	player.face(Facing.DOWN)
	await _wait(0.6)

	# 4. Via le bande, poi due parole: Emilia si apposta in piazza.
	await _hide_bars()
	if emilia:
		await _emilia_takes_post(player, emilia, emilia_post)
	else:
		await _say("Subaru", ["Erbalta... Vediamo se qualcuno sa dirmi qualcosa."])

	# 5. Fine: il giocatore riprende i comandi. il ricordo finisce nel salvataggio.
	Game.set_flag(FlagKeys.INTRO_SEEN)
	Game.in_cutscene = false
	# Il primo punto di ritorno del Ritorno dalla Morte: Subaru in piazza, appena arrivato.
	Game.set_checkpoint()
	queue_free()


func _emilia_takes_post(player: Node2D, emilia: Node2D, post: Vector2) -> void:
	player.face(Facing.RIGHT)
	emilia.face(Facing.LEFT)
	await _say("Emilia", [
		"Eccoci: il villaggio di Erbalta. Sembra così tranquillo...",
		"Io mi apposto qui, in piazza. Da qui vedo chi entra e chi esce.",
		"Tu fai un giro e parla con gli abitanti. Se scopri qualcosa, vieni a dirmelo!",
	])
	# Va al suo posto; Subaru la segue con lo sguardo.
	player.face(Facing.DOWN)
	await emilia.walk_to(post)
	emilia.face(Facing.DOWN)
	player.face(Facing.LEFT)
	await _say("Subaru", [
		"Agli ordini! Il vecchio Subaru non ti deluderà.",
		"...Allora. Da dove comincio?",
	])


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
