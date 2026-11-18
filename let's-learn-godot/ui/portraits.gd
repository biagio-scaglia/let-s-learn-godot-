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
