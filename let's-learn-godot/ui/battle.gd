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
## Le icone dentro battle_icons.png (celle da 16x16), nell'ordine.
const ICON_SHIELD := 0
const ICON_BROKEN := 5
const ICON_UNKNOWN := 4
const TYPE_ICONS := {"pugno": 1, "calcio": 2, "ombra": 3}

## Su una debolezza il danno cresce del 50%; a nemico rotto raddoppia.
const WEAK_BONUS := 1.5
const BREAK_BONUS := 2.0
## I punti tecnica che tornano difendendosi.
const DEFEND_SP := 2

## Colori del testo della salute: normale, poca, finita.
const HP_OK := Color(0.96, 0.95, 1.0)
const HP_LOW := Color(1.0, 0.85, 0.3)
const HP_ZERO := Color(1.0, 0.35, 0.3)

## Gli effetti disegnati a mano (sprite sheet a celle quadrate, in fila) e gli shader.
const IMPACT_SHEET := preload("res://assets/effects/vfx_impact.png")
const SLASH_SHEET := preload("res://assets/effects/vfx_slash.png")
const HIT_FLASH := preload("res://effects/hit_flash.gdshader")
const SHOCKWAVE := preload("res://effects/shockwave.gdshader")

## Quanto resta un messaggio se non si preme niente, in secondi.
@export var message_time := 1.2
## Quanto dura la transizione d'ingresso (la mappa che gira e le bande nere).
@export var transition_time := 0.75
## La probabilità di riuscire a scappare (0.5 = una volta su due).
@export var flee_chance := 0.5
## Il ritratto di Subaru nella barra dei turni.
@export var hero_portrait: Texture2D
## Le icone di scudo e debolezze.
@export var icons: Texture2D
## Il fumo di Shamac.
@export var smoke: Texture2D

@onready var backdrop: ColorRect = $Backdrop
@onready var flash: ColorRect = $Flash
@onready var transition: ColorRect = $Transition
@onready var screen: Control = $Screen
@onready var stage: Control = %Stage
@onready var hero: AnimatedSprite2D = %Hero
@onready var enemy_sprite: Sprite2D = %Enemy
@onready var hero_shadow: Sprite2D = %HeroShadow
@onready var enemy_shadow: Sprite2D = %EnemyShadow
@onready var enemy_info: Control = %EnemyInfo
@onready var enemy_name: Label = %EnemyName
@onready var shield_icon: TextureRect = %Shield
@onready var shield_number: Label = %ShieldNumber
@onready var weakness_row: HBoxContainer = %Weaknesses
@onready var break_label: Label = %BreakLabel
@onready var turn_bar: Control = %TurnBar
@onready var turn_icons: HBoxContainer = %TurnIcons
@onready var party: Control = %Party
@onready var hero_level: Label = %HeroLevel
@onready var hero_hp: Label = %HeroHp
@onready var hero_bar: ProgressBar = %HeroBar
@onready var hero_sp: Label = %HeroSp
@onready var sp_bar: ProgressBar = %SpBar
@onready var hero_status: Label = %HeroStatus
@onready var announce_box: Control = %Announce
@onready var message: Label = %Message
@onready var help: Control = %Help
@onready var help_text: Label = %HelpText
@onready var commands: Control = %Commands
@onready var menu: Control = %Menu
@onready var attack_button: MenuItem = %Attack
@onready var skills_button: MenuItem = %Skills
@onready var items_button: MenuItem = %Items
@onready var defend_button: MenuItem = %Defend
@onready var flee_button: MenuItem = %Flee
@onready var skill_window: Control = %SkillWindow
@onready var kick_button: MenuItem = %Kick
@onready var shamac_button: MenuItem = %Shamac
@onready var power_button: MenuItem = %PowerPunch
@onready var item_window: Control = %ItemWindow
@onready var potion_button: MenuItem = %Potion
@onready var results: Control = %Results
@onready var results_text: Label = %ResultsText

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
var _stage_home := Vector2.ZERO
## La descrizione di ogni voce di menu, mostrata in basso quando è selezionata.
var _help_for := {}
## Le animazioni degli effetti, costruite una volta sola dagli sprite sheet.
var _vfx_frames := {}
## Il rettangolo a tutto schermo che disegna l'onda d'urto.
var _shockwave: ColorRect


