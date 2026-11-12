## Test automatico: parla con il Saggio e con il cartello, controlla la finestra di dialogo,
## la polvere della corsa e i passi.
##
## Uso (dalla cartella let's-learn-godot):
##   <Godot.exe> --path . -s ../tools/test_dialogo.gd -- <cartella_screenshot>
##
## Si apre una finestra per qualche secondo, poi si chiude da sola.
extends SceneTree

var out_dir := "user://screenshots/"
var main: Node
var subaru: CharacterBody2D
var npc: Node2D
var sign_post: Area2D   # non "Interactable": negli script -s gli autoload non esistono ancora quando si compila
var dialogue: CanvasLayer
var errors := 0


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		out_dir = args[0]
	DirAccess.make_dir_recursive_absolute(out_dir)

	main = load("res://world/main.tscn").instantiate()
	root.add_child(main)
	subaru = main.get_node("World/Subaru")
	npc = main.get_node("World/Npc")
	sign_post = main.get_node("World/Sign")
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


## Simula la pressione (e il rilascio) di un'azione, come farebbe un tasto vero.
func press(action: String) -> void:
	for pressed in [true, false]:
		var ev := InputEventAction.new()
		ev.action = action
		ev.pressed = pressed
		Input.parse_input_event(ev)
		await process_frame


## Va avanti nel dialogo finché non si chiude (qualunque sia il numero di frasi).
func finish_dialogue() -> void:
	for i in 20:
		if not dialogue.is_active:
			return
		await press("interact")
		await wait(0.2)


func _run() -> void:
	var prompt: Sprite2D = npc.get_node("Interactable/Prompt")
	await wait(0.3)
	check(not prompt.visible, "lontano dal Saggio la nuvoletta è nascosta")

	# Mettiamo Subaru accanto al Saggio.
	subaru.position = npc.position + Vector2(-34, 8)
	await wait(1.2)
	check(prompt.visible, "vicino al Saggio compare la nuvoletta")
	await shot("01_vicino_al_saggio")

	await press("interact")
	check(dialogue.is_active, "premendo E si apre il dialogo")
	check(subaru.facing == "right", "Subaru si gira verso il Saggio")
	await wait(0.5)
	await shot("02_scrive")
	var text: Label = dialogue.get_node("Box/Panel/Text")
	check(text.visible_characters > 0 and text.visible_characters < text.get_total_character_count(), "il testo compare un po' alla volta")

	await wait(1.5)
	check(dialogue.get_node("Box/Panel/Arrow").visible, "a frase finita compare la freccia")
	await shot("03_frase_completa")

	var before := subaru.position
	Input.action_press("move_left")
	await wait(0.5)
	Input.action_release("move_left")
	check(subaru.position == before, "durante il dialogo Subaru non si muove")

	# Seconda frase: premere durante la scrittura la completa subito.
	await press("interact")
	await wait(0.2)
	await press("interact")
	check(text.visible_characters == -1, "premere durante la scrittura mostra tutta la frase")

	# Avanti fino all'ultima frase (sono 4: ne abbiamo viste 2), poi chiudi.
	for i in 2:
		await press("interact")
		await wait(2.5)
	await press("interact")
	await wait(0.4)
	check(not dialogue.is_active, "dopo l'ultima frase il dialogo si chiude")

	# Seconda conversazione: il Saggio dice altre cose.
	await press("interact")
	await wait(0.1)
	check(text.text.begins_with("Ancora qui?"), "la seconda volta il Saggio dice frasi diverse")
	await finish_dialogue()
	check(not dialogue.is_active, "anche il secondo dialogo si chiude")

	# Il cartello.
	subaru.position = sign_post.position + Vector2(24, 10)
	await wait(1.0)
	check(sign_post.get_node("Prompt").visible, "vicino al cartello compare la nuvoletta")
	await press("interact")
	await wait(1.2)
	check(dialogue.is_active and dialogue.get_node("Box/NameTag/Name").text == "Cartello", "il cartello si può leggere")
	check(subaru.facing == "left", "Subaru si gira verso il cartello")
	await shot("05_cartello")
	await finish_dialogue()

	# Corsa: la polvere deve comparire e i passi devono suonare.
	subaru.position = Vector2(560, 420)
	await wait(0.8)
	var steps_before: int = subaru.step_count
	Input.action_press("run")
	Input.action_press("move_left")
	await wait(0.35)
	check(subaru.get_node("Dust").emitting, "correndo compaiono le nuvolette di polvere")
	await shot("04_polvere")
	await wait(0.4)
	check(subaru.step_count > steps_before, "camminando si sentono i passi")
	Input.action_release("move_left")
	Input.action_release("run")
	await wait(0.2)
	check(not subaru.get_node("Dust").emitting, "da fermo la polvere si spegne")

	print("RISULTATO: ", "tutto ok" if errors == 0 else str(errors) + " errori")
	quit(errors)
