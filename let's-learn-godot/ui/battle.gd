extends CanvasLayer
## Il combattimento a turni. È un autoload chiamato "Battle".
##
##     var result: String = await Battle.start(enemy_data)
##
## Un turno a testa: prima Subaru (Attacca, Oggetti o Fuggi), poi il nemico.
## Finisce quando uno dei due resta senza punti salute, o Subaru scappa.
## I numeri di Subaru stanno in Stats, quelli del nemico in una risorsa EnemyData.
##
## L'aspetto è quello dei giochi di ruolo classici: il nemico a sinistra, Subaru a
## destra, finestre blu in basso, il nome dell'azione in alto, la barra d'attesa che
## si riempie prima di ogni turno di Subaru.

## Emesso alla fine, con WIN, LOSE o FLED. Battle.start() lo aspetta per te.
signal finished(result: String)
## Il messaggio in alto è stato letto (tasto premuto o tempo scaduto).
signal _advance

const WIN := "win"
const LOSE := "lose"
const FLED := "fled"

## Colori del testo della salute: normale, poca, finita.
const HP_OK := Color(0.96, 0.95, 1.0)
const HP_LOW := Color(1.0, 0.85, 0.3)
const HP_ZERO := Color(1.0, 0.35, 0.3)

## Quanto resta un messaggio se non si preme niente, in secondi.
@export var message_time := 1.2
## Quanto ci mette la barra d'attesa a riempirsi prima del turno di Subaru.
@export var gauge_time := 0.7
## La probabilità di riuscire a scappare (0.5 = una volta su due).
@export var flee_chance := 0.5

@onready var backdrop: ColorRect = $Backdrop
@onready var flash: ColorRect = $Flash
@onready var screen: Control = $Screen
@onready var hero: AnimatedSprite2D = %Hero
@onready var enemy_sprite: Sprite2D = %Enemy
@onready var hero_shadow: Sprite2D = %HeroShadow
@onready var enemy_shadow: Sprite2D = %EnemyShadow
@onready var hero_name: Label = %HeroName
@onready var hero_bar: ProgressBar = %HeroBar
@onready var hero_hp: Label = %HeroHp
@onready var gauge: ProgressBar = %Gauge
@onready var enemy_name: Label = %EnemyName
@onready var enemy_bar: ProgressBar = %EnemyBar
@onready var help: Control = %Help
@onready var message: Label = %Message
@onready var menu: Control = %Menu
@onready var attack_button: MenuItem = %Attack
@onready var items_button: MenuItem = %Items
@onready var flee_button: MenuItem = %Flee
@onready var item_window: Control = %ItemWindow
@onready var potion_button: MenuItem = %Potion
@onready var item_info: Label = %ItemInfo
@onready var results: Control = %Results
@onready var results_text: Label = %ResultsText

## True dall'inizio alla fine del combattimento.
var is_active := false
## Chi stiamo affrontando, e quanti punti salute gli restano.
var enemy: EnemyData
var enemy_hp := 0
## I dadi. È una variabile così i test possono fissare il "seme" (rng.seed)
## e ottenere sempre gli stessi tiri.
var rng := RandomNumberGenerator.new()

var _waiting := false
## Cresce a ogni messaggio: il timer di un messaggio vecchio non chiude quello nuovo.
var _message_id := 0
var _hero_home := Vector2.ZERO
var _enemy_home := Vector2.ZERO
var _enemy_scale := Vector2.ONE
var _gauge_glow: Tween


func _ready() -> void:
	visible = false
	rng.randomize()
	_hero_home = hero.position
	_enemy_home = enemy_sprite.position
	_enemy_scale = enemy_sprite.scale
	attack_button.pressed.connect(_on_attack)
	items_button.pressed.connect(_open_items)
	potion_button.pressed.connect(_on_potion)
	flee_button.pressed.connect(_on_flee)
	Stats.changed.connect(_update_hero_info)