func _ready() -> void:
	visible = false
	rng.randomize()
	_hero_home = hero.position
	_enemy_home = enemy_sprite.position
	_enemy_scale = enemy_sprite.scale
	attack_button.pressed.connect(_use_skill.bind(ATTACK))
	skills_button.pressed.connect(_open_skills)
	items_button.pressed.connect(_open_items)
	defend_button.pressed.connect(_on_defend)
	flee_button.pressed.connect(_on_flee)
	kick_button.pressed.connect(_use_skill.bind("calcio"))
	shamac_button.pressed.connect(_use_skill.bind("shamac"))
	power_button.pressed.connect(_use_skill.bind("carica"))
	potion_button.pressed.connect(_on_potion)
	_help_for = {
		attack_button: SKILLS[ATTACK].info,
		skills_button: "Le tecniche di Subaru. Costano punti tecnica (PT).",
		items_button: "Usa un oggetto dello zaino.",
		defend_button: "Para: il prossimo colpo fa metà danno. Recuperi %d PT." % DEFEND_SP,
		flee_button: "Prova a scappare. Non sempre ci si riesce.",
		kick_button: SKILLS.calcio.info,
		shamac_button: SKILLS.shamac.info,
		power_button: SKILLS.carica.info,
		potion_button: "",
	}
	for button: MenuItem in _help_for:
		button.focus_entered.connect(_show_help.bind(button))
	# Il costo in PT, allineato a destra dentro la voce.
	for pair in [[kick_button, "calcio"], [shamac_button, "shamac"], [power_button, "carica"]]:
		var cost := Label.new()
		cost.text = "%d PT" % SKILLS[pair[1]].cost
		cost.theme_type_variation = &"HintLabel"
		cost.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		cost.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		cost.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		cost.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pair[0].add_child(cost)
	Stats.changed.connect(_update_hero_info)
	_setup_vfx()


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
	enemy_sprite.modulate = Color.WHITE
	enemy_sprite.scale = _enemy_scale
	enemy_sprite.rotation = 0.0
	enemy_name.text = data.name
	enemy_info.modulate.a = 1.0
	_update_shield()
	_update_weaknesses()
	hero.modulate = Color.WHITE
	hero.flip_h = true   # le azioni guardano a destra: qui Subaru guarda il nemico, a sinistra
	_idle()
	_update_hero_info()
	hero_bar.value = Stats.hp
	sp_bar.value = Stats.sp
	announce_box.visible = false
	help.visible = false
	results.visible = false
	break_label.visible = false
	_close_submenus()
	_show_menu(false)
	_refresh_turns()

	visible = true
	_stage_home = stage.position
	_intro()
	return await finished


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
	_shockwave_at(Vector2(0, -30), 0.9, 0.6)
	for sprite: CanvasItem in [hero, enemy_sprite]:
		_set_flash(1.0, sprite)
		create_tween().tween_method(_set_flash.bind(sprite), 1.0, 0.0, 0.35).set_delay(0.15)
	await enter.finished
	_landing_dust(hero.position)
	_landing_dust(enemy_sprite.position)
	_shake(2.0, 0.15)
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
	_show_menu(true)


## Subaru ha scelto: i comandi spariscono.
func _act() -> void:
	_show_menu(false)
	_close_submenus()


## Attacca e le abilità: spende i PT, fa la mossa, poi tocca al nemico.
func _use_skill(id: String) -> void:
	var skill: Dictionary = SKILLS[id]
	if not Stats.spend_sp(skill.cost):
		Sfx.play(Sfx.BACK)
		help_text.text = "Non hai abbastanza PT."
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
	_impact(_impact_point(), 2.0)
	_sparks(_impact_point(), Color(1, 0.95, 0.8), 10, 140.0)
	await hero.animation_finished


## Calcio: come il pugno ma più pesante, con una scossa.
func _do_kick(skill: Dictionary) -> void:
	_dash_to_enemy(0.15)
	Sfx.play(Sfx.SWING)
	hero.play("kick")
	await _until_frame(1)
	_hit_stop()
	_strike(skill, Sfx.KICK)
	_slash(_impact_point() + Vector2(-8, 4))
	_impact(_impact_point(), 2.5)
	_shake(5.0, 0.25)
	_sparks(_impact_point(), Color(1, 0.75, 0.4), 16, 200.0)
	await hero.animation_finished


