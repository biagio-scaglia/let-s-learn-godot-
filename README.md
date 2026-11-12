# Let's learn Godot

Progetto personale per imparare le basi di **Godot 4**, un passo alla volta.

Per ora c'è Subaru che cammina e corre in una piccola mappa con alberi, sentieri e staccionate.

## Come avviarlo

1. Apri Godot 4.7 e importa la cartella `let's-learn-godot` (il file `project.godot`).
2. Premi **F5**.

| Tasto | Azione |
|---|---|
| Frecce o WASD | Muoversi |
| Shift (tenuto premuto) | Correre |

## Struttura

| Cartella | Contenuto |
|---|---|
| `let's-learn-godot/` | Il progetto Godot |
| `let's-learn-godot/characters/subaru/` | Subaru: spritesheet, animazioni, scena e script |
| `let's-learn-godot/world/` | La mappa (`main.tscn`) e il TileSet |
| `let's-learn-godot/assets/` | Asset esterni (vedi [CREDITS.md](CREDITS.md)) |
| `tools/` | Script di supporto: generazione della mappa e test automatico |
| `gamelog/` | Il diario del progetto, è un vault di [Obsidian](https://obsidian.md) |
| `Sprite Sheet Subaru.png` | La spritesheet originale, prima della pulizia |

## Gamelog

Il diario racconta cosa è stato fatto, perché, e cosa ho imparato di Godot.
Si parte da [`gamelog/Gamelog.md`](gamelog/Gamelog.md); per leggerlo al meglio apri la cartella `gamelog` come vault in Obsidian.
