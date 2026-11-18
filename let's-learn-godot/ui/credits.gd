extends Control
## I titoli di coda. Il cielo passa dalla notte all'alba, Subaru ed Emilia camminano
## in basso lungo la strada, i nomi scorrono verso l'alto al ritmo della musica.
## Alla fine resta "Un gioco di Biagio Scaglia"; con Invio si torna al titolo.
##
## I titoli non sono scritti nella scena: li costruisce _build_list() a partire da
## CREDITS (e dal cast di GalleryBooks), così aggiungere un nome è una riga sola.

## Ogni riga: [stile, testo]. Stili: "title", "by", "header", "name", "small", "gap",
## "cast" (i personaggi, col ritratto), "monsters" (i mostri, col ritratto).
const CREDITS := [
	["title", "Erbalta"],
	["by", "Un gioco di Biagio Scaglia"],
	["gap", ""],
	["header", "Ideato, scritto e diretto da"],
	["name", "Biagio Scaglia"],
	["header", "Programmazione"],
	["name", "Biagio Scaglia"],
	["header", "Storia e dialoghi"],
	["name", "Biagio Scaglia"],
	["header", "Musiche originali"],
	["name", "Biagio Scaglia"],
	["small", "\"Un giorno nuovo\" - il tema di questi titoli"],
	["gap", ""],
	["header", "Personaggi"],
	["cast", ""],
	["gap", ""],
	["header", "Mostri"],
	["monsters", ""],
	["gap", ""],
	["header", "Grafica"],
	["name", "Tiny Town, Tiny Dungeon, Particle Pack"],
	["small", "Kenney (CC0)"],
	["name", "Biblioteca, castello, bosco, nemici, effetti"],
	["small", "Biagio Scaglia"],
	["header", "Suoni"],
	["name", "Sci-fi Sounds, Interface Sounds"],
	["small", "Kenney (CC0)"],
	["name", "Heartbeat sounds"],
	["small", "bart (CC0)"],
	["header", "Carattere"],
	["name", "KenPixel High Square"],
	["small", "Kenney (CC0)"],
	["header", "Fatto con"],
	["name", "Godot Engine 4.7"],
	["small", "gdUnit4 - Dialogue Manager - Phantom Camera - Beehave"],
	["gap", ""],
	["header", "Subaru ed Emilia"],
	["small", "da Re:Zero - Starting Life in Another World"],
	["small", "(c) Tappei Nagatsuki, Kadokawa"],
	["small", "Usati per imparare, in un progetto personale e non commerciale."],
	["gap", ""],
	["header", "Grazie per aver giocato!"],
]

## Quanto prima della fine della musica devono finire di scorrere i nomi
## (il tempo per il cartello finale).
const FINAL_HOLD := 16.0
## Tenendo premuto Invio (o E) i titoli vanno più veloci.
const FAST_FORWARD := 5.0
## Il cielo: notte, alba, mattina.
const SKY := [Color(0.06, 0.04, 0.12), Color(0.55, 0.28, 0.32), Color(0.98, 0.7, 0.5), Color(0.55, 0.72, 0.9)]
## Larghezza della colonna dei titoli.
const COLUMN := 420.0

@onready var sky: ColorRect = %Sky
@onready var stars: CPUParticles2D = %Stars
@onready var scroller: Control = %Scroller
@onready var list: VBoxContainer = %List
@onready var road: Node2D = %Road
@onready var subaru: AnimatedSprite2D = %Subaru
@onready var emilia: Sprite2D = %Emilia
@onready var trees: Node2D = %Trees
@onready var final_card: Control = %FinalCard
@onready var unlocked: Label = %Unlocked
@onready var press: Label = %Press
@onready var hint: Label = %Hint
@onready var music: AudioStreamPlayer = %Music

## Pixel al secondo dello scorrimento (calcolato dalla durata della musica).
var _speed := 20.0
## Quanto tempo è passato "nella storia dei titoli" (va più veloce se si tiene premuto).
var _time := 0.0
var _total := 100.0
var _finished := false
var _can_leave := false
## La Galleria si è appena sbloccata? (Lo dice Progress prima che la tocchiamo.)
var _new_gallery := false
