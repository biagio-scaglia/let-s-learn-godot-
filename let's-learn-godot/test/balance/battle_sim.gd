extends RefCounted
## Un combattimento simulato, senza animazioni: le stesse regole di ui/battle.gd
## (danno, debolezze, scudo e rottura, PT, Emilia, il boss) con i numeri veri del gioco.
## Serve ai test di bilanciamento: "a quel livello, quel nemico si batte? In quanti turni?"
##
## I dadi si scelgono: hero_roll è il +-1 sui colpi di Subaru ed Emilia, enemy_roll quello
## dei colpi nemici. Il caso peggiore è hero_roll = -1, enemy_roll = +1.

const BATTLE := preload("res://ui/battle.gd")
const STATS := preload("res://core/stats.gd")
const WATCHER := preload("res://enemies/watcher_behavior.gd")
const POTION_HEAL := 12

## Subaru: livello e statistiche come le darebbe Stats dopo "xp" punti esperienza.
var level := 1
var max_hp := 0
var hp := 0
var max_sp := 0
var sp := 0
var attack := 0
var defense := 0
var potions := 0

## Le regole della partita in quel momento.
var with_emilia := false
var combo_unlocked := false
## Contro il boss: Subaru sa già del trucco dello Shamac (dopo la prima morte)?
var knows_gaze_trick := true
## Senza il trucco: quando lo schermo diventa rosso si difende (true) o continua ad attaccare?
var defends_on_charge := true
var hero_roll := -1
var enemy_roll := 1

## Il risultato.
var won := false
var rounds := 0
var potions_used := 0
var log: PackedStringArray = []


## Statistiche di Subaru a un certo livello (come Stats.gain_xp).
func set_level(new_level: int) -> void:
	level = new_level
	max_hp = STATS.BASE.max_hp + STATS.HP_PER_LEVEL * (level - 1)
	max_sp = STATS.BASE.max_sp + STATS.SP_PER_LEVEL * (level - 1)
	attack = STATS.BASE.attack + STATS.ATTACK_PER_LEVEL * (level - 1)
	defense = STATS.BASE.defense + STATS.DEFENSE_PER_LEVEL * (level - 1)
	hp = max_hp
	sp = max_sp


## Il livello che si ha partendo dal livello 1 con "total_xp" punti (stessa regola di Stats).
static func level_for_xp(total_xp: int) -> int:
	var lvl := 1
	var xp := total_xp
	while xp >= lvl * 10:
		xp -= lvl * 10
		lvl += 1
	return lvl


