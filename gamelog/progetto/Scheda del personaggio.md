---
tags:
  - progetto
  - ui
aliases:
  - StatusCard
  - status_card.tscn
  - Menu del personaggio
---

# Scheda del personaggio

← [[Gamelog]]

Il riquadro con i numeri di [[Subaru]], a sinistra delle voci del [[Menu di pausa]] (**Esc**).

![[scheda_personaggio.png|500]]

Mostra: il viso, il livello, i punti salute (numero e barra), attacco, difesa, esperienza verso il prossimo livello, e quante volte è morto.

## Com'è fatta

`ui/status_card.tscn` è una scena a parte, [[Istanza|istanziata]] dentro `pause_menu.tscn`. È un `PanelContainer` con una colonna di `Label` e una [[ProgressBar]].

| Pezzo | Concetto |
|---|---|
| Il viso | Un'[[AtlasTexture]] che ritaglia la testa dal primo frame di `subaru_sheet.png` |
| Nodi presi con `%Nome` | I *nomi unici* della scena: lo script non dipende da dove sta il nodo nell'albero |
| Si aggiorna da sola | Ascolta `Stats.changed` ([[Segnali]]). Il menu di pausa non le passa niente |
| Le morti | Stanno in [[Game]], che per quelle non avvisa: si rileggono ogni volta che la scheda compare (`visibility_changed`) |

## Perché una scena a parte

Il menu di pausa sa solo che c'è un nodo `Status` da mostrare e nascondere insieme al resto. Cosa c'è scritto dentro lo sa solo la scheda. Domani può finire anche in un'altra schermata senza toccarla ([[Composizione]]).

## Vedi anche

- [[Statistiche]] · [[Menu di pausa]] · [[Zaino]]
