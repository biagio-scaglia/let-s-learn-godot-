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

Quello che succede quando **chiudi il gioco**: con la X della finestra, Alt+F4, oppure **Esci** nella [[Schermata iniziale]] o nel [[Menu di pausa]].

![[congedo_sei_sicuro.png|400]] ![[congedo_glitch.png|400]]

1. La finestra del gioco si riduce a icona.
2. Sul desktop, **fuori dal gioco**, compare una piccola finestra senza bordi e trasparente: una figura d'ombra dai capelli lunghi e gli occhi viola, rotta da glitch. Un suono distorto.
3. Un battito di cuore. Lettera per lettera, con qualche scatto: **"Sei sicuro?"**
4. Non aspetta la risposta. Un ultimo strappo, l'immagine si schiaccia in una riga bianca come un vecchio televisore che si spegne, e il gioco si chiude.

Se provi a chiudere anche lei, non succede niente: se ne va da sola.

## Com'è fatto

| Pezzo | Dove |
|---|---|
| L'autoload `Farewell` | `ui/farewell.gd` |
| La figura (56×64) | `assets/effects/watcher.png`, fatta da noi |
| Il glitch | `effects/glitch.gdshader`: [[Shader#Glitch]] |
| La finestra fuori dal gioco, la X | [[Window]] |
| 4 test | `test/ui/farewell_test.gd`: lì la finestra resta dentro il gioco e la chiusura viene solo "segnata" |

![[figura_ombra_8x.png|300]]

## Vedi anche

- [[2026-11-17-congedo]] · [[Effetti visivi]] · [[Schermata iniziale#Qualcuno ti guarda]]