## Gioca il combattimento. Restituisce true se Subaru vince.
func fight(enemy: EnemyData) -> bool:
	var is_boss := enemy.behavior != null
	var enemy_hp := enemy.max_hp
	var shield := enemy.shield
	var broken := false
	var stun := 0
	var bonus := 0
	var ally_sp: int = BATTLE.ALLY_MAX_SP
	# Il boss (WatcherBehavior): turni, carica dello Sguardo, fasi.
	var boss_turns := 0
	var charging := false
	var phase := 1
	var ultimate_used := false
	rounds = 0
	potions_used = 0
	won = false

	while rounds < 60:
		rounds += 1
		var defending := false

		# ---- Subaru ----
		var worst_hit := _enemy_hit(enemy.attack + bonus, false)
		var gaze := ceili(max_hp * WATCHER.GAZE_RATIO)
		var danger := gaze if charging else worst_hit * (2 if with_emilia else 1)
		if is_boss and phase >= 3 and with_emilia and not ultimate_used:
			# Alba di cristallo: chiude il combattimento (battle.gd mette enemy_hp a 0).
			ultimate_used = true
			enemy_hp = 0
			log.append("%d: Alba di cristallo" % rounds)
		elif charging and knows_gaze_trick and sp >= BATTLE.SKILLS.shamac.cost:
			sp -= BATTLE.SKILLS.shamac.cost
			enemy_hp -= _hit_amount(BATTLE.SKILLS.shamac, enemy, broken, is_boss)
			# Accecato: lo Sguardo non parte, scudo in frantumi, salta il turno.
			charging = false
			broken = true
			shield = 0
			stun = 1
			log.append("%d: Shamac acceca" % rounds)
		elif charging and (knows_gaze_trick or defends_on_charge):
			defending = true   # non sa del trucco (o non ha PT): si difende
			sp = mini(max_sp, sp + BATTLE.DEFEND_SP)
		elif hp <= danger and potions > 0:
			potions -= 1
			potions_used += 1
			hp = mini(max_hp, hp + POTION_HEAL)
		else:
			var id := _best_skill(enemy, broken, ally_sp, is_boss)
			var skill: Dictionary = BATTLE.SKILLS[id]
			sp -= skill.cost
			ally_sp -= skill.get("ally_cost", 0)
			enemy_hp -= _hit_amount(skill, enemy, broken, is_boss)
			if enemy.weaknesses.has(skill.type) and not broken:
				shield -= 1
				if shield == 0:
					broken = true
					stun = 1
		if is_boss:
			phase = _boss_phase(phase, enemy_hp, enemy.max_hp)
			if phase >= 2:
				bonus = 3
		if enemy_hp <= 0:
			won = true
			return true

		# ---- Emilia ----
		if with_emilia:
			var ally_skill: Dictionary = BATTLE.SKILLS.gelo if ally_sp >= BATTLE.SKILLS.gelo.cost else BATTLE.SKILLS.dardo
			ally_sp -= ally_skill.cost
			enemy_hp -= _hit_amount(ally_skill, enemy, broken, is_boss)
			if enemy.weaknesses.has(ally_skill.type) and not broken:
				shield -= 1
				if shield == 0:
					broken = true
					stun = 1
			if is_boss:
				phase = _boss_phase(phase, enemy_hp, enemy.max_hp)
				if phase >= 2:
					bonus = 3
			if enemy_hp <= 0:
				won = true
				return true

		# ---- Il nemico ----
		if broken:
			if stun > 0:
				stun -= 1
				continue
			broken = false
			shield = enemy.shield
		if is_boss:
			boss_turns += 1
			if charging:
				charging = false
				var dealt := ceili(gaze / 2.0) if defending else gaze
				hp -= dealt
				log.append("%d: Sguardo -%d" % [rounds, dealt])
			elif boss_turns == 2 or (boss_turns > 2 and (boss_turns - 2) % 3 == 0):
				charging = true
				continue
			else:
				hp -= _enemy_hit(enemy.attack + bonus, defending)
		else:
			hp -= _enemy_hit(enemy.attack + bonus, defending)
		if hp <= 0:
			return false
	return false


func _enemy_hit(enemy_attack: int, defending: bool) -> int:
	var dealt := STATS.damage(enemy_attack, defense, enemy_roll)
	return maxi(1, ceili(dealt / 2.0)) if defending else dealt


func _hit_amount(skill: Dictionary, enemy: EnemyData, broken: bool, is_boss: bool) -> int:
	var amount := STATS.damage(attack, enemy.defense, hero_roll)
	var multiplier: float = skill.power
	if enemy.weaknesses.has(skill.type):
		multiplier *= BATTLE.WEAK_BONUS
	if broken:
		multiplier *= BATTLE.BREAK_BONUS
	amount = maxi(1, roundi(amount * multiplier))
	if is_boss and not broken:
		amount = maxi(1, roundi(amount * WATCHER.SEEN_HIT))
	return amount


## La mossa di Subaru che fa più danno con i PT che ha (come farebbe un giocatore attento).
func _best_skill(enemy: EnemyData, broken: bool, ally_sp: int, is_boss: bool) -> String:
	var best := "pugno"
	var best_damage := -1
	# Chi sa del trucco tiene da parte i PT per lo Shamac contro lo Sguardo.
	var reserve: int = BATTLE.SKILLS.shamac.cost if is_boss and knows_gaze_trick else 0
	for id in ["pugno", "calcio", "shamac", "carica", "cristallo"]:
		var skill: Dictionary = BATTLE.SKILLS[id]
		if skill.cost > 0 and skill.cost > sp - reserve:
			continue
		if skill.get("ally_cost", 0) > ally_sp:
			continue
		if id == "cristallo" and not (combo_unlocked and with_emilia):
			continue
		var dmg := _hit_amount(skill, enemy, broken, is_boss)
		if dmg > best_damage:
			best = id
			best_damage = dmg
	return best


func _boss_phase(phase: int, enemy_hp: int, max_enemy_hp: int) -> int:
	var ratio := float(enemy_hp) / float(max_enemy_hp)
	if phase == 1 and ratio <= 0.6:
		phase = 2
	if phase == 2 and ratio <= 0.25:
		phase = 3
	return phase
