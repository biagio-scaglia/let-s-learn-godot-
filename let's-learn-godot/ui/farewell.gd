extends Node
## Il congedo. È un autoload chiamato "Farewell".
##
## Quando chiudi il gioco (la X della finestra, Alt+F4, oppure "Esci" nei menu e nel
## game over) la finestra del gioco si riduce a icona e sul desktop, FUORI dal gioco,
## compare una finestra di sistema: "Vuoi davvero uscire?", Sì / No. Sembra normale.
## Poi si corrompe: il titolo diventa "???" e la domanda si riscrive col tuo nome.
##
## - "No" (o Esc): "Bene. Resta con me." e si torna al gioco, com'era.
## - "Sì": la finestra si strappa, dal buio sale una figura con gli occhi viola e ti
##   saluta con una frase che dipende da te (ora, morti, quanto hai giocato…).
## - Se non rispondi, decide lei.
##
## Il nome è quello con cui sei entrato nel computer (la variabile USERNAME): si legge
## solo qui, sul tuo PC, e non va da nessuna parte.
##
##     Farewell.leave()   # al posto di get_tree().quit()

## Emesso alla fine: true se il gioco sta per chiudersi, false se si resta.
signal finished(quitting: bool)

const WATCHER := preload("res://assets/effects/watcher.png")
const WARNING := preload("res://assets/ui/dialog_warning.png")
const GLITCH := preload("res://effects/glitch.gdshader")
const FONT := preload("res://assets/fonts/kenpixel_high_square.ttf")
const HEARTBEAT := preload("res://assets/heartbeat_bart/heartbeat_slow.wav")

## La finestra: piccola risoluzione, ingrandita due volte (pixel art).
const VIEW := Vector2i(300, 140)
const ZOOM := 2
const TITLE := "Erbalta"
const QUESTION := "Vuoi davvero uscire da Erbalta?"

## True: una finestra vera del sistema, fuori dal gioco. False: dentro il gioco
## (serve ai test, che non possono aprire finestre sul desktop).
var separate_window := true
## Cosa fare per chiudere davvero. I test la cambiano per non chiudere tutto.
var quit_action := func() -> void: get_tree().quit()
## Quanto durano le pause (1 = normale). I test la abbassano.
var speed := 1.0
## Quanti secondi aspetta una risposta, dopo essersi corrotta, prima di decidere lei.
var patience := 9.0
## True mentre la finestra è aperta: un secondo clic sulla X non rifà tutto.
var leaving := false
## Il tuo nome, preso dal computer.
var user_name := ""

## I pezzi della finestra (pubblici per i test).
var window: Window
var title_label: Label
var message: Label
var yes_button: Button
var no_button: Button
var goodbye: Label

## "yes", "no", oppure "" finché non scegli.
var _choice := ""
var _screen: SubViewportContainer
var _void: ColorRect
var _figure: Sprite2D
var _glow: TextureRect
var _heartbeat: AudioStreamPlayer
## Come stava la finestra del gioco prima di sparire (finestra, schermo intero…).
var _previous_mode := Window.MODE_WINDOWED


func _ready() -> void:
	# Funziona anche col gioco in pausa (il menu di pausa ha "Esci").
	process_mode = Node.PROCESS_MODE_ALWAYS
	# La X della finestra non chiude più subito: arriva una notifica, e decidiamo noi.
	get_tree().auto_accept_quit = false
	_heartbeat = AudioStreamPlayer.new()
	_heartbeat.stream = HEARTBEAT
	_heartbeat.volume_db = -6.0
	add_child(_heartbeat)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		# Questa notifica arriva a tutti i nodi, uno dopo l'altro: mentre gira non si
		# possono aggiungere nodi (la finestra). Allora leave() parte un istante dopo.
		leave.call_deferred()


# ---------- Le parti "pure": niente finestre, facili da provare ----------

## Da "biagio.scaglia" (o "biagio_scaglia", "BIAGIO") a "Biagio".
static func name_from_login(login: String) -> String:
	var first := login.strip_edges()
	for separator in [".", "_", "-", " ", "@"]:
		first = first.get_slice(separator, 0)
	if first.is_empty():
		return "straniero"
	return first.left(1).to_upper() + first.substr(1).to_lower()


