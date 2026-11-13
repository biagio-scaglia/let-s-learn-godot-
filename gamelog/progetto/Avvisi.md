---
tags:
  - progetto
  - ui
aliases:
  - Hud
  - Toast
  - hud.tscn
---

# Avvisi

← [[Gamelog]]

I messaggi a comparsa in alto: "Hai trovato: Chiave", "Partita salvata". È un [[Autoload]] chiamato `Hud`.

![[avviso.png|400]]

- Scendono dall'alto con un piccolo rimbalzo, restano quasi 2 secondi, risalgono. Tutto con un [[Tween]].
- Se ne arrivano più insieme (il baule dà pozioni **e** monete) si mettono **in coda** e si mostrano uno alla volta.
- Hanno l'icona dell'oggetto, quando c'è.
- Funzionano anche in [[Pausa]], per "Partita salvata" dal [[Menu di pausa]].
- Lo stile è la variazione `ToastPanel` del [[Theme]]: compatta, con il bordo dorato.

```gdscript
Hud.show_item(Game.item("chiave"))       # "Hai trovato: Chiave"
Hud.show_message("Partita salvata")
```
