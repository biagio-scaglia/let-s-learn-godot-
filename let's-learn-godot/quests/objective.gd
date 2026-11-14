class_name Objective
## Qual è l'obiettivo del giocatore in questo momento?
##
## Non c'è niente da ricordare: la risposta si ricava ogni volta dai ricordi (Game.flags)
## e dallo zaino. Così dopo un Ritorno dalla Morte o un "Continua" è già giusta da sola.

const EXPLORE := "Esplora il villaggio"
const FIND_KEY := "Trova la chiave di Lina, a ovest della piazza"
const BRING_KEY := "Porta la chiave a Lina"
const OPEN_CHEST := "Apri il baule di Lina"
## Missione finita: nessun obiettivo, il riquadro sparisce.
const NONE := ""


static func current() -> String:
	if Game.has_flag(FlagKeys.CHEST_OPEN):
		return NONE
	if Inventory.has(Inventory.KEY):
		return OPEN_CHEST if Game.has_flag(FlagKeys.KEY_SHOWN) else BRING_KEY
	if Game.has_flag(FlagKeys.KEY_QUEST_STARTED):
		return FIND_KEY
	return EXPLORE
