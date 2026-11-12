---
tags:
  - concetto
  - nodo
aliases:
  - AudioStreamPlayer
  - Suoni
---

# Audio

← [[godot-basi|Basi di Godot]]

Per riprodurre un suono si usa un nodo **`AudioStreamPlayer`** con un file audio (`.wav`, `.ogg`, `.mp3`) nella proprietà `stream`.

| Proprietà / funzione | Cosa fa |
|---|---|
| `play()` | Fa partire il suono (da capo, se stava già suonando) |
| `volume_db` | Volume in decibel: 0 normale, −6 circa la metà |
| `pitch_scale` | Più alto = più acuto e più veloce |

- `AudioStreamPlayer2D` invece si sente più forte vicino e più piano lontano: utile per suoni nel mondo.
- `.wav` per suoni brevi, `.ogg` per musica.

## Nel progetto

- I **passi** di [[Subaru]]: `step.wav`, un colpo di rumore filtrato di 60 ms. Suona quando l'animazione di camminata arriva ai frame con il piede a terra (segnale `frame_changed`), con un tono leggermente diverso ogni volta. È un `AudioStreamPlayer2D`.
- Il **blip** della [[Finestra di dialogo]]: un `.wav` di 45 millesimi di secondo generato da noi ([[Generatore degli effetti]]). Suona ogni due lettere con `pitch_scale` casuale tra 0,9 e 1,15, così non è monotono.

## Vedi anche

- [[Effetti visivi]]
