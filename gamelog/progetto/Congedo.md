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
4. **Sì**: la finestra si strappa, il corpo diventa buio e dal buio sale una figura con gli occhi viola, in un alone. Ti saluta, e il gioco si chiude.
5. **Se non rispondi** per 9 secondi: *"Non rispondi? Allora decido io."*, e succede come con Sì.

![[congedo_finestra.png|400]] ![[congedo_corrotta.png|400]]
![[congedo_saluto.png|400]]

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
| La figura (56×64) | `assets/effects/watcher.png`, fatta da noi |
| Il glitch | `effects/glitch.gdshader`: [[Shader#Glitch]] |
| 14 test | `test/ui/farewell_test.gd`: lì la finestra resta dentro il gioco e la chiusura viene solo "segnata" |

![[figura_ombra_8x.png|300]]

## Vedi anche

- [[2026-11-17-congedo]] · [[2026-11-17-congedo-v2]] · [[Effetti visivi]] · [[Schermata iniziale#Qualcuno ti guarda]]