## La frase d'addio. Sceglie la più "personale" che può.
static func goodbye_line(who: String, deaths: int, hour: int, minute: int, minutes_played: int, in_game_over: bool) -> String:
	if in_game_over:
		return "Scappi proprio adesso, %s?" % who
	if hour < 5:
		return "Sono le %d:%02d, %s. Dovresti dormire." % [hour, minute, who]
	if minutes_played < 2:
		return "Te ne vai già, %s?" % who
	if deaths == 1:
		return "Sei morto una volta. Tornerai, %s." % who
	if deaths > 1:
		return "Sei morto %d volte. Tornerai, %s." % [deaths, who]
	return "Ci rivedremo, %s." % who


# ---------- Il congedo ----------

## Esci dal gioco, con il congedo. Si può aspettare: dice se si chiude davvero.
func leave() -> bool:
	if leaving:
		return false
	leaving = true
	_choice = ""
	var login := OS.get_environment("USERNAME")
	if login.is_empty():
		login = OS.get_environment("USER")
	user_name = name_from_login(login)
	_open_window()
	if separate_window:
		# Il gioco sparisce (ridotto a icona: Godot non lascia nascondere la finestra
		# principale) e resta solo lei, sul desktop.
		_previous_mode = get_tree().root.mode
		get_tree().root.mode = Window.MODE_MINIMIZED

	# 1. Una finestra normale, con il suo "tic".
	Sfx.play(Sfx.CONFIRM)
	_set_glitch(0.0)
	await _wait_for_choice(1.8)

	# 2. Se non hai ancora scelto, si corrompe e ti chiama per nome.
	if _choice.is_empty():
		await _corrupt()
		await _wait_for_choice(patience)

	var quitting := _choice != "no"
	if quitting:
		await _goodbye(_choice.is_empty())
	else:
		await _stay()
	finished.emit(quitting)
	return quitting


## Aspetta che tu scelga, al massimo "seconds" secondi.
func _wait_for_choice(seconds: float) -> void:
	var end := Time.get_ticks_msec() + int(seconds * speed * 1000.0)
	while _choice.is_empty() and Time.get_ticks_msec() < end:
		await get_tree().process_frame


## La tua risposta: "yes" o "no". Conta solo la prima.
func choose(answer: String) -> void:
	if _choice.is_empty():
		_choice = answer
		Sfx.play(Sfx.CONFIRM if answer == "yes" else Sfx.BACK)


## Il titolo diventa "???", la domanda si cancella e si riscrive con il tuo nome.
func _corrupt() -> void:
	Sfx.play(Sfx.SHAMAC)
	_heartbeat.play()
	title_label.text = "???"
	var t := create_tween()
	t.tween_method(_set_glitch, 0.9, 0.2, 0.4 * speed)
	t.tween_property(message, "visible_ratio", 0.0, 0.3 * speed)
	t.tween_callback(func() -> void: message.text = "%s... sei sicuro?" % user_name)
	t.tween_property(message, "visible_ratio", 1.0, 0.9 * speed)
	_flicker_no()
	await t.finished


## Ogni tanto, per un istante, "No" diventa "Sì".
func _flicker_no() -> void:
	while is_instance_valid(no_button) and _choice.is_empty():
		await get_tree().create_timer(0.7 * speed).timeout
		if not is_instance_valid(no_button) or not _choice.is_empty():
			return
		no_button.text = "Sì"
		_spike()
		await get_tree().create_timer(0.08).timeout
		if is_instance_valid(no_button):
			no_button.text = "No"


## Hai detto no: si calma, ti lascia restare, e il gioco torna com'era.
func _stay() -> void:
	message.text = "...Bene. Resta con me, %s." % user_name
	message.visible_ratio = 1.0
	yes_button.disabled = true
	no_button.disabled = true
	var calm := create_tween()
	calm.tween_method(_set_glitch, 0.6, 0.0, 0.5 * speed)
	await calm.finished
	await _wait(1.2)
	await _switch_off()
	_close_window()
	if separate_window:
		get_tree().root.mode = _previous_mode
		get_tree().root.grab_focus()
	leaving = false


