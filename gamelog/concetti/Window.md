---
tags:
  - concetto
  - nodo
aliases:
  - Finestre
  - SubViewport
  - NOTIFICATION_WM_CLOSE_REQUEST
---

# Window

← [[godot-basi|Basi di Godot]]

In Godot anche la finestra del gioco è un **nodo**: la radice dell'albero (`get_tree().root`) è una `Window`. Se ne possono creare altre.

## Finestre dentro o fuori

Di solito una `Window` nuova viene disegnata **dentro** quella del gioco (come un popup). Per farla diventare una finestra **vera del sistema**, che puoi trovare sul desktop:

```gdscript
get_tree().root.gui_embed_subwindows = false
var window := Window.new()
window.borderless = true          # niente bordo né titolo
window.transparent = true         # lo sfondo non c'è: si vede il desktop
window.transparent_bg = true
window.always_on_top = true
add_child(window)
```

Per la trasparenza serve anche, nelle impostazioni del progetto, `display/window/per_pixel_transparency/allowed = true`.

- **Pixel art in una finestra:** `content_scale_size` è la risoluzione "finta" (160×110) e `size` quella vera (480×330): tutto viene ingrandito tre volte.
- **La finestra principale non si può nascondere** (`root.hide()` dà errore): si può ridurre a icona con `root.mode = Window.MODE_MINIMIZED`.

## La X della finestra

Normalmente cliccando la X il gioco si chiude subito. Con `get_tree().auto_accept_quit = false` invece arriva una **notifica** a tutti i nodi, e sei tu a decidere:

```gdscript
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		leave.call_deferred()
```

> [!warning] Perché `call_deferred`
> La notifica "gira" per l'albero, un nodo dopo l'altro. Mentre gira, i nodi sono **occupati** e non accettano figli nuovi (`Parent node is busy setting up children`). Con `call_deferred` la funzione parte un istante dopo, quando il giro è finito.

## SubViewport

Uno "schermo nello schermo": quello che ci metti dentro viene disegnato in una texture (`get_texture()`), che puoi mostrare con una `TextureRect`. Serve per applicare **uno shader a un gruppo di nodi insieme**: uno shader su un nodo non tocca i suoi figli, ma su una `TextureRect` che mostra un SubViewport tocca tutto quello che c'è dentro.

### Il mouse nei SubViewport

Per **cliccare** qualcosa dentro un SubViewport lo si mette in un `SubViewportContainer`, che dovrebbe passargli mouse e tastiera. Nel [[Congedo]] la tastiera arrivava ai bottoni, ma il clic no: il contenitore lo riceveva (`gui_input`, con le coordinate giuste) senza passarlo. Soluzione semplice: nel `gui_input` del contenitore guardiamo noi su quale bottone è caduto (`button.get_rect().has_point(posizione)`) e chiamiamo `pressed.emit()`.

> [!tip] Come l'ho scoperto
> Invece di provare a caso, ho "ascoltato" i segnali uno per uno: `window_input` della finestra, `gui_input` del contenitore, `mouse_entered` del bottone. Il primo che non arrivava diceva dove si fermava il clic.

## Nel progetto

Il [[Congedo]]: quando chiudi il gioco, `ui/farewell.gd` (autoload `Farewell`) apre una finestra senza bordi e trasparente sul desktop. Dentro c'è un SubViewport con la figura e la scritta, mostrato con lo [[Shader#Glitch|shader del glitch]]. Vedi [[2026-11-17-congedo]].

## Vedi anche

- [[Viewport e stretch]] · [[Autoload]] · [[Shader]]
