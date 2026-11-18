---
tags:
  - progetto
  - storia
aliases:
  - Prologo
  - Opening
---

# Filmato iniziale

← [[Gamelog]]

Parte all'avvio del gioco (`run/main_scene` in `project.godot`), prima della [[Schermata iniziale]]. Dura 37 secondi, quanto la sua musica (`prologue_theme.wav`). Qualsiasi tasto lo salta.

| Secondi | Cosa si vede | Voce narrante |
|---|---|---|
| 0–3 | Nero | *Biagio Scaglia presenta* |
| 3–7 | La [[Rocca d'Argento]] di notte, la camera scende | *Una notte, due viaggiatori lasciarono la Rocca d'Argento.* |
| 7–17,5 | Erbalta di giorno, che piano si spegne | *Andavano a Erbalta: un villaggio tranquillo, dove nessuno invecchia.* … *…e da cui nessuno se n'è mai andato.* |
| 17,5–29 | Il [[Bosco Senza Tempo]], sempre più buio | *Nel bosco a nord, qualcosa non chiude mai gli occhi.* … *E guarda.* |
| 29,5 | Lampo bianco, un colpo, l'occhio si apre nel nero | |
| 32–36 | Nero | *"Questa volta, portala via di qui."* |

![[filmato_castello.png|320]] ![[filmato_villaggio.png|320]] ![[filmato_bosco.png|320]]

## Come funziona

- **Le scene vere.** `_backdrop()` istanzia il livello, toglie Subaru (gruppo `player`), il nodo `Music` e spegne le sue Camera2D, poi lo mette sul palco (`Stage`) e fa scorrere la camera del filmato con un [[Tween]]. Le cutscene dei livelli, senza Subaru, si cancellano da sole.
- **Il tempo segue la musica.** `_at(secondi)` aspetta quel momento del filmato e restituisce `false` se nel frattempo è stato saltato: chi chiama smette (`if not await _at(7.0): return`).
- **Il buio** è un `ColorRect` (`Shade`) sopra il mondo e sotto le scritte, con l'alfa animato.
- **L'occhio** è lo stesso `WatchingEye` del [[Congedo]], ingrandito dal suo contenitore.
- **Torna da solo.** Se nel titolo nessuno tocca niente per 45 secondi, si riparte da qui.

## Vedi anche

- [[2026-11-18-finale]] · [[Cutscene]] · [[Colonna sonora#Il finale]]