## Hai detto sì (o non hai risposto): la finestra si strappa, sale lei, ti saluta.
func _goodbye(no_answer: bool) -> void:
	yes_button.disabled = true
	no_button.disabled = true
	if no_answer:
		message.text = "Non rispondi? Allora decido io."
		message.visible_ratio = 1.0
		await _wait(1.2)
	Sfx.play(Sfx.SHAMAC)
	_heartbeat.play()
	title_label.text = "???"
	var tear := create_tween()
	tear.tween_method(_set_glitch, 1.0, 0.25, 0.6 * speed)
	tear.parallel().tween_property(_void, "color:a", 1.0, 0.35 * speed)
	tear.parallel().tween_property(_glow, "modulate:a", 1.0, 0.6 * speed).set_delay(0.15 * speed)
	tear.parallel().tween_property(_figure, "modulate:a", 1.0, 0.6 * speed).set_delay(0.15 * speed)
	tear.parallel().tween_property(_figure, "position:y", _figure.position.y - 12.0, 0.8 * speed).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tear.finished
	var time := Time.get_time_dict_from_system()
	goodbye.text = goodbye_line(user_name, Game.deaths, time.hour, time.minute,
		int(Time.get_ticks_msec() / 60000.0), ReturnByDeath.is_active)
	goodbye.visible = true
	goodbye.visible_ratio = 0.0
	var typing := create_tween()
	typing.tween_property(goodbye, "visible_ratio", 1.0, 1.0 * speed)
	await typing.finished
	await _wait(1.6)
	await _switch_off()
	quit_action.call()


## Uno strappo, poi l'immagine si schiaccia in una riga e in un punto, come un
## vecchio televisore che si spegne.
func _switch_off() -> void:
	Sfx.play(Sfx.SHAMAC)
	var off := create_tween()
	off.tween_method(_set_glitch, 0.3, 1.0, 0.2 * speed)
	off.tween_property(_screen, "scale:y", 0.02, 0.12 * speed).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	off.parallel().tween_property(_screen, "modulate", Color(3, 3, 3), 0.12 * speed)
	off.tween_property(_screen, "scale:x", 0.0, 0.1 * speed)
	await off.finished
	await _wait(0.15)


# ---------- La finestra ----------

## Una finestra "di sistema" disegnata da noi, in un SubViewport. Il contenitore che
## la mostra ha lo shader del glitch (così si rompe tutto insieme) e le passa il mouse
## e la tastiera (così i bottoni funzionano).
func _open_window() -> void:
	window = Window.new()
	window.title = TITLE
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
		var root := get_tree().root
		window.position = root.position + root.size / 2 - window.size / 2
	# Chiudere lei, o premere Esc, vuol dire "No".
	window.close_requested.connect(choose.bind("no"))
	window.window_input.connect(_on_window_input)

	_screen = SubViewportContainer.new()
	_screen.size = Vector2(VIEW)
	_screen.stretch = true
	_screen.pivot_offset = Vector2(VIEW) / 2.0
	_screen.focus_mode = Control.FOCUS_ALL
	var mat := ShaderMaterial.new()
	mat.shader = GLITCH
	_screen.material = mat
	_screen.gui_input.connect(_on_screen_input)
	window.add_child(_screen)
	var view := SubViewport.new()
	view.size = VIEW
	view.transparent_bg = true
	view.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	_screen.add_child(view)
	_build_dialog(view)
	add_child(window)
	_screen.grab_focus()
	no_button.grab_focus()   # la risposta già selezionata è la più prudente


func _build_dialog(view: SubViewport) -> void:
	var dialog := Control.new()
	dialog.size = Vector2(VIEW)
	dialog.theme = _dialog_theme()
	view.add_child(dialog)
	# La barra del titolo e il corpo.
	_rect(dialog, Rect2(0, 0, VIEW.x, 20), Color(0.16, 0.2, 0.32))
	_rect(dialog, Rect2(0, 20, VIEW.x, VIEW.y - 20), Color(0.86, 0.86, 0.89))
	_rect(dialog, Rect2(0, VIEW.y - 1, VIEW.x, 1), Color(0.45, 0.45, 0.5))
	title_label = _label(dialog, TITLE, Rect2(8, 1, 200, 18), Color(0.93, 0.94, 1.0))
	_label(dialog, "x", Rect2(VIEW.x - 18, 0, 12, 18), Color(0.93, 0.94, 1.0))
	var icon := TextureRect.new()
	icon.texture = WARNING
	icon.position = Vector2(18, 40)
	icon.size = Vector2(32, 32)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	dialog.add_child(icon)
	message = _label(dialog, QUESTION, Rect2(64, 36, VIEW.x - 80, 44), Color(0.1, 0.1, 0.14))
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	yes_button = _button(dialog, "Sì", Rect2(VIEW.x - 156, VIEW.y - 34, 66, 24))
	no_button = _button(dialog, "No", Rect2(VIEW.x - 82, VIEW.y - 34, 66, 24))
	yes_button.pressed.connect(choose.bind("yes"))
	no_button.pressed.connect(choose.bind("no"))
	yes_button.focus_neighbor_right = yes_button.get_path_to(no_button)
	no_button.focus_neighbor_left = no_button.get_path_to(yes_button)
	# Il buio e la figura, nascosti finché non servono.
	_void = _rect(dialog, Rect2(0, 20, VIEW.x, VIEW.y - 20), Color(0.02, 0.0, 0.04, 0.0))
	# Dietro di lei un alone viola, se no nel buio non si vedrebbe.
	_glow = TextureRect.new()
	_glow.texture = _glow_texture()
	_glow.position = Vector2(VIEW.x / 2.0 - 75, 14)
	_glow.size = Vector2(150, 116)
	_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_glow.modulate.a = 0.0
	dialog.add_child(_glow)
	_figure = Sprite2D.new()
	_figure.texture = WATCHER
	_figure.position = Vector2(VIEW.x / 2.0, 72)
	_figure.modulate.a = 0.0
	dialog.add_child(_figure)
	goodbye = _label(dialog, "", Rect2(0, VIEW.y - 26, VIEW.x, 20), Color(0.85, 0.65, 1.0))
	goodbye.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	goodbye.add_theme_color_override("font_outline_color", Color(0.05, 0.0, 0.08))
	goodbye.add_theme_constant_override("outline_size", 4)
	goodbye.visible = false


