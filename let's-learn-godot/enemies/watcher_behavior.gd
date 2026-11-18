class_name WatcherBehavior
extends BattleBehavior
## Colui che guarda, il boss dell'atto 3.
##
## - L'occhio aperto vede arrivare i colpi: ne schiva una parte (danno x0,7).
## - Ogni tre turni carica lo SGUARDO: lo schermo si fa rosso, si sente il battito, e al
##   turno dopo parte un raggio che toglie gran parte della vita (metà, se ci si difende).
## - Il trucco: lo Shamac (tipo ombra) mentre carica lo ACCECA. Il raggio non parte, lo
##   scudo va in frantumi e salta il turno. La prima volta di solito non lo si sa... e si
##   muore. Ma Subaru ricorda (Game.remember): al tentativo dopo lo sa già.
## - Al 60% di vita le mani si moltiplicano (colpisce più forte); sotto il 25% Subaru ed
##   Emilia si guardano: è pronta l'ultimate, "Alba di cristallo".

## Il ricordo che sopravvive alla morte: lo Shamac lo acceca mentre carica lo Sguardo.
const MEMORY_GAZE := "sguardo_del_guardiano"
## Quanta vita (del massimo di Subaru) toglie lo Sguardo.
const GAZE_RATIO := 0.7
## Quanto danno arriva quando l'occhio è aperto e vede il colpo.
const SEEN_HIT := 0.7

var charging := false
var phase := 1
var _turns := 0
## Una frase da dire all'inizio del prossimo turno (i cambi di fase arrivano durante un colpo).
var _pending := ""
## Il rosso che pulsa sullo schermo mentre carica.
var _red: ColorRect
var _pulse: Tween


func after_intro() -> void:
	Sfx.play(Sfx.BOSS_ROAR)
	battle.vfx.shake(8.0, 0.9)
	await battle._pause(0.6)
	if Game.remembers(MEMORY_GAZE):
		battle._reveal("ombra")
		await battle._say("Subaru ricorda: quando carica lo Sguardo, lo Shamac lo acceca!")
