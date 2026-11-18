extends Area2D
## Una porta (o un'uscita): quando il giocatore ci entra, si passa a un'altra scena.

## La scena in cui portare il giocatore.
@export_file("*.tscn") var target_scene := ""
## Il nome del Marker2D (dentro "Spawns" della scena di arrivo) dove farlo comparire.
@export var target_spawn := ""
## Verso dove guarda il giocatore quando arriva.
@export_enum("down", "up", "left", "right") var arrive_facing := "down"
## Grandezza della zona che fa scattare la porta.
@export var size := Vector2(24, 12)
## Se non è vuoto, la porta funziona solo con questo ricordo (es. "guardiano_sconfitto":
## il sentiero dal bosco al villaggio si apre solo dopo il boss).
@export var required_flag := ""


func _ready() -> void:
	# Ogni porta ha la sua forma: la copiamo, altrimenti tutte le porte
	# condividerebbero la stessa risorsa e quindi la stessa grandezza.
	var shape := ($CollisionShape2D.shape as RectangleShape2D).duplicate() as RectangleShape2D
	shape.size = size
	$CollisionShape2D.shape = shape
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or target_scene == "":
		return
	if required_flag != "" and not Game.has_flag(required_flag):
		return
	Game.change_scene(target_scene, target_spawn, arrive_facing)