## Shamac: Subaru si accuccia, lo schermo si scurisce e una nebbia nera avvolge il nemico.
func _do_shamac(skill: Dictionary) -> void:
	hero.play("charge")
	Sfx.play(Sfx.SHAMAC)
	flash.color = Color(0.12, 0.0, 0.2, 0.0)
	var dark := create_tween()
	dark.tween_property(flash, "color:a", 0.45, 0.25)
	_mist(enemy_sprite.position + Vector2(0, -36))
	create_tween().tween_property(enemy_sprite, "modulate", Color(0.45, 0.3, 0.6), 0.4)
	await _pause(0.7)
	_strike(skill, Sfx.HIT)
	_shake(3.0, 0.3)
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
	var aura := _aura()
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
	_shake(9.0, 0.4)
	_impact(_impact_point(), 4.0)
	_shockwave_at(_impact_point(), 0.45)
	_sparks(_impact_point(), Color(1, 0.8, 0.35), 28, 260.0)
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
			_bump(shield_icon)
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
	_shake(7.0, 0.35)
	_shockwave_at(enemy_sprite.position + Vector2(0, -40), 0.6)
	var shards := _sparks(enemy_sprite.position + Vector2(0, -40), Color(0.7, 0.85, 1.0), 30, 280.0)
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
	var wobble := create_tween()
	wobble.tween_property(enemy_sprite, "rotation", -0.25, 0.15)
	wobble.tween_property(enemy_sprite, "modulate", _enemy_color(), 0.2)


## Dopo il turno saltato il nemico si riprende: scudo di nuovo pieno.
func _recover() -> void:
	enemy_broken = false
	enemy_shield = enemy.shield
	_update_shield()
	_bump(shield_icon)
	Sfx.play(Sfx.GUARD)
	var t := create_tween().set_parallel()
	t.tween_property(enemy_sprite, "rotation", 0.0, 0.2)
	t.tween_property(enemy_sprite, "modulate", Color.WHITE, 0.2)


## Il sottomenu "Abilità". Le mosse che costano troppo sono più scure.
func _open_skills() -> void:
	for pair in [[kick_button, "calcio"], [shamac_button, "shamac"], [power_button, "carica"]]:
		var button: MenuItem = pair[0]
		var cost: int = SKILLS[pair[1]].cost
		button.modulate = Color.WHITE if Stats.sp >= cost else Color(0.55, 0.55, 0.65)
	skill_window.visible = true
	kick_button.focus_silently()
	_show_help(kick_button)


## Il sottomenu "Oggetti". Esc torna ai comandi (vedi _unhandled_input).
func _open_items() -> void:
	var count: int = Inventory.items.get(Inventory.POTION, 0)
	potion_button.text = "Pozione   x%d" % count
	_help_for[potion_button] = "Rimette %d PS." % Inventory.item(Inventory.POTION).heal if count > 0 else "Non ne hai."
	item_window.visible = true
	potion_button.focus_silently()
	_show_help(potion_button)


## Chiude il sottomenu aperto e torna alla sua voce dei comandi.
func _close_items() -> void:
	var back_to := items_button if item_window.visible else skills_button
	_close_submenus()
	Sfx.play(Sfx.BACK)
	back_to.focus_silently()
	_show_help(back_to)


