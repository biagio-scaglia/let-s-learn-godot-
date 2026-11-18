extends Cutscene
## Il finale: dopo Colui che guarda, quando Subaru ha salutato tutti e va in fondo al
## sentiero a sud, Subaru ed Emilia lasciano Erbalta all'alba. È l'intro al contrario:
## là arrivavano dal sentiero a sud mentre sorgeva il sole, qui se ne vanno.
## Il Saggio corre a salutarli, poi lo schermo sfuma sui titoli di coda.
##
## Finché non è il momento la cutscene aspetta: ogni frame guarda se Subaru è arrivato
## in fondo al sentiero (TRIGGER). Prima di aver salutato tutti, Emilia lo ferma.

## La scena dei titoli di coda.
const CREDITS_SCENE := "res://ui/credits.tscn"
## Il fondo del sentiero a sud: entrandoci si parte (o Emilia ricorda chi manca).
const TRIGGER := Rect2(592, 664, 128, 60)
## Il centro del sentiero e il punto, fuori dallo schermo, dove spariscono.
const PATH_X := 656.0
const EXIT_Y := 840.0
## Emilia cammina accanto a Subaru, sulla destra (come nell'intro).
const EMILIA_OFFSET := Vector2(36, 6)
## Passo lento: non si ha fretta, quando si parte per sempre... o quasi.
const SPEED := 50.0
## Gli stessi colori dell'alba dell'intro.
const DAWN_TINT := Color(1.0, 0.76, 0.62)
const DAWN_RAYS := 0.9

var _player: Node2D
## Emilia ha già detto "prima salutiamo tutti": non lo ripete finché Subaru non esce dalla zona.
var _warned := false


func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player") as Node2D
	# Niente finale nello sfondo del titolo (niente Subaru) o prima del boss.
	if _player == null or not Game.has_flag(FlagKeys.BOSS_DEFEATED) \
			or Game.has_flag(FlagKeys.GAME_FINISHED):
		queue_free()
		return


func _process(_delta: float) -> void:
	if not Game.player_can_move():
		return
	if not TRIGGER.has_point(_player.global_position):
		_warned = false
		return
	if FlagKeys.greeted_count() == FlagKeys.VILLAGERS.size():
		set_process(false)
		Game.in_cutscene = true
		play()
	elif not _warned:
		_warned = true
		Dialogue.start("Emilia", [
			"Aspetta, Subaru. Prima di partire salutiamo tutti.",
			"Il Saggio, Lina e l'Archivista. Non possiamo andarcene senza una parola.",
		])


## La regia del finale. Pubblica (senza "_") così un test la può far partire.
func play() -> void:
	Game.in_cutscene = true
	var world := get_parent().get_node("World")
	var emilia := world.get_node_or_null("Emilia") as Node2D
	var saggio := world.get_node_or_null("Npc") as Node2D

	# 1. Subaru si volta a guardare il villaggio; Emilia gli si mette accanto.
	_player.face(Facing.UP)
	if emilia:
		await emilia.walk_to(_player.global_position + EMILIA_OFFSET)
		emilia.face(Facing.UP)

	# 2. Il Saggio arriva di corsa (per quanto corre un vecchio) a salutarli.
	if saggio:
		await saggio.walk_to(_player.global_position + Vector2(-44, -40), 60.0)
		saggio.face(Facing.RIGHT)
		_player.face(Facing.LEFT)
		await _say("Saggio", [
			"Fiuu... Alla mia età non si corre. Ma volevo vedervi partire.",
			"Lina vi saluta. E l'Archivista dice che non vede l'ora di leggere il capitolo dopo.",
		])
		if emilia:
			emilia.face(Facing.LEFT)
		await _say("Emilia", ["Grazie di tutto, Saggio. Torneremo, promesso."])
		await _say("Subaru", ["E quando torniamo voglio vedere quegli alberi più alti di me!"])
		await _say("Saggio", ["Ah! Allora sbrigatevi: adesso crescono."])

	# 3. Le ultime parole, guardando la strada.
	_player.face(Facing.RIGHT)
	if emilia:
		emilia.face(Facing.LEFT)
	await _say("Subaru", ["Allora... andiamo, Emiliuccia?"])
	await _say("Emilia", ["Andiamo. ...Subaru?"])
	await _say("Subaru", ["Mh?"])
	await _say("Emilia", ["Grazie. Per esserti ricordato. Di tutto."])
	await _say("Subaru", ["...È la cosa che mi riesce meglio."])

	# 4. L'alba, le bande nere, e si incamminano verso sud: l'intro al contrario.
	Game.set_flag(FlagKeys.GAME_FINISHED)
	Progress.finish_story()
	_sunrise()
	_fade_music(6.0)
	await _show_bars()
	if saggio and saggio.has_method("face"):
		saggio.face(Facing.DOWN)
	var start := Vector2(PATH_X, _player.global_position.y)
	if emilia:
		emilia.walk_to(start + EMILIA_OFFSET, SPEED)
	await _player.walk_to(start, SPEED)
	_show_place_card()
	if emilia:
		emilia.walk_to(Vector2(PATH_X, EXIT_Y) + EMILIA_OFFSET, SPEED)
	_player.walk_to(Vector2(PATH_X, EXIT_Y), SPEED)
	if saggio:
		_wave(saggio)
	await _wait(3.6)
	await Fade.fade_out(2.5)
	await _wait(0.8)
	Game.change_scene(CREDITS_SCENE, "", "", false)


## Il Saggio saluta: due saltelli sul posto.
func _wave(saggio: Node2D) -> void:
	var y := saggio.position.y
	var t := create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS).set_loops(3)
	t.tween_property(saggio, "position:y", y - 4.0, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(saggio, "position:y", y, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.tween_interval(0.5)
