extends CanvasLayer
## Il combattimento a turni. È un autoload chiamato "Battle".
##
##     var result: String = await Battle.start(enemy_data)
##
## Un turno a testa: prima Subaru (Attacca, Abilità, Oggetti, Difendi o Fuggi), poi il
## nemico. Finisce quando uno dei due resta senza punti salute, o Subaru scappa.
## I numeri di Subaru stanno in Stats, quelli del nemico in una risorsa EnemyData.
##
## Scudi e debolezze: ogni nemico ha dei punti scudo e dei tipi di colpo che lo
## indeboliscono ("pugno", "calcio", "ombra"). All'inizio si vedono come "?": si
## scoprono colpendo. Un colpo su una debolezza toglie un punto scudo; a zero il
## nemico è ROTTO: salta il suo turno e fino al prossimo prende il doppio dei danni.
##
## L'aspetto: i turni in alto a sinistra, Subaru in alto a destra, i comandi in una
## lista inclinata accanto, scudo e debolezze sotto il nemico, la descrizione in basso.

## Emesso alla fine, con WIN, LOSE o FLED. Battle.start() lo aspetta per te.
signal finished(result: String)
## Il messaggio in alto è stato letto (tasto premuto o tempo scaduto).
signal _advance

const WIN := "win"
const LOSE := "lose"
const FLED := "fled"

const HERO := "hero"
const ENEMY := "enemy"
## Emilia, quando è nel party (vedi Game.emilia_in_party()).
const ALLY := "ally"

## Le mosse di Subaru. "power" moltiplica il danno, "type" decide le debolezze,
## "cost" sono i punti tecnica (PT) che servono.
const ATTACK := "pugno"
const SKILLS := {
	"pugno": {"name": "Pugno", "cost": 0, "power": 1.0, "type": "pugno",
		"info": "Un pugno veloce. Colpo di tipo pugno."},
	"calcio": {"name": "Calcio", "cost": 3, "power": 1.5, "type": "calcio",
		"info": "Un calcio alto, più forte di un pugno. Tipo calcio."},
	"shamac": {"name": "Shamac", "cost": 4, "power": 1.2, "type": "ombra",
		"info": "Una nebbia nera avvolge il nemico. Tipo ombra."},
	"carica": {"name": "Pugno caricato", "cost": 6, "power": 2.4, "type": "pugno",
		"info": "Si concentra, poi colpisce con tutta la forza. Tipo pugno."},
}
## Su una debolezza il danno cresce del 50%; a nemico rotto raddoppia.
const WEAK_BONUS := 1.5
const BREAK_BONUS := 2.0
## I punti tecnica che tornano difendendosi.
const DEFEND_SP := 2

## Colori del testo della salute: normale, poca, finita.
const HP_OK := Color(0.96, 0.95, 1.0)
const HP_LOW := Color(1.0, 0.85, 0.3)
const HP_ZERO := Color(1.0, 0.35, 0.3)

## Quanto resta un messaggio se non si preme niente, in secondi.
@export var message_time := 1.2
## Quanto dura la transizione d'ingresso (la mappa che gira e le bande nere).
@export var transition_time := 0.75
## La probabilità di riuscire a scappare (0.5 = una volta su due).
@export var flee_chance := 0.5

@onready var backdrop: ColorRect = $Backdrop
@onready var flash: ColorRect = $Flash
@onready var transition: ColorRect = $Transition
@onready var screen: Control = $Screen
@onready var stage: Control = %Stage
@onready var hero: AnimatedSprite2D = %Hero
@onready var enemy_sprite: Sprite2D = %Enemy
@onready var hero_shadow: Sprite2D = %HeroShadow
@onready var enemy_shadow: Sprite2D = %EnemyShadow
@onready var enemy_info: BattleEnemyInfo = %EnemyInfo
@onready var break_label: Label = %BreakLabel
@onready var turn_bar: BattleTurnBar = %TurnBar
@onready var commands: BattleCommands = %Commands
@onready var party: Control = %Party
@onready var hero_level: Label = %HeroLevel
@onready var hero_hp: Label = %HeroHp
@onready var hero_bar: ProgressBar = %HeroBar
@onready var hero_sp: Label = %HeroSp
@onready var sp_bar: ProgressBar = %SpBar
@onready var hero_status: Label = %HeroStatus
@onready var announce_box: Control = %Announce
@onready var message: Label = %Message
@onready var results: Control = %Results
@onready var results_text: Label = %ResultsText
@onready var music: AudioStreamPlayer = $Music

