class_name GalleryBooks
## I libri della Galleria: uno per ogni personaggio e per ogni mostro.
##
## Ogni libro ha un id (lo stesso dei ritratti, vedi Portraits), un nome, un
## sottotitolo e le pagine da leggere. Per i mostri nome e numeri (PS, attacco,
## debolezze...) vengono dal loro file EnemyData: si scrive solo la storia.
## Li leggono il lettore di libri (BookReader) e i titoli di coda (il cast).

const CHARACTERS := [
	{
		"id": "subaru",
		"name": "Natsuki Subaru",
		"role": "Colui che ritorna",
		"pages": [
			"Un ragazzo arrivato da un altro mondo, con una tuta, tanta parlantina e nessuna intenzione di arrendersi.",
			"Ha un potere che non ha mai chiesto: quando muore torna indietro, all'ultimo punto di ritorno. Il mondo dimentica. Lui no.",
			"In battaglia usa pugni, calci e un'ombra che non sa spiegare. Chiama Emilia \"Emiliuccia\": lei fa finta di arrabbiarsi.",
		],
	},
	{
		"id": "emilia",
		"name": "Emilia",
		"role": "La ragazza dai capelli d'argento",
		"pages": [
			"Gentile e testarda. È lei che ha portato Subaru a Erbalta, per capire da dove arrivassero le voci strane.",
			"Nel Bosco Senza Tempo combatte accanto a Subaru con la magia del gelo: le Scaglie di gelo e, insieme a lui, il Cristallo infranto.",
			"Non chiede mai a Subaru come faccia a ricordare certe cose. Si fida. A volte basta questo.",
		],
	},
	{
		"id": "saggio",
		"name": "Il Saggio",
		"role": "Il nonno di Erbalta",
		"pages": [
			"Passa le giornate in piazza a guardare crescere gli alberi. Conosce tutti e ricorda tutto... o almeno così crede.",
			"Per anni gli alberi di Erbalta sono rimasti alti uguale, e lui non se n'era accorto. Dopo la caduta di Colui che guarda sono cresciuti di un palmo in una notte.",
		],
	},
	{
		"id": "lina",
		"name": "Lina",
		"role": "La nipote del Saggio",
		"pages": [
			"Vive nella casa col tetto rosso. Vivace, distratta, perde sempre le chiavi.",
			"Nel baule della nonna custodiva, senza saperlo, la pagina strappata del libro nero. La nonna diceva: \"I libri che nessuno legge sono quelli che ricordano di più.\"",
		],
	},
	{
		"id": "archivista",
		"name": "L'Archivista",
		"role": "Custode della biblioteca",
		"pages": [
			"Parla piano, cammina piano e legge di tutto. La biblioteca di pietra, a nord-est della piazza, è casa sua.",
			"È stata la prima a leggere la pagina strappata e l'ultima a salutare Subaru ed Emilia. Ora legge la storia nuova che il libro nero scrive da solo.",
		],
	},
]

const MONSTERS := [
	{
		"id": "melma",
		"role": "Villaggio di Erbalta",
		"pages": [
			"Una gelatina verde che rimbalza nell'erba a est della piazza. Non è cattiva: è solo affamata, e Subaru le sembra commestibile.",
		],
	},
	{
		"id": "spettro",
		"role": "Villaggio, a est della piazza",
		"pages": [
			"Un'ombra fredda con due occhi vuoti. Custodiva la lacrima d'ombra: l'inchiostro che ha fatto parlare il libro nero.",
		],
	},
	{
		"id": "mano_ombra",
		"role": "Bosco Senza Tempo",
		"pages": [
			"Mani nere che escono dal terreno del bosco e cercano qualcuno da afferrare. Qualcuno dice che sono le stesse che si muovono nel buio, dietro il menu del titolo...",
		],
	},
	{
		"id": "occhio_errante",
		"role": "Bosco Senza Tempo",
		"pages": [
			"Un occhio che ha lasciato il suo padrone e vaga tra gli alberi. Vede tutto, ma da solo non può fare molto.",
		],
	},
	{
		"id": "guardiano_rovi",
		"role": "Bosco Senza Tempo",
		"pages": [
			"Un groviglio di rovi che ha preso forma e coscienza. Sorveglia i sentieri del bosco: non lascia passare nessuno, né dentro né fuori.",
		],
	},
	{
		"id": "colui_che_guarda",
		"role": "Il cuore del bosco",
		"pages": [
			"Dormiva nella radura in cima al Bosco Senza Tempo e non chiudeva mai gli occhi. Finché guardava, Erbalta ricominciava ogni alba lo stesso giorno.",
			"Il suo Sguardo pietrifica chi lo incrocia. Subaru l'ha capito nel modo peggiore: morendo. Poi è tornato indietro, ricordando.",
			"Lo hanno sconfitto insieme, con l'Alba di cristallo. Da quella notte, a Erbalta, gli alberi crescono.",
		],
	},
]

## I nomi dei tipi di colpo, come li vede il giocatore.
const HIT_NAMES := {"pugno": "Pugno", "calcio": "Calcio", "ombra": "Ombra", "ghiaccio": "Ghiaccio"}


## Il libro con questo id, completo: per i mostri aggiunge nome e numeri da EnemyData.
## Vuoto se non esiste.
static func entry(id: String) -> Dictionary:
	for book in CHARACTERS:
		if book.id == id:
			return book
	for book in MONSTERS:
		if book.id == id:
			return _with_stats(book)
	return {}
