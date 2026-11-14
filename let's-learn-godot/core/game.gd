extends Node
## Lo stato della partita che deve sopravvivere ai cambi di scena. È un autoload chiamato "Game".
##
## Quando si cambia scena, la vecchia viene distrutta con tutti i suoi nodi e le loro
## variabili. Quello che va ricordato (con chi hai parlato, dove comparire…) sta qui.
##
## Il resto ha il suo autoload: lo zaino è Inventory, il salvataggio SaveSystem,
## le opzioni Settings, i suoni Sfx, le statistiche di Subaru Stats.

const TITLE_SCENE := "res://ui/title_screen.tscn"
const FIRST_LEVEL := "res://world/main.tscn"

## Emesso quando cambia qualcosa che l'interfaccia deve sapere: un ricordo,
## una cutscene che comincia o finisce, una partita nuova o ripresa.
## Lo ascolta l'obiettivo in alto a sinistra (Hud).
signal state_changed

## In quale Marker2D (figlio di "Spawns") far comparire il giocatore nella prossima scena.
var spawn_point := ""
## Oppure una posizione esatta (quando si carica un salvataggio). null = non usata.
var spawn_position: Variant = null
## Verso dove deve guardare il giocatore all'arrivo (una costante di Facing, o "").
var spawn_facing := ""
## I ricordi del gioco: con chi hai parlato, oggetti raccolti, bauli aperti…
## Le chiavi sono in FlagKeys.
var flags := {}
## True durante un cambio di scena.
var changing_scene := false
## True durante una scena d'intermezzo (cutscene): il giocatore non comanda, niente menu.
var in_cutscene := false:
	set(value):
		if in_cutscene != value:
			in_cutscene = value
			state_changed.emit()
## Il punto di ritorno del Ritorno dalla Morte: com'era il mondo in quel momento
## (scena, posizione, direzione, ricordi, zaino, statistiche). Vuoto = nessuno.
var checkpoint := {}
## Quante volte Subaru è morto. Il Ritorno NON lo riporta indietro: lui se lo ricorda.
var deaths := 0


func _ready() -> void:
	# Deve funzionare anche a gioco in pausa ("Torna al titolo" dal menu di pausa).
	process_mode = Node.PROCESS_MODE_ALWAYS


# ---------- Ricordi ----------

func has_flag(key: String) -> bool:
	return flags.get(key, false)


func set_flag(key: String, value: Variant = true) -> void:
	flags[key] = value
	state_changed.emit()


## Sostituisce tutti i ricordi (partita nuova, salvataggio, ritorno dalla morte).
func load_flags(data := {}) -> void:
	# duplicate(): una copia, così modificarla non tocca i dati di partenza.
	flags = data.duplicate(true)
	state_changed.emit()


# ---------- Chi può fare cosa ----------

## Il giocatore può muoversi e interagire? No durante un dialogo, un cambio di scena
## o una cutscene.
func player_can_move() -> bool:
	return not changing_scene and not in_cutscene and not Dialogue.is_active


## Si può aprire un menu (pausa, zaino)? Solo in un livello (non nel titolo), quando
## il giocatore potrebbe muoversi e nessun altro menu ha già messo in pausa il gioco.
func can_open_menu() -> bool:
	var scene := get_tree().current_scene
	return scene != null and scene.is_in_group("level") \
		and not get_tree().paused and player_can_move()


# ---------- Partita e scene ----------

## Comincia una partita nuova: dimentica tutto e va al primo livello.
func new_game() -> void:
	load_flags()
	Inventory.reset()
	Stats.reset()
	spawn_position = null
	checkpoint = {}
	deaths = 0
	change_scene(FIRST_LEVEL, "", "", false)


# ---------- Ritorno dalla Morte ----------

## Fissa il punto di ritorno qui e adesso. Lo chiamano la fine dell'intro,
## il salvataggio e "Continua".
func set_checkpoint() -> void:
	var scene := get_tree().current_scene
	var player := get_tree().get_first_node_in_group("player")
	if scene == null or player == null:
		return
	checkpoint = {
		"scene": scene.scene_file_path,
		"position": player.global_position,
		"facing": player.facing,
		# Copie: quello che succede dopo non deve cambiare il punto di ritorno.
		"flags": flags.duplicate(true),
		"inventory": Inventory.items.duplicate(true),
		"stats": Stats.to_dict(),
	}


## Riporta il mondo al punto di ritorno. Si può aspettare (await).
func return_to_checkpoint() -> void:
	if checkpoint.is_empty():
		# Nessun punto di ritorno: si ricomincia dal villaggio, ma la morte resta.
		load_flags({FlagKeys.INTRO_SEEN: true})
		Inventory.reset()
		Stats.heal_fully()
		spawn_position = null
		await change_scene(FIRST_LEVEL, "", "", false)
		return
	load_flags(checkpoint.flags)
	Inventory.reset(checkpoint.inventory)
	# Livello ed esperienza tornano com'erano; ma ci si risveglia in piena salute,
	# altrimenti chi è morto in un combattimento ci ricadrebbe subito.
	Stats.reset(checkpoint.get("stats", Stats.to_dict()))
	Stats.heal_fully()
	spawn_position = checkpoint.position
	await change_scene(checkpoint.scene, "", checkpoint.facing, false)


## Passa a un'altra scena con la dissolvenza, e fa comparire il giocatore in "spawn".
func change_scene(path: String, spawn: String, facing := "", door_sound := true) -> void:
	if changing_scene:
		return
	changing_scene = true
	spawn_point = spawn
	spawn_facing = facing
	if door_sound:
		Sfx.play(Sfx.DOOR)
	await Fade.fade_out()
	get_tree().paused = false
	in_cutscene = false   # la nuova scena, se vuole, ne fa partire un'altra
	get_tree().change_scene_to_file(path)
	# La nuova scena viene aggiunta alla fine del frame: aspettiamo il segnale
	# che arriva quando è nell'albero e pronta (dopo tutti i suoi _ready).
	await get_tree().scene_changed
	# Se la nuova scena è partita con una cutscene, è lei a decidere quando togliere il nero.
	if not in_cutscene:
		await Fade.fade_in()
	# Solo ora: mentre lo schermo si schiarisce il giocatore resta fermo.
	changing_scene = false
