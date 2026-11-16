---
tags:
  - progetto
  - autoload
  - audio
aliases:
  - sfx.gd
  - Suoni
---

# Sfx

← [[Gamelog]]

L'[[Autoload]] **`Sfx`** (`core/sfx.gd`): i suoni brevi dei menu e degli eventi.

```gdscript
Sfx.play(Sfx.CONFIRM)
pressed.connect(Sfx.play.bind(Sfx.CONFIRM))   # suona quando si preme un bottone
```

| Costante | Quando |
|---|---|
| `MOVE`, `CONFIRM`, `BACK` | Spostarsi, confermare, tornare indietro nei menu |
| `PICKUP` | Raccogliere un oggetto |
| `CHEST_OPEN` | Aprire il baule |
| `SAVE` | Partita salvata |
| `DOOR` | Attraversare una [[Porta]] |

All'avvio crea un `AudioStreamPlayer` per ogni suono, leggendo la tabella `SOUNDS` (file e volume). Per aggiungere un suono basta una riga lì e una costante. Un nome sbagliato ferma il gioco con "Suono sconosciuto: …".

Funziona anche in [[Pausa]] (`process_mode = Always`): il [[Menu di pausa]] e lo [[Zaino]] suonano mentre il gioco è fermo.

## Suoni del combattimento

Quasi tutti fatti da noi con uno script Python usa e getta (onde e rumore sintetizzati), come gli altri di `assets/effects/`; due vengono da [[Kenney]]. Li usa il [[Combattimento]].

| Costante | Suono | Quando |
|---|---|---|
| `HIT` | Colpo secco | Pugno, Shamac, il nemico che colpisce |
| `HEAL` | Tre note in salita | Pozione |
| `LEVEL_UP` | Quattro note e una lunga | Si sale di livello |
| `SWING` | Fruscio d'aria (rumore filtrato) | Ogni scatto verso il nemico |
| `KICK` | Tonfo basso | Calcio, pugno caricato |
| `WEAK` | "Clink" metallico | Colpo su una debolezza |
| `BREAK` | Vetro in frantumi e un colpo basso | Scudo rotto |
| `GUARD` | "Vwum" morbido | Difendi, un colpo parato, il nemico che si riprende |
| `BATTLE_START` | Spazzata che sale e un colpo | La transizione d'ingresso |
| `CHARGE` | `forceField_001.ogg` di Kenney (lo usa anche il [[Ritorno dalla Morte]]) | Pugno caricato |
| `SHAMAC` | `glitch_002.ogg` di Kenney | Shamac |

## Vedi anche

- [[Audio]] · [[Costanti]] · [[Game]]
