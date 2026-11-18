extends Node2D
## La Galleria: una sala della biblioteca dove stanno tutti i personaggi e i mostri
## del gioco, ognuno con il suo libro. Si apre dal titolo dopo aver finito la storia.
##
## Non è un livello della storia (non è nel gruppo "level"): niente menu di pausa,
## niente salvataggi, niente obiettivo. Esc o la porta in basso riportano al titolo.

@onready var reader: BookReader = $Reader
@onready var place_name: Control = %PlaceName
@onready var hint: Label = %Hint
