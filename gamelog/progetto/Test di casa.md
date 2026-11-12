---
tags:
  - progetto
  - strumento
aliases:
  - test_casa.gd
---

# Test di casa

← [[Gamelog]] · [[Strumenti archiviati]]

> [!note] Script rimosso
> Lo script è stato tolto dal repository durante la [[2026-11-12-pulizia|pulizia]]: resta nella cronologia di git. Questa nota spiega come funzionava. Vedi [[Strumenti archiviati]].

Lo script `tools/test_casa.gd` verifica il [[Cambio di scena]] dall'inizio alla fine. Dalla cartella `let's-learn-godot`:

```
<Godot.exe> --path . -s ../tools/test_casa.gd -- <cartella_screenshot>
```

## Cosa controlla (10 controlli)

1. Parla con il [[Saggio]] la prima volta.
2. Camminando nella [[Porta]] si entra in casa; Subaru compare all'ingresso e guarda verso l'interno.
3. Si può parlare con [[Lina]] ed esaminare il baule.
4. Camminando verso l'uscita si torna al villaggio, davanti alla porta, guardando in giù.
5. Il Saggio **si ricorda** della prima conversazione, anche dopo due cambi di scena: è la prova che [[Game]] funziona.

## Cose imparate scrivendolo

- In uno script `-s` bisogna dire a Godot qual è la scena attuale (`current_scene = main`), altrimenti `change_scene_to_file` non sa cosa sostituire.
- Dopo un cambio di scena i vecchi nodi non esistono più: il giocatore va ritrovato ogni volta, con `get_first_node_in_group("player")`.

## Vedi anche

- [[Test del dialogo]] · [[Test automatico]] · [[Godot da riga di comando]]
