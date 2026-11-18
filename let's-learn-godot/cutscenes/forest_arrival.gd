extends Cutscene
## L'arrivo nel Bosco Senza Tempo, all'alba (atto 3). Subaru ed Emilia salgono dal
## sentiero a sud, si guardano intorno, un corvo rompe il silenzio. Poi Emilia
## comincia a seguire Subaru (vedi Follower).

const START := Vector2(598, 1180)
const STOP := Vector2(598, 900)
const EMILIA_OFFSET := Vector2(34, 6)

@onready var crow: AudioStreamPlayer = get_parent().get_node_or_null("Sounds/Crow")


func _ready() -> void:
	var player := get_tree().get_first_node_in_group("player")
	var emilia := get_parent().get_node_or_null("World/Emilia")
	# Solo la prima volta, e non quando si torna qui da un salvataggio o da una morte.
	if player == null or emilia == null or Game.has_flag(FlagKeys.FOREST_ARRIVED) \
			or Game.spawn_point != "" or Game.spawn_position != null:
		queue_free()
		return
	Game.in_cutscene = true
	_play(player, emilia)
