extends PanelContainer
## La scheda del personaggio: livello, salute, punti tecnica, attacco, difesa, esperienza, morti.
## Sta nel menu di pausa. Non chiede niente a nessuno: ascolta Stats e si aggiorna.

@onready var level: Label = %Level
@onready var hp_bar: ProgressBar = %HpBar
@onready var hp: Label = %Hp
@onready var sp_bar: ProgressBar = %SpBar
@onready var sp: Label = %Sp
@onready var attack: Label = %Attack
@onready var defense: Label = %Defense
@onready var xp: Label = %Xp
@onready var deaths: Label = %Deaths


func _ready() -> void:
	Stats.changed.connect(refresh)
	# Le morti stanno in Game, che non avvisa: si rilegge ogni volta che la scheda compare.
	visibility_changed.connect(refresh)
	refresh()


func refresh() -> void:
	level.text = tr("Livello %d") % Stats.level
	hp_bar.max_value = Stats.max_hp
	hp_bar.value = Stats.hp
	hp.text = tr("PS %d/%d") % [Stats.hp, Stats.max_hp]
	sp_bar.max_value = Stats.max_sp
	sp_bar.value = Stats.sp
	sp.text = tr("PT %d/%d") % [Stats.sp, Stats.max_sp]
	attack.text = tr("Attacco %d") % Stats.attack
	defense.text = tr("Difesa %d") % Stats.defense
	xp.text = tr("Esp. %d/%d") % [Stats.xp, Stats.xp_to_next()]
	deaths.text = tr("Morti %d") % Game.deaths
