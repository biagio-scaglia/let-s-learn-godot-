class_name Cutscene
extends CanvasLayer
## La base di tutte le cutscene: le bande nere "da film", il cartello col nome del
## luogo e le attese. Una cutscene vera scrive "extends Cutscene" e si trova già
## pronti questi metodi (si chiama ereditarietà).
##
## La scena di una cutscene deve avere i nodi TopBar, BottomBar e PlaceCard (con Line).

## Altezza delle bande nere, in pixel.
const BAR_HEIGHT := 36.0

@onready var top_bar: ColorRect = $TopBar
@onready var bottom_bar: ColorRect = $BottomBar
@onready var place_card: Control = $PlaceCard
@onready var place_line: ColorRect = $PlaceCard/Line


## Mette subito le bande nere al loro posto (sono ancorate ai bordi:
## basta dire quanto sporgono verso il centro).
func _show_bars_now() -> void:
	top_bar.offset_bottom = BAR_HEIGHT
	bottom_bar.offset_top = -BAR_HEIGHT


func _hide_bars() -> void:
	var t := create_tween().set_parallel().set_trans(Tween.TRANS_SINE)
	t.tween_property(top_bar, "offset_bottom", 0.0, 0.4)
	t.tween_property(bottom_bar, "offset_top", 0.0, 0.4)
	await t.finished


## Il nome del luogo: la scritta scende un poco e compare, la linea dorata si allarga
## dal centro, poi tutto sparisce. Non ferma la cutscene.
func _show_place_card() -> void:
	var y := place_card.position.y
	place_card.position.y = y - 8.0
	place_line.scale.x = 0.0
	var t := create_tween()
	t.tween_property(place_card, "modulate:a", 1.0, 0.6)
	t.parallel().tween_property(place_card, "position:y", y, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(place_line, "scale:x", 1.0, 0.9).set_delay(0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_interval(1.4)
	t.tween_property(place_card, "modulate:a", 0.0, 0.7)


## Toglie il nero dopo "delay" secondi, in "seconds" secondi, senza fermare la cutscene.
func _fade_in_later(delay: float, seconds: float) -> void:
	await _wait(delay)
	Fade.fade_in(seconds)


## Una battuta (o più) e si aspetta che il giocatore le abbia lette tutte.
func _say(speaker: String, lines: PackedStringArray) -> void:
	Dialogue.start(speaker, lines)
	await Dialogue.finished


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
