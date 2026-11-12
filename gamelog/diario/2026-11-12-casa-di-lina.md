---
data: 2026-11-12
tags:
  - gamelog
  - scene
  - luci
stato: funzionante
aliases:
  - Casa di Lina (diario)
---

# 2026-11-12 — Si entra in casa

← [[Gamelog]] · Voce precedente: [[2026-11-12-interazioni-e-rifiniture|Interazioni e rifiniture]]

## Obiettivo

Il secondo passo verso l'RPG: **entrare in un edificio**, cioè cambiare scena. E farlo bene: dissolvenza, suono, punto d'arrivo giusto, e senza che il mondo si dimentichi di te.

![[casa_interno.png]]

## Come provarlo

Dalla piazza vai verso nord-ovest: c'è una casa col tetto rosso, con un vialetto e un varco nella staccionata. Cammina nella porta.

## Cosa è stato fatto

### Fuori: la casa

La casa è fatta di tile di [[Tiny Town]], nel livello degli oggetti del villaggio: due file di tetto e una di muro, con finestre e porta. Il tetto ha uno *Y Sort Origin* spostato alla base del muro, come le chiome degli alberi. Vedi [[Casa di Lina]].

![[casa_esterno.png|500]]

### Il cambio di scena

| Pezzo | Cosa fa |
|---|---|
| [[Porta]] | Un'Area2D: quando ci entri chiama `Game.change_scene()` |
| [[Game]] (nuovo autoload) | Suono della porta, dissolvenza, cambio di scena, dissolvenza |
| `level.gd` | Nella nuova scena, sposta il giocatore sul Marker2D giusto e lo gira |
| Marker2D in `Spawns` | I punti d'arrivo |

Spiegato in [[Cambio di scena]] e [[Await]].

### La memoria

Cambiando scena tutto viene distrutto e ricreato, quindi il [[Saggio]] si sarebbe dimenticato di te. Ora il contatore delle conversazioni di ogni [[Interactable]] sta in `Game.flags`, che non viene mai distrutto.

### Dentro: la casa di Lina

- Pavimento, muri e mobili di [[Tiny Dungeon]], generati dal [[Generatore della casa]].
- **Più buio** ([[CanvasModulate]]), con una **torcia che tremola** e la **luce fredda** della finestra: [[Luci 2D]].
- **[[Lina]]**, la nipote del Saggio: stessa scena del Saggio, con un altro personaggio di Tiny Dungeon (`sprite_tile = 99`).
- Un **baule chiuso a chiave** e una **libreria** da esaminare.
- La camera resta ferma al centro della stanza, che è più piccola dello schermo.

## Decisioni e perché

- **Porte "a camminata", non "a tasto":** come nei classici RPG, entri camminando nella porta. Il tasto E resta per parlare ed esaminare.
- **Memoria in un autoload:** un unico posto per tutto ciò che va ricordato. Servirà per inventario e salvataggio.
- **La chiave come prossimo obiettivo:** il baule chiuso prepara l'inventario.

## Problemi incontrati

- **Angoli marroni:** i tile "testa" e "piede" delle colonne di Tiny Dungeon hanno lo sfondo marrone. Negli angoli della stanza stonavano: ora la colonna usa sempre lo stesso tile.
- **Test del dialogo rotto:** il Saggio ora dice tre frasi la seconda volta (manda da Lina), e il test premeva E un numero fisso di volte. Ora il test va avanti finché il dialogo non si chiude, qualunque sia il numero di frasi.

## Verifica

| Test | Controlli |
|---|---|
| [[Test di casa]] (nuovo) | 10, tutti ok |
| [[Test del dialogo]] | 17, tutti ok |
| [[Test automatico]] della corsa | ok |

## Prossimi passi

- [ ] Trovare la chiave del baule (inventario)
- [ ] Una seconda mappa (il bosco a nord?)

## Collegamenti

- **Progetto:** [[Casa di Lina]] · [[Lina]] · [[Game]] · [[Porta]] · [[Saggio]] · [[Interactable]] · [[Mappa principale]] · [[Tiny Town]] · [[Tiny Dungeon]]
- **Strumenti:** [[Generatore della casa]] · [[Generatore della mappa]] · [[Test di casa]] · [[Test del dialogo]]
- **Concetti:** [[Cambio di scena]] · [[Await]] · [[Luci 2D]] · [[CanvasModulate]] · [[Autoload]] · [[Area2D]] · [[Camera2D]] · [[Y-sort]]
