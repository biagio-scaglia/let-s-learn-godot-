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
	# Tornati dal bosco dopo il boss: Emilia è con Subaru, lo segue anche nel villaggio.
	if emilia and Game.has_flag(FlagKeys.BOSS_DEFEATED):
		emilia.get_parent().add_child(Follower.new())
		Game.set_flag(FlagKeys.HOME_AGAIN)
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
	elif Game.has_flag(FlagKeys.BOSS_DEFEATED):
		saggio.override_lines = [
			"Ragazzo! Ragazzo, guarda!",
			"Gli alberi... stanotte sono cresciuti. Tutti quanti. Di un palmo!",
			"Non succedeva da... da quando? Non lo so. Ma me lo ricorderò, questo. Me lo ricorderò.",
		] if not Game.has_flag(FlagKeys.greeted("saggio")) else [
			"Partite? Allora andate dal sentiero a sud, all'alba. È da lì che si va nel mondo.",
			"E tornate, eh. Voglio farvi vedere quanto sono cresciuti, i miei alberi.",
		]
		Game.set_flag(FlagKeys.greeted("saggio"))
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
	if Game.has_flag(FlagKeys.BOSS_DEFEATED):
		if FlagKeys.greeted_count() == FlagKeys.VILLAGERS.size():
			emilia.override_lines = [
				"Hai salutato tutti? ...Anch'io. Il Saggio mi ha regalato una ghianda. Dice che è di un albero nuovo.",
				"Allora andiamo, Subaru. Dal sentiero a sud, come quando siamo arrivati.",
			]
		else:
			emilia.override_lines = [
				"Erbalta sembra la stessa... ma l'aria è diversa. Più leggera.",
				"Andiamo a vedere come stanno tutti. Il Saggio, Lina, l'Archivista.",
				"Poi, quando sei pronto, partiamo. Dal sentiero a sud.",
			]
		return
	if Game.has_flag(FlagKeys.ACT2_DONE):
		_depart()
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


## La fine dell'atto 2: Subaru racconta, Emilia decide. È una conversazione a più
## voci: la prima battuta la dice il dialogo normale di Emilia, le altre seguono.
func _final_talk() -> void:
	emilia.override_lines = [
		"Subaru! Sei corso fin qui. Cosa c'era scritto nel libro?",
	]
	Game.in_cutscene = true   # nessuno interrompe la conversazione
	await _then("Subaru", [
		"Erbalta non invecchia, Emilia. Ricomincia.",
		"Ogni alba è la stessa alba. Gli abitanti la vivono per sempre e non se ne accorgono.",
		"C'è qualcosa che li tiene qui. Il libro lo chiama \"Colui che guarda\". Dorme nel bosco a nord.",
	])
	await _then("Emilia", [
		"Un villaggio che ricomincia sempre lo stesso giorno...",
		"Allora è per questo che nessuno se ne va. Non è che non vogliono: non possono.",
		"...Ma tu come fai a ricordartelo, Subaru?",
	])
	await _then("Subaru", [
		"...",
		"Diciamo che sono bravo a ricordare le cose. Anche quelle che non dovrei.",
	])
	await _then("Emilia", [
		"Va bene. Non ti chiedo altro.",
		"Andremo nel bosco a nord. Insieme.",
		"Ma non adesso: riposati, prima. Partiamo domani all'alba.",
		"...Sempre che domani arrivi davvero.",
	])
	await Dialogue.finished
	Game.set_flag(FlagKeys.ACT2_DONE)
	Game.in_cutscene = false
	# Fine dell'atto: da qui si riparte dopo un Ritorno dalla Morte.
	Game.set_checkpoint()


## Inizio dell'atto 3: Emilia è pronta, si parte per il bosco a nord.
func _depart() -> void:
	emilia.override_lines = [
		"Ci hai pensato bene? Una volta nel bosco, non so se potremo tornare indietro.",
		"...Va bene. Anch'io sono pronta.",
		"Andiamo, Subaru. Prima che il sole sia alto.",
	]
	Game.in_cutscene = true
	# Un collegamento, non un await: se la scena sparisce prima (un test, un cambio di
	# scena), Godot lo scollega da solo e nessuno ci porta nel bosco per sbaglio.
	Dialogue.finished.connect(_go_to_forest, CONNECT_ONE_SHOT)


func _go_to_forest() -> void:
	# Niente punto d'arrivo: nel bosco parte la cutscene dell'arrivo.
	Game.change_scene(Game.FOREST_SCENE, "", "", false)


## Aspetta che il dialogo in corso finisca, poi fa parlare qualcun altro.
func _then(speaker: String, lines: PackedStringArray) -> void:
	await Dialogue.finished
	Dialogue.start(speaker, lines)


# ---------- L'Archivista ----------

