extends Node2D
## Script delle scene "livello" (il villaggio, la casa…).
## All'avvio mette il giocatore nel punto d'arrivo scelto da chi ha cambiato scena.


func _ready() -> void:
	# Il menu di pausa si apre solo nelle scene di questo gruppo.
	add_to_group("level")
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return   # es. il villaggio usato come sfondo nella schermata iniziale

	if Game.spawn_position != null:
		# Caricamento di un salvataggio: la posizione esatta.
		player.global_position = Game.spawn_position
		Game.spawn_position = null
	elif Game.spawn_point != "":
		var marker := get_node_or_null("Spawns/" + Game.spawn_point) as Node2D
		if marker == null:
			push_warning("Punto d'arrivo non trovato: " + Game.spawn_point)
			return
		player.global_position = marker.global_position
	else:
		return   # partita nuova: il giocatore resta dov'è nella scena

	if Game.spawn_facing != "" and player.has_method("face"):
		player.face(Game.spawn_facing)
	# La camera deve "saltare" subito sul giocatore, non scivolare dalla vecchia posizione.
	var camera := player.get_node_or_null("Camera2D") as Camera2D
	if camera:
		camera.reset_smoothing.call_deferred()
