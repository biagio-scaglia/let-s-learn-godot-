---
tags:
  - progetto
  - storia
aliases:
  - Cutscene d'apertura
  - intro.tscn
---

# Intro

← [[Gamelog]]

La [[Cutscene]] d'apertura (`cutscenes/intro.tscn`, [[Istanza]] dentro la [[Mappa principale]]). Si vede **solo alla prima partita**.

![[cutscene_intro.png|500]]

## Cosa succede

1. Schermo nero: si sentono solo i passi di [[Subaru]].
2. L'immagine compare piano ([[Dissolvenza]] di 1,8 secondi), con le **bande nere** da film.
3. **Sorge il sole:** la luce del mondo passa dal blu all'arancio al giorno, e i [[Effetti visivi|raggi di sole]] si accendono forti e poi si calmano.
4. Subaru sale dal sentiero a sud fino alla piazza.
5. Compare il nome del luogo, **Villaggio di Erbalta**, mentre si guarda a sinistra, a destra, poi verso di noi.
6. Le bande spariscono e pensa ad alta voce: *"...Dove sono finito?"*
7. Il giocatore riprende i comandi.

## Com'è fatta

```
Intro (CanvasLayer 10, intro.gd)
├── TopBar (ColorRect)      ← banda in alto
├── BottomBar (ColorRect)   ← banda in basso
└── PlaceCard (Control)     ← "Villaggio di Erbalta"
    ├── Name (Label)
    └── Line (ColorRect)    ← la linea dorata
```

Nel `_ready()` decide se partire. **Non** parte quando:

- il villaggio fa da sfondo alla [[Schermata iniziale]] (lì Subaru non c'è);
- in `Game.flags` c'è già `"intro_vista"`;
- si arriva da una [[Porta]] (`Game.spawn_point`) o da un [[Salvataggio]] (`Game.spawn_position`).

Altrimenti mette `Game.in_cutscene = true` **subito**, durante `_ready`: così [[Game]] `change_scene()` sa che non deve togliere il nero da solo, ci pensa la cutscene.

Subaru cammina con `walk_to()`, una funzione nuova in `subaru.gd`: un [[Tween]] sulla posizione più l'animazione di camminata. Attraversa i muri (il punto di partenza è sotto il bordo della mappa), quindi va usata solo nelle scene scritte.

## L'alba

`_sunrise()` cerca nella scena `Tint` ([[CanvasModulate]]) ed `Effects/SunRays`, si ricorda i loro valori normali, li porta alla notte e li anima con due [[Tween]] che corrono in parallelo. I colori sono le costanti `NIGHT_TINT` e `DAWN_TINT`. Vedi [[2026-11-13-sole-e-nuvole]].

## Per cambiarla

Tutto sta in `cutscenes/intro.gd`: `START` e `STOP` sono il punto di partenza e d'arrivo, le frasi sono nel `Dialogue.start(...)`, le pause nei `_wait(...)`. Per rivederla basta una *Nuova partita*.

## Vedi anche

- [[Cutscene]] · [[Await]] · [[Game]] · [[2026-11-13-cutscene]]
