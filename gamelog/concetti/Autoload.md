---
tags:
  - concetto
aliases:
  - Singleton
  - Autoload Dialogue
---

# Autoload

← [[godot-basi|Basi di Godot]]

Una [[Scena]] (o uno script) che Godot **carica da sola all'avvio** e tiene sempre viva, qualunque scena sia aperta. Si raggiunge da qualsiasi script con il suo nome.

- Si registra in *Impostazioni progetto → scheda Globali → Autoload*: si sceglie il file e il nome.
- È perfetta per le cose "uniche e globali": la finestra di dialogo, la musica, i dati del salvataggio.
- Viene aggiunta come figlia della radice, prima della scena principale.

## Nel progetto

La [[Finestra di dialogo]] è l'autoload **`Dialogue`**. Per questo il [[Saggio]] può scrivere:

```gdscript
Dialogue.start(npc_name, lines)
```

e [[Subaru]] può chiedere `Dialogue.is_active` per sapere se deve stare fermo.

## Vedi anche

- [[Segnali]] · [[CanvasLayer]]
