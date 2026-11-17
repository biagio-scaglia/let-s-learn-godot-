class_name BattleEnemyInfo
extends VBoxContainer
## Il riquadro sotto il nemico: lo scudo con il suo numero, le debolezze (un "?" finché
## non le scopri) e il nome. Disegna e basta: cosa è stato scoperto lo sa battle.gd.

## Le icone dentro battle_icons.png (celle da 16x16), nell'ordine.
const ICON_SHIELD := 0
const ICON_UNKNOWN := 4
const ICON_BROKEN := 5
const TYPE_ICONS := {"pugno": 1, "calcio": 2, "ombra": 3}

## Le icone di scudo e debolezze.
@export var icons: Texture2D

@onready var shield_icon: TextureRect = %Shield
@onready var shield_number: Label = %ShieldNumber
@onready var weakness_row: HBoxContainer = %Weaknesses
@onready var enemy_name: Label = %EnemyName


## Un nemico nuovo: il nome e una casella per ogni debolezza.
func show_enemy(data: EnemyData, revealed: Array[String]) -> void:
	enemy_name.text = data.name
	modulate.a = 1.0
	for child in weakness_row.get_children():
		child.queue_free()
	for kind in data.weaknesses:
		var slot := TextureRect.new()
		slot.custom_minimum_size = Vector2(16, 16)
		slot.texture = _icon(TYPE_ICONS[kind] if revealed.has(kind) else ICON_UNKNOWN)
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.name = kind
		weakness_row.add_child(slot)


## Lo scudo: l'icona intera con il numero, oppure quella rotta senza numero.
func set_shield(value: int, broken: bool) -> void:
	shield_icon.texture = _icon(ICON_BROKEN if broken else ICON_SHIELD)
	shield_number.text = str(value)
	shield_number.visible = not broken


## Una debolezza appena scoperta: il "?" diventa l'icona. Restituisce la casella
## (per farla "saltare"), o null se quel nemico non ha quella debolezza.
func reveal(kind: String) -> TextureRect:
	var slot := weakness_row.get_node_or_null(NodePath(kind)) as TextureRect
	if slot:
		slot.texture = _icon(TYPE_ICONS[kind])
	return slot


func _icon(index: int) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = icons
	atlas.region = Rect2(index * 16, 0, 16, 16)
	return atlas
