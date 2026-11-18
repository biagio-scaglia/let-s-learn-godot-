---
tags:
  - progetto
  - audio
aliases:
  - Musica
  - OST
  - Risata
---

# Colonna sonora

← [[Gamelog]]

Tutta la musica del gioco è **originale**, composta e sintetizzata per questo progetto con Python (numpy + scipy): nessun campione registrato, ogni nota è una somma di onde. L'atmosfera è quella dei vecchi giochi horror fatti con RPG Maker: carillon, valzer lenti, armonie che a un certo punto "sbagliano".

| Brano | Dove | Tonalità e tempo | Durata | Loop |
|---|---|---|---|---|
| `library_theme.wav` | [[Biblioteca]] | re minore, 66 BPM, 3/4 | 87 s | Sì |
| `village_theme.wav` | [[Mappa principale]] e titolo | fa maggiore, 76 BPM, 3/4 | 76 s | Sì |
| `battle_theme.wav` | [[Combattimento]] | la minore, 140 BPM, 4/4 | 55 s | Sì |
| `game_over_theme.wav` | [[Ritorno dalla Morte]] | re, 48 BPM, 3/4 | 45 s | Sì |
| `game_over_laugh.wav` | [[Ritorno dalla Morte]] | — | 6 s | No |

Sono WAV mono a 32 kHz in `assets/music/`. All'import Godot li comprime (QOA); il loop si attiva nell'import, vedi [[Audio#Musica in loop]].

## Gli strumenti

| Strumento | Com'è fatto |
|---|---|
| Carillon | Sinusoide con armoniche "stonate" (×4,2 e ×6,8) che si spengono in fretta, e un'altezza che ondeggia appena |
| Pianoforte | 6 armoniche, le più alte si spengono prima |
| Flauto | Sinusoide morbida, un filo di fiato (rumore filtrato) e un vibrato che arriva dopo un attimo |
| Archi | Tre voci per nota, leggermente scordate, che entrano e escono piano |
| Batteria | Cassa: sinusoide che scende di tono. Rullante e charleston: rumore filtrato |
| Riverbero | Convoluzione con un rumore che si spegne: l'eco di una stanza |

## Erbalta

Un valzer in **fa maggiore**: flauto e carillon sulla melodia, arpa (pianoforte in crome) e basso sotto. Nella seconda metà arrivano le ombre: un accordo di **si bemolle minore** (malinconico) e uno di **re bemolle**, fuori tonalità, dove il carillon si sdoppia e si scorda. Il villaggio è tranquillo… quasi.

Vicino al bordo della mappa la musica si spegne e resta il cuore: vedi [[Audio#La musica del livello]].

## Combattimento

**La minore, 140 BPM**: cassa e rullante, basso in crome che salta d'ottava, arpeggi, la melodia su flauto e carillon. Nella seconda metà la cassa aggiunge un colpo e arriva un accordo di **si bemolle**, a un semitono dalla tonica: il momento più teso. Ogni otto battute un colpo grave di pianoforte.

## Game over

È il **tema del villaggio, rotto**: sul carillon, rallentato fino a 48 BPM, con alcune note saltate e altre che cadono di un semitono. Sotto, un bordone di **re e mi bemolle** (a un semitono: "battono" tra loro), archi acuti in cluster e accordi suonati **al contrario** che crescono fino alla battuta dopo.

## La risata

Una **voce sintetica**: un'onda a dente di sega (le corde vocali) che passa per tre filtri risonanti alle frequenze della vocale "a" (le *formanti*: 750, 1150 e 2600 Hz). Ogni "ha" comincia con un soffio di rumore (la "h"). Sette "ha" che scendono di tono, poi un "haaa" lungo.

Tre voci insieme (una normale, una un'ottava sotto, una più acuta), una **modulazione ad anello** a 38 Hz che la rende un po' meno umana e un riverbero corto.

## Bosco Senza Tempo

`assets/music/forest_theme.wav`: re minore, 4/4, 58 BPM, 16 battute, 66 secondi in loop. Si apre con l'inizio del valzer del villaggio, ma storto (re-fa-mi-fa invece di do-fa-mi-fa): lo stesso posto, guardato male. Carillon con un'eco sottile un'ottava sopra, un bordone di re e la che non si ferma mai, accordi d'organo morbidi, soffi come respiri tra gli alberi e un battito lontano ogni due battute: lo stesso cuore del bordo del villaggio. Nella battuta 12 c'è un sol diesis, la nota che non dovrebbe esserci, con il carillon scordato. Riverbero lungo.

## Colui che guarda

`assets/music/boss_theme.wav`: mi minore, 140 BPM, 32 battute, 55 secondi in loop, in quattro sezioni da otto battute.

| Sezione | Cosa si sente |
|---|---|
| Ingresso | Organo da chiesa, basso distorto in crome (mi-mi-fa-mi), batteria a metà tempo |
| Coro | Voci sintetiche che cantano "aah" (le formanti della risata del game over, intonate), batteria piena |
| Pausa | Niente basso: il carillon suona l'inizio del valzer del villaggio, in minore e storto, sul battito del cuore |
| Finale | Tutto insieme, il coro a tre voci, la grancassa raddoppiata |

Con il tema, sei suoni: lo Sguardo che si carica (un ronzio che sale, con il battito), il raggio (un fischio che scende e un boato), il ruggito (voci grosse con modulazione ad anello), lo stacco dei ritratti, la lancia di cristallo (tintinnii che salgono) e l'alba (esplosione, vetri, poi un accordo maggiore d'organo e pianoforte).

## Vedi anche

- [[2026-11-17-biblioteca#La musica]] · [[2026-11-17-colonna-sonora]] · [[Audio]] · [[Sfx]]

## Il finale

Due brani nuovi, con gli stessi strumenti sintetizzati (flauto, carillon, pianoforte, archi):

| Brano | Dove | Com'è |
|---|---|---|
| `prologue_theme.wav` (37 s) | [[Filmato iniziale]] | Notte: un bordone basso e note isolate di carillon. Villaggio: la prima frase del valzer al flauto. Bosco: il carillon si scorda, il bordone diventa re contro mi bemolle. Un accordo al contrario che cresce, un colpo, una nota sola |
| `credits_theme.wav` (126 s) | [[Titoli di coda]] | *Un giorno nuovo*: il valzer del villaggio **senza ombre** (al posto del si bemolle minore e del re bemolle, accordi maggiori), poi la seconda metà un tono sopra e più piena, e un accordo finale di sol maggiore col carillon che sale |

Non sono in loop: finiscono con il filmato e con i titoli.
