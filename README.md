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
| Esc | Menu di pausa (riprendi, salva, opzioni, torna al titolo, esci) |
| Tab o I | Zaino |

In alto a sinistra c'è sempre l'**obiettivo** del momento.

Il gioco parte dalla schermata iniziale: frecce o mouse per scegliere, Invio per confermare. Nelle opzioni si regolano volume e schermo intero, che vengono ricordati. Dal menu di pausa si salva, e nel titolo compare *Continua*.

Alla prima partita una breve cutscene mostra Subaru che arriva al villaggio.

**Attenzione:** non provare a uscire dal villaggio. Se muori, puoi sempre *ritornare*…

**La prima missione:** Lina ha perso la chiave del suo baule. Trovala nel villaggio e portagliela.

## Test

I test automatici sono in `let's-learn-godot/test/` e usano [gdUnit4](https://github.com/godot-gdunit-labs/gdUnit4).

- **Nell'editor:** pannello *GdUnit* → ▶.
- **Da terminale**, nella cartella `let's-learn-godot`:

```
test.cmd --godot_binary C:\percorso\Godot_v4.7.2-stable_win64.exe
```

(oppure imposta la variabile d'ambiente `GODOT_BIN` e lancia solo `test.cmd`). I report vanno in `reports/`.

## Struttura

| Cartella | Contenuto |
|---|---|
| `let's-learn-godot/` | Il progetto Godot |
| `let's-learn-godot/characters/subaru/` | Subaru: spritesheet, animazioni, scena e script |
| `let's-learn-godot/characters/npc/` | Personaggio con cui parlare (riutilizzabile) |
| `let's-learn-godot/interactables/` | Componente `Interactable`: tutto ciò con cui si interagisce |
| `let's-learn-godot/ui/` | Schermata iniziale, menu di pausa (autoload `Pause`), opzioni, Theme, finestra di dialogo (autoload `Dialogue`) e dissolvenza (autoload `Fade`) |
| `let's-learn-godot/effects/` | Shader (vignettatura, sfocatura dei menu) e luci che tremolano |
| `let's-learn-godot/world/` | Il villaggio (`main.tscn`), la casa di Lina (`house.tscn`) e i loro TileSet |
| `let's-learn-godot/cutscenes/` | Le scene d'intermezzo (per ora l'arrivo al villaggio) |
| `let's-learn-godot/core/` | Gli autoload di base: stato della partita (`Game`), zaino (`Inventory`), salvataggio (`SaveSystem`), opzioni (`Settings`), suoni (`Sfx`); e le costanti `Facing` e `FlagKeys` |
| `let's-learn-godot/test/` | I test di gdUnit4: `core/` e `quests/` (unitari), `world/` e `characters/` (di scena) |
| `let's-learn-godot/addons/gdUnit4/` | Il plugin gdUnit4 (MIT, vedi [CREDITS.md](CREDITS.md)) |
| `let's-learn-godot/assets/` | Asset esterni (vedi [CREDITS.md](CREDITS.md)) |
| `gamelog/` | Il diario del progetto, è un vault di [Obsidian](https://obsidian.md) |
| `sorgenti/` | I file di partenza, prima della pulizia (le due spritesheet originali di Subaru: camminata e azioni) |

## Gamelog

Il diario racconta cosa è stato fatto, perché, e cosa ho imparato di Godot.
Si parte da [`gamelog/Gamelog.md`](gamelog/Gamelog.md); per leggerlo al meglio apri la cartella `gamelog` come vault in Obsidian.
