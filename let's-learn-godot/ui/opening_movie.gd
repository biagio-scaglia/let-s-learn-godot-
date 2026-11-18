extends Node2D
## Il filmato iniziale, prima del titolo. Quattro "inquadrature" fatte con le scene
## vere del gioco (il castello, il villaggio, il bosco) senza Subaru, con una camera
## che scorre, le bande nere e una voce narrante scritta. Poi l'occhio, e il titolo.
##
## I tempi seguono la musica (prologue_theme.wav): notte 0-7 s, villaggio 7-17.5,
## bosco 17.5-29, il colpo a 29.5. Ogni passo aspetta il suo secondo con _at().
## Qualsiasi tasto lo salta. Il titolo lo rilancia se nessuno tocca niente per un po'.

const CASTLE := "res://world/castle.tscn"
const FOREST := "res://world/forest.tscn"
## Il colore che "spegne" il mondo quando la storia si fa scura.
const SHADOW := Color(0.08, 0.02, 0.14)

@onready var stage: Node2D = $Stage
@onready var camera: Camera2D = $Camera2D
@onready var shade: ColorRect = %Shade
@onready var black: ColorRect = %Black
@onready var flash: ColorRect = %Flash
@onready var presents: Label = %Presents
@onready var narration: Label = %Narration
@onready var skip_hint: Label = %SkipHint
@onready var eye_holder: Node2D = %EyeHolder
@onready var music: AudioStreamPlayer = %Music

## Quando è cominciato il filmato (millisecondi da Time.get_ticks_msec).
var _start := 0
## True quando il filmato è finito o è stato saltato: chi aspetta smette.
var _done := false
var _camera_tween: Tween
