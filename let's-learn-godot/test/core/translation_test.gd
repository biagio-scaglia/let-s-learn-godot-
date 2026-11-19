# La traduzione è completa? Ogni frase che il giocatore può vedere deve avere la sua
# versione inglese in locale/en.po. Se aggiungi un testo al gioco e questo test fallisce,
# aggiungi la traduzione a en.po (msgid = la frase italiana, msgstr = l'inglese).
extends GdUnitTestSuite

const PO := "res://locale/en.po"
## Testi che restano uguali in tutte le lingue: nomi, numeri, segnaposto, sigle.
const SAME_IN_ALL := [
	"Emilia", "Subaru", "Lina", "Erbalta", "Shamac", "Natsuki Subaru", "Biagio Scaglia",
	"Kenney (CC0)", "bart (CC0)", "Tiny Town, Tiny Dungeon, Particle Pack",
	"Sci-fi Sounds, Interface Sounds", "Heartbeat sounds", "KenPixel High Square",
	"Godot Engine 4.7", "gdUnit4 - Dialogue Manager - Phantom Camera - Beehave",
	"(c) Tappei Nagatsuki, Kadokawa", "English", "Italiano", "Volume", "???", "...",
	# Segnaposto nelle scene, sostituiti dal codice prima di essere visti:
	"Testo di prova", "Nome", "Lv 1", "Pozione   x2", "Esperienza  +10", "Livello 1",
	"PS 20/20", "PT 10/10", "Attacco 5", "Difesa 2", "Esp. 0/10", "Morti 0", "Morte n. 1",
	"Hai trovato: Chiave", "Un pugno. Colpo di tipo pugno.", "< English >", "< Normale >",
	"Villaggio di Erbalta\n19/11 10:30", "v1.1",
]
## Cartelle dove stanno le cose che il giocatore vede.
const DIRS := ["res://core", "res://characters", "res://cutscenes", "res://enemies",
	"res://interactables", "res://items", "res://quests", "res://ui", "res://world"]
## Parole che in una frase inglese vogliono dire "qui è rimasto dell'italiano".
const ITALIAN_WORDS := [" il ", " della ", " delle ", " che ", " non ", " sono ", " per ",
	" una ", " gli ", " nel ", " con ", " è ", " ancora ", " anche "]

var _ids := {}


func before() -> void:
	var po := FileAccess.get_file_as_string(PO)
	var re := RegEx.create_from_string('msgid "(.*)"\\nmsgstr "(.*)"')
	for m in re.search_all(po):
		_ids[_unescape(m.get_string(1))] = _unescape(m.get_string(2))


func _unescape(s: String) -> String:
	return s.replace("\\n", "\n").replace("\\\"", "\"").replace("\\\\", "\\")


func _missing(texts: Array) -> Array:
	var out := []
	for t in texts:
		var text := str(t)
		if text.strip_edges().is_empty() or text in SAME_IN_ALL or _ids.has(text):
			continue
		if text.to_lower() == text.to_upper():
			continue   # niente lettere: numeri come "20/20" o "80%"
		out.append(text)
	return out


func _files(ext: String) -> Array:
	var out := []
	for dir in DIRS:
		_collect(dir, ext, out)
	return out


func _collect(dir: String, ext: String, out: Array) -> void:
	for f in DirAccess.get_files_at(dir):
		if f.ends_with(ext):
			out.append(dir.path_join(f))
	for d in DirAccess.get_directories_at(dir):
		_collect(dir.path_join(d), ext, out)


# ---------- I dati ----------

func test_nemici_e_oggetti() -> void:
	var texts := []
	for path in _files(".tres"):
		var res := load(path)
		if res is EnemyData:
			texts.append(res.name)
		elif res is Item:
			texts.append_array([res.name, res.description])
	assert_array(_missing(texts)).is_empty()


func test_abilita() -> void:
	var texts := []
	for skill: Dictionary in preload("res://ui/battle.gd").SKILLS.values():
		texts.append_array([skill.name, skill.info])
	texts.append(preload("res://ui/battle.gd").ULTIMATE_NAME)
	assert_array(_missing(texts)).is_empty()


