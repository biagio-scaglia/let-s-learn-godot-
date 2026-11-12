## Test automatico: avvia la mappa, simula i tasti e salva degli screenshot.
##
## Uso (dalla cartella let's-learn-godot):
##   <Godot.exe> --path . -s ../tools/test_corsa.gd -- <cartella_screenshot>
##
## Si apre una finestra per qualche secondo, poi si chiude da sola.
extends SceneTree

var out_dir := "user://screenshots/"
var main: Node
var subaru: CharacterBody2D


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		out_dir = args[0].path_join("")
	DirAccess.make_dir_recursive_absolute(out_dir)

	main = load("res://world/main.tscn").instantiate()
	root.add_child(main)
	subaru = main.get_node("World/Subaru")
	print("celle terreno: ", main.get_node("Ground").get_used_cells().size())
	print("celle oggetti: ", main.get_node("World/Objects").get_used_cells().size())
	_run.call_deferred()


func wait(sec: float) -> void:
	await create_timer(sec).timeout


func shot(file_name: String) -> void:
	await process_frame
	await process_frame
	root.get_texture().get_image().save_png(out_dir.path_join(file_name + ".png"))
	var sprite: AnimatedSprite2D = subaru.get_node("AnimatedSprite2D")
	print(file_name, ": pos=", subaru.position.round(), " anim=", sprite.animation, " speed_scale=", sprite.speed_scale)


func _run() -> void:
	await wait(0.5)
	await shot("01_fermo")

	var p0 := subaru.position
	Input.action_press("move_right")
	await wait(1.0)
	print("camminata: ~", round(subaru.position.x - p0.x), " px/s")
	await shot("02_cammina")

	Input.action_press("run")
	var p1 := subaru.position
	await wait(1.0)
	print("corsa: ~", round(subaru.position.x - p1.x), " px/s")
	await shot("03_corre")
	Input.action_release("run")
	Input.action_release("move_right")

	# Cammina verso gli alberi del bordo: deve fermarsi.
	Input.action_press("move_up")
	await wait(4.0)
	Input.action_release("move_up")
	print("fermo a y=", round(subaru.position.y), " (il muro del bordo finisce a y=64)")
	await shot("04_contro_gli_alberi")
	quit()
