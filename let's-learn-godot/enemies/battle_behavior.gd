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
