class_name ThicketEyes
extends Sprite2D
## Due occhi nel buio dei rovi. Si aprono piano, sbattono le palpebre ogni tanto,
## e quando Subaru si avvicina troppo si chiudono di colpo: come se non ci fossero mai stati.
## Lo sprite ha 3 celle: aperti, socchiusi, chiusi.

enum Lids { OPEN, HALF, SHUT }

## Sotto questa distanza dal giocatore gli occhi si chiudono.
@export var shy_distance := 90.0

var _player: Node2D
var _shut := true
var _busy := false
