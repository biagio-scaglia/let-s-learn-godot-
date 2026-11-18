class_name BattleBehavior
extends RefCounted
## Un comportamento speciale per un nemico in battaglia (un boss). Si aggancia alla sua
## risorsa EnemyData ("behavior"): all'inizio del combattimento Battle ne crea uno nuovo
## e lo chiama nei momenti giusti. Così le regole di un boss stanno in un file suo, e
## battle.gd non deve sapere niente di lui.
##
## Ogni funzione qui fa "la cosa normale": un nemico senza comportamento si comporta così.
## Un boss scrive "extends BattleBehavior" e cambia solo quello che gli serve.

## La battaglia (l'autoload Battle). Il comportamento può leggerla e usarne gli effetti.
var battle: Node


func setup(owner_battle: Node) -> void:
	battle = owner_battle


## Dopo "X appare!": un ruggito, un ricordo, una frase. Si può aspettare (await).
func after_intro() -> void:
	pass


## Il turno del nemico. Restituisce true se ha fatto lui qualcosa di speciale (allora
## Battle salta l'attacco normale), false per l'attacco normale. Si può aspettare.
func take_turn() -> bool:
	return false


## Il danno di un colpo di Subaru o di Emilia, prima che arrivi: lo può cambiare.
func modify_damage(_skill: Dictionary, amount: int) -> int:
	return amount


## Un colpo è arrivato (danno fatto, debolezza e scudo già sistemati).
func on_hit(_skill: Dictionary) -> void:
	pass
