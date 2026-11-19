# Pubblicare Erbalta su itch.io e Game Jolt

## 1. Esportare

Una volta sola: nell'editor di Godot, **Editor > Gestisci modelli di esportazione > Scarica e installa**
(i template della stessa versione, 4.7.2).

Poi, dalla cartella `let's-learn-godot`:

```
export.cmd C:\Users\biagio.scaglia\Desktop\Godot_v4.7.2-stable_win64.exe
```

Escono, nella cartella `build/` (ignorata da git):

| File | Cosa caricare |
|---|---|
| `Erbalta-windows.zip` | il gioco per Windows (un solo `.exe`) |
| `Erbalta-web.zip` | la versione da giocare nel browser |

La versione web usa il renderer *Compatibility* (WebGL 2) e non usa i thread:
funziona su itch.io e Game Jolt **senza** SharedArrayBuffer.
Nel browser il pulsante "Esci" sparisce (si chiude la scheda) e lo schermo intero
lo gestisce la pagina.

## 2. itch.io

1. *Create new project*. Kind of project: **HTML**.
2. Carica `Erbalta-web.zip` e spunta **This file will be played in the browser**.
   Carica anche `Erbalta-windows.zip` e segnalo come **Windows**.
3. Embed options: **1280 x 720**, spunta *Fullscreen button*. Non serve
   *SharedArrayBuffer support*.
4. Pricing: **No payments** (vedi la nota sui diritti in fondo).
5. Genre: *Role Playing*. Tag: vedi sotto. Lingue: English, Italian.
   Accessibilità: tutto il parlato è testo; le opzioni di scuotimento e lampi sono nella descrizione.

Con [butler](https://itch.io/docs/butler/) si può anche caricare da riga di comando:

```
butler push build/web       <utente>/erbalta:html5
butler push build/windows   <utente>/erbalta:windows
```

## 3. Game Jolt

1. *Add game* → compila titolo e descrizione (sotto).
2. *Packages* → nuovo package → nuova release `1.1.0`:
   - carica `Erbalta-windows.zip` come build **Windows**;
   - carica `Erbalta-web.zip` come build **Browser (HTML)**, dimensioni **1280 x 720**.
3. Maturity: c'è una morte del protagonista e un po' di horror leggero (occhi, mani d'ombra).

## 4. Testi per la pagina

**Titolo:** Erbalta
**Sottotitolo / tagline (EN):** One more dawn.
**Tag:** rpg, pixel-art, short, story-rich, turn-based, fangame, time-loop, top-down, singleplayer

### English

> **An unofficial Re:Zero fan game.** Subaru and Emilia belong to *Re:Zero − Starting Life
> in Another World* by Tappei Nagatsuki (Kadokawa). This is a free, non-commercial project
> made by a fan, not affiliated with or endorsed by the original authors.
>
> ---
>
> **One more dawn.**
>
> A short pixel-art RPG about a village that starts the same day over, every dawn.
>
> Subaru and Emilia arrive in Erbalta, a quiet village where nobody grows old... and
> nobody ever leaves. Talk to the villagers, uncover what the black book in the library
> remembers, and cross the Timeless Wood, where something never closes its eyes.
>
> When Subaru dies, he goes back. The world forgets. He doesn't.
>
> **Features**
> - Turn-based battles with weaknesses, shields and a combo attack with Emilia
> - Return by Death: every death teaches you something
> - Original music, and a gallery to unlock after the ending
> - English and Italian
> - Accessibility options: text speed, screen shake on/off, reduced flashing
>
> **Controls**
> WASD / arrows: move · E / Space / Enter: interact · Shift: run · Tab: backpack · Esc: pause
>
> **Windows note**
> The game isn't digitally signed, so Windows may say "Windows protected your PC".
> Click **More info → Run anyway**.
>
> **About this project**
> Erbalta is a learning project: I made it to learn Godot 4, working with an AI assistant
> (Claude) for code, writing, music and pixel art. I designed it, directed it, tested it
> and played it. The full dev diary (in Italian) is on GitHub:
> https://github.com/biagio-scaglia/let-s-learn-godot-
>
> Made with Godot 4.7. Tiles, font and some sounds by Kenney (CC0).

### Italiano

> Un piccolo RPG in pixel art su un villaggio che ricomincia lo stesso giorno, ogni alba.
>
> Subaru ed Emilia arrivano a Erbalta, un villaggio tranquillo dove nessuno invecchia...
> e da cui nessuno se n'è mai andato. Parla con gli abitanti, scopri cosa ricorda il
> libro nero della biblioteca e attraversa il Bosco Senza Tempo, dove qualcosa non chiude
> mai gli occhi.
>
> Quando Subaru muore, torna indietro. Il mondo dimentica. Lui no.
>
> - Battaglie a turni con debolezze, scudi e un attacco combinato con Emilia
> - Il Ritorno dalla Morte: ogni morte ti insegna qualcosa
> - Musiche originali e una Galleria da sbloccare dopo il finale
> - In inglese e in italiano
> - Accessibilità: velocità del testo, scuotimento dello schermo, lampi attenuati
>
> Comandi: WASD / frecce per muoverti, E / Spazio / Invio per interagire, Shift per
> correre, Tab per lo zaino, Esc per la pausa.
>
> Un fan game fatto per imparare Godot 4. Subaru ed Emilia vengono da *Re:Zero - Starting
> Life in Another World* (c) Tappei Nagatsuki, Kadokawa. Gratis e senza scopo di lucro.

### Immagini

- Copertina itch.io: 630 x 500 (si può partire da `docs/titolo.gif` o da uno screenshot del titolo).
- Screenshot: battaglia, bosco, Galleria. Le GIF in `docs/` vanno già bene.
- Trailer: `docs/trailer.mp4` (caricalo su YouTube e metti il link).

## Nota sui diritti

Subaru ed Emilia sono personaggi di *Re:Zero*. I fan game gratuiti sono di solito tollerati,
ma il titolare dei diritti può chiederne la rimozione in qualsiasi momento: niente prezzo,
niente donazioni obbligatorie, e dichiaralo come fan game nella pagina.
