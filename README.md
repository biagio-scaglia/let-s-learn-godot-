# Let's learn Godot

Progetto personale per imparare le basi di **Godot 4**, un passo alla volta.

Per ora c'è Subaru che cammina e corre in una piccola mappa con alberi, sentieri e staccionate, un Saggio con cui parlare, un cartello da leggere e una casa in cui entrare, dove abita Lina. Ci sono già ombre, polvere, pollini, passi sonori e una finestra di dialogo animata.

## Come avviarlo

1. Apri Godot 4.7 e importa la cartella `let's-learn-godot` (il file `project.godot`).
2. Premi **F5**.

| Tasto | Azione |
|---|---|
| Frecce o WASD | Muoversi |
| Shift (tenuto premuto) | Correre |
| E, Spazio o Invio | Parlare, andare avanti nel dialogo |

## Struttura

| Cartella | Contenuto |
|---|---|
| `let's-learn-godot/` | Il progetto Godot |
| `let's-learn-godot/characters/subaru/` | Subaru: spritesheet, animazioni, scena e script |
| `let's-learn-godot/characters/npc/` | Personaggio con cui parlare (riutilizzabile) |
| `let's-learn-godot/interactables/` | Componente `Interactable`: tutto ciò con cui si interagisce |
| `let's-learn-godot/ui/` | Finestra di dialogo (autoload `Dialogue`) e dissolvenza (autoload `Fade`) |
| `let's-learn-godot/effects/` | Shader (vignettatura) |
| `let's-learn-godot/world/` | Il villaggio (`main.tscn`), la casa di Lina (`house.tscn`) e i loro TileSet |
| `let's-learn-godot/core/` | Stato del gioco (autoload `Game`) |
| `let's-learn-godot/assets/` | Asset esterni (vedi [CREDITS.md](CREDITS.md)) |
| `gamelog/` | Il diario del progetto, è un vault di [Obsidian](https://obsidian.md) |
| `sorgenti/` | I file di partenza, prima della pulizia (per ora la spritesheet originale di Subaru) |

## Gamelog

Il diario racconta cosa è stato fatto, perché, e cosa ho imparato di Godot.
Si parte da [`gamelog/Gamelog.md`](gamelog/Gamelog.md); per leggerlo al meglio apri la cartella `gamelog` come vault in Obsidian.