func _close_submenus() -> void:
	item_window.visible = false
	skill_window.visible = false


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
	var leaves := _sparks(hero.position + Vector2(0, -30), Color(0.55, 1.0, 0.6), 14, 60.0)
	leaves.gravity = Vector2(0, -80)
	_pop_number(hero.position, str(healed), Color(0.45, 1.0, 0.55), -128.0)
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
	_glow(hero, Color(0.6, 0.85, 1.6))
	var restored := Stats.restore_sp(DEFEND_SP)
	if restored > 0:
		_pop_number(hero.position, "+%d PT" % restored, Color(0.5, 0.78, 1.0), -128.0, 24)
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
	# Scatta verso Subaru, colpisce, torna al suo posto.
	var lunge := create_tween()
	lunge.tween_property(enemy_sprite, "position:x", _enemy_home.x + 70.0, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await lunge.finished
	Stats.take_damage(dealt)
	if defending:
		Sfx.play(Sfx.GUARD)
		_sparks(hero.position + Vector2(-30, -36), Color(0.6, 0.85, 1.0), 10, 120.0)
	else:
		hero.play("stagger")
		_shake(3.0, 0.2)
		_impact(hero.position + Vector2(-24, -40), 2.0)
	_hit(hero, dealt, -128.0, Sfx.HIT, Color.WHITE, 32)
	create_tween().tween_property(enemy_sprite, "position:x", _enemy_home.x, 0.25)
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
	_impact(enemy_sprite.position + Vector2(0, -40), 4.0)
	_set_flash(1.0, enemy_sprite)
	create_tween().tween_method(_set_flash.bind(enemy_sprite), 1.0, 0.0, 0.5)
	var t := create_tween()
	t.tween_property(enemy_sprite, "modulate", Color(3, 3, 3), 0.06)
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
		_level_up_burst()
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
	await t.finished
	visible = false
	is_active = false
	enemy_shadow.modulate.a = 1.0
	stage.position = _stage_home
	stage.scale = Vector2.ONE
	flash.color = Color(1, 1, 1, 0)
	_shockwave.visible = false
	_set_flash(0.0, hero)
	_set_flash(0.0, enemy_sprite)
	hero_status.visible = false
	Game.in_cutscene = false
	finished.emit(result)
	if result == LOSE:
		# Perdere è morire: e Subaru, quando muore, torna indietro.
		ReturnByDeath.die()


# ---------- La barra dei turni ----------

## Ridisegna la barra in alto: chi agisce ora (più grande) e i prossimi.
## Un turno che il nemico rotto salterà è grigio.
func _refresh_turns() -> void:
	for child in turn_icons.get_children():
		child.queue_free()
	var who := turn
	var stun := _enemy_stun
	for i in 6:
		var skipped := who == ENEMY and stun > 0
		if skipped:
			stun -= 1
		# Un trattino separa un giro (Subaru + nemico) dal successivo.
		if i > 0 and who == HERO:
			var line := ColorRect.new()
			line.custom_minimum_size = Vector2(1, 14)
			line.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			line.color = Color(0.92, 0.84, 0.62, 0.5)
			turn_icons.add_child(line)
		turn_icons.add_child(_turn_icon(who, i == 0, skipped))
		who = ENEMY if who == HERO else HERO


func _turn_icon(who: String, current: bool, skipped: bool) -> Control:
	var frame := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.1, 0.2, 0.9) if who == HERO else Color(0.2, 0.06, 0.08, 0.9)
	style.set_border_width_all(1)
	style.border_color = Color(1, 0.85, 0.45) if current else Color(0.6, 0.62, 0.72, 0.8)
	style.anti_aliasing = false
	frame.add_theme_stylebox_override("panel", style)
	frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var face := TextureRect.new()
	face.texture = hero_portrait if who == HERO else enemy.texture
	face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	face.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	face.custom_minimum_size = Vector2(20, 20) if current else Vector2(14, 14)
	face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(face)
	if skipped:
		frame.modulate = Color(0.45, 0.45, 0.55, 0.8)
	return frame


# ---------- Scudo e debolezze ----------

func _icon(index: int) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = icons
	atlas.region = Rect2(index * 16, 0, 16, 16)
	return atlas


func _update_shield() -> void:
	shield_icon.texture = _icon(ICON_BROKEN if enemy_broken else ICON_SHIELD)
	shield_number.text = str(enemy_shield)
	shield_number.visible = not enemy_broken


## Una casella per ogni debolezza: l'icona se scoperta, "?" se no.
func _update_weaknesses() -> void:
	for child in weakness_row.get_children():
		child.queue_free()
	for kind in enemy.weaknesses:
		var slot := TextureRect.new()
		slot.custom_minimum_size = Vector2(16, 16)
		slot.texture = _icon(TYPE_ICONS[kind] if revealed.has(kind) else ICON_UNKNOWN)
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.name = kind
		weakness_row.add_child(slot)


