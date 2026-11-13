class_name Facing
## Le quattro direzioni in cui può guardare un personaggio.
##
## Sono stringhe (finiscono nei salvataggi e nelle porte), ma nel codice si scrive
## Facing.UP invece di "up": se sbagli a scrivere, Godot se ne accorge subito.

const DOWN := "down"
const UP := "up"
const LEFT := "left"
const RIGHT := "right"


## La direzione più vicina a un vettore. Prende l'asse dominante, così anche le
## diagonali scelgono una direzione sensata.
static func from_vector(dir: Vector2) -> String:
	if abs(dir.x) > abs(dir.y):
		return RIGHT if dir.x > 0 else LEFT
	return DOWN if dir.y > 0 else UP
