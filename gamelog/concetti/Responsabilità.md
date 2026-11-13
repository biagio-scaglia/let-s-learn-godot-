---
tags:
  - concetto
  - codice
aliases:
  - Oggetto dio
  - God object
  - Accoppiamento
  - Separare il codice
---

# Responsabilità

← [[godot-basi|Basi di Godot]]

Una buona regola per organizzare il codice: **ogni script ha un solo compito**, che si può dire in una frase. Se per descriverlo serve una lista, probabilmente sono più script.

## L'"oggetto dio"

Succede piano piano: c'è un posto comodo (un [[Autoload]]) e ci si mette tutto. Il nostro `Game` era arrivato a gestire cambi di scena, ricordi, zaino, salvataggio, opzioni e suoni. Funzionava, ma:

- per trovare una cosa bisognava leggere tutto il file;
- ogni modifica rischiava di rompere qualcos'altro;
- tutti gli script del gioco dipendevano da `Game`.

## Come l'abbiamo diviso

| Prima | Dopo |
|---|---|
| `Game.add_item("chiave")` | `Inventory.add(Inventory.KEY)` |
| `Game.save_game()` | `SaveSystem.save_game()` |
| `Game.set_volume(0.5)` | `Settings.set_volume(0.5)` |
| `Game.ui_sound("confirm")` | `Sfx.play(Sfx.CONFIRM)` |

Ora il nome dell'autoload dice già cosa fa. Vedi [[Game]] per la tabella completa.

## Chi conosce chi (accoppiamento)

Due script sono **accoppiati** quando uno chiama direttamente l'altro. Un po' è inevitabile, ma meno ce n'è, più è facile cambiare un pezzo senza toccare gli altri.

Il trucco di Godot sono i [[Segnali]]: chi fa qualcosa **annuncia** cosa è successo, chi è interessato **ascolta**.

```gdscript
# inventory.gd: annuncia
signal item_added(item: Item, amount: int)

# hud.gd: ascolta
Inventory.item_added.connect(show_item)
```

Prima era lo zaino a chiamare l'avviso (`Hud.show_item(...)`): lo zaino doveva sapere che l'avviso esisteva. Ora non lo sa, e domani anche un suono o un'animazione possono ascoltare lo stesso segnale senza toccare lo zaino.

## Una regola, un posto

Il [[Menu di pausa]] e lo [[Zaino]] avevano ognuno la sua funzione `_can_open()`, quasi uguali ma non del tutto. Ora c'è solo `Game.can_open_menu()`. Se la regola cambia, si cambia una volta.

## Vedi anche

- [[Segnali]] · [[Autoload]] · [[Costanti]] · [[Composizione]]