## Una debolezza appena scoperta: il "?" diventa l'icona, con un lampo.
func _reveal(kind: String) -> void:
	if revealed.has(kind):
		return
	revealed.append(kind)
	var slot := weakness_row.get_node_or_null(NodePath(kind)) as TextureRect
	if slot:
		slot.texture = _icon(TYPE_ICONS[kind])
		_bump(slot)


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
	if (item_window.visible or skill_window.visible) and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close_items()
	elif _waiting and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		_advance.emit()


func _show_menu(shown: bool) -> void:
	commands.visible = shown
	menu.visible = shown
	help.visible = shown
	if shown:
		attack_button.focus_silently()
		_show_help(attack_button)


func _show_help(button: MenuItem) -> void:
	help_text.text = _help_for.get(button, "")


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
	_afterimages(time)
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


## Scuote la scena: tanti piccoli spostamenti casuali che si smorzano.
func _shake(strength: float, time: float) -> void:
	var t := create_tween()
	var steps := int(time / 0.03)
	for i in steps:
		var fade := 1.0 - float(i) / steps
		var offset := Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1)) * strength * fade
		t.tween_property(stage, "position", _stage_home + offset, 0.03)
	t.tween_property(stage, "position", _stage_home, 0.03)


## Una manciata di scintille che esplodono da "pos" e ricadono. Si cancellano da sole.
func _sparks(pos: Vector2, color: Color, amount: int, speed: float) -> CPUParticles2D:
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
func _aura() -> CPUParticles2D:
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
func _mist(pos: Vector2) -> void:
	var p := CPUParticles2D.new()
	p.one_shot = true
	p.explosiveness = 0.6
	p.amount = 18
	p.lifetime = 1.1
	p.texture = smoke
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


func _fade_ramp() -> Gradient:
	var ramp := Gradient.new()
	ramp.set_color(0, Color.WHITE)
	ramp.set_color(1, Color(1, 1, 1, 0))
	return ramp


## Il colpo: un suono, un lampo rosso, una scossa e il numero del danno che rimbalza.
func _hit(target: Node2D, amount: int, height: float, sound: String, color: Color, font_size: int) -> void:
	Sfx.play(sound)
	create_tween().tween_method(_set_flash.bind(target), 1.0, 0.0, 0.14)
	var x := target.position.x
	var t := create_tween()
	t.tween_property(target, "modulate", Color(1.0, 0.35, 0.35), 0.05)
	t.parallel().tween_property(target, "position:x", x + 6.0, 0.05)
	t.tween_property(target, "position:x", x - 5.0, 0.05)
	t.tween_property(target, "position:x", x, 0.05)
	var rest := _enemy_color() if target == enemy_sprite else Color.WHITE
	t.parallel().tween_property(target, "modulate", rest, 0.15)
	_pop_number(Vector2(x, target.position.y), str(amount), color, height, font_size)


