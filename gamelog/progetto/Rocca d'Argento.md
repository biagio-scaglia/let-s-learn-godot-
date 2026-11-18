---
tags:
  - progetto
  - mappa
  - storia
aliases:
  - Castello
  - castle.tscn
---

# Rocca d'Argento

← [[Gamelog]]

Il castello da cui comincia la storia (`world/castle.tscn`). Non ci si gioca: è il palco della prima [[Cutscene]], di notte. Si vede a ogni *Nuova partita*, prima dell'[[Intro]].

![[castello_portone.png|500]]

## La scena

```
Castle (Node2D)
├── Ground (TileMapLayer)        ← erba, sentiero, riva, ponte
├── Moat (TileMapLayer)          ← solo l'acqua, con lo shader water.gdshader
├── Walls (TileMapLayer)         ← mura, torri, portone, stendardi, finestre
├── Objects (TileMapLayer)       ← torce, siepi, cespugli, sassi
├── Night (CanvasModulate)       ← la notte: tutto più blu e più scuro
├── Lights
│   ├── Torch1..4 (PointLight2D + flicker.gd)
│   │   ├── Embers (CPUParticles2D)       ← braci
│   │   └── Crackle (AudioStreamPlayer2D) ← fuoco che crepita
│   ├── Window1..8 (PointLight2D)         ← le finestre accese
│   └── GateGlow (PointLight2D)
├── WaterSparkles (CPUParticles2D)        ← scintille sul fossato
│   └── WaterSound (AudioStreamPlayer2D)
├── Fireflies (CPUParticles2D)            ← lucciole sul prato
├── World (y-sort): Emilia, Subaru
├── Camera2D                              ← la muove la cutscene
├── Music                                 ← il tema della biblioteca, piano
├── Effects/Vignette
└── CastleOpening (cutscene)
```

I tile sono a 16 px, la mappa è scalata ×2 come il [[Mappa principale|villaggio]]: 24 × 18 celle, cioè 768 × 576 pixel.

## Il tileset

`assets/castle/castle_tiles.png`, 8 × 4 tile, disegnati con uno script Python + Pillow (fuori dal repository, vedi [[Strumenti archiviati]]) usando **gli stessi colori** di [[Tiny Town]], così sembra dello stesso gioco.

| Riga | Cosa c'è |
|---|---|
| 0 | erba (3 varianti), selciato, selciato con bordo d'erba a sinistra e a destra, acqua, acqua in ombra sotto le mura |
| 1 | merli, mattoni, finestra accesa, stendardo (sopra e sotto), zoccolo delle mura, merli e corpo della torre |
| 2 | arco del portone (2 tile), buio del portone (2 tile), finestra della torre, base della torre, ponte con corrimano (2 tile) |
| 3 | assi del ponte, torcia (fiamma e palo), cespuglio, siepe, sasso, aiuola, riva del fossato |

Nessun tile ha collisioni: nessuno ci cammina sopra con i tasti.

## La cutscene

`cutscenes/castle_opening.gd` (`extends Cutscene`, vedi [[Ereditarietà]]):

1. bande nere, dal nero compare il castello e il nome **Rocca d'Argento**;
2. Subaru ed Emilia escono dal portone e scendono il ponte, la camera scende con loro;
3. si fermano tra le torce e parlano: Erbalta è a sud, da lì arrivano voci strane; Emilia resterà in piazza, Subaru parlerà con la gente;
4. ripartono verso sud; `Game.change_scene()` porta al villaggio, dove parte l'[[Intro]].

Per cambiarla: le posizioni sono le costanti in cima (`SUBARU_STOP`, `EMILIA_STOP`, `EXIT_Y`, `SPEED`), le frasi nei `_say(...)`.

## Vedi anche

- [[Intro]] · [[Emilia]] · [[Cutscene]] · [[Luci 2D]] · [[Particelle]] · [[Shader#Acqua]] · [[2026-11-18-castello]]
