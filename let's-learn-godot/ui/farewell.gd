extends Node
## Il congedo. È un autoload chiamato "Farewell".
##
## Quando chiudi il gioco (la X della finestra, Alt+F4, oppure "Esci" nei menu) la
## finestra del gioco sparisce, e sul desktop, FUORI dal gioco, compare una piccola
## finestra senza bordi: una figura d'ombra con gli occhi viola, rotta da glitch,
## che ti chiede "Sei sicuro?". Poi l'immagine collassa come un vecchio televisore
## e il gioco si chiude davvero.
##
##     Farewell.leave()   # al posto di get_tree().quit()

const WATCHER := preload("res://assets/effects/watcher.png")
const GLITCH := preload("res://effects/glitch.gdshader")
const FONT := preload("res://assets/fonts/kenpixel_high_square.ttf")
const HEARTBEAT := preload("res://assets/heartbeat_bart/heartbeat_slow.wav")

## La finestra del congedo: piccola risoluzione, ingrandita tre volte (pixel art).
const VIEW := Vector2i(160, 110)
const ZOOM := 3

## True: una finestra vera del sistema, fuori dal gioco. False: una finestra dentro
## il gioco (serve ai test, che non possono aprire finestre sul desktop).
var separate_window := true
## Cosa fare alla fine. Di solito chiudere; i test la cambiano per non chiudere tutto.
var quit_action := func() -> void: get_tree().quit()
## Quanto durano le pause (1 = normale). I test la abbassano.
var speed := 1.0
## True dal momento in cui si comincia a uscire: un secondo clic sulla X non rifà tutto.
var leaving := false
## La finestra aperta, e il testo dentro (per i test).
var window: Window
var label: Label

var _screen: TextureRect


func _ready() -> void:
	# Funziona anche col gioco in pausa (il menu di pausa ha "Esci").
	process_mode = Node.PROCESS_MODE_ALWAYS
	# La X della finestra non chiude più subito: arriva una notifica, e decidiamo noi.
	get_tree().auto_accept_quit = false


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		# Questa notifica arriva a tutti i nodi, uno dopo l'altro: mentre gira non si
		# possono aggiungere nodi (la finestra). Allora leave() parte un istante dopo.
		leave.call_deferred()


## Esci dal gioco, con il congedo.
func leave() -> void:
	if leaving:
		return
	leaving = true
	_open_window()
	if separate_window:
		# Il gioco sparisce (ridotto a icona: Godot non lascia nascondere la finestra
		# principale) e resta solo lei, sul desktop.
		get_tree().root.mode = Window.MODE_MINIMIZED
	var heartbeat := AudioStreamPlayer.new()
	heartbeat.stream = HEARTBEAT
	heartbeat.volume_db = -6.0
	add_child(heartbeat)

	# Compare a pezzi, poi si calma (ma non del tutto).
	Sfx.play(Sfx.SHAMAC)
	_set_glitch(1.0)
	var t := create_tween()
	t.tween_method(_set_glitch, 1.0, 0.15, 0.4 * speed)
	await t.finished
	heartbeat.play()
	# "Sei sicuro?", lettera per lettera, con qualche scatto in mezzo.
	var typing := create_tween()
	typing.tween_property(label, "visible_ratio", 1.0, 0.9 * speed)
	_spike_at(0.35 * speed)
	_spike_at(0.75 * speed)
	await typing.finished
	await _wait(1.3)
	# Un ultimo strappo, poi lo schermo si spegne: si schiaccia in una riga, poi in un punto.
	Sfx.play(Sfx.SHAMAC)
	var off := create_tween()
	off.tween_method(_set_glitch, 0.2, 1.0, 0.25 * speed)
	off.tween_property(_screen, "scale:y", 0.02, 0.12 * speed).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	off.parallel().tween_property(_screen, "modulate", Color(3, 3, 3), 0.12 * speed)
	off.tween_property(_screen, "scale:x", 0.0, 0.1 * speed)
	await off.finished
	await _wait(0.2)
	quit_action.call()


## Costruisce la finestra: una figura e una scritta disegnate in un SubViewport,
## mostrato da una TextureRect con lo shader del glitch (così si rompono insieme).
func _open_window() -> void:
	window = Window.new()
	window.title = "..."
	window.borderless = true
	window.unresizable = true
	window.always_on_top = true
	window.transparent = true
	window.transparent_bg = true
	window.size = VIEW * ZOOM
	window.content_scale_size = VIEW
	window.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	window.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	if separate_window:
		# Le finestre "figlie" di solito stanno DENTRO quella del gioco: così no.
		get_tree().root.gui_embed_subwindows = false
		window.position = _center_of_game() - window.size / 2
	else:
		window.position = Vector2i.ZERO
	# Se si prova a chiudere anche lei, non succede niente: se ne va da sola.
	window.close_requested.connect(func() -> void: pass)

	var view := SubViewport.new()
	view.size = VIEW
	view.transparent_bg = true
	view.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	window.add_child(view)
	# Dietro, una macchia di buio: si legge su qualsiasi sfondo del desktop.
	var blot := TextureRect.new()
	blot.texture = _dark_blot()
	blot.size = Vector2(VIEW)
	view.add_child(blot)
	var figure := Sprite2D.new()
	figure.texture = WATCHER
	figure.position = Vector2(VIEW.x / 2.0, 40)
	view.add_child(figure)
	label = Label.new()
	label.text = "Sei sicuro?"
	label.visible_ratio = 0.0   # le lettere arrivano dopo, una alla volta
	label.add_theme_font_override("font", FONT)
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(0.85, 0.65, 1.0))
	label.add_theme_color_override("font_outline_color", Color(0.05, 0.0, 0.08))
	label.add_theme_constant_override("outline_size", 4)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(0, 78)
	label.size = Vector2(VIEW.x, 20)
	view.add_child(label)

	_screen = TextureRect.new()
	_screen.texture = view.get_texture()
	_screen.size = Vector2(VIEW)
	_screen.pivot_offset = Vector2(VIEW) / 2.0
	var mat := ShaderMaterial.new()
	mat.shader = GLITCH
	_screen.material = mat
	window.add_child(_screen)
	add_child(window)


## Il centro della finestra del gioco, in coordinate dello schermo.
func _center_of_game() -> Vector2i:
	var root := get_tree().root
	return root.position + root.size / 2


func _set_glitch(value: float) -> void:
	(_screen.material as ShaderMaterial).set_shader_parameter("intensity", value)


## Tra "delay" secondi, un istante di glitch forte.
func _spike_at(delay: float) -> void:
	var t := create_tween()
	t.tween_interval(delay)
	t.tween_method(_set_glitch, 0.9, 0.15, 0.2 * speed)


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds * speed).timeout


## Un ovale sfumato, scuro al centro e trasparente ai bordi.
func _dark_blot() -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(0.02, 0.0, 0.04, 0.9))
	gradient.set_color(1, Color(0.02, 0.0, 0.04, 0.0))
	var tex := GradientTexture2D.new()
	tex.gradient = gradient
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.45)
	tex.fill_to = Vector2(1.0, 0.45)
	tex.width = VIEW.x
	tex.height = VIEW.y
	return tex
