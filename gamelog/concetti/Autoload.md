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

Tutti gli autoload del progetto:

| Nome | Compito |
|---|---|
| `Settings` | [[Opzioni]] su file |
| `Sfx` | [[Sfx\|Suoni]] dei menu e degli eventi |
| `Inventory` | [[Inventory\|Lo zaino]] |
| `SaveSystem` | [[Salvataggio]] |
| `Dialogue` | [[Finestra di dialogo]] |
| `Fade` | [[Dissolvenza]] |
| `Game` | [[Game\|Stato della partita]] e cambi di scena |
| `Pause` | [[Menu di pausa]] |
| `Hud` | [[Avvisi]] |
| `InventoryMenu` | [[Zaino\|Il menu dello zaino]] |

> [!warning] L'ordine conta
> Gli autoload partono **nell'ordine della lista**. Se `Hud`, nel suo `_ready()`, si collega a un segnale di `Inventory`, allora `Inventory` deve stare **prima** nella lista. Per questo i servizi "di base" (opzioni, suoni, zaino, salvataggio) sono in cima.

> [!tip] Un compito per autoload
> È comodo mettere tutto in un autoload solo, ma diventa presto un groviglio. Vedi [[Responsabilità]].

## Vedi anche

- [[Segnali]] · [[CanvasLayer]]
