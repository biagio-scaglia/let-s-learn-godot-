---
tags:
  - concetto
  - codice
aliases:
  - Scena d'intermezzo
  - Cutscene
---

# Cutscene

← [[godot-basi|Basi di Godot]]

Una **cutscene** (scena d'intermezzo) è un momento in cui il gioco "recita da solo": il giocatore guarda, non comanda. In Godot non c'è un nodo apposta: si scrive una **regia in codice**, un'azione dopo l'altra, con [[Await]] per aspettare che ognuna finisca.

```gdscript
Game.in_cutscene = true                    # 1. togli i comandi al giocatore
await player.walk_to(Vector2(656, 416))    # 2. fallo camminare e aspetta che arrivi
player.face("left")                        # 3. si guarda intorno
await get_tree().create_timer(0.6).timeout
Dialogue.start("Subaru", ["...Dove sono finito?"])
await Dialogue.finished                    # 4. aspetta che il dialogo sia chiuso
Game.in_cutscene = false                   # 5. restituisci i comandi
```

Si legge come un copione. Senza `await` tutte le righe partirebbero nello stesso istante.

## Le tre cose da ricordare

1. **Togliere i comandi**, e non solo il movimento: niente menu di pausa, niente zaino, niente interazioni. Nel progetto basta una variabile, `Game.in_cutscene`, controllata da `player_can_move()` e dai menu.
2. **Restituirli alla fine**, sempre. Per sicurezza `Game.change_scene()` la rimette a `false` a ogni cambio di scena.
3. **Ricordarsi che è già stata vista**, con un ricordo in `Game.flags` (es. `"intro_vista"`). Finisce nel [[Salvare la partita|salvataggio]] insieme agli altri.

## Far partire qualcosa senza aspettarlo

A volte due cose devono succedere insieme: Subaru cammina **mentre** lo schermo esce dal nero. Una funzione con `await` chiamata **senza** `await` parte e va avanti da sola:

```gdscript
_fade_in_later(1.6, 1.8)       # parte, ma non la aspettiamo
await player.walk_to(STOP)     # questa sì
```

## Le bande nere

Due `ColorRect` neri in un [[CanvasLayer]], uno in alto e uno in basso, ancorati ai bordi. Fanno subito "film". Si fanno sparire con un [[Tween]] su `offset_bottom` / `offset_top`.

> [!tip] Per scene più lunghe
> Per una cutscene lunga, con tanti personaggi, si può usare un **AnimationPlayer**: una linea del tempo in cui si mettono posizioni, animazioni e chiamate a funzioni. Per una scena corta il codice con `await` è più semplice da leggere e da cambiare.

## Nel progetto

- [[Intro]]: Subaru arriva al villaggio, alla prima partita.

## Vedi anche

- [[Await]] · [[Tween]] · [[Game]] · [[Dissolvenza]] · [[Finestra di dialogo]]
