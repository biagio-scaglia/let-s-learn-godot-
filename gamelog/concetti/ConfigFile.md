---
tags:
  - concetto
  - codice
aliases:
  - Salvare le impostazioni
  - user://
---

# ConfigFile

← [[godot-basi|Basi di Godot]]

Un **ConfigFile** salva e legge un file di testo diviso in sezioni, come le impostazioni di un programma:

```
[audio]
volume=0.6

[video]
fullscreen=false
```

```gdscript
var config := ConfigFile.new()
config.set_value("audio", "volume", volume)
config.save("user://impostazioni.cfg")

if config.load("user://impostazioni.cfg") == OK:
	volume = config.get_value("audio", "volume", 0.8)   # 0.8 se manca
```

- **`user://`** è la cartella in cui il gioco può scrivere (vedi [[Percorsi res]]). Su Windows è dentro `%APPDATA%\Godot\app_userdata\<nome del progetto>`.
- `res://` invece, nel gioco esportato, è di sola lettura.

## Nel progetto

[[Game]] salva così le [[Opzioni]] (volume e schermo intero) ogni volta che cambiano, e le rilegge all'avvio. Più avanti lo stesso modo servirà per il salvataggio della partita.

## Vedi anche

- [[Opzioni]] · [[Game]] · [[Percorsi res]]