## Un piccolo "salto" di grandezza: per l'icona dello scudo o una debolezza scoperta.
func _bump(control: Control) -> void:
	control.pivot_offset = control.size / 2.0
	control.scale = Vector2(1.8, 1.8)
	create_tween().tween_property(control, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Un bagliore colorato che va e viene (la cura, la difesa).
func _glow(target: CanvasItem, color: Color) -> void:
	var t := create_tween()
	t.tween_property(target, "modulate", color, 0.15)
	t.tween_property(target, "modulate", Color.WHITE, 0.35)


## Il numero salta su, ricade con un piccolo rimbalzo, resta un attimo e svanisce.
func _pop_number(at: Vector2, text: String, color: Color, height: float, font_size := 32) -> void:
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


# ---------- VFX: sprite animati, lampi, onde d'urto, scie ----------

## Prepara gli effetti: il lampo bianco sui due personaggi (ognuno con il SUO
## materiale, se no lampeggerebbero insieme) e il rettangolo dell'onda d'urto.
func _setup_vfx() -> void:
	for sprite: CanvasItem in [hero, enemy_sprite]:
		var mat := ShaderMaterial.new()
		mat.shader = HIT_FLASH
		sprite.material = mat
	_shockwave = ColorRect.new()
	_shockwave.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_shockwave.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var wave := ShaderMaterial.new()
	wave.shader = SHOCKWAVE
	_shockwave.material = wave
	_shockwave.visible = false
	# Lo "screen texture" viene copiato una volta sola, al primo shader che lo usa:
	# qui è lo sfondo sfocato, PRIMA che la battaglia sia disegnata. Senza una nuova
	# copia l'onda deformerebbe la mappa vecchia e coprirebbe tutto il resto.
	var copy := BackBufferCopy.new()
	copy.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
	add_child(copy)
	move_child(copy, flash.get_index())
	add_child(_shockwave)
	move_child(_shockwave, flash.get_index())   # sopra la battaglia, sotto il lampo
	_vfx_frames = {
		"impact": _frames_from_sheet(IMPACT_SHEET, 24.0),
		"slash": _frames_from_sheet(SLASH_SHEET, 26.0),
	}


## Da uno sprite sheet con celle quadrate in fila a un'animazione che non si ripete.
func _frames_from_sheet(sheet: Texture2D, fps: float) -> SpriteFrames:
	var cell := sheet.get_height()
	var frames := SpriteFrames.new()
	frames.set_animation_loop(&"default", false)
	frames.set_animation_speed(&"default", fps)
	for i in sheet.get_width() / cell:
		var atlas := AtlasTexture.new()
		atlas.atlas = sheet
		atlas.region = Rect2(i * cell, 0, cell, cell)
		frames.add_frame(&"default", atlas)
	return frames


## Fa partire un effetto disegnato in "pos" e lo cancella quando finisce.
## Il blend "additivo" somma la luce: su uno sfondo scuro sembra brillare.
func _play_vfx(kind: String, pos: Vector2, size: float, angle := 0.0) -> AnimatedSprite2D:
	var fx := AnimatedSprite2D.new()
	fx.sprite_frames = _vfx_frames[kind]
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


## La stella del colpo, girata a caso perché due colpi non sembrino identici.
func _impact(pos: Vector2, size: float) -> void:
	_play_vfx("impact", pos, size, rng.randi_range(0, 3) * PI / 8.0)


## Il fendente del calcio: un arco di luce che passa sul nemico.
func _slash(pos: Vector2) -> void:
	_play_vfx("slash", pos, 2.5, PI)


## Quanto è "bianco" uno dei due personaggi (0 = normale, 1 = sagoma bianca).
func _set_flash(value: float, target: CanvasItem) -> void:
	var mat := target.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("amount", value)


## Un'onda d'urto che parte da "pos" (coordinate dello Stage) e deforma lo schermo.
func _shockwave_at(pos: Vector2, size: float, time := 0.45) -> void:
	var mat := _shockwave.material as ShaderMaterial
	# Lo shader lavora in coordinate dello schermo da 0 a 1: convertiamo.
	var on_screen := stage.get_global_transform_with_canvas() * pos
	mat.set_shader_parameter("center", on_screen / get_viewport().get_visible_rect().size)
	mat.set_shader_parameter("max_radius", size)
	_shockwave.visible = true
	var t := create_tween()
	t.tween_method(_set_wave, 0.0, 1.0, time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	t.tween_callback(_shockwave.hide)


func _set_wave(value: float) -> void:
	(_shockwave.material as ShaderMaterial).set_shader_parameter("progress", value)


## La scia: copie di Subaru, azzurre e trasparenti, lasciate indietro mentre scatta.
func _afterimages(time: float) -> void:
	var copies := 4
	for i in copies:
		if not is_active:
			return
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
		await _pause(time / copies)


## Due sbuffi di polvere ai piedi, uno per lato, quando qualcuno atterra.
func _landing_dust(feet: Vector2) -> void:
	for side in [-1.0, 1.0]:
		var p := _sparks(feet + Vector2(side * 10.0, -2.0), Color(0.85, 0.8, 0.9, 0.7), 8, 70.0)
		p.direction = Vector2(side, -0.3)
		p.spread = 25.0
		p.gravity = Vector2(0, -20)
		p.scale_amount_min = 3.0
		p.scale_amount_max = 5.0


## Il passaggio di livello: una colonna di luce che sale da Subaru e una stella.
func _level_up_burst() -> void:
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
	_impact(base + Vector2(0, -36), 3.0)
	_glow(hero, Color(1.5, 1.4, 0.9))
