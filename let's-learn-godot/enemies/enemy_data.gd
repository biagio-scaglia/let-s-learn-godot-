class_name EnemyData
extends Resource
## Un tipo di nemico. Ogni nemico è un file .tres in enemies/: si crea dall'editor
## con "Nuova risorsa → EnemyData" e si compila nell'Inspector.
## Il nemico sulla mappa (characters/enemy) e il combattimento (Battle) leggono da qui.

## Il nome che vede il giocatore.
@export var name := ""
## Punti salute.
@export var max_hp := 10
@export var attack := 4
@export var defense := 1
## I punti scudo: ogni colpo su una debolezza ne toglie uno. A zero il nemico è
## "rotto": salta il turno e prende il doppio dei danni (vedi Battle).
@export var shield := 2
## I tipi di colpo che lo indeboliscono: "pugno", "calcio", "ombra".
## All'inizio il giocatore li vede come "?": li scopre colpendo.
@export var weaknesses: Array[String] = []
## L'esperienza che dà quando viene sconfitto.
@export var xp := 5
## Le pose, nell'ordine in cui stanno nel foglio (texture con "frames" celle in fila).
enum Pose { IDLE, IDLE_2, WINDUP, ATTACK, HURT }

## Il suo aspetto: celle quadrate (16x16 o 32x32) in fila, con i piedi in basso.
## Con 5 celle sono le pose di Pose (respiro x2, carica, attacco, colpito);
## con 1 cella il nemico è un'immagine ferma.
@export var texture: Texture2D
