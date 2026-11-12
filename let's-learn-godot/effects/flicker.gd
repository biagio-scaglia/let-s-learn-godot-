extends PointLight2D
## Fa tremolare una luce come una fiamma.

## Quanto cambia l'intensità (0 = ferma).
@export var amount := 0.18
## Quanto è veloce il tremolio.
@export var speed := 7.0

var _base_energy := 1.0
var _base_scale := 1.0
var _time := 0.0
var _noise := FastNoiseLite.new()


func _ready() -> void:
	_base_energy = energy
	_base_scale = texture_scale
	# Il rumore "Perlin" cambia in modo morbido: più naturale di un numero a caso.
	_noise.seed = randi()
	_noise.frequency = 0.5


func _process(delta: float) -> void:
	_time += delta * speed
	var n := _noise.get_noise_1d(_time)   # tra -1 e 1
	energy = _base_energy * (1.0 + n * amount)
	texture_scale = _base_scale * (1.0 + n * amount * 0.3)
