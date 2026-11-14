extends CanvasLayer
## Il combattimento a turni. È un autoload chiamato "Battle".
##
##     var result: String = await Battle.start(enemy_data)
##
## Un turno a testa: prima Subaru (Attacca, Pozione o Fuggi), poi il nemico.
## Finisce quando uno dei due resta senza punti salute, o Subaru scappa.
## I numeri di Subaru stanno in Stats, quelli del nemico in una risorsa EnemyData.

## Emesso alla fine, con WIN, LOSE o FLED. Battle.start() lo aspetta per te.
signal finished(result: String)
## Il messaggio in basso è stato letto (tasto premuto o tempo scaduto).
signal _advance

const WIN := "win"
const LOSE := "lose"
const FLED := "fled"

## Quanto resta un messaggio se non si preme niente, in secondi.
@export var message_time := 1.2
## La probabilità di riuscire a scappare (0.5 = una volta su due).
@export var flee_chance := 0.5

@onready var backdrop: ColorRect = $Backdrop
@onready var screen: Control = $Screen
@onready var hero: AnimatedSprite2D = %Hero
@onready var enemy_sprite: Sprite2D = %Enemy
@onready var hero_name: Label = %HeroName
@onready var hero_bar: ProgressBar = %HeroBar
@onready var hero_hp: Label = %HeroHp
@onready var enemy_name: Label = %EnemyName
@onready var enemy_bar: ProgressBar = %EnemyBar
@onready var message: Label = %Message
@onready var menu: Control = %Menu
@onready var attack_button: MenuItem = %Attack
@onready var potion_button: MenuItem = %Potion
@onready var flee_button: MenuItem = %Flee

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


func _ready() -> void:
	visible = false
	rng.randomize()
	_hero_home = hero.position
	_enemy_home = enemy_sprite.position
	attack_button.pressed.connect(_on_attack)
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
	enemy_sprite.position = _enemy_home
	enemy_sprite.modulate = Color.WHITE
	enemy_name.text = data.name
	enemy_bar.max_value = data.max_hp
	enemy_bar.value = enemy_hp
	hero.position = _hero_home
	hero.modulate = Color.WHITE
	hero.play("guard")
	_update_hero_info()
	hero_bar.value = Stats.hp
	message.text = ""
	_show_menu(false)

	visible = true
	screen.modulate.a = 0.0
	var t := create_tween().set_parallel()
	t.tween_method(_set_blur, 0.0, 1.0, 0.3)
	t.tween_property(screen, "modulate:a", 1.0, 0.3)
	_intro()
	return await finished


func _intro() -> void:
	await _say("%s ti sbarra la strada!" % enemy.name)
	_player_turn()


# ---------- Il turno di Subaru ----------

func _player_turn() -> void:
	message.text = "Cosa fai?"
	_show_menu(true)


