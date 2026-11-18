extends Node
## La regia del Bosco Senza Tempo (atto 3, pezzo 2): ascolta gli occhi di pietra.
## - Ogni occhio chiuso spegne un bagliore nella nebbia, con un raggio che vola fin lì.
## - Al primo occhio chiuso Emilia insegna a Subaru a chiamarla in battaglia:
##   la mossa "Scaglie di gelo" (ricordo gelo_sbloccato).
## - Al terzo, la nebbia si dissolve e la radura è aperta.

@export var fog_gate: FogGate
## Il colore della scia che va dall'occhio di pietra alla nebbia.
@export var beam_color := Color(0.75, 0.45, 1.0)

const ICE_ICON_INDEX := 6   # il fiocco di neve in battle_icons.png


func _ready() -> void:
	for eye in get_tree().get_nodes_in_group("stone_eyes"):
		eye.closed.connect(_on_eye_closed.bind(eye))


func _on_eye_closed(id: String, eye: StoneEye) -> void:
	Game.in_cutscene = true
	if is_instance_valid(fog_gate):
		await _send_beam(eye.global_position + Vector2(0, -34), fog_gate.eye_position(id))
		fog_gate.close_eye(id)
	await get_tree().create_timer(0.5).timeout
	if not Game.has_flag(FlagKeys.ICE_UNLOCKED):
		await _teach_frost()
	var count := FlagKeys.eyes_closed_count()
	if count == FlagKeys.STONE_EYES.size():
		await _open_the_way()
	else:
		Dialogue.start("Emilia", ["Uno in meno. Ne restano %d." % (FlagKeys.STONE_EYES.size() - count)])
		await Dialogue.finished
	Game.in_cutscene = false
