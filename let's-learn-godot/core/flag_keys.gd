class_name FlagKeys
## I nomi dei ricordi del gioco (le chiavi di Game.flags), tutti in un posto.
##
## Il valore è la stringa salvata nel file: non cambiarlo, o i vecchi salvataggi
## non se lo ricorderanno più. Il nome della costante invece si può cambiare.

## La cutscene d'apertura è già stata vista.
const INTRO_SEEN := "intro_vista"
## Il baule di Lina è stato aperto.
const CHEST_OPEN := "baule_aperto"
## Lina ti ha chiesto di trovare la sua chiave.
const KEY_QUEST_STARTED := "missione_chiave"
## Hai mostrato la chiave a Lina, che ti ha detto di aprire il baule.
const KEY_SHOWN := "chiave_mostrata"

# ---------- Atto 2: le voci di Erbalta ----------
## Il Saggio ha ammesso di non ricordare da quanto tempo è a Erbalta.
const SAGE_FORGETS := "saggio_dimentica"
## L'Archivista ha letto la pagina strappata e ha parlato dello Spettro.
const PAGE_READ := "pagina_letta"
## Pagina e lacrima sul libro nero: Subaru conosce la verità su Erbalta.
const BOOK_READ := "libro_letto"
## Subaru l'ha raccontato a Emilia: fine dell'atto 2.
const ACT2_DONE := "atto2_finito"

# ---------- Atto 3: il Bosco Senza Tempo ----------
## Subaru ed Emilia sono arrivati nel bosco (la cutscene d'arrivo è stata vista).
const FOREST_ARRIVED := "bosco_arrivo"


## Quante volte si è parlato con un Interactable (uno per percorso nella scena).
static func talked(node: Node) -> String:
	return "talked:" + str(node.get_path())


## Un personaggio ha già commentato la faccia di Subaru dopo una morte.
static func death_noticed(who: String) -> String:
	return "morte_notata:" + who


## Un nemico già sconfitto.
static func defeated(node: Node) -> String:
	return "sconfitto:" + str(node.get_path())


## Un oggetto per terra già raccolto.
static func picked(node: Node) -> String:
	return "preso:" + str(node.get_path())