## Il volume del tema di battaglia quando è entrato del tutto.
const MUSIC_DB := -7.0

## True dall'inizio alla fine del combattimento.
var is_active := false
## Chi stiamo affrontando, e quanti punti salute e scudo gli restano.
var enemy: EnemyData
var enemy_hp := 0
var enemy_shield := 0
## Rotto: scudo a zero. Salta un turno e prende il doppio dei danni.
var enemy_broken := false
## I tipi di debolezza già scoperti in questo combattimento.
var revealed: Array[String] = []
## Subaru si è difeso: il prossimo colpo del nemico fa metà danno.
var defending := false
## A chi tocca: HERO o ENEMY.
var turn := HERO
## I dadi. È una variabile così i test possono fissare il "seme" (rng.seed)
## e ottenere sempre gli stessi tiri.
var rng := RandomNumberGenerator.new()

var _waiting := false
## Cresce a ogni messaggio: il timer di un messaggio vecchio non chiude quello nuovo.
var _message_id := 0
## Quanti turni il nemico rotto deve ancora saltare.
var _enemy_stun := 0
var _hero_home := Vector2.ZERO
var _enemy_home := Vector2.ZERO
var _enemy_scale := Vector2.ONE
## La scala del nemico nella scena per uno sprite da 16 pixel. Gli sprite più grandi
## (i nemici nuovi sono da 32) vengono rimpiccioliti: sullo schermo sono tutti alti uguali.
var _enemy_base_scale := Vector2.ONE
## Il respiro del nemico (le due pose di riposo in loop) e se una posa lo sta sostituendo.
var _enemy_breath: Tween
var _enemy_posing := false
## Gli effetti visivi (scintille, stelle, onde d'urto…): vedi battle_vfx.gd.
var vfx: BattleVfx


func _ready() -> void:
	visible = false
	rng.randomize()
	_hero_home = hero.position
	_enemy_home = enemy_sprite.position
	_enemy_base_scale = enemy_sprite.scale
	# I comandi dicono cosa hai scelto; qui si decide cosa succede.
	commands.setup(SKILLS, ATTACK, DEFEND_SP)
	commands.skill_chosen.connect(_use_skill)
	commands.potion_chosen.connect(_on_potion)
	commands.defend_chosen.connect(_on_defend)
	commands.flee_chosen.connect(_on_flee)
	Stats.changed.connect(_update_hero_info)
	vfx = BattleVfx.new()
	vfx.name = "Vfx"
	add_child(vfx)
	vfx.setup(stage, hero, enemy_sprite, self, flash)


## Comincia un combattimento e aspetta che finisca. Restituisce WIN, LOSE o FLED.
func start(data: EnemyData) -> String:
	if is_active:
		return ""
	is_active = true
	# Come in una cutscene: Subaru sulla mappa sta fermo e i menu non si aprono.
	Game.in_cutscene = true
	enemy = data
	enemy_hp = data.max_hp
	enemy_shield = data.shield
	enemy_broken = false
	_enemy_stun = 0
	revealed.clear()
	defending = false
	turn = HERO

	enemy_sprite.texture = data.texture
	enemy_sprite.hframes = maxi(1, data.frames)
	enemy_sprite.frame = 0
	var height := data.cell_size()
	_enemy_scale = _enemy_base_scale * (16.0 / height)
	enemy_sprite.offset = Vector2(0, -height / 2.0)   # i piedi restano sulla posizione
	enemy_sprite.modulate = Color.WHITE
	enemy_sprite.scale = _enemy_scale
	enemy_sprite.rotation = 0.0
	enemy_info.show_enemy(data, revealed)
	_update_shield()
	hero.modulate = Color.WHITE
	hero.flip_h = true   # le azioni guardano a destra: qui Subaru guarda il nemico, a sinistra
	_start_enemy_breathing()
	_idle()
	_update_hero_info()
	hero_bar.value = Stats.hp
	sp_bar.value = Stats.sp
	announce_box.visible = false
	results.visible = false
	break_label.visible = false
	commands.close_submenus()
	commands.show_menu(false)
	_refresh_turns()

	visible = true
	vfx.stage_home = stage.position
	_start_music()
	_intro()
	return await finished