func _on_archivista() -> void:
	if Game.has_flag(FlagKeys.BOSS_DEFEATED):
		archivista.override_lines = [
			"Shh... ah, sei tu. Vieni, guarda. Ma piano.",
			"Il libro nero. Stanotte le pagine hanno ricominciato a scriversi da sole.",
			"È una storia nuova. Parla di un ragazzo che tornava dalla morte, e di una ragazza dai capelli d'argento.",
			"Non so ancora come finisce. Le ultime pagine sono bianche.",
			"...Credo che toccherà a voi scriverle. Andate. Io resto qui a leggere.",
		] if not Game.has_flag(FlagKeys.greeted("archivista")) else [
			"Una pagina nuova, proprio adesso: \"All'alba, partirono dal sentiero a sud.\"",
			"Non fatemi aspettare troppo il capitolo dopo.",
		]
		Game.set_flag(FlagKeys.greeted("archivista"))
	elif Game.has_flag(FlagKeys.BOOK_READ):
		archivista.override_lines = [
			"Il libro ti ha parlato, vero? L'ho sentito. Le pagine frusciavano come foglie.",
			"Io resto qui coi miei libri. Qualcuno deve ricordare, anche se nessuno legge.",
		]
	elif Game.has_flag(FlagKeys.PAGE_READ):
		archivista.override_lines = [
			"La lacrima d'ombra... ce l'hai. Mettila sul libro nero, insieme alla pagina.",
		] if Inventory.has(Inventory.TEAR) else [
			"Lo Spettro vive a est della piazza, dove l'aria si fa fredda.",
			"Il calcio gli fa male, dicono i libri. E qualcosa di più scuro ancora.",
		]
	elif Inventory.has(Inventory.PAGE):
		archivista.override_lines = [
			"Shh! ...Oh. Cos'hai lì?",
			"Questa pagina... viene dal libro nero. Ma è impossibile: quel libro è sempre stato vuoto.",
			"C'è scritto: \"Colui che guarda non dorme mai. Il suo occhio piange solo quando lo Spettro cade.\"",
			"Lo Spettro vive a est della piazza. Se lo sconfiggi, forse lascerà cadere quella lacrima.",
			"Pagina e lacrima, insieme, sul libro nero. Allora, forse, il libro parlerà.",
		] + ([
			"...Aspetta. Quella che hai in tasca è già una lacrima d'ombra?",
		] if Inventory.has(Inventory.TEAR) else [])
		Game.set_flag(FlagKeys.PAGE_READ)


# ---------- Il libro nero ----------

func _on_black_book() -> void:
	if Game.has_flag(FlagKeys.BOSS_DEFEATED):
		black_book.override_lines = [
			"L'inchiostro è nero e lucido, come appena steso. Le pagine sono piene.",
			"L'ultima riga, con la tua calligrafia, è cambiata:",
			"\"Questa volta, ce l'hai fatta.\"",
		]
		return
	if Game.has_flag(FlagKeys.BOOK_READ):
		black_book.override_lines = [
			"Le pagine sono di nuovo vuote. Ma ora sai cosa c'era scritto.",
			"\"Questa volta, portala via di qui.\"",
		]
		return
	if not (Game.has_flag(FlagKeys.PAGE_READ) and Inventory.has(Inventory.PAGE) \
			and Inventory.has(Inventory.TEAR)):
		return   # le sue frasi normali, misteriose
	black_book.override_lines = [
		"Rimetti la pagina al suo posto. Combacia perfettamente, strappo per strappo.",
		"La lacrima d'ombra scivola sulla carta... e l'inchiostro comincia a muoversi da solo.",
		"\"Erbalta non invecchia. Erbalta ricomincia.\"",
		"\"Ogni alba è la stessa alba. Chi vive qui la vive per sempre, e non se ne accorge.\"",
		"\"Solo chi torna dalla morte ricorda.\"",
		"\"Colui che guarda dorme nel bosco a nord, dove gli alberi non crescono. Finché i suoi occhi resteranno aperti, nessuno lascerà il villaggio.\"",
		"Sotto, l'ultima riga. Con la tua calligrafia:",
		"\"Questa volta, portala via di qui.\"",
	]
	Inventory.remove(Inventory.PAGE)
	Inventory.remove(Inventory.TEAR)
	_book_wakes()
	await Dialogue.finished
	Game.set_flag(FlagKeys.BOOK_READ)
	Dialogue.start("Subaru", [
		"...Questa è la mia calligrafia. Non c'è dubbio.",
		"Devo dirlo a Emilia. Subito.",
	])


## Il libro si "sveglia": la sua luce viola si gonfia e torna a tremolare piano.
func _book_wakes() -> void:
	if book_glow == null:
		return
	Sfx.play(Sfx.SHAMAC)
	# La luce ha flicker.gd, che a ogni frame riscrive "energy" partendo da "_base_energy":
	# per questo animiamo il valore di base, e il tremolio continua sopra.
	var base: float = book_glow.get("_base_energy")
	var t := create_tween()
	t.tween_property(book_glow, "_base_energy", base * 4.0, 0.6).set_trans(Tween.TRANS_SINE)
	t.tween_property(book_glow, "_base_energy", base, 2.5).set_trans(Tween.TRANS_SINE)
