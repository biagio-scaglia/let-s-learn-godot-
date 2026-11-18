class_name Objective
## Qual è l'obiettivo del giocatore in questo momento?
##
## Non c'è niente da ricordare: la risposta si ricava ogni volta dai ricordi (Game.flags)
## e dallo zaino. Così dopo un Ritorno dalla Morte o un "Continua" è già giusta da sola.
##
## L'atto 2, "Le voci di Erbalta", in ordine:
## Saggio → Lina e la sua chiave → il baule (la pagina) → l'Archivista → lo Spettro
## (la lacrima) → il libro nero → Emilia.

const ASK_SAGE := "Chiedi al Saggio delle voci strane"
const VISIT_LINA := "Vai da Lina, nella casa col tetto rosso"
const FIND_KEY := "Trova la chiave di Lina, a ovest della piazza"
const BRING_KEY := "Porta la chiave a Lina"
const OPEN_CHEST := "Apri il baule di Lina"
## Solo per i salvataggi di prima dell'atto 2: baule aperto, ma senza la pagina.
const CHECK_CHEST := "Guarda meglio nel baule di Lina"
const SHOW_PAGE := "Porta la pagina strappata all'Archivista"
const DEFEAT_SPECTRE := "Sconfiggi lo Spettro, a est della piazza"
const READ_BOOK := "Leggi il libro nero, in biblioteca"
const TELL_EMILIA := "Racconta tutto a Emilia, in piazza"
const DEPART := "Parla con Emilia quando sei pronto a partire"
## Atto 3.
const CROSS_FOREST := "Attraversa il Bosco Senza Tempo"
## %d = quanti occhi di pietra sono già chiusi.
const CLOSE_EYES := "Chiudi gli occhi di pietra (%d/3)"
const ENTER_CLEARING := "Entra nella radura, in cima al bosco"
const BACK_HOME := "Torna a Erbalta con Emilia"
## Nessun obiettivo: il riquadro sparisce.
const NONE := ""


static func current() -> String:
	# Si parte dalla fine: il primo passo già fatto decide cosa viene dopo.
	if Game.has_flag(FlagKeys.FOREST_ARRIVED):
		var closed := FlagKeys.eyes_closed_count()
		if closed == FlagKeys.STONE_EYES.size():
			return ENTER_CLEARING
		# Finché non ha visto la nebbia (o chiuso un occhio), basta attraversare il bosco.
		if closed > 0 or Game.has_flag(FlagKeys.FOG_SEEN):
			return CLOSE_EYES % closed
		return CROSS_FOREST
	if Game.has_flag(FlagKeys.ACT2_DONE):
		return DEPART
	if Game.has_flag(FlagKeys.BOOK_READ):
		return TELL_EMILIA
	if Game.has_flag(FlagKeys.PAGE_READ):
		return READ_BOOK if Inventory.has(Inventory.TEAR) else DEFEAT_SPECTRE
	if Inventory.has(Inventory.PAGE):
		return SHOW_PAGE
	if Game.has_flag(FlagKeys.CHEST_OPEN):
		return CHECK_CHEST
	if Inventory.has(Inventory.KEY):
		return OPEN_CHEST if Game.has_flag(FlagKeys.KEY_SHOWN) else BRING_KEY
	if Game.has_flag(FlagKeys.KEY_QUEST_STARTED):
		return FIND_KEY
	if Game.has_flag(FlagKeys.SAGE_FORGETS):
		return VISIT_LINA
	return ASK_SAGE
