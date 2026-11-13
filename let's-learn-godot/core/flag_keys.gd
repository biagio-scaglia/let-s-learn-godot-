class_name FlagKeys
## I nomi dei ricordi del gioco (le chiavi di Game.flags), tutti in un posto.
##
## Il valore è la stringa salvata nel file: non cambiarlo, o i vecchi salvataggi
## non se lo ricorderanno più. Il nome della costante invece si può cambiare.

## La cutscene d'apertura è già stata vista.
const INTRO_SEEN := "intro_vista"
## Il baule di Lina è stato aperto.
const CHEST_OPEN := "baule_aperto"


## Quante volte si è parlato con un Interactable (uno per percorso nella scena).
static func talked(node: Node) -> String:
	return "talked:" + str(node.get_path())


## Un oggetto per terra già raccolto.
static func picked(node: Node) -> String:
	return "preso:" + str(node.get_path())
