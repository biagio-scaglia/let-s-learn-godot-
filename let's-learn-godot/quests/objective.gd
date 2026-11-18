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
const FOREST := "All'alba, il bosco a nord (atto 3 in arrivo)"
## Nessun obiettivo: il riquadro sparisce.
const NONE := ""


static func current() -> String:
	if Game.has_flag(FlagKeys.CHEST_OPEN):
		return NONE
	if Inventory.has(Inventory.KEY):
		return OPEN_CHEST if Game.has_flag(FlagKeys.KEY_SHOWN) else BRING_KEY
	if Game.has_flag(FlagKeys.KEY_QUEST_STARTED):
		return FIND_KEY
	return EXPLORE
