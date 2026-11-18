class_name BookReader
extends CanvasLayer
## Il libro aperto della Galleria. A sinistra il ritratto, il nome, il sottotitolo e
## (per i mostri) i numeri; a destra la storia, una pagina alla volta.
## Frecce: sfoglia. E, Invio o Esc: chiudi.
##
## Tutta l'interfaccia è costruita da codice in _build(): pannelli con StyleBoxFlat
## (un rettangolo col bordo, senza immagini), Label e un TextureRect per il ritratto.

signal closed

const PAPER := Color(0.95, 0.89, 0.74)
const PAPER_DARK := Color(0.82, 0.72, 0.55)
const LEATHER := Color(0.36, 0.18, 0.16)
const INK := Color(0.24, 0.14, 0.1)
const INK_SOFT := Color(0.45, 0.3, 0.22)
const BOOK_SIZE := Vector2(540, 290)

var is_open := false
var _pages: Array = []
var _page := 0
var _dim: ColorRect
var _book: Control
var _portrait: TextureRect
var _name: Label
var _role: Label
var _stats: GridContainer
var _text: Label
var _page_number: Label
var _prev: Label
var _next: Label
var _tween: Tween


func _ready() -> void:
	layer = 7
	_build()
	visible = false
