---
tags:
  - progetto
  - ui
aliases:
  - options_menu.tscn
  - Impostazioni
---

# Opzioni

← [[Gamelog]]

Il pannello delle opzioni (`ui/options_menu.tscn`), **lo stesso** per la [[Schermata iniziale]] e per il [[Menu di pausa]]: una scena sola, usata come [[Istanza]] in tutti e due. Vedi [[Composizione]].

![[menu_opzioni.png|400]]

| Opzione | Controllo | Cosa cambia |
|---|---|---|
| Volume | `HSlider` da 0 a 100, a passi di 10 | Il volume del bus audio *Master*, cioè di tutti i suoni ([[Audio]]) |
| Schermo intero | `CheckBox` | La modalità della finestra |
| Indietro (o Esc) | [[MenuItem]] | Chiude il pannello e manda il segnale `closed` |

- Muovendo lo slider si sente subito un "tic" al nuovo volume.
- Le opzioni stanno nell'[[Autoload]] **`Settings`** (`core/settings.gd`: `volume`, `fullscreen`, `set_volume()`, `set_fullscreen()`) e vengono **salvate su file** a ogni cambiamento ([[ConfigFile]]): al prossimo avvio sono come le avevi lasciate.
- Con la tastiera: su e giù per scegliere, sinistra e destra per lo slider, Invio per la casella.
