class_name VoicesQuest
extends Node
## Atto 2, "Le voci di Erbalta": cosa dicono i personaggi della storia a ogni passo.
##
## Come KeyQuest, non sta dentro i personaggi: li ascolta (segnale interacted) e
## sceglie le loro frasi (override_lines). Ce n'è un'istanza nel villaggio (Saggio,
## Emilia) e una in biblioteca (Archivista, libro nero): i campi vuoti si ignorano.
##
## Il filo: Emilia → Saggio (non ricorda da quanto è qui) → Lina e il baule (una
## pagina strappata) → Archivista (la pagina parla dello Spettro) → Spettro (lascia
## una lacrima d'ombra) → libro nero (la verità) → di nuovo Emilia. L'obiettivo in
## alto a sinistra lo calcola Objective dagli stessi ricordi.

@export var saggio: Interactable
@export var emilia: Interactable
@export var archivista: Interactable
@export var black_book: Interactable
## La luce viola sopra il libro nero: si accende forte quando il libro "parla".
@export var book_glow: PointLight2D


func _ready() -> void:
	for pair in [[saggio, _on_saggio], [emilia, _on_emilia],
			[archivista, _on_archivista], [black_book, _on_black_book]]:
		if pair[0]:
			pair[0].interacted.connect(pair[1])


# ---------- Il Saggio ----------

func _on_saggio() -> void:
	if not Game.has_flag(FlagKeys.SAGE_FORGETS):
		var hello: PackedStringArray = [
			"Oh, un volto nuovo! Benvenuto a Erbalta. Io sono il Saggio: passo le giornate a guardare crescere gli alberi.",
			"Se hai fretta, tieni premuto Shift per correre... ma qui nessuno ha fretta.",
		] if saggio.times == 0 else []
		saggio.override_lines = hello + PackedStringArray([
			"Voci strane? Su Erbalta? Ah! Qui non succede mai niente, ragazzo.",
			"Ogni giorno è uguale a quello prima. Gli stessi alberi, alti uguale...",
			"...Uguale. Proprio uguale.",
			"Da quanto tempo li guardo crescere? Ieri. L'altro ieri. Prima ancora...",
			"Che strano. Non me lo ricordo.",
			"Il cartello della piazza l'ha scritto mio nonno. O l'ho scritto io? Che testa...",
			"Senti, va' da mia nipote Lina, nella casa col tetto rosso. Nel baule di sua nonna c'è tutta la storia della famiglia.",
		])
		Game.set_flag(FlagKeys.SAGE_FORGETS)
	elif Game.has_flag(FlagKeys.ACT2_DONE):
		saggio.override_lines = [
			"Il bosco a nord? Non ci va nessuno, ragazzo. Non ci è mai andato nessuno.",
			"...Però, se ci vai, guarda se gli alberi lassù crescono. Io non li ho mai visti crescere.",
		]
	elif Game.has_flag(FlagKeys.BOOK_READ):
		saggio.override_lines = [
			"Hai la faccia di chi ha letto qualcosa che non doveva.",
			"Non dirmelo. Se è una cosa triste, preferisco dimenticarla. Mi riesce bene.",
		]
	else:
		saggio.override_lines = [
			"Sei stato da Lina? Casa col tetto rosso, a nord-ovest. Non puoi sbagliare.",
			"Io resto qui, con i miei alberi. Ci facciamo compagnia.",
		]


# ---------- Emilia: il punto di riferimento ----------

func _on_emilia() -> void:
	if Game.has_flag(FlagKeys.ACT2_DONE):
		emilia.override_lines = [
			"Domani all'alba, il bosco a nord. Io ci sarò.",
			"Non sparire, d'accordo? ...E non morire. Nemmeno per finta.",
		]
	elif Game.has_flag(FlagKeys.BOOK_READ):
		_final_talk()
	elif Game.has_flag(FlagKeys.PAGE_READ):
		emilia.override_lines = [
			"Uno Spettro a est della piazza? Stai attento, Subaru.",
			"Colpiscilo dove gli fa più male, e se sei ferito usa le pozioni di Lina.",
		] if not Inventory.has(Inventory.TEAR) else [
			"Una lacrima d'ombra... è fredda solo a guardarla.",
			"Portala al libro nero, insieme alla pagina. Io ti aspetto qui.",
		]
	elif Inventory.has(Inventory.PAGE):
		emilia.override_lines = [
			"Una pagina strappata? Fa' vedere... è scritta in una lingua antica.",
			"Portala in biblioteca, la casa di pietra a nord-est. L'Archivista saprà leggerla.",
		]
	elif Game.has_flag(FlagKeys.SAGE_FORGETS):
		emilia.override_lines = [
			"Il Saggio non si ricorda da quanto tempo è qui? ...Che strano.",
			"Prova a sentire Lina, come ti ha detto lui. Io tengo d'occhio la piazza.",
		]
	else:
		emilia.override_lines = [
			"Allora, Subaru? Hai già fatto un giro?",
			"Comincerei dal Saggio: sta sempre vicino agli alberi, a est della piazza.",
			"Se qualcuno sa qualcosa delle voci su Erbalta, è lui.",
		]
