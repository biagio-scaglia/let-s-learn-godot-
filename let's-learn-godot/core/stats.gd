extends Node
## Le statistiche di Subaru. È un autoload chiamato "Stats".
##
## Come lo zaino, non sa niente di barre o finestre: quando cambia manda un segnale,
## e chi è interessato (la scheda del personaggio, il combattimento) lo ascolta.

## Emesso a ogni cambiamento.
signal changed
## Emesso quando si sale di livello.
signal leveled_up(new_level: int)

## Come si parte a livello 1.
const BASE := {"level": 1, "xp": 0, "max_hp": 20, "hp": 20, "attack": 5, "defense": 2}
## Cosa si guadagna a ogni livello.
const HP_PER_LEVEL := 5
const ATTACK_PER_LEVEL := 1
const DEFENSE_PER_LEVEL := 1

var level := 1
## Punti esperienza verso il prossimo livello.
var xp := 0
## Punti salute (PS): a zero si muore.
var max_hp := 20
var hp := 20
## Quanto fa male un colpo di Subaru.
var attack := 5
## Quanto toglie ai colpi che riceve.
var defense := 2


## Il danno di un colpo: attacco meno difesa, più un po' di fortuna ("roll").
## Mai meno di 1: un colpo andato a segno fa sempre qualcosa.
static func damage(attacker_attack: int, target_defense: int, roll := 0) -> int:
	return maxi(1, attacker_attack - target_defense + roll)


## Quanta esperienza serve per passare dal livello attuale al prossimo.
func xp_to_next() -> int:
	return level * 10


## Toglie punti salute (mai sotto zero).
func take_damage(amount: int) -> void:
	hp = maxi(0, hp - amount)
	changed.emit()


## Cura. Restituisce quanti PS sono tornati davvero (non si supera il massimo).
func heal(amount: int) -> int:
	var healed := mini(amount, max_hp - hp)
	hp += healed
	changed.emit()
	return healed


func heal_fully() -> void:
	heal(max_hp)


## Dà esperienza. Restituisce di quanti livelli si è saliti (di solito 0 o 1).
func gain_xp(amount: int) -> int:
	xp += amount
	var gained := 0
	while xp >= xp_to_next():
		xp -= xp_to_next()
		level += 1
		gained += 1
		max_hp += HP_PER_LEVEL
		attack += ATTACK_PER_LEVEL
		defense += DEFENSE_PER_LEVEL
		hp = max_hp   # salire di livello rimette in forze
		leveled_up.emit(level)
	changed.emit()
	return gained


## Le statistiche come dizionario, per i salvataggi e il punto di ritorno.
func to_dict() -> Dictionary:
	return {"level": level, "xp": xp, "max_hp": max_hp, "hp": hp, "attack": attack, "defense": defense}


## Riparte dal livello 1, oppure da quello letto da un salvataggio.
## Quello che manca in "data" (un vecchio salvataggio) prende il valore di partenza.
func reset(data := {}) -> void:
	level = data.get("level", BASE.level)
	xp = data.get("xp", BASE.xp)
	max_hp = data.get("max_hp", BASE.max_hp)
	hp = data.get("hp", BASE.hp)
	attack = data.get("attack", BASE.attack)
	defense = data.get("defense", BASE.defense)
	changed.emit()
