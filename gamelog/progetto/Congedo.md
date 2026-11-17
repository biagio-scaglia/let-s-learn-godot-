---
tags:
  - progetto
  - interfaccia
  - effetti
aliases:
  - Farewell
  - Sei sicuro?
---

# Congedo

← [[Gamelog]]

Quello che succede quando **chiudi il gioco**: con la X della finestra, Alt+F4, oppure **Esci** nella [[Schermata iniziale]], nel [[Menu di pausa]] o nel game over del [[Ritorno dalla Morte]].

## Cosa succede

1. La finestra del gioco si riduce a icona. Sul desktop, **fuori dal gioco**, compare una finestra "di sistema": *Vuoi davvero uscire da Erbalta?* — **Sì** / **No**. Sembra del tutto normale; "No" è già selezionato.
2. Se non rispondi, dopo un paio di secondi **si corrompe**: un suono distorto, un battito di cuore, il titolo diventa **???**, la domanda si cancella e si riscrive con **il tuo nome**: *"Biagio... sei sicuro?"*. Ogni tanto, per un istante, il bottone "No" diventa "Sì".
3. **No** (o Esc, o chiudere lei): *"...Bene. Resta con me."*, la finestra si spegne e il gioco torna com'era, anche se eri a schermo intero.
4. **Sì**: tre cose, una dopo l'altra (dal [[2026-11-17-congedo-v3|17 novembre, terza versione]]):
   - **Lei arriva accanto.** Sul desktop, a fianco della finestra, compare una figura alta d'ombra, con i capelli lunghissimi e gli occhi viola. Si materializza pixel per pixel, ondeggia come fumo e allunga un braccio fino al bordo della finestra, che **trema**.
   - **Le mani strappano.** Due mani d'ombra escono dai bordi, afferrano il centro e strappano la finestra in due.
   - **L'occhio.** Nello strappo, nel buio, si apre un occhio enorme che **segue il tuo mouse**, ovunque sia sul desktop, e ogni tanto sbatte le palpebre. Sotto, la frase d'addio. Poi tutto si spegne.
5. **Se non rispondi** per 9 secondi: *"Non rispondi? Allora decido io."*, e succede come con Sì.

![[congedo_finestra.png|400]] ![[congedo_corrotta.png|400]]
![[congedo_lei.png|160]] ![[congedo_strappo_occhio.png|400]]

## Il nome e la frase d'addio

Il nome è quello con cui sei entrato nel computer (la variabile d'ambiente `USERNAME`): `biagio.scaglia` → **Biagio**. Si legge solo lì, sul PC, e **non va da nessuna parte**. Se non c'è, sei "straniero".

La frase d'addio cerca di essere la più personale possibile, in quest'ordine:

| Se… | Dice |
|---|---|
| sei nel game over | *Scappi proprio adesso, Biagio?* |
| è notte fonda (prima delle 5) | *Sono le 3:07, Biagio. Dovresti dormire.* |
| hai giocato meno di due minuti | *Te ne vai già, Biagio?* |
| sei morto almeno una volta | *Sei morto 4 volte. Tornerai, Biagio.* |
| altrimenti | *Ci rivedremo, Biagio.* |

## Com'è fatto

| Pezzo | Dove |
|---|---|
| L'autoload `Farewell` | `ui/farewell.gd` |
| Nome e frase: due funzioni `static`, senza finestre | `name_from_login()`, `goodbye_line()`: facili da provare |
| La finestra fuori dal gioco, la X | [[Window]] |
| La finestra finta: barra del titolo, icona, bottoni | Nodi creati dal codice dentro un SubViewport, con un [[Theme]] suo "da sistema operativo" |
| L'icona di avviso (16×16) | `assets/ui/dialog_warning.png`, fatta da noi |
| Lei (64×150, occhi a parte) | `ui/farewell_figure.gd` (`FarewellFigure`, una `Window`), `assets/effects/watcher_tall.png` |
| Le mani che strappano | `ShadowHand` della [[Schermata iniziale]], rimpicciolite con `set_size_factor()` |
| Lo strappo | Nello shader del glitch: [[Shader#Lo strappo]] |
| L'occhio che segue il mouse | `ui/watching_eye.gd` (`WatchingEye`), `assets/effects/big_eye_*.png`, [[Shader#Ritagliare con una forma]] |
| Il glitch | `effects/glitch.gdshader`: [[Shader#Glitch]] |
| 15 test | `test/ui/farewell_test.gd`: lì la finestra resta dentro il gioco e la chiusura viene solo "segnata" |

![[lei_4x.png|200]] ![[occhio_grande_8x.png|400]]

## Vedi anche

- [[2026-11-17-congedo]] · [[2026-11-17-congedo-v2]] · [[2026-11-17-congedo-v3]] · [[Effetti visivi]] · [[Schermata iniziale#Qualcuno ti guarda]]
