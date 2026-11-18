---
tags:
  - concetto
aliases:
  - Progress
  - Sbloccabili
---

# Progressi permanenti

← [[godot-basi]]

Nel gioco ci sono tre tipi di "memoria", e durano in modo diverso:

| Cosa | Dove | Quando si perde |
|---|---|---|
| I ricordi della partita (chi hai salutato, cosa hai raccolto) | `Game.flags` | Con una partita nuova, o tornando indietro col [[Ritorno dalla Morte]] |
| La partita salvata | `user://salvataggio.cfg` ([[Salvataggio]]) | Quando salvi di nuovo |
| Cosa hai **sbloccato** (la Galleria) | `user://progressi.cfg`, autoload `Progress` | Mai |

`Progress` è un [[Autoload]] piccolo come `Settings`: legge un [[ConfigFile]] all'avvio e lo riscrive quando cambia qualcosa.

```gdscript
func finish_story() -> void:
	if story_finished:
		return
	story_finished = true
	_save()
```

Il titolo chiede `Progress.gallery_unlocked()` per decidere se la [[Galleria]] ha il lucchetto. `Game.new_game()` non tocca `Progress`: ricominciando da capo la Galleria resta aperta.

Come per `Settings` e `SaveSystem`, il percorso del file è una **variabile**: i test ne usano uno loro (`user://test_progressi.cfg`) e non toccano mai quello vero.

## Vedi anche

- [[ConfigFile]] · [[Autoload]] · [[Salvare la partita]] · [[Galleria]]
