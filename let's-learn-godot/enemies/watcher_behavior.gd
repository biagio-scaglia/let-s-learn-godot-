class_name WatcherBehavior
extends BattleBehavior
## Colui che guarda, il boss dell'atto 3.
##
## - L'occhio aperto vede arrivare i colpi: ne schiva una parte (danno x0,7).
## - Ogni tre turni carica lo SGUARDO: lo schermo si fa rosso, si sente il battito, e al
##   turno dopo parte un raggio che toglie gran parte della vita (metà, se ci si difende).
## - Il trucco: lo Shamac (tipo ombra) mentre carica lo ACCECA. Il raggio non parte, lo
##   scudo va in frantumi e salta il turno. La prima volta di solito non lo si sa... e si
##   muore. Ma Subaru ricorda (Game.remember): al tentativo dopo lo sa già.
## - Al 60% di vita le mani si moltiplicano (colpisce più forte); sotto il 25% Subaru ed
##   Emilia si guardano: è pronta l'ultimate, "Alba di cristallo".

## Il ricordo che sopravvive alla morte: lo Shamac lo acceca mentre carica lo Sguardo.
const MEMORY_GAZE := "sguardo_del_guardiano"
## Quanta vita (del massimo di Subaru) toglie lo Sguardo.
const GAZE_RATIO := 0.7
## Quanto danno arriva quando l'occhio è aperto e vede il colpo.
const SEEN_HIT := 0.7

var charging := false
var phase := 1
var _turns := 0
## Una frase da dire all'inizio del prossimo turno (i cambi di fase arrivano durante un colpo).
var _pending := ""
## Il rosso che pulsa sullo schermo mentre carica.
var _red: ColorRect
var _pulse: Tween


func after_intro() -> void:
	Sfx.play(Sfx.BOSS_ROAR)
	battle.vfx.shake(8.0, 0.9)
	await battle._pause(0.6)
	if Game.remembers(MEMORY_GAZE):
		battle._reveal("ombra")
		await battle._say("Subaru ricorda: quando carica lo Sguardo, lo Shamac lo acceca!")


func take_turn() -> bool:
	if _pending != "":
		Sfx.play(Sfx.BOSS_ROAR)
		battle.vfx.shake(9.0, 0.8)
		await battle._say(_pending)
		_pending = ""
	_turns += 1
	if charging:
		await _fire_gaze()
		return true
	if _turns == 2 or (_turns > 2 and (_turns - 2) % 3 == 0):
		await _start_charge()
		return true
	return false


func held_pose() -> int:
	return EnemyData.Pose.WINDUP if charging else -1


func modify_damage(_skill: Dictionary, amount: int) -> int:
	if battle.enemy_broken:
		return amount   # accecato o rotto: non vede niente
	return maxi(1, roundi(amount * SEEN_HIT))


func on_hit(skill: Dictionary) -> void:
	if charging and skill.type == "ombra":
		_blind()
	_check_phase()


func can_flee() -> bool:
	return false


func no_flee_text() -> String:
	return "Non si scappa da Colui che guarda."


func ultimate_ready() -> bool:
	return phase >= 3


# ---------- Lo Sguardo ----------

func _start_charge() -> void:
	charging = true
	battle._announce("Colui che guarda")
	battle._enemy_pose(EnemyData.Pose.WINDUP)
	Sfx.play(Sfx.GAZE_CHARGE)
	battle.vfx.shake(3.0, 0.8)
	battle.vfx.sparks(battle._enemy_center(), Color(1.0, 0.3, 0.4), 24, 160.0)
	_start_pulse()
	await battle._say("Colui che guarda spalanca l'occhio. Sta caricando lo Sguardo!")
	if Game.remembers(MEMORY_GAZE):
		await battle._say("Subaru: \"Lo so cosa succede adesso. Lo Shamac, subito!\"")


func _fire_gaze() -> void:
	charging = false
	_stop_pulse()
	battle._announce("Sguardo")
	battle._enemy_pose(EnemyData.Pose.ATTACK)
	Sfx.play(Sfx.GAZE_BEAM)
	var from: Vector2 = battle._enemy_center()
	var to: Vector2 = battle.hero.position + Vector2(0, -60)
	battle.vfx.beam(from, to, Color(1.0, 0.25, 0.35), 48.0, 0.9)
	battle.flash.color = Color(1.0, 0.2, 0.3, 0.55)
	battle.create_tween().tween_property(battle.flash, "color:a", 0.0, 0.7)
	battle.vfx.shake(12.0, 0.7)
	var dealt := ceili(Stats.max_hp * GAZE_RATIO)
	if battle.defending:
		dealt = ceili(dealt / 2.0)
	Stats.take_damage(dealt)
	battle.hero.play("stagger")
	battle._hit(battle.hero, dealt, -140.0, Sfx.HIT, Color(1.0, 0.45, 0.5), 44)
	await battle._pause(1.0)
	battle._enemy_rest()


## Lo Shamac mentre carica: l'occhio è accecato, lo Sguardo non parte, scudo in frantumi.
func _blind() -> void:
	charging = false
	_stop_pulse()
	Game.remember(MEMORY_GAZE)   # anche scoprendolo da solo, Subaru non lo dimentica più
	battle._reveal("ombra")
	battle.vfx.pop_number(battle._enemy_center(), "ACCECATO!", Color(0.85, 0.6, 1.0), -120.0, 40)
	if not battle.enemy_broken:
		battle.enemy_shield = 0
		battle._break()


func _check_phase() -> void:
	var ratio := float(battle.enemy_hp) / float(battle.enemy.max_hp)
	if battle.enemy_hp == 0:
		return
	if phase == 1 and ratio <= 0.6:
		phase = 2
		battle.enemy_attack_bonus = 3
		_pending = "Le mani d'ombra si moltiplicano. Colui che guarda è furioso!"
	if phase == 2 and ratio <= 0.25:
		phase = 3
		_pending = "L'occhio trema. Subaru ed Emilia si guardano: è il momento!"


## Un velo rosso che pulsa su tutta la scena, come un battito.
func _start_pulse() -> void:
	_red = ColorRect.new()
	_red.color = Color(0.8, 0.0, 0.1, 0.0)
	_red.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_red.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	battle.screen.add_child(_red)
	_pulse = battle.create_tween().set_loops()
	_pulse.tween_property(_red, "color:a", 0.22, 0.45).set_trans(Tween.TRANS_SINE)
	_pulse.tween_property(_red, "color:a", 0.05, 0.45).set_trans(Tween.TRANS_SINE)


func _stop_pulse() -> void:
	if _pulse:
		_pulse.kill()
		_pulse = null
	if is_instance_valid(_red):
		_red.queue_free()