func _on_attack() -> void:
	_show_menu(false)
	# Scatta fin davanti al nemico, e intanto parte il pugno.
	create_tween().tween_property(hero, "position:x", _enemy_home.x - 95.0, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	hero.play("punch")
	await hero.animation_finished
	var dealt := Stats.damage(Stats.attack, enemy.defense, rng.randi_range(-1, 1))
	enemy_hp = maxi(0, enemy_hp - dealt)
	_hit(enemy_sprite, dealt)
	create_tween().tween_property(enemy_bar, "value", enemy_hp, 0.3)
	await _say("Subaru colpisce! %d danni." % dealt)
	hero.play("guard")
	create_tween().tween_property(hero, "position:x", _hero_home.x, 0.2)
	if enemy_hp == 0:
		_victory()
	else:
		_enemy_turn()


func _on_potion() -> void:
	_show_menu(false)
	if not Inventory.has(Inventory.POTION):
		await _say("Non hai pozioni.")
		_player_turn()   # non hai fatto niente: il turno è ancora tuo
		return
	var healed := Inventory.use(Inventory.POTION)
	if healed == 0:
		await _say("Sei già in piena forma.")
		_player_turn()
		return
	Sfx.play(Sfx.HEAL)
	_pop_number(hero, "+%d" % healed, Color(0.5, 1.0, 0.55))
	await _say("Bevi una pozione: +%d PS." % healed)
	_enemy_turn()   # curarsi costa il turno


func _on_flee() -> void:
	_show_menu(false)
	if rng.randf() < flee_chance:
		await _say("Sei scappato!")
		_end(FLED)
	else:
		await _say("Non riesci a scappare!")
		_enemy_turn()


# ---------- Il turno del nemico ----------

func _enemy_turn() -> void:
	var dealt := Stats.damage(enemy.attack, Stats.defense, rng.randi_range(-1, 1))
	# Scatta in avanti, colpisce, torna al suo posto.
	var lunge := create_tween()
	lunge.tween_property(enemy_sprite, "position:x", _enemy_home.x - 70.0, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await lunge.finished
	Stats.take_damage(dealt)
	hero.play("hurt")
	_hit(hero, dealt)
	create_tween().tween_property(enemy_sprite, "position:x", _enemy_home.x, 0.25)
	await _say("%s attacca! %d danni." % [enemy.name, dealt])
	if Stats.hp == 0:
		_defeat()
	else:
		hero.play("guard")
		_player_turn()


# ---------- Come finisce ----------

func _victory() -> void:
	create_tween().tween_property(enemy_sprite, "modulate:a", 0.0, 0.4)
	hero.play("cheer")
	await _say("%s è sconfitto!" % enemy.name)
	var levels := Stats.gain_xp(enemy.xp)
	await _say("Ottieni %d punti esperienza." % enemy.xp)
	if levels > 0:
		Sfx.play(Sfx.LEVEL_UP)
		await _say("Livello %d! Salute, attacco e difesa aumentano." % Stats.level)
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
	Game.in_cutscene = false
	finished.emit(result)
	if result == LOSE:
		# Perdere è morire: e Subaru, quando muore, torna indietro.
		ReturnByDeath.die()


# ---------- Messaggi, menu, effetti ----------

## Scrive un messaggio in basso e aspetta che venga letto: un tasto, oppure message_time.
func _say(text: String) -> void:
	message.text = text
	message.visible_ratio = 0.0
	create_tween().tween_property(message, "visible_ratio", 1.0, 0.2)
	_message_id += 1
	var id := _message_id
	get_tree().create_timer(message_time).timeout.connect(_on_message_timeout.bind(id))
	_waiting = true
	await _advance
	_waiting = false


func _on_message_timeout(id: int) -> void:
	# Se nel frattempo si è premuto un tasto, questo timer appartiene a un messaggio già passato.
	if _waiting and id == _message_id:
		_advance.emit()


func _unhandled_input(event: InputEvent) -> void:
	if _waiting and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		_advance.emit()


func _show_menu(shown: bool) -> void:
	menu.visible = shown
	if shown:
		potion_button.text = "Pozione x%d" % Inventory.items.get(Inventory.POTION, 0)
		attack_button.focus_silently()


func _update_hero_info() -> void:
	hero_name.text = "Subaru  Lv %d" % Stats.level
	hero_hp.text = "PS %d/%d" % [Stats.hp, Stats.max_hp]
	hero_bar.max_value = Stats.max_hp
	if is_active:
		create_tween().tween_property(hero_bar, "value", Stats.hp, 0.3)
	else:
		hero_bar.value = Stats.hp


## Il colpo: un suono, un lampo rosso, una scossa e il numero del danno che sale.
func _hit(target: Node2D, amount: int) -> void:
	Sfx.play(Sfx.HIT)
	var x := target.position.x
	var t := create_tween()
	t.tween_property(target, "modulate", Color(1.0, 0.35, 0.35), 0.05)
	t.parallel().tween_property(target, "position:x", x + 6.0, 0.05)
	t.tween_property(target, "position:x", x - 5.0, 0.05)
	t.tween_property(target, "position:x", x, 0.05)
	t.parallel().tween_property(target, "modulate", Color.WHITE, 0.15)
	_pop_number(target, str(amount), Color(1.0, 0.85, 0.4))


func _pop_number(target: Node2D, text: String, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.theme_type_variation = &"HeaderLabel"
	label.add_theme_color_override("font_color", color)
	label.position = target.position + Vector2(-10, -110)
	target.get_parent().add_child(label)
	var t := create_tween()
	t.tween_property(label, "position:y", label.position.y - 26.0, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(label, "modulate:a", 0.0, 0.6).set_ease(Tween.EASE_IN)
	t.tween_callback(label.queue_free)


func _set_blur(value: float) -> void:
	(backdrop.material as ShaderMaterial).set_shader_parameter("amount", value)
