extends PanelContainer
## La scheda del personaggio: livello, salute, attacco, difesa, esperienza, morti.
## Sta nel menu di pausa. Non chiede niente a nessuno: ascolta Stats e si aggiorna.

@onready var level: Label = %Level
@onready var hp_bar: ProgressBar = %HpBar
@onready var hp: Label = %Hp
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
	level.text = "Livello %d" % Stats.level
	hp_bar.max_value = Stats.max_hp
	hp_bar.value = Stats.hp
	hp.text = "PS %d/%d" % [Stats.hp, Stats.max_hp]
	attack.text = "Attacco %d" % Stats.attack
	defense.text = "Difesa %d" % Stats.defense
	xp.text = "Esp. %d/%d" % [Stats.xp, Stats.xp_to_next()]
	deaths.text = "Morti %d" % Game.deaths
