class_name BattleCommands
extends PanelContainer
## I comandi del combattimento (Attacca, Abilità, Oggetti, Difendi, Fuggi), i due
## sottomenu e la descrizione in basso. Non fa le mosse: quando scegli qualcosa
## emette un segnale, e battle.gd decide cosa succede.

## Hai scelto una mossa (anche "Attacca": è il pugno). "id" è una chiave di SKILLS.
signal skill_chosen(id: String)
signal potion_chosen
signal defend_chosen
signal flee_chosen

@onready var menu: Control = %Menu
@onready var attack_button: MenuItem = %Attack
@onready var skills_button: MenuItem = %Skills
@onready var items_button: MenuItem = %Items
@onready var defend_button: MenuItem = %Defend
@onready var flee_button: MenuItem = %Flee
@onready var skill_window: Control = %SkillWindow
@onready var kick_button: MenuItem = %Kick
@onready var shamac_button: MenuItem = %Shamac
@onready var power_button: MenuItem = %PowerPunch
## La mossa con Emilia: c'è solo dopo che lei l'ha insegnata (atto 3).
@onready var frost_button: MenuItem = %Frost
@onready var item_window: Control = %ItemWindow
@onready var potion_button: MenuItem = %Potion
@onready var help: Control = %Help
@onready var help_text: Label = %HelpText

## Le mosse (nome, costo, descrizione…), le passa battle.gd con setup().
var _skills := {}
## Quale mossa fa ogni bottone del sottomenu Abilità.
var _skill_buttons := {}
## La descrizione di ogni voce, mostrata in basso quando è selezionata.
var _help_for := {}


## Collega i bottoni. "attack" è la mossa del comando Attacca.
func setup(skills: Dictionary, attack: String, defend_sp: int) -> void:
	_skills = skills
	_skill_buttons = {kick_button: "calcio", shamac_button: "shamac", power_button: "carica"}
	attack_button.pressed.connect(skill_chosen.emit.bind(attack))
	for button: MenuItem in _skill_buttons:
		button.pressed.connect(skill_chosen.emit.bind(_skill_buttons[button]))
	skills_button.pressed.connect(open_skills)
	items_button.pressed.connect(open_items)
	defend_button.pressed.connect(defend_chosen.emit)
	flee_button.pressed.connect(flee_chosen.emit)
	potion_button.pressed.connect(potion_chosen.emit)
	_help_for = {
		attack_button: skills[attack].info,
		skills_button: "Le tecniche di Subaru. Costano punti tecnica (PT).",
		items_button: "Usa un oggetto dello zaino.",
		defend_button: "Para: il prossimo colpo fa metà danno. Recuperi %d PT." % defend_sp,
		flee_button: "Prova a scappare. Non sempre ci si riesce.",
		potion_button: "",
	}
	for button: MenuItem in _skill_buttons:
		_help_for[button] = skills[_skill_buttons[button]].info
		_add_cost_label(button, skills[_skill_buttons[button]].cost)
	for button: MenuItem in _help_for:
		button.focus_entered.connect(show_help.bind(button))


## Mostra (o nasconde) i comandi e la descrizione. Mostrandoli, si parte da Attacca.
func show_menu(shown: bool) -> void:
	visible = shown
	menu.visible = shown
	help.visible = shown
	if shown:
		attack_button.focus_silently()
		show_help(attack_button)


func show_help(button: MenuItem) -> void:
	help_text.text = _help_for.get(button, "")


## Una frase al posto della descrizione (per esempio "Non hai abbastanza PT.").
func say(text: String) -> void:
	help_text.text = text


## Il sottomenu "Abilità". Le mosse che costano troppo sono più scure.
func open_skills() -> void:
	for button: MenuItem in _skill_buttons:
		var cost: int = _skills[_skill_buttons[button]].cost
		button.modulate = Color.WHITE if Stats.sp >= cost else Color(0.55, 0.55, 0.65)
	skill_window.visible = true
	kick_button.focus_silently()
	show_help(kick_button)


## Il sottomenu "Oggetti". Esc torna ai comandi.
func open_items() -> void:
	var count: int = Inventory.items.get(Inventory.POTION, 0)
	potion_button.text = "Pozione   x%d" % count
	_help_for[potion_button] = "Rimette %d PS." % Inventory.item(Inventory.POTION).heal if count > 0 else "Non ne hai."
	item_window.visible = true
	potion_button.focus_silently()
	show_help(potion_button)


func close_submenus() -> void:
	item_window.visible = false
	skill_window.visible = false


## Esc in un sottomenu: lo chiude e torna alla sua voce dei comandi.
func _unhandled_input(event: InputEvent) -> void:
	if not (item_window.visible or skill_window.visible) or not event.is_action_pressed("ui_cancel"):
		return
	get_viewport().set_input_as_handled()
	var back_to := items_button if item_window.visible else skills_button
	close_submenus()
	Sfx.play(Sfx.BACK)
	back_to.focus_silently()
	show_help(back_to)


## Il costo in PT, allineato a destra dentro la voce.
func _add_cost_label(button: MenuItem, cost: int) -> void:
	var label := Label.new()
	label.text = "%d PT" % cost
	label.theme_type_variation = &"HintLabel"
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(label)
