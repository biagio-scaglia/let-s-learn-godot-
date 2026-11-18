---
tags:
  - progetto
  - mappa
aliases:
  - Bosco
  - forest.tscn
---

# Bosco Senza Tempo

← [[Gamelog]]

Il bosco morto a nord di Erbalta (`world/forest.tscn`), dove dorme Colui che guarda. Si arriva all'alba con [[Emilia]], all'inizio dell'[[Atto 3]]. Gli alberi non hanno foglie e non crescono; tra i rovi qualcosa ti guarda.

![[bosco_emilia_segue.png|500]]

## La mappa

40 × 34 celle da 16 px, scalate ×2 come il [[Mappa principale|villaggio]] (1280 × 1088 pixel). Un sentiero sale a zig-zag dall'ingresso a sud fino a una radura in cima, sbarrata da una **nebbia viola** (`World/FogGate`: un [[StaticBody2D]] con particelle, una luce e un [[Interactable]] che parla di tre bagliori). Ai lati, slarghi e radure piccole: lì andranno gli occhi dell'enigma.

La mappa è stata disegnata "a caratteri" in uno script Python usa e getta (`#` rovi, `.` terra, `P` sentiero, `T` albero…); lo script sceglie il tile giusto guardando i vicini (per esempio un rovo con il prato sotto usa il tile con le punte che scendono).

```
Forest (Node2D, level.gd)
├── Ground, Decor (TileMapLayer)      ← terreno e cose piatte (foglie, ossa, pozze, funghi)
├── Dawn (CanvasModulate)             ← la luce grigio-rosa dell'alba
├── Lights                            ← funghi viola (tremolano), alberi con l'occhio
├── World (y-sort)
│   ├── Objects (TileMapLayer)        ← tronchi, rovi, sassi: hanno collisioni
│   ├── FogGate                       ← la nebbia che sbarra la radura
│   ├── Emilia + Follower
│   └── Subaru + Camera2D + Leaves    ← foglie secche che cadono
├── Canopy                            ← chiome spoglie (sopra i personaggi) e occhi nei rovi
├── Fog (ColorRect, fog.gdshader)
├── Effects (CanvasLayer): PaleRays, Vignette
├── Music, Wind, Sounds/Crow, Ambience
└── ForestArrival (cutscene)
```

## Il tileset

![[bosco_tileset.png|600]]

`assets/forest/forest_tiles.png`, disegnato con Python + Pillow come quello del [[Rocca d'Argento|castello]]: colori spenti, grigio-verdi, con il viola degli occhi come unico colore acceso. Una sola cosa è viva: un fiore bianco, da qualche parte a est.

| Riga | Cosa c'è |
|---|---|
| 0 | erba secca (3 varianti), sentiero e i suoi bordi |
| 1 | chiome spoglie (3), ceppo, tronco caduto (2 tile), sasso, rovo con bacche |
| 2 | tronchi (3, uno con l'**occhio**), funghi viola, radici, foglie, ossa, pozza |
| 3 | rovi fitti (pieno, bordo in basso, bordo in alto, con occhietti), lapide con l'occhio inciso, erba nebbiosa, radice sul sentiero, il fiore |

Tronchi, rovi, sassi e lapidi hanno una forma di collisione e un `y_sort_origin` alla base.

## L'arrivo

`cutscenes/forest_arrival.gd` (`extends Cutscene`): bande nere, i due salgono dal sentiero, il nome del luogo, Subaru si guarda intorno. Emilia nota che non si sente nemmeno un uccello… e un corvo gracchia. Alla fine il ricordo `bosco_arrivo` e il punto di ritorno: se muori nel bosco, ricominci da qui.

## Gli occhi nei rovi

`world/forest/thicket_eyes.gd` (`ThicketEyes`), 14 coppie sul bordo dei rovi. Ognuna si apre in un momento a caso (dissolvenza, poi socchiusa, poi aperta), sbatte le palpebre ogni 2-5 secondi, e quando Subaru arriva a meno di 90 pixel **si chiude di colpo** e svanisce. Si riapre dopo un po', solo se lui si è allontanato.

## I suoni

| Suono | Come |
|---|---|
| Tema (`forest_theme.wav`) | [[Colonna sonora#Bosco Senza Tempo]] |
| Vento (`forest_wind.wav`) | Loop di 12 s: rumore grave con folate, due fischi a banda stretta, due rami che scricchiolano |
| Corvo, ramo | `forest_ambience.gd` li fa nascere ogni 5-12 s in un punto a caso attorno a Subaru, con un `AudioStreamPlayer2D`: si sentono da destra o da sinistra |

## Vedi anche

- [[Atto 3]] · [[Emilia]] · [[Shader#Nebbia]] · [[2026-11-18-bosco]]
