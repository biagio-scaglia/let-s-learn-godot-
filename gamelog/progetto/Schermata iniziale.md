---
tags:
  - progetto
  - ui
aliases:
  - Titolo
  - title_screen.tscn
  - Menu principale
---

# Schermata iniziale

← [[Gamelog]]

La prima cosa che si vede avviando il gioco (`ui/title_screen.tscn`, la scena principale).

![[menu_titolo.png]]

## Cosa c'è

| Pezzo | Come |
|---|---|
| Lo sfondo | Il **villaggio vero** ([[Mappa principale]]) caricato da codice, senza [[Subaru]]: il Saggio respira, Emilia è in piazza, i pollini volano |
| La camera | Scorre piano avanti e indietro tra due punti del villaggio ([[Tween]] in loop) |
| La sfocatura | Lo stesso [[Shader]] del [[Menu di pausa]], più leggero: il titolo risalta |
| Le sfumature | Un `GradientTexture2D` verticale, più scuro in alto e in basso |
| I petali | [[Particelle]] rosa e crema che cadono ruotando |
| Il titolo "ERBALTA" | Variazione `TitleLabel` del [[Theme]]: 64 px, contorno e ombra. Galleggia piano su e giù |
| Il menu | Tre [[MenuItem]]: Nuova partita, Opzioni, Esci |
| Le mani d'ombra | `ShadowHands`: qualcuno nel buio afferra la voce che scegli. Vedi più sotto |

## L'entrata

1. Lo schermo compare dal nero ([[Dissolvenza]]).
2. Il titolo scende dall'alto con un piccolo rimbalzo (`TRANS_BACK`).
3. Il sottotitolo e le voci del menu compaiono una alla volta.
4. Alla fine la prima voce riceve il focus.

## Le voci

| Voce | Cosa fa |
|---|---|
| Continua | Solo se c'è un [[Salvataggio]]; già selezionato. Sotto, luogo e data |
| Nuova partita | `Game.new_game()`: dimentica tutto ([[Game]] `flags` e zaino) e va al villaggio |
| Opzioni | Nasconde titolo e menu e apre le [[Opzioni]] |
| Esci | Chiude il gioco |

Il nome **Erbalta** è quello del villaggio sul [[Cartello]]: si cambia nel testo del nodo `UI/Title`.

## Qualcuno ti guarda

Dal [[2026-11-17-mani-d-ombra|17 novembre]], come se una strega nel buio non ti perdesse di vista:

![[mani_presa.png|400]] ![[mani_occhi.png|400]]

| Quando | Cosa succede |
|---|---|
| Selezioni una voce | Una **mano d'ombra** esce dal bordo sinistro, la afferra, la fa tremare e la tira verso di sé. Cambiando voce la lascia e si ritira, sciogliendosi |
| Ogni 5-10 secondi, da sola | Due **occhi viola** si aprono in una macchia di buio e battono le palpebre, con un battito di cuore. A volte con un **sussurro** ("Ti amo…"). Oppure una mano si affaccia e tasta l'aria |
| Confermi Nuova partita o Continua | La mano stringe, ne arrivano altre quattro dagli angoli, gli occhi si aprono sopra il titolo, lo schermo si fa buio e la voce viene **trascinata via** |
| Apri le opzioni | Le mani se ne vanno; tornano quando chiudi |

![[mani_trascinata.png|400]]

È tutto in due script: `ui/shadow_hand.gd` (una mano con il braccio) e `ui/shadow_hands.gd` (chi decide quando e dove). Il nodo `UI/ShadowHands` sta sopra al menu e alle scritte, sotto le [[Opzioni]].
