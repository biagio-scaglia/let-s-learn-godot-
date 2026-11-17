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

## Vedi anche

- [[2026-11-17-biblioteca#La musica]] · [[2026-11-17-colonna-sonora]] · [[Audio]] · [[Sfx]]
