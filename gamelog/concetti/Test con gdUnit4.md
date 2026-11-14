---
tags:
  - concetto
  - codice
  - test
aliases:
  - gdUnit4
  - Test
  - Unit test
---

# Test con gdUnit4

← [[godot-basi|Basi di Godot]]

Un **test** è un piccolo script che usa il gioco al posto tuo e controlla che succeda quello che deve succedere. Si scrive una volta e si rilancia a ogni modifica: se qualcosa si rompe, lo dice in pochi secondi.

**gdUnit4** è il framework di test più usato per Godot. È un plugin, in `addons/gdUnit4/` (licenza MIT, versione 6.2.3).

## Com'è fatto un test

```gdscript
extends GdUnitTestSuite                       # una "suite" = un file di test

func before_test() -> void:                   # prima di OGNI test: si parte puliti
	inventory = auto_free(InventoryScript.new())

func test_aggiungere_somma_le_quantita() -> void:   # ogni func test_… è un test
	inventory.add(Inventory.POTION, 2)
	inventory.add(Inventory.POTION)
	assert_int(inventory.items[Inventory.POTION]).is_equal(3)
```

- **`assert_…`**: il controllo. Ce n'è uno per tipo: `assert_int`, `assert_str`, `assert_bool`, `assert_dict`, `assert_vector`…
- **`before_test()` / `after_test()`**: preparano e rimettono a posto. Indispensabili quando si toccano gli [[Autoload]], che restano vivi tra un test e l'altro.
- **`auto_free(…)`**: libera il nodo alla fine del test (sennò gdUnit segnala un *orphan*, un nodo dimenticato in memoria).

## Segnali

```gdscript
monitor_signals(inventory)          # comincia ad ascoltare
inventory.add(Inventory.COIN, 5)
await assert_signal(inventory).is_emitted("item_added", [moneta, 5])
```

## Test di scena

Il **scene runner** carica una scena vera e simula i tasti:

```gdscript
var runner := scene_runner("res://world/house.tscn")
runner.simulate_action_pressed("interact")   # come premere E
await await_millis(150)                      # dare tempo al gioco
assert_bool(Game.has_flag(FlagKeys.CHEST_OPEN)).is_true()
```

## Due tipi di test

| Tipo | Cosa prova | Esempi nel progetto |
|---|---|---|
| **Unitario** | Un pezzo da solo, veloce | `facing_test`, `inventory_test`, `game_test`, `save_system_test`, `settings_test` |
| **Di scena** (integrazione) | Più pezzi insieme, con i tasti | `key_quest_test` (la missione), `intro_test` (la cutscene), `return_by_death_test` (i confini e la morte) |

## Non toccare i dati veri

I test del [[Salvataggio]] e delle [[Opzioni]] cambiano `SaveSystem.path` e `Settings.path` con un file loro (`user://test_…cfg`) e lo cancellano alla fine. Per questo `path` è una **variabile** e non una costante: rendere il codice facile da provare è una scelta di progetto.

## Come lanciarli

| Dove | Come |
|---|---|
| Nell'editor | Pannello **GdUnit** (in basso a sinistra), tasto ▶. Oppure tasto destro sulla cartella `test` → *Run Tests* |
| Da terminale | `test.cmd --godot_binary C:\percorso\Godot.exe` nella cartella del progetto (oppure imposta la variabile `GODOT_BIN`) |

I risultati finiscono in `reports/` (un report HTML da aprire nel browser), che git ignora.

> [!tip] Un test deve poter fallire
> Un test che passa sempre non serve. Dopo averlo scritto, prova a rompere il codice apposta: se il test non se ne accorge, non sta controllando niente. Vedi [[2026-11-13-test-con-gdunit]].

## Vedi anche

- [[Responsabilità]] · [[Costanti]] · [[Segnali]] · [[Await]]
