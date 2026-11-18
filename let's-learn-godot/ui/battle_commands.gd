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
## L'ultimate di Subaru ed Emilia (contro un boss, quando è pronta).
signal ultimate_chosen

@onready var menu: Control = %Menu
@onready var attack_button: MenuItem = %Attack
@onready var skills_button: MenuItem = %Skills
@onready var items_button: MenuItem = %Items
@onready var defend_button: MenuItem = %Defend
@onready var flee_button: MenuItem = %Flee
@onready var ultimate_button: MenuItem = %Ultimate
@onready var skill_window: Control = %SkillWindow
@onready var kick_button: MenuItem = %Kick
@onready var shamac_button: MenuItem = %Shamac
@onready var power_button: MenuItem = %PowerPunch
## Le Scaglie di gelo: una magia di Emilia, nel suo turno.
@onready var frost_button: MenuItem = %Frost
## Cristallo infranto: la mossa combinata di Subaru ed Emilia (dopo il primo occhio di pietra).
@onready var shatter_button: MenuItem = %Shatter
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
## Chi sta scegliendo: "hero" (Subaru) o "ally" (Emilia). Cambia voci e PT.
var actor := "hero"
## La mossa del comando Attacca per chi sta scegliendo.
var _attack_id := ""
var _hero_attack := ""
## I PT di Emilia (quelli di Subaru stanno in Stats).
var ally_sp := 0
var _defend_sp := 0


## Collega i bottoni. "attack" è la mossa del comando Attacca.
func setup(skills: Dictionary, attack: String, defend_sp: int) -> void:
	_skills = skills
	_hero_attack = attack
	_attack_id = attack
	_defend_sp = defend_sp
	_skill_buttons = {kick_button: "calcio", shamac_button: "shamac", power_button: "carica", frost_button: "gelo", shatter_button: "cristallo"}
	attack_button.pressed.connect(func(): skill_chosen.emit(_attack_id))
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
		_add_cost_label(button, skills[_skill_buttons[button]])
	for button: MenuItem in _help_for:
		button.focus_entered.connect(show_help.bind(button))


## Chi sceglie adesso. Subaru: le sue mosse, più Cristallo infranto se l'hanno imparato
## (costa PT a tutti e due). Emilia: Dardo di gelo al posto di Attacca, e tra le abilità
## le Scaglie di gelo, pagate con i suoi PT. "emilia_sp" serve anche a Subaru: la mossa
## combinata si può scegliere solo se anche lei ha abbastanza PT.
func set_actor(who: String, emilia_sp := 0, ally_attack := "dardo", ally_defend_sp := 3) -> void:
	actor = who
	ally_sp = emilia_sp
	var is_ally := who == "ally"
	_attack_id = ally_attack if is_ally else _hero_attack
	attack_button.text = _skills[_attack_id].name if is_ally else "Attacca"
	_help_for[attack_button] = _skills[_attack_id].info
	for button: MenuItem in [kick_button, shamac_button, power_button]:
		button.visible = not is_ally
	frost_button.visible = is_ally
	shatter_button.visible = not is_ally and Game.has_flag(FlagKeys.COMBO_UNLOCKED) and Game.emilia_in_party()
	_help_for[skills_button] = "Le magie di Emilia. Costano i suoi PT." if is_ally \
		else "Le tecniche di Subaru. Costano punti tecnica (PT)."
	_help_for[defend_button] = ("Una barriera di ghiaccio: il prossimo colpo a Subaru fa metà danno. Emilia recupera %d PT." % ally_defend_sp) if is_ally \
		else ("Para: il prossimo colpo fa metà danno. Recuperi %d PT." % _defend_sp)
	_help_for[items_button] = "Emilia dà un oggetto a Subaru." if is_ally else "Usa un oggetto dello zaino."


## I PT di chi sta scegliendo.
func current_sp() -> int:
	return ally_sp if actor == "ally" else Stats.sp


## Si può pagare questa mossa? (Per Cristallo infranto pagano in due.)
func can_afford(id: String) -> bool:
	var skill: Dictionary = _skills[id]
	return current_sp() >= skill.cost and ally_sp >= skill.get("ally_cost", 0)


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
		button.modulate = Color.WHITE if can_afford(_skill_buttons[button]) else Color(0.55, 0.55, 0.65)
	skill_window.visible = true
	var first: MenuItem = frost_button if actor == "ally" else kick_button
	first.focus_silently()
	show_help(first)


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


## Il costo in PT, allineato a destra dentro la voce ("4+4 PT" se pagano in due).
func _add_cost_label(button: MenuItem, skill: Dictionary) -> void:
	var label := Label.new()
	label.text = "%d PT" % skill.cost if not skill.has("ally_cost") else "%d+%d PT" % [skill.cost, skill.ally_cost]
	label.theme_type_variation = &"HintLabel"
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(label)
