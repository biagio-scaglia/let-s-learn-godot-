extends Cutscene
## Il finale: dopo Colui che guarda, quando Subaru ha salutato tutti e va in fondo al
## sentiero a sud, Subaru ed Emilia lasciano Erbalta all'alba. È l'intro al contrario:
## là arrivavano dal sentiero a sud mentre sorgeva il sole, qui se ne vanno.
## Il Saggio corre a salutarli, poi lo schermo sfuma sui titoli di coda.
##
## Finché non è il momento la cutscene aspetta: ogni frame guarda se Subaru è arrivato
## in fondo al sentiero (TRIGGER). Prima di aver salutato tutti, Emilia lo ferma.

## La scena dei titoli di coda.
const CREDITS_SCENE := "res://ui/credits.tscn"
## Il fondo del sentiero a sud: entrandoci si parte (o Emilia ricorda chi manca).
const TRIGGER := Rect2(592, 664, 128, 60)
## Il centro del sentiero e il punto, fuori dallo schermo, dove spariscono.
const PATH_X := 656.0
const EXIT_Y := 840.0
## Emilia cammina accanto a Subaru, sulla destra (come nell'intro).
const EMILIA_OFFSET := Vector2(36, 6)
## Passo lento: non si ha fretta, quando si parte per sempre... o quasi.
const SPEED := 50.0
## Gli stessi colori dell'alba dell'intro.
const DAWN_TINT := Color(1.0, 0.76, 0.62)
const DAWN_RAYS := 0.9

var _player: Node2D
## Emilia ha già detto "prima salutiamo tutti": non lo ripete finché Subaru non esce dalla zona.
var _warned := false
