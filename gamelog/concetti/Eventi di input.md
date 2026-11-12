---
tags:
  - concetto
  - input
aliases:
  - InputEvent
  - _unhandled_input
  - set_input_as_handled
---

# Eventi di input

← [[godot-basi|Basi di Godot]]

Ci sono due modi di leggere i tasti:

| Modo | Come | Quando usarlo |
|---|---|---|
| **Chiedere lo stato** | `Input.is_action_pressed("run")` | Cose continue: muoversi, correre |
| **Ricevere l'evento** | `func _unhandled_input(event)` | Cose "una volta per pressione": parlare, aprire un menu |

```gdscript
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		# ...
```

- Un evento passa da un nodo all'altro finché qualcuno non lo segna come **gestito** con `set_input_as_handled()`. Da lì in poi gli altri non lo ricevono.
- *Unhandled* vuol dire "non già usato dall'interfaccia": se un pulsante ha preso il clic, il gioco non lo vede.

## Il bug che abbiamo evitato

Premendo E vicino al [[Saggio]], il suo [[Interactable]] apre il dialogo. Se non segnasse il tasto come gestito, **lo stesso evento** arriverebbe subito dopo alla [[Finestra di dialogo]], che lo prenderebbe come "vai avanti" e salterebbe la prima frase.

## Nei test

`Input.action_press()` cambia solo lo *stato* e non genera eventi. Per simulare una pressione vera il [[Test del dialogo]] usa `Input.parse_input_event()` con un `InputEventAction`.

## Vedi anche

- [[Input Map]] · [[Ciclo di gioco]]
