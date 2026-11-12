---
data: 2026-11-12
tags:
  - gamelog
  - dialoghi
  - effetti
  - personaggi/saggio
stato: funzionante
aliases:
  - Primo dialogo
---

# 2026-11-12 — Il primo dialogo, e un po' di atmosfera

← [[Gamelog]] · Voce precedente: [[2026-11-12-mappa-e-corsa|Mappa e corsa]]

## Obiettivo

Primo passo verso un RPG vero: **un personaggio con cui parlare**. E già che c'eravamo, rendere il mondo più vivo con ombre, particelle e altri effetti.

![[dialogo.png]]

## Come provarlo

Avvia con **F5**, cammina fino al mago nella piazza: sopra la sua testa compare una nuvoletta. Premi **E** (oppure Spazio o Invio).

| Tasto | Azione |
|---|---|
| Frecce / WASD | Muoversi |
| Shift | Correre |
| E / Spazio / Invio | Parlare, andare avanti nel dialogo |

## Cosa è stato fatto

### 1. Il Saggio

Un nuovo personaggio, il [[Saggio]]. È una [[Scena]] riutilizzabile (`characters/npc/npc.tscn`): nome e frasi si cambiano dall'Inspector.

- È un [[StaticBody2D]]: non lo si attraversa.
- Ha un'[[Area2D]] intorno: quando [[Subaru]] (che è nel [[Gruppi|gruppo]] `player`) ci entra, il [[Segnali|segnale]] `body_entered` lo avvisa e compare la nuvoletta.
- Premendo `interact` apre il dialogo e fa girare Subaru verso di lui.
- "Respira" e la nuvoletta saltella, grazie ai [[Tween]].

L'immagine è il mago di [[Tiny Dungeon]] (Kenney, CC0).

### 2. La finestra di dialogo

La [[Finestra di dialogo]] è un [[Autoload]] chiamato `Dialogue`: esiste sempre, e qualsiasi script può usarla con `Dialogue.start(nome, frasi)`.

- Testo **a macchina da scrivere**, con un "blip" ogni due lettere ([[Audio]]).
- Premere durante la scrittura mostra subito la frase intera.
- Una freccia che saltella indica che si può andare avanti.
- Entra ed esce sfumando.
- Mentre è aperta, Subaru non si muove.
- Font pixel [[KenPixel]] High Square (Kenney, CC0), con le lettere accentate.

### 3. Gli effetti

Raccolti nella nota [[Effetti visivi]]:

![[polvere.png|400]]

| Effetto | Concetto |
|---|---|
| Ombre ai piedi dei personaggi | [[Sprite2D]] |
| Ombre sotto gli alberi | Un nuovo livello di tile `Shadows` ([[TileMapLayer]]) e una seconda sorgente nel [[TileSet]] |
| Polvere quando Subaru corre | [[Particelle]] |
| Pollini nell'aria | [[Particelle]] |
| Luce calda | [[CanvasModulate]] |
| Angoli più scuri (vignettatura) | [[Shader]] in un [[CanvasLayer]] |

Ombre, icone e suono sono disegnati dal codice con il [[Generatore degli effetti]]: niente asset esterni.

## Decisioni e perché

- **Autoload per i dialoghi:** ci sarà un solo dialogo alla volta e tanti personaggi che lo usano. Un nodo globale evita di metterne una copia in ogni scena.
- **Il PNG gestisce il suo tasto:** ogni PNG sa se il giocatore gli è vicino, quindi è lui a decidere se aprire il dialogo. Subaru non deve conoscere i PNG.
- **Azione `interact` separata:** E, Spazio e Invio fanno la stessa cosa; in futuro servirà anche per aprire porte e raccogliere oggetti.
- **Frasi nell'Inspector (`@export_multiline`):** per scrivere un nuovo dialogo non serve toccare il codice.

## Problemi incontrati

- **La prima frase che "salta":** premendo E, il Saggio apre il dialogo, ma lo stesso evento arriverebbe subito dopo alla finestra, che lo prenderebbe come "vai avanti". Soluzione: il Saggio chiama `set_input_as_handled()`. Spiegato in [[Eventi di input]].
- **Font senza accenti:** KenPixel normale non ha à, è, ù. Li abbiamo provati prima di scegliere: la versione *High Square* li ha. Vedi [[KenPixel]].
- **Font sfocato:** di default Godot sfuma i bordi delle lettere. Abbiamo reimportato il font senza antialiasing, hinting e subpixel. Vedi [[Font]].
- **Polvere invisibile:** il primo colore della polvere era quasi uguale a quello del sentiero. Resa più chiara e più grande.
- **Ombra del Saggio nascosta:** lo sprite è largo e copriva l'ombra. Ingrandita.
- **Gli errori "Failed loading" alla prima importazione:** l'autoload provava a caricare il font prima che Godot lo avesse importato. Alla seconda importazione spariscono.

## Verifica

Il [[Test del dialogo]] fa 11 controlli automatici: tutti ok. Anche il [[Test automatico]] della corsa passa ancora.

## Prossimi passi

- [ ] Un PNG che dice cose diverse la seconda volta (variabili e stato)
- [ ] Entrare in una casa (cambio scena)
- [ ] Raccogliere oggetti (inventario)

## Collegamenti

- **Progetto:** [[Saggio]] · [[Finestra di dialogo]] · [[Effetti visivi]] · [[Subaru]] · [[Mappa principale]] · [[Tiny Dungeon]] · [[KenPixel]] · [[Kenney]]
- **Strumenti:** [[Generatore degli effetti]] · [[Generatore della mappa]] · [[Test del dialogo]]
- **Concetti:** [[Autoload]] · [[Area2D]] · [[Segnali]] · [[Gruppi]] · [[Eventi di input]] · [[Tween]] · [[Particelle]] · [[Shader]] · [[CanvasLayer]] · [[CanvasModulate]] · [[Interfaccia (Control)]] · [[StyleBox]] · [[Font]] · [[Audio]] · [[Sprite2D]]
