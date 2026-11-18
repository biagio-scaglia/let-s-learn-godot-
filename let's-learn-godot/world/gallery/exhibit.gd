class_name Exhibit
extends Node2D
## Una "vetrina" della Galleria: un piedistallo, sopra un personaggio o un mostro,
## e accanto un leggio con il suo libro. Avvicinati al leggio e premi E per leggerlo.
##
## Si costruisce tutta da codice a partire da "book_id" (lo stesso id di GalleryBooks
## e di Portraits): nella scena basta un Node2D con questo script e l'id giusto.
## - "subaru": una statua (lui è il giocatore, non può stare anche qui!)
## - gli altri personaggi: il PNG vero (npc.tscn), che respira e si gira verso di te
## - i mostri: lo sprite del nemico, che respira con le sue due pose di riposo

## Emesso quando il giocatore apre il libro del leggio.
signal book_opened(book_id: String)

const NPC_SCENE := preload("res://characters/npc/npc.tscn")
const INTERACTABLE := preload("res://interactables/interactable.tscn")
const LIBRARY_TILES := preload("res://assets/library/library_tiles.png")
const SHADOW := preload("res://assets/effects/shadow_character.png")
## Il leggio col libro: casella (3, 4) del tileset della biblioteca.
const LECTERN_REGION := Rect2(48, 64, 16, 16)
## Cosa dicono i personaggi della Galleria: [prima volta, dalla seconda in poi].
const QUIPS := {
	"emilia": [
		["Una galleria tutta per noi? ...Quella statua di Subaru è un po' troppo eroica, non trovi?"],
		["Leggi pure il libro qui accanto. Ma non credere a tutto quello che c'è scritto su di me!"],
	],
	"saggio": [
		["Anche qui ci sono degli alberi? No? Peccato. Li avrei guardati crescere."],
		["Il libro dice che non mi ricordo le cose? Mah. Non me lo ricordo."],
	],
	"lina": [
		["Che bello! È come il baule della nonna, ma enorme!"],
		["Il mio libro dice che perdo sempre le chiavi. ...A proposito, hai visto la mia chiave?"],
	],
	"archivista": [
		["Shh. Una biblioteca di ricordi: il posto più bello del mondo."],
		["Questi libri si sono scritti da soli. Io li ho solo messi in ordine."],
	],
}

## Quale libro (e quale figura): "subaru", "emilia", "melma", "colui_che_guarda"...
@export var book_id := ""
## Quanto è grande la figura (un boss: 2).
@export var figure_scale := 1.0

## Mezza larghezza del piedistallo, in pixel.
var _half := 18.0
