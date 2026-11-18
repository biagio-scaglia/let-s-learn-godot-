class_name VoicesQuest
extends Node
## Atto 2, "Le voci di Erbalta": cosa dicono i personaggi della storia a ogni passo.
##
## Come KeyQuest, non sta dentro i personaggi: li ascolta (segnale interacted) e
## sceglie le loro frasi (override_lines). Ce n'è un'istanza nel villaggio (Saggio,
## Emilia) e una in biblioteca (Archivista, libro nero): i campi vuoti si ignorano.
##
## Il filo: Emilia → Saggio (non ricorda da quanto è qui) → Lina e il baule (una
## pagina strappata) → Archivista (la pagina parla dello Spettro) → Spettro (lascia
## una lacrima d'ombra) → libro nero (la verità) → di nuovo Emilia. L'obiettivo in
## alto a sinistra lo calcola Objective dagli stessi ricordi.

@export var saggio: Interactable
@export var emilia: Interactable
@export var archivista: Interactable
@export var black_book: Interactable
## La luce viola sopra il libro nero: si accende forte quando il libro "parla".
@export var book_glow: PointLight2D


func _ready() -> void:
	for pair in [[saggio, _on_saggio], [emilia, _on_emilia],
			[archivista, _on_archivista], [black_book, _on_black_book]]:
		if pair[0]:
			pair[0].interacted.connect(pair[1])
