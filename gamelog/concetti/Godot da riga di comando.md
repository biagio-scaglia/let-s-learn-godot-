---
tags:
  - concetto
  - strumenti
aliases:
  - CLI
  - Riga di comando
---

# Godot da riga di comando

← [[godot-basi|Basi di Godot]]

L'eseguibile di Godot accetta delle opzioni da terminale:

| Opzione | Cosa fa |
|---|---|
| `--path <cartella>` | Apre il progetto in quella cartella |
| `--headless` | Nessuna finestra, utile per controlli automatici |
| `--import` | Importa gli asset ed esce, vedi [[File import e uid]] |
| `-s <script.gd>` | Esegue uno script che estende `SceneTree` al posto del gioco normale |
| `-- <argomenti>` | Quello che segue arriva allo script con `OS.get_cmdline_user_args()` |

Uscendo da uno script `-s`, Godot stampa messaggi come `ERROR: BUG: Unreferenced static string` o `leaked at exit`: sono normali e non indicano problemi del gioco.

Attenzione: negli script `-s` gli [[Autoload]] vengono aggiunti dopo la compilazione dello script, vedi [[Classi globali]].

`--quit-after 180` avvia il gioco normale e lo chiude dopo 180 frame: utile per controllare che parta senza errori.

## Nel progetto

Il [[Test automatico]] e il [[Test del dialogo]] si lanciano così.

## Vedi anche

- [[Editor di Godot]]
