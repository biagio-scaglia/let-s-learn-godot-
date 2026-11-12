## Test automatico: entra in casa, parla con Lina, esce, e controlla che il Saggio
## si ricordi di averti già parlato (la memoria sopravvive al cambio di scena).
##
## Uso (dalla cartella let's-learn-godot):
##   <Godot.exe> --path . -s ../tools/test_casa.gd -- <cartella_screenshot>
##
## Si apre una finestra per qualche secondo, poi si chiude da sola.
extends SceneTree

var out_dir := "user://screenshots/"
var dialogue: CanvasLayer
var errors := 0


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		out_dir = args[0]
	DirAccess.make_dir_recursive_absolute(out_dir)
	var main: Node = load("res://world/main.tscn").instantiate()
	root.add_child(main)
	current_scene = main   # serve perché change_scene_to_file sappia quale scena sostituire
	dialogue = root.get_node("Dialogue")
	_run.call_deferred()


func wait(sec: float) -> void:
	await create_timer(sec).timeout


func shot(file_name: String) -> void:
	await process_frame
	await process_frame
	root.get_texture().get_image().save_png(out_dir.path_join(file_name + ".png"))
	print("screenshot: ", file_name)


func check(ok: bool, what: String) -> void:
	print(("OK    " if ok else "ERRORE") + "  " + what)
	if not ok:
		errors += 1


func press(action: String) -> void:
	for pressed in [true, false]:
		var ev := InputEventAction.new()
		ev.action = action
		ev.pressed = pressed
		Input.parse_input_event(ev)
		await process_frame


func player() -> CharacterBody2D:
	return get_first_node_in_group("player")


## Va avanti nel dialogo finché non si chiude.
func finish_dialogue() -> void:
	for i in 20:
		if not dialogue.is_active:
			return
		await press("interact")
		await wait(0.15)


## Tiene premuto un tasto finché la scena non cambia (al massimo "limit" secondi).
func walk_until_scene(action: String, scene_name: String, limit := 4.0) -> void:
	Input.action_press(action)
	var t := 0.0
	while current_scene.name != scene_name and t < limit:
		await wait(0.1)
		t += 0.1
	Input.action_release(action)
	await wait(1.0)   # dissolvenza


func _run() -> void:
	await wait(0.6)

	# 1. Parla con il Saggio la prima volta.
	var npc: Node2D = current_scene.get_node("World/Npc")
	player().position = npc.position + Vector2(-34, 8)
	await wait(0.5)
	await press("interact")
	await finish_dialogue()
	check(not dialogue.is_active, "primo dialogo con il Saggio concluso")

	# 2. Vai alla porta di casa e cammina verso l'alto.
	var spawn: Node2D = current_scene.get_node("Spawns/HouseDoor")
	player().position = spawn.position
	await wait(0.5)
	await shot("01_davanti_a_casa")
	await walk_until_scene("move_up", "House")
	check(current_scene.name == "House", "camminando nella porta si entra in casa")
	var entrance: Node2D = current_scene.get_node("Spawns/Entrance")
	check(player().position.distance_to(entrance.position) < 4.0, "Subaru compare all'ingresso")
	check(player().facing == "up", "Subaru guarda verso l'interno")
	await shot("02_dentro_casa")

	# 3. Parla con Lina.
	var lina: Node2D = current_scene.get_node("World/Lina")
	player().position = lina.position + Vector2(-34, 8)
	await wait(0.5)
	await press("interact")
	await wait(1.6)
	check(dialogue.is_active and dialogue.get_node("Box/NameTag/Name").text == "Lina", "si può parlare con Lina")
	await shot("03_lina")
	await finish_dialogue()

	# 4. Il baule.
	var chest: Node2D = current_scene.get_node("World/Chest")
	player().position = chest.position + Vector2(0, 30)
	await wait(0.5)
	await press("interact")
	await wait(0.6)
	check(dialogue.is_active and dialogue.get_node("Box/NameTag/Name").text == "Baule", "il baule si può esaminare")
	await finish_dialogue()

	# 5. Esci camminando verso il basso.
	player().position = entrance.position
	await wait(0.3)
	await walk_until_scene("move_down", "Main")
	check(current_scene.name == "Main", "camminando verso l'uscita si torna al villaggio")
	spawn = current_scene.get_node("Spawns/HouseDoor")
	check(player().position.distance_to(spawn.position) < 4.0, "Subaru ricompare davanti alla porta")
	check(player().facing == "down", "Subaru guarda verso il villaggio")
	await shot("04_uscito")

	# 6. Il Saggio si ricorda di te anche dopo due cambi di scena.
	npc = current_scene.get_node("World/Npc")
	player().position = npc.position + Vector2(-34, 8)
	await wait(0.5)
	await press("interact")
	await wait(0.1)
	var text: Label = dialogue.get_node("Box/Panel/Text")
	check(text.text.begins_with("Ancora qui?"), "il Saggio si ricorda di te dopo essere entrato e uscito")
	await finish_dialogue()

	print("RISULTATO: ", "tutto ok" if errors == 0 else str(errors) + " errori")
	quit(errors)
