class_name Portraits
## I ritratti dei personaggi: un pezzo (AtlasTexture) del loro foglio di sprite,
## fermo e rivolto verso di noi. Li usano i titoli di coda e la Galleria.
##
## Solo metodi "static": non serve un nodo, si chiama Portraits.of("emilia").

const SUBARU_SHEET := preload("res://characters/subaru/subaru_sheet.png")
const EMILIA_CHARSET := preload("res://characters/emilia/emilia_charset.png")
const DUNGEON := preload("res://assets/kenney_tiny_dungeon/tilemap_packed.png")
## I personaggi di Tiny Dungeon: quale casella del foglio (come "sprite_tile" dei PNG).
const DUNGEON_TILES := {"saggio": 84, "lina": 99, "archivista": 100}


## Il ritratto di un personaggio ("subaru", "emilia", "saggio"...) o di un nemico
## (il nome del suo file in enemies/, es. "melma"). null se non esiste.
static func of(id: String) -> Texture2D:
	match id:
		"subaru":
			return _region(SUBARU_SHEET, Rect2(0, 0, 32, 48))
		"emilia":
			# Charset RPG Maker 4x4: la prima cella è "fermo, verso il basso".
			return _region(EMILIA_CHARSET, Rect2(Vector2.ZERO, EMILIA_CHARSET.get_size() / 4.0))
	if DUNGEON_TILES.has(id):
		var tile: int = DUNGEON_TILES[id]
		return _region(DUNGEON, Rect2((tile % 12) * 16, floori(tile / 12.0) * 16, 16, 16))
	var enemy := enemy_data(id)
	return enemy.portrait() if enemy else null


## I dati di un nemico dal nome del file (es. "spettro" → enemies/spettro.tres).
static func enemy_data(id: String) -> EnemyData:
	var path := "res://enemies/%s.tres" % id
	return load(path) as EnemyData if ResourceLoader.exists(path) else null