## La musica del livello si mette in pausa (riprenderà da dove era) e parte quella
## della battaglia, sempre dall'inizio, entrando in fretta.
func _start_music() -> void:
	_pause_level_music(true)
	music.volume_db = -20.0
	music.play()
	create_tween().tween_property(music, "volume_db", MUSIC_DB, 0.6)


func _pause_level_music(paused: bool) -> void:
	for level_music in get_tree().get_nodes_in_group("level_music"):
		(level_music as AudioStreamPlayer).stream_paused = paused


## L'entrata. Prima la transizione: un lampo, la mappa che gira e si sgrana mentre
## le bande nere la coprono. Poi le bande si ritirano e, sotto, la battaglia entra:
## lo schermo che si avvicina, i due dai lati, la barra dei turni che scende e la
## scheda di Subaru che arriva da destra.
func _intro() -> void:
	Sfx.play(Sfx.BATTLE_START)
	flash.color = Color(1, 1, 1, 0.9)
	create_tween().tween_property(flash, "color:a", 0.0, 0.15)
	_set_transition(0.0)
	_transition_material().set_shader_parameter("swirl", 1.0)
	transition.visible = true
	var cover := create_tween()
	cover.tween_method(_set_transition, 0.0, 1.0, transition_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await cover.finished
	# Sotto il nero: lo sfondo è già sfocato quando le bande si aprono.
	_set_blur(1.0)
	_transition_material().set_shader_parameter("swirl", 0.0)
	create_tween().tween_method(_set_transition, 1.0, 0.0, transition_time * 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	get_tree().create_timer(transition_time * 0.6).timeout.connect(transition.hide)

	screen.pivot_offset = screen.size / 2.0
	screen.scale = Vector2(1.15, 1.15)
	screen.modulate.a = 0.0
	enemy_sprite.position.x = _enemy_home.x - 260.0
	hero.position.x = _hero_home.x + 260.0
	var bar_y := turn_bar.position.y
	var party_x := party.position.x
	turn_bar.position.y = bar_y - 40.0
	party.position.x = party_x + 180.0
	var enter := create_tween().set_parallel().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	enter.tween_property(screen, "scale", Vector2.ONE, 0.3)
	enter.tween_property(screen, "modulate:a", 1.0, 0.2)
	enter.tween_property(enemy_sprite, "position:x", _enemy_home.x, 0.4)
	enter.tween_property(hero, "position:x", _hero_home.x, 0.4)
	enter.tween_property(turn_bar, "position:y", bar_y, 0.35).set_delay(0.15)
	enter.tween_property(party, "position:x", party_x, 0.35).set_delay(0.15)
	# Le bande si aprono con un'onda d'urto dal centro; i due arrivano come
	# sagome bianche che prendono colore, e atterrano sollevando polvere.
	vfx.shockwave_at(Vector2(0, -30), 0.9, 0.6)
	for sprite: CanvasItem in [hero, enemy_sprite]:
		vfx.flash_white(sprite, 0.35, 0.15)
	await enter.finished
	vfx.landing_dust(hero.position)
	vfx.landing_dust(enemy_sprite.position)
	vfx.shake(2.0, 0.15)
	await _say("%s appare!" % enemy.name)
	_player_turn()


# ---------- Il turno di Subaru ----------

func _player_turn() -> void:
	turn = HERO
	if defending:
		defending = false
		hero_status.visible = false
		_idle()
	_refresh_turns()
	commands.show_menu(true)


## Subaru ha scelto: i comandi spariscono.
func _act() -> void:
	commands.show_menu(false)
	commands.close_submenus()


## Attacca e le abilità: spende i PT, fa la mossa, poi tocca al nemico.
func _use_skill(id: String) -> void:
	var skill: Dictionary = SKILLS[id]
	if not Stats.spend_sp(skill.cost):
		Sfx.play(Sfx.BACK)
		commands.say("Non hai abbastanza PT.")
		return
	_act()
	_announce(skill.name)
	match id:
		"calcio":
			await _do_kick(skill)
		"shamac":
			await _do_shamac(skill)
		"carica":
			await _do_power_punch(skill)
		_:
			await _do_jab(skill)
	await _pause(message_time * 0.5)
	announce_box.visible = false
	create_tween().tween_property(hero, "position:x", _hero_home.x, 0.2)
	_idle()
	if enemy_hp == 0:
		_victory()
	else:
		_enemy_turn()


## Pugno: scatta davanti al nemico e colpisce al terzo frame.
func _do_jab(skill: Dictionary) -> void:
	_dash_to_enemy(0.15)
	Sfx.play(Sfx.SWING)
	hero.play("jab")
	await _until_frame(2)
	_hit_stop()
	_strike(skill, Sfx.HIT)
	vfx.impact(_impact_point(), 2.0)
	vfx.sparks(_impact_point(), Color(1, 0.95, 0.8), 10, 140.0)
	await hero.animation_finished


## Calcio: come il pugno ma più pesante, con una scossa.
func _do_kick(skill: Dictionary) -> void:
	_dash_to_enemy(0.15)
	Sfx.play(Sfx.SWING)
	hero.play("kick")
	await _until_frame(1)
	_hit_stop()
	_strike(skill, Sfx.KICK)
	vfx.slash(_impact_point() + Vector2(-8, 4))
	vfx.impact(_impact_point(), 2.5)
	vfx.shake(5.0, 0.25)
	vfx.sparks(_impact_point(), Color(1, 0.75, 0.4), 16, 200.0)
	await hero.animation_finished


## Shamac: Subaru si accuccia, lo schermo si scurisce e una nebbia nera avvolge il nemico.
func _do_shamac(skill: Dictionary) -> void:
	hero.play("charge")
	Sfx.play(Sfx.SHAMAC)
	flash.color = Color(0.12, 0.0, 0.2, 0.0)
	var dark := create_tween()
	dark.tween_property(flash, "color:a", 0.45, 0.25)
	vfx.mist(enemy_sprite.position + Vector2(0, -36))
	create_tween().tween_property(enemy_sprite, "modulate", Color(0.45, 0.3, 0.6), 0.4)
	await _pause(0.7)
	_strike(skill, Sfx.HIT)
	vfx.shake(3.0, 0.3)
	var back := create_tween().set_parallel()
	back.tween_property(flash, "color:a", 0.0, 0.4)
	back.tween_property(enemy_sprite, "modulate", _enemy_color(), 0.5)
	await back.finished
	flash.color = Color(1, 1, 1, 0)


## Pugno caricato: si concentra (scintille che salgono, lo schermo che si avvicina),
## poi scatta e colpisce con un lampo e una gran scossa.
func _do_power_punch(skill: Dictionary) -> void:
	hero.play("charge")
	Sfx.play(Sfx.CHARGE)
	var aura := vfx.aura()
	var zoom := create_tween()
	zoom.tween_property(stage, "scale", Vector2(1.06, 1.06), 0.8).set_trans(Tween.TRANS_SINE)
	await _pause(0.8)
	aura.emitting = false
	get_tree().create_timer(1.0).timeout.connect(aura.queue_free)
	_dash_to_enemy(0.1)
	Sfx.play(Sfx.SWING)
	hero.play("power_punch")
	await _until_frame(1)
	_hit_stop(0.12)
	_strike(skill, Sfx.KICK)
	flash.color = Color(1, 0.95, 0.85, 0.7)
	create_tween().tween_property(flash, "color:a", 0.0, 0.3)
	vfx.shake(9.0, 0.4)
	vfx.impact(_impact_point(), 4.0)
	vfx.shockwave_at(_impact_point(), 0.45)
	vfx.sparks(_impact_point(), Color(1, 0.8, 0.35), 28, 260.0)
	create_tween().tween_property(stage, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await hero.animation_finished


## Il colpo arriva: danno, debolezza, scudo, magari la rottura.
func _strike(skill: Dictionary, sound: String) -> void:
	var weak := enemy.weaknesses.has(skill.type)
	var amount := Stats.damage(Stats.attack, enemy.defense, rng.randi_range(-1, 1))
	var multiplier: float = skill.power
	if weak:
		multiplier *= WEAK_BONUS
	if enemy_broken:
		multiplier *= BREAK_BONUS
	amount = maxi(1, roundi(amount * multiplier))
	enemy_hp = maxi(0, enemy_hp - amount)

	var color := Color.WHITE
	var size := 32
	if enemy_broken:
		color = Color(1.0, 0.6, 0.25)
		size = 40
	elif weak:
		color = Color(1.0, 0.88, 0.35)
		size = 36
	_hit(enemy_sprite, amount, -92.0, sound, color, size)

	if weak:
		Sfx.play(Sfx.WEAK)
		_reveal(skill.type)
		if not enemy_broken:
			enemy_shield -= 1
			_update_shield()
			vfx.bump(enemy_info.shield_icon)
			if enemy_shield == 0:
				_break()


## Il nemico è rotto: scudo in frantumi, salta il prossimo turno.
func _break() -> void:
	enemy_broken = true
	_enemy_stun = 1
	_update_shield()
	_refresh_turns()
	Sfx.play(Sfx.BREAK)
	flash.color = Color(0.85, 0.95, 1.0, 0.75)
	create_tween().tween_property(flash, "color:a", 0.0, 0.35)
	vfx.shake(7.0, 0.35)
	vfx.shockwave_at(enemy_sprite.position + Vector2(0, -40), 0.6)
	var shards := vfx.sparks(enemy_sprite.position + Vector2(0, -40), Color(0.7, 0.85, 1.0), 30, 280.0)
	shards.scale_amount_min = 3.0
	shards.scale_amount_max = 5.0
	# La scritta salta fuori, grande, poi torna alla misura giusta e svanisce.
	break_label.visible = true
	break_label.modulate.a = 1.0
	break_label.scale = Vector2(2.2, 2.2)
	var t := create_tween()
	t.tween_property(break_label, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_interval(0.6)
	t.tween_property(break_label, "modulate:a", 0.0, 0.3)
	t.tween_callback(break_label.hide)
	# Il nemico rotto barcolla, si inclina e diventa più scuro.
	_enemy_pose(EnemyData.Pose.HURT)
	var wobble := create_tween()
	wobble.tween_property(enemy_sprite, "rotation", -0.25, 0.15)
	wobble.tween_property(enemy_sprite, "modulate", _enemy_color(), 0.2)


## Dopo il turno saltato il nemico si riprende: scudo di nuovo pieno.
func _recover() -> void:
	enemy_broken = false
	enemy_shield = enemy.shield
	_update_shield()
	vfx.bump(enemy_info.shield_icon)
	Sfx.play(Sfx.GUARD)
	var t := create_tween().set_parallel()
	t.tween_property(enemy_sprite, "rotation", 0.0, 0.2)
	t.tween_property(enemy_sprite, "modulate", Color.WHITE, 0.2)
	_enemy_rest()


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
	vfx.glow(hero, Color(0.6, 1.4, 0.7))
	var leaves := vfx.sparks(hero.position + Vector2(0, -30), Color(0.55, 1.0, 0.6), 14, 60.0)
	leaves.gravity = Vector2(0, -80)
	vfx.pop_number(hero.position, str(healed), Color(0.45, 1.0, 0.55), -128.0)
	await _pause(message_time * 0.6)
	announce_box.visible = false
	_idle()
	_enemy_turn()   # curarsi costa il turno


## Difendersi: metà danno al prossimo colpo, e qualche PT di ritorno.
func _on_defend() -> void:
	_act()
	defending = true
	_announce("Difesa")
	Sfx.play(Sfx.GUARD)
	hero.play("defend")
	hero_status.visible = true
	vfx.glow(hero, Color(0.6, 0.85, 1.6))
	var restored := Stats.restore_sp(DEFEND_SP)
	if restored > 0:
		vfx.pop_number(hero.position, "+%d PT" % restored, Color(0.5, 0.78, 1.0), -128.0, 24)
	await _pause(message_time * 0.6)
	announce_box.visible = false
	_enemy_turn()


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
	turn = ENEMY
	_refresh_turns()
	if enemy_broken:
		if _enemy_stun > 0:
			# Rotto: perde il turno. Resta rotto (e fragile) fino al prossimo.
			_enemy_stun -= 1
			var t := create_tween()
			t.tween_property(enemy_sprite, "rotation", 0.25, 0.15)
			t.tween_property(enemy_sprite, "rotation", -0.25, 0.15)
			await _say("%s è stordito!" % enemy.name)
			_player_turn()
			return
		_recover()
		await _say("%s si riprende." % enemy.name)

	_announce(enemy.name)
	var dealt := Stats.damage(enemy.attack, Stats.defense, rng.randi_range(-1, 1))
	if defending:
		dealt = maxi(1, ceili(dealt / 2.0))
	# Si carica (indietreggia un poco), poi scatta verso Subaru, colpisce, torna al suo posto.
	_enemy_pose(EnemyData.Pose.WINDUP)
	var windup := create_tween()
	windup.tween_property(enemy_sprite, "position:x", _enemy_home.x - 14.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await windup.finished
	_enemy_pose(EnemyData.Pose.ATTACK)
	var lunge := create_tween()
	lunge.tween_property(enemy_sprite, "position:x", _enemy_home.x + 70.0, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await lunge.finished
	Stats.take_damage(dealt)
	if defending:
		Sfx.play(Sfx.GUARD)
		vfx.sparks(hero.position + Vector2(-30, -36), Color(0.6, 0.85, 1.0), 10, 120.0)
	else:
		hero.play("stagger")
		vfx.shake(3.0, 0.2)
		vfx.impact(hero.position + Vector2(-24, -40), 2.0)
	_hit(hero, dealt, -128.0, Sfx.HIT, Color.WHITE, 32)
	var back := create_tween()
	back.tween_property(enemy_sprite, "position:x", _enemy_home.x, 0.25)
	back.tween_callback(_enemy_rest)
	await _pause(message_time * 0.6)
	announce_box.visible = false
	if Stats.hp == 0:
		_defeat()
	else:
		if not defending:
			_idle()
		_player_turn()


# ---------- Come finisce ----------

func _victory() -> void:
	# Il nemico lampeggia di bianco, si tinge di viola e si scioglie verso il basso.
	_stop_enemy_breathing()
	_enemy_pose(EnemyData.Pose.HURT)
	vfx.impact(enemy_sprite.position + Vector2(0, -40), 4.0)
	vfx.flash_white(enemy_sprite, 0.5)
	var t := create_tween()
	t.tween_property(enemy_sprite, "modulate", Color(1.0, 0.3, 0.8, 0.0), 0.5)
	t.parallel().tween_property(enemy_sprite, "scale", _enemy_scale * Vector2(1.3, 0.2), 0.5).set_ease(Tween.EASE_IN)
	t.parallel().tween_property(enemy_shadow, "modulate:a", 0.0, 0.5)
	t.parallel().tween_property(enemy_info, "modulate:a", 0.0, 0.3)
	await t.finished
	hero.play("cheer")
	var levels := Stats.gain_xp(enemy.xp)
	var text := "Esperienza  +%d" % enemy.xp
	if levels > 0:
		Sfx.play(Sfx.LEVEL_UP)
		vfx.level_up_burst()
		text += "\nLivello %d!  Salute, PT, attacco e difesa aumentano." % Stats.level
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
	if result != LOSE:
		flash.color = Color(1, 1, 1, 0.6)
		create_tween().tween_property(flash, "color:a", 0.0, 0.25)
	var t := create_tween().set_parallel()
	t.tween_method(_set_blur, 1.0, 0.0, 0.25)
	t.tween_property(screen, "modulate:a", 0.0, 0.25)
	t.tween_property(music, "volume_db", -40.0, 0.25)
	await t.finished
	music.stop()
	# Se si perde la musica del livello resta in pausa: ci pensa il Ritorno dalla Morte.
	if result != LOSE:
		_pause_level_music(false)
	visible = false
	is_active = false
	_stop_enemy_breathing()
	enemy_shadow.modulate.a = 1.0
	flash.color = Color(1, 1, 1, 0)
	vfx.reset()
	hero_status.visible = false
	Game.in_cutscene = false
	finished.emit(result)
	if result == LOSE:
		# Perdere è morire: e Subaru, quando muore, torna indietro.
		ReturnByDeath.die()


# ---------- Le pose del nemico (vedi EnemyData.Pose) ----------

## Respiro: le due pose di riposo si alternano, finché una posa "speciale" non le ferma.
func _start_enemy_breathing() -> void:
	_stop_enemy_breathing()
	_enemy_posing = false
	if not enemy.animated():
		return
	_enemy_breath = create_tween().set_loops()
	for pose in [EnemyData.Pose.IDLE, EnemyData.Pose.IDLE_2]:
		_enemy_breath.tween_callback(_breathe.bind(pose))
		_enemy_breath.tween_interval(0.45)


func _stop_enemy_breathing() -> void:
	if _enemy_breath:
		_enemy_breath.kill()
		_enemy_breath = null


func _breathe(pose: int) -> void:
	if not _enemy_posing:
		enemy_sprite.frame = pose


## Mette il nemico in una posa (carica, attacco, colpito) e ferma il respiro.
func _enemy_pose(pose: int) -> void:
	if enemy == null or not enemy.animated():
		return
	_enemy_posing = true
	enemy_sprite.frame = pose


## Torna a respirare; se è rotto (stordito) resta con la smorfia di dolore.
func _enemy_rest() -> void:
	if enemy == null or not enemy.animated() or not is_active:
		return
	if enemy_broken or enemy_hp == 0:
		enemy_sprite.frame = EnemyData.Pose.HURT
		return
	_enemy_posing = false
	enemy_sprite.frame = EnemyData.Pose.IDLE


## Ridisegna la barra dei turni in alto (vedi battle_turn_bar.gd).
func _refresh_turns() -> void:
	turn_bar.refresh(turn, _enemy_stun, enemy.portrait())


# ---------- Scudo, debolezze e barra dei turni ----------

func _update_shield() -> void:
	enemy_info.set_shield(enemy_shield, enemy_broken)


## Una debolezza appena scoperta: la si ricorda, e la sua casella fa un salto.
func _reveal(kind: String) -> void:
	if revealed.has(kind):
		return
	revealed.append(kind)
	var slot := enemy_info.reveal(kind)
	if slot:
		vfx.bump(slot)


# ---------- Messaggi, menu ----------

## Il nome dell'azione nella striscia in alto, senza aspettare.
func _announce(text: String) -> void:
	message.text = text
	message.visible_ratio = 1.0
	announce_box.visible = true


## Un messaggio nella striscia in alto, che aspetta di essere letto.
func _say(text: String) -> void:
	_announce(text)
	message.visible_ratio = 0.0
	create_tween().tween_property(message, "visible_ratio", 1.0, 0.2)
	await _wait_for_reader(message_time)
	announce_box.visible = false


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
	# (Esc nei sottomenu lo gestisce battle_commands.gd.)
	if _waiting and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		_advance.emit()


## In guardia (con il "respiro"), oppure in ginocchio se la salute è quasi finita.
func _idle() -> void:
	hero.play("weak" if Stats.hp * 4 <= Stats.max_hp else "fight_idle")


func _update_hero_info() -> void:
	hero_level.text = "Lv %d" % Stats.level
	hero_hp.text = "%d/%d" % [Stats.hp, Stats.max_hp]
	hero_sp.text = "%d/%d" % [Stats.sp, Stats.max_sp]
	var color := HP_OK
	if Stats.hp == 0:
		color = HP_ZERO
	elif Stats.hp * 4 <= Stats.max_hp:
		color = HP_LOW
	hero_hp.add_theme_color_override("font_color", color)
	hero_bar.max_value = Stats.max_hp
	sp_bar.max_value = Stats.max_sp
	if is_active:
		create_tween().tween_property(hero_bar, "value", Stats.hp, 0.3)
		create_tween().tween_property(sp_bar, "value", Stats.sp, 0.3)
	else:
		hero_bar.value = Stats.hp
		sp_bar.value = Stats.sp


# ---------- Effetti ----------

## Il colore "a riposo" del nemico: più scuro quando è rotto.
func _enemy_color() -> Color:
	return Color(0.6, 0.6, 0.75) if enemy_broken else Color.WHITE


func _dash_to_enemy(time: float) -> void:
	vfx.afterimages(time)
	create_tween().tween_property(hero, "position:x", _enemy_home.x + 95.0, time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


## Dove arriva il colpo: sul lato destro del nemico, a mezza altezza.
func _impact_point() -> Vector2:
	return enemy_sprite.position + Vector2(24, -40)


## Aspetta che l'animazione di Subaru arrivi al frame "index" (quello del colpo).
func _until_frame(index: int) -> void:
	while hero.is_playing() and hero.frame < index:
		await hero.frame_changed


## "Hit stop": l'animazione si ferma un istante quando il colpo va a segno. Dà peso.
func _hit_stop(seconds := 0.07) -> void:
	hero.speed_scale = 0.0
	await _pause(seconds)
	hero.speed_scale = 1.0


## Il colpo: un suono, un lampo rosso, una scossa e il numero del danno che rimbalza.
func _hit(target: Node2D, amount: int, height: float, sound: String, color: Color, font_size: int) -> void:
	Sfx.play(sound)
	vfx.flash_white(target, 0.14)
	var x := target.position.x
	var t := create_tween()
	t.tween_property(target, "modulate", Color(1.0, 0.35, 0.35), 0.05)
	t.parallel().tween_property(target, "position:x", x + 6.0, 0.05)
	t.tween_property(target, "position:x", x - 5.0, 0.05)
	t.tween_property(target, "position:x", x, 0.05)
	var rest := _enemy_color() if target == enemy_sprite else Color.WHITE
	t.parallel().tween_property(target, "modulate", rest, 0.15)
	if target == enemy_sprite:
		# Una smorfia di dolore, poi torna a respirare.
		_enemy_pose(EnemyData.Pose.HURT)
		t.tween_interval(0.3)
		t.tween_callback(_enemy_rest)
	vfx.pop_number(Vector2(x, target.position.y), str(amount), color, height, font_size)


## Le ombre seguono i due quando scattano in avanti.
func _process(_delta: float) -> void:
	if is_active:
		hero_shadow.position.x = hero.position.x
		enemy_shadow.position.x = enemy_sprite.position.x


func _transition_material() -> ShaderMaterial:
	return transition.material as ShaderMaterial


func _set_transition(value: float) -> void:
	_transition_material().set_shader_parameter("progress", value)


func _set_blur(value: float) -> void:
	(backdrop.material as ShaderMaterial).set_shader_parameter("amount", value)