func test_libri_della_galleria() -> void:
	var texts := []
	for book: Dictionary in GalleryBooks.CHARACTERS + GalleryBooks.MONSTERS:
		texts.append(book.get("name", ""))
		texts.append(book.get("role", ""))
		texts.append_array(book.get("pages", []))
	texts.append_array(GalleryBooks.HIT_NAMES.values())
	for quips: Array in Exhibit.QUIPS.values():
		for lines: Array in quips:
			texts.append_array(lines)
	assert_array(_missing(texts)).is_empty()


func test_obiettivi_e_opzioni() -> void:
	var texts := []
	for value in Objective.new().get_script().get_script_constant_map().values():
		if value is String:
			texts.append(value)
	texts.append_array(Settings.TEXT_SPEED_NAMES)
	assert_array(_missing(texts)).is_empty()


# ---------- Le scene ----------

## Ogni text, lines, repeat_lines, speaker, npc_name scritto nelle scene.
func test_ogni_testo_delle_scene() -> void:
	var prop := RegEx.create_from_string('^(text|speaker|npc_name|placeholder_text|tooltip_text) = "((?:[^"\\\\]|\\\\.)*)"')
	var array := RegEx.create_from_string('^(lines|repeat_lines) = PackedStringArray\\((.*)\\)$')
	var item := RegEx.create_from_string('"((?:[^"\\\\]|\\\\.)*)"')
	var missing := []
	for path in _files(".tscn"):
		var source := FileAccess.get_file_as_string(path)
		for line in source.split("\n"):
			var m := prop.search(line)
			if m:
				for t in _missing([_unescape(m.get_string(2))]):
					missing.append("%s: %s" % [path, t])
			m = array.search(line)
			if m:
				for s in item.search_all(m.get_string(2)):
					for t in _missing([_unescape(s.get_string(1))]):
						missing.append("%s: %s" % [path, t])
	assert_array(missing).is_empty()


# ---------- Gli script ----------

## Le frasi scritte negli script: tutte le stringhe con almeno due parole e una
## lettera minuscola (cioè frasi, non nomi di nodi o chiavi) devono essere tradotte.
## Le eccezioni sono i commenti, i messaggi per lo sviluppatore e i testi tecnici.
func test_ogni_frase_degli_script() -> void:
	var literal := RegEx.create_from_string('"((?:[^"\\\\\\n]|\\\\.)*)"')
	var technical := RegEx.create_from_string('^[%0-9 .:/\\\\n+x()dsDS<>-]*$')
	var missing := []
	for path in _files(".gd"):
		var lines := FileAccess.get_file_as_string(path).split("\n")
		for i in lines.size():
			var line := lines[i].strip_edges()
			line = _without_comment(line)
			if line.begins_with("#") or line.begins_with("assert(") or line.begins_with("push_") \
					or line.begins_with("print") or "res://" in line or "user://" in line:
				continue
			for m in literal.search_all(line):
				var text := _unescape(m.get_string(1))
				if text.count(" ") < 1 or text.to_lower() == text.to_upper():
					continue
				if technical.search(text):
					continue
				for t in _missing([text]):
					missing.append("%s:%d: %s" % [path, i + 1, t])
	assert_array(missing).is_empty()


## La riga senza il commento finale: il primo # che non sta dentro una stringa.
func _without_comment(line: String) -> String:
	var in_string := false
	var i := 0
	while i < line.length():
		var c := line[i]
		if in_string and c == "\\":
			i += 2
			continue
		if c == "\"":
			in_string = not in_string
		elif c == "#" and not in_string:
			return line.left(i)
		i += 1
	return line


# ---------- Le traduzioni ----------

## Nessuna frase inglese ha dentro parole italiane dimenticate.
func test_l_inglese_non_ha_parole_italiane() -> void:
	var suspicious := []
	for it: String in _ids:
		var en: String = " " + _ids[it].to_lower() + " "
		for word: String in ITALIAN_WORDS:
			if word in en:
				suspicious.append("%s -> %s" % [it, _ids[it]])
				break
	assert_array(suspicious).is_empty()