## Un tema "da sistema operativo": bottoni chiari con il bordo, blu quando selezionati.
func _dialog_theme() -> Theme:
	var theme := Theme.new()
	theme.default_font = FONT
	theme.default_font_size = 16
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.95, 0.95, 0.97)
	normal.set_border_width_all(1)
	normal.border_color = Color(0.5, 0.5, 0.56)
	normal.anti_aliasing = false
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.88, 0.92, 1.0)
	var focus := normal.duplicate() as StyleBoxFlat
	focus.draw_center = false
	focus.border_color = Color(0.2, 0.45, 0.9)
	focus.set_border_width_all(2)
	for state in ["normal", "disabled"]:
		theme.set_stylebox(state, "Button", normal)
	theme.set_stylebox("hover", "Button", hover)
	theme.set_stylebox("pressed", "Button", hover)
	theme.set_stylebox("focus", "Button", focus)
	for color_name in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_disabled_color"]:
		theme.set_color(color_name, "Button", Color(0.1, 0.1, 0.14))
	# Il tema del gioco dà ai bottoni un contorno spesso: qui il testo deve essere pulito.
	theme.set_constant("outline_size", "Button", 0)
	return theme


## Un ovale viola sfumato, più chiaro al centro.
func _glow_texture() -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(0.55, 0.2, 0.8, 0.9))
	gradient.set_color(1, Color(0.55, 0.2, 0.8, 0.0))
	var tex := GradientTexture2D.new()
	tex.gradient = gradient
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	return tex


func _rect(parent: Control, area: Rect2, color: Color) -> ColorRect:
	var rect := ColorRect.new()
	rect.position = area.position
	rect.size = area.size
	rect.color = color
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(rect)
	return rect


func _label(parent: Control, text: String, area: Rect2, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.position = area.position
	label.size = area.size
	label.add_theme_color_override("font_color", color)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	parent.add_child(label)
	return label


func _button(parent: Control, text: String, area: Rect2) -> Button:
	var button := Button.new()
	button.text = text
	button.position = area.position
	button.size = area.size
	parent.add_child(button)
	return button


## Il mouse. Il contenitore riceve i clic ma non li passa ai bottoni dentro il
## SubViewport: allora guardiamo noi su quale bottone è caduto. Le coordinate sono
## già quelle piccole (300x140), le stesse dei bottoni.
func _on_screen_input(event: InputEvent) -> void:
	for button: Button in [yes_button, no_button]:
		if button.disabled or not button.get_rect().has_point(event.position if event is InputEventMouse else Vector2(-1, -1)):
			continue
		if event is InputEventMouseMotion and not button.has_focus():
			button.grab_focus()   # passandoci sopra si seleziona
		elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			button.pressed.emit()


func _on_window_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		choose("no")


func _close_window() -> void:
	if is_instance_valid(window):
		window.queue_free()
	window = null


func _set_glitch(value: float) -> void:
	if is_instance_valid(_screen):
		(_screen.material as ShaderMaterial).set_shader_parameter("intensity", value)


## Un istante di glitch forte.
func _spike() -> void:
	create_tween().tween_method(_set_glitch, 0.9, 0.2, 0.2 * speed)


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds * speed).timeout