## Comincia un combattimento e aspetta che finisca. Restituisce WIN, LOSE o FLED.
func start(data: EnemyData) -> String:
	if is_active:
		return ""
	is_active = true
	# Come in una cutscene: Subaru sulla mappa sta fermo e i menu non si aprono.
	Game.in_cutscene = true
	enemy = data
	enemy_hp = data.max_hp

	enemy_sprite.texture = data.texture
	enemy_sprite.modulate = Color.WHITE
	enemy_sprite.scale = _enemy_scale
	enemy_name.text = data.name
	enemy_bar.max_value = data.max_hp
	enemy_bar.value = enemy_hp
	hero.modulate = Color.WHITE
	hero.flip_h = true   # le azioni guardano a destra: qui Subaru guarda il nemico, a sinistra
	_idle()
	_update_hero_info()
	hero_bar.value = Stats.hp
	gauge.value = 0
	help.visible = false
	results.visible = false
	item_window.visible = false
	_show_menu(false)

	visible = true
	_intro()
	return await finished


## L'entrata: due lampi, lo schermo che si avvicina, i due che arrivano dai lati.
func _intro() -> void:
	Sfx.play(Sfx.HIT)
	flash.color.a = 0.0
	var t := create_tween()
	for i in 2:
		t.tween_property(flash, "color:a", 0.85, 0.05)
		t.tween_property(flash, "color:a", 0.0, 0.07)
	t.parallel().tween_method(_set_blur, 0.0, 1.0, 0.3)
	await t.finished

	screen.pivot_offset = screen.size / 2.0
	screen.scale = Vector2(1.15, 1.15)
	screen.modulate.a = 0.0
	enemy_sprite.position.x = _enemy_home.x - 260.0
	hero.position.x = _hero_home.x + 260.0
	var enter := create_tween().set_parallel()
	enter.tween_property(screen, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	enter.tween_property(screen, "modulate:a", 1.0, 0.2)
	enter.tween_property(enemy_sprite, "position:x", _enemy_home.x, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	enter.tween_property(hero, "position:x", _hero_home.x, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await enter.finished
	await _say("%s appare!" % enemy.name)
	_player_turn()


# ---------- Il turno di Subaru ----------

## La barra d'attesa si riempie, poi compare la finestra dei comandi.
func _player_turn() -> void:
	gauge.value = 0
	var t := create_tween()
	t.tween_property(gauge, "value", gauge.max_value, gauge_time)
	await t.finished
	# Barra piena: lampeggia finché Subaru non sceglie.
	_gauge_glow = create_tween().set_loops()
	_gauge_glow.tween_property(gauge, "modulate", Color(1.6, 1.6, 1.6), 0.25)
	_gauge_glow.tween_property(gauge, "modulate", Color.WHITE, 0.25)
	_show_menu(true)


## Subaru ha scelto: la barra si svuota e i comandi spariscono.
func _act() -> void:
	_show_menu(false)
	item_window.visible = false
	if _gauge_glow:
		_gauge_glow.kill()
	gauge.modulate = Color.WHITE
	gauge.value = 0


func _on_attack() -> void:
	_act()
	_announce("Pugno")
	# Scatta fin davanti al nemico, e intanto parte il pugno.
	create_tween().tween_property(hero, "position:x", _enemy_home.x + 95.0, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	hero.play("punch")
	await hero.animation_finished
	var dealt := Stats.damage(Stats.attack, enemy.defense, rng.randi_range(-1, 1))
	enemy_hp = maxi(0, enemy_hp - dealt)
	_hit(enemy_sprite, dealt, -92.0)
	create_tween().tween_property(enemy_bar, "value", enemy_hp, 0.3)
	await _pause(message_time * 0.6)
	help.visible = false
	create_tween().tween_property(hero, "position:x", _hero_home.x, 0.2)
	_idle()
	if enemy_hp == 0:
		_victory()
	else:
		_enemy_turn()


## Il sottomenu "Oggetti". Esc torna ai comandi (vedi _unhandled_input).
func _open_items() -> void:
	var count: int = Inventory.items.get(Inventory.POTION, 0)
	potion_button.text = "Pozione   x%d" % count
	item_info.text = "Rimette %d PS." % Inventory.item(Inventory.POTION).heal if count > 0 else "Non ne hai."
	item_window.visible = true
	potion_button.focus_silently()


func _close_items() -> void:
	item_window.visible = false
	Sfx.play(Sfx.BACK)
	items_button.focus_silently()


func _on_potion() -> void:
	_act()
	if not Inventory.has(Inventory.POTION):
		await _say("Non hai pozioni.")
		_player_turn()   # non hai fatto niente: il turno è ancora tuo
		return
	var healed := Inventory.use(Inventory.POTION)
	if healed == 0:
		await _say("Sei già in piena forma.")
		_player_turn()
		return
	_announce("Pozione")
	Sfx.play(Sfx.HEAL)
	_glow(hero, Color(0.6, 1.4, 0.7))
	_pop_number(hero, str(healed), Color(0.45, 1.0, 0.55), -128.0)
	await _pause(message_time * 0.6)
	help.visible = false
	_idle()
	_enemy_turn()   # curarsi costa il turno


func _on_flee() -> void:
	_act()
	_announce("Fuga")
	if rng.randf() < flee_chance:
		var t := create_tween()
		t.tween_property(hero, "position:x", _hero_home.x + 260.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		await _say("Sei scappato!")
		_end(FLED)
	else:
		await _say("Non riesci a scappare!")
		_enemy_turn()


# ---------- Il turno del nemico ----------

func _enemy_turn() -> void:
	_announce(enemy.name)
	var dealt := Stats.damage(enemy.attack, Stats.defense, rng.randi_range(-1, 1))
	# Scatta verso Subaru, colpisce, torna al suo posto.
	var lunge := create_tween()
	lunge.tween_property(enemy_sprite, "position:x", _enemy_home.x + 70.0, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await lunge.finished
	Stats.take_damage(dealt)
	hero.play("hurt")
	_hit(hero, dealt, -128.0)
	create_tween().tween_property(enemy_sprite, "position:x", _enemy_home.x, 0.25)
	await _pause(message_time * 0.6)
	help.visible = false
	if Stats.hp == 0:
		_defeat()
	else:
		_idle()
		_player_turn()


# ---------- Come finisce ----------

func _victory() -> void:
	# Il nemico lampeggia di bianco, si tinge di viola e si scioglie verso il basso.
	var t := create_tween()
	t.tween_property(enemy_sprite, "modulate", Color(3, 3, 3), 0.06)
	t.tween_property(enemy_sprite, "modulate", Color(1.0, 0.3, 0.8, 0.0), 0.5)
	t.parallel().tween_property(enemy_sprite, "scale", _enemy_scale * Vector2(1.3, 0.2), 0.5).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(enemy_shadow, "modulate:a", 0.0, 0.5)
	await t.finished
	hero.play("cheer")
	var levels := Stats.gain_xp(enemy.xp)
	var text := "Esperienza  +%d" % enemy.xp
	if levels > 0:
		Sfx.play(Sfx.LEVEL_UP)
		text += "\nLivello %d!  Salute, attacco e difesa aumentano." % Stats.level
	else:
		Sfx.play(Sfx.CONFIRM)
		text += "\nAl prossimo livello: %d" % (Stats.xp_to_next() - Stats.xp)
	results_text.text = text
	results.visible = true
	results.modulate.a = 0.0
	create_tween().tween_property(results, "modulate:a", 1.0, 0.2)
	await _wait_for_reader(message_time * 2.0)
	_end(WIN)


func _defeat() -> void:
	hero.play("collapse")
	create_tween().tween_property(hero, "modulate", Color(0.45, 0.35, 0.55), 0.8)
	await _say("Subaru crolla a terra...")
	_end(LOSE)


func _end(result: String) -> void:
	var t := create_tween().set_parallel()
	t.tween_method(_set_blur, 1.0, 0.0, 0.25)
	t.tween_property(screen, "modulate:a", 0.0, 0.25)
	await t.finished
	visible = false
	is_active = false
	enemy_shadow.modulate.a = 1.0
	Game.in_cutscene = false
	finished.emit(result)
	if result == LOSE:
		# Perdere è morire: e Subaru, quando muore, torna indietro.
		ReturnByDeath.die()


# ---------- Messaggi, menu, effetti ----------

## Il nome dell'azione nella finestra in alto, senza aspettare.
func _announce(text: String) -> void:
	message.text = text
	message.visible_ratio = 1.0
	help.visible = true


## Un messaggio nella finestra in alto, che aspetta di essere letto.
func _say(text: String) -> void:
	_announce(text)
	message.visible_ratio = 0.0
	create_tween().tween_property(message, "visible_ratio", 1.0, 0.2)
	await _wait_for_reader(message_time)
	help.visible = false


## Aspetta un tasto, oppure "seconds" secondi.
func _wait_for_reader(seconds: float) -> void:
	_message_id += 1
	var id := _message_id
	get_tree().create_timer(seconds).timeout.connect(_on_message_timeout.bind(id))
	_waiting = true
	await _advance
	_waiting = false


func _on_message_timeout(id: int) -> void:
	# Se nel frattempo si è premuto un tasto, questo timer appartiene a un messaggio già passato.
	if _waiting and id == _message_id:
		_advance.emit()


func _pause(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return
	if item_window.visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close_items()
	elif _waiting and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		_advance.emit()


func _show_menu(shown: bool) -> void:
	menu.visible = shown
	if shown:
		attack_button.focus_silently()


## In guardia, oppure in ginocchio se la salute è quasi finita.
func _idle() -> void:
	hero.play("weak" if Stats.hp * 4 <= Stats.max_hp else "guard")


func _update_hero_info() -> void:
	hero_name.text = "Subaru  Lv %d" % Stats.level
	hero_hp.text = "%d/%d" % [Stats.hp, Stats.max_hp]
	var color := HP_OK
	if Stats.hp == 0:
		color = HP_ZERO
	elif Stats.hp * 4 <= Stats.max_hp:
		color = HP_LOW
	hero_hp.add_theme_color_override("font_color", color)
	hero_bar.max_value = Stats.max_hp
	if is_active:
		create_tween().tween_property(hero_bar, "value", Stats.hp, 0.3)
	else:
		hero_bar.value = Stats.hp


## Il colpo: un suono, un lampo rosso, una scossa e il numero del danno che rimbalza.
func _hit(target: Node2D, amount: int, height: float) -> void:
	Sfx.play(Sfx.HIT)
	var x := target.position.x
	var t := create_tween()
	t.tween_property(target, "modulate", Color(1.0, 0.35, 0.35), 0.05)
	t.parallel().tween_property(target, "position:x", x + 6.0, 0.05)
	t.tween_property(target, "position:x", x - 5.0, 0.05)
	t.tween_property(target, "position:x", x, 0.05)
	t.parallel().tween_property(target, "modulate", Color.WHITE, 0.15)
	_pop_number(target, str(amount), Color.WHITE, height)


## Un bagliore colorato che va e viene (la cura).
func _glow(target: CanvasItem, color: Color) -> void:
	var t := create_tween()
	t.tween_property(target, "modulate", color, 0.15)
	t.tween_property(target, "modulate", Color.WHITE, 0.35)


## Il numero salta su, ricade con un piccolo rimbalzo, resta un attimo e svanisce.
func _pop_number(target: Node2D, text: String, color: Color, height: float) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 32)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.05, 0.03, 0.1))
	label.add_theme_constant_override("outline_size", 6)
	target.get_parent().add_child(label)
	var base_y := target.position.y + height
	label.position = Vector2(target.position.x - label.get_minimum_size().x / 2.0, base_y)
	var t := create_tween()
	t.tween_property(label, "position:y", base_y - 16.0, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(label, "position:y", base_y, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.tween_property(label, "position:y", base_y - 5.0, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(label, "position:y", base_y, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.tween_interval(0.45)
	t.tween_property(label, "modulate:a", 0.0, 0.25)
	t.tween_callback(label.queue_free)


## Le ombre seguono i due quando scattano in avanti.
func _process(_delta: float) -> void:
	if is_active:
		hero_shadow.position.x = hero.position.x
		enemy_shadow.position.x = enemy_sprite.position.x


func _set_blur(value: float) -> void:
	(backdrop.material as ShaderMaterial).set_shader_parameter("amount", value)
