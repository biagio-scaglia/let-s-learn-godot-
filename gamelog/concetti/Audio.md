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

## Il volume generale

Tutti i suoni passano dal **bus audio** *Master* (pannello *Audio* in basso nell'editor). Le [[Opzioni]] ne cambiano il volume:

```gdscript
AudioServer.set_bus_volume_db(0, linear_to_db(volume))   # volume da 0 a 1
```

`linear_to_db` converte da "percentuale" a decibel, l'unità che usano i suoni.

## Musica in loop

La musica della [[Biblioteca]] è un `AudioStreamPlayer` con **`autoplay = true`**: parte da sola quando si entra nella scena, e si ferma quando la scena viene liberata (uscendo dalla porta).

Per farla **ripetere**, con un WAV non si tocca il nodo ma l'**import**: selezionare il file, pannello *Import*, **Loop Mode → Forward**, poi *Reimport*. Nel file `.import` diventa `edit/loop_mode=2`. (Con gli OGG invece c'è la casella `loop`.)

Perché il loop non si "senta", la fine del brano deve attaccarsi bene all'inizio: nel nostro WAV la coda del riverbero è già sommata all'inizio, vedi [[2026-11-17-biblioteca#La musica]].

## La musica del livello

Ogni livello ha un nodo `Music` nel **gruppo** `level_music` ([[Gruppi]]). Così chi deve comandarla la trova senza sapere in che scena siamo:

```gdscript
for music in get_tree().get_nodes_in_group("level_music"):
	t.tween_property(music, "volume_db", -60.0, 1.5)   # alla morte: si spegne
```

Nel villaggio `VillageEdge` la abbassa quando Subaru si avvicina al bordo:

```gdscript
music.volume_db = _music_db + linear_to_db(maxf(1.0 - danger * 0.95, 0.001))
```

`linear_to_db(1.0)` è 0 (volume invariato), `linear_to_db(0.05)` circa −26 dB (quasi muto).

## Pausa e ripresa

Il [[Combattimento]] non ferma la musica del villaggio: la mette **in pausa**.

| Comando | Cosa succede |
|---|---|
| `stop()` poi `play()` | Ricomincia **da capo** |
| `stream_paused = true` poi `false` | Riprende **dal punto in cui era** |

Tutti i brani sono descritti in [[Colonna sonora]].

## Suoni nello spazio

`AudioStreamPlayer2D` è un suono **con una posizione**: si sente più forte quando la camera è vicina e sparisce oltre `max_distance`; se sta a destra, si sente più a destra. Nella [[Rocca d'Argento]] ogni torcia ha il suo crepitio (`max_distance = 320`) e il fossato il suo sciabordio: mentre la camera scende verso il prato, l'acqua si allontana e il fuoco si avvicina, da solo.

I due loop (`assets/castle/castle_water.wav`, `castle_fire.wav`) sono sintetizzati come la musica: rumore filtrato che "respira" più qualche bolla per l'acqua, un fruscio basso più tanti clic brevissimi per il fuoco. Per non sentire il "clic" quando il loop ricomincia, la coda del suono è sfumata sopra l'inizio.

## Suoni sparsi

Nel [[Bosco Senza Tempo]] i corvi e i rami non stanno in un posto fisso: `forest_ambience.gd` crea ogni 5-12 secondi un `AudioStreamPlayer2D` nuovo, lo mette in un punto a caso attorno a Subaru, lo fa suonare e lo cancella quando ha finito (`finished.connect(queue_free)`). Così il bosco sembra pieno di cose, da tutte le parti.

## Vedi anche

- [[Effetti visivi]]
