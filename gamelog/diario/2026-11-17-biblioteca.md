---
data: 2026-11-17
tags:
  - gamelog
  - mappa
  - pixel-art
  - effetti
stato: funzionante
aliases:
  - La biblioteca
---

# 2026-11-17 — La biblioteca di Erbalta

← [[Gamelog]] · Voce precedente: [[2026-11-17-congedo-v3|Lei accanto, le mani che strappano, l'occhio che ti segue]] · Successiva: [[2026-11-17-colonna-sonora|La colonna sonora]]

## Obiettivo

Un **tileset nostro**, disegnato da zero in pixel art, e una seconda stanza esplorabile costruita con quello: la [[Biblioteca]]. Con le solite luci d'atmosfera, una porta sul villaggio e un po' di dialoghi.

![[biblioteca_interno.png]]

## Come provarlo

1. Nel villaggio vai a **nord-est**: c'è una casa di **pietra col tetto grigio**, con un sentierino che scende alla strada. Entra dalla porta.
2. Dentro è notte, anche se fuori è giorno. Guarda i **raggi di luna** che entrano dalle finestre, con la polvere che ci galleggia dentro, e le **candele che tremolano**.
3. Parla con l'**Archivista** (la signora coi capelli grigi vicino alla scrivania).
4. Premi **E** davanti a: i quattro blocchi di **scaffali**, il **mappamondo**, la **mappa** e la **finestra** sul muro, la **scrivania**, e il **libro nero** sul leggio (quello che brilla di viola).
5. Esci dal varco in basso: torni davanti alla porta della biblioteca.

![[biblioteca_esterno.png|500]]

## Cosa è stato fatto

| Pezzo | Nota |
|---|---|
| `assets/library/library_tiles.png`: 54 tile da 16×16 (pavimenti, muri, librerie, tappeto, mobili, oggetti) | [[Biblioteca#Il tileset]], [[Pixel art]] |
| `world/library_tileset.tres`: collisioni e Y-sort di ogni tile | [[TileSet#Oggetti alti più tile]] |
| `world/library.tscn`: la stanza, 24×15 tile, più grande dello schermo | [[Biblioteca]] |
| Raggi di luna: `Polygon2D` con un colore per vertice e materiale additivo | [[Luci 2D#Raggi di luce senza texture]] |
| Polvere nei raggi e scintille viola sul libro nero | [[Particelle]] |
| 8 fiamme con `flicker.gd`, e una luce viola che "respira" lenta | [[Luci 2D#La fiamma che tremola]] |
| Nel villaggio: casa di pietra (tile di [[Tiny Town]] già nell'immagine, aggiunti al [[TileSet]]), sentiero, porta, punto d'arrivo | [[Mappa principale]], [[Porta]] |
| Il Saggio ha una frase nuova sulla biblioteca | [[Saggio]] |
| `assets/music/library_theme.wav`: la musica della biblioteca, in loop | [[#La musica]], [[Audio#Musica in loop]] |
| `test/world/library_test.gd`: 4 test (porte, Archivista, musica, fiamme): **115 in tutto** | [[Test con gdUnit4]] |

![[biblioteca_tileset_6x.png]]

*Il tileset ingrandito 6 volte, con la griglia. Le librerie sono alte 2 tile; il tappeto è un 3×3.*

## Come funzionano

- **Il tileset è generato da uno script Python** (con Pillow), come gli effetti del [[Generatore degli effetti]]: ogni tile è disegnato su una tela 16×16 pixel per pixel, con la palette di [[Tiny Dungeon]] (stesso contorno scuro `#3f2631`). Gli oggetti piccoli sono "disegnati a caratteri": una riga di testo per riga di pixel, una lettera per colore. Lo script è rimasto fuori dal repository, come da regola ([[Strumenti archiviati]]).
- **Tile che si ripetono senza cuciture.** Il pavimento ha le assi alte 4 pixel: 16 è divisibile per 4, quindi la riga sotto di un tile combacia con la riga sopra del tile successivo. Il tappeto ha un motivo che si ripete ogni 16 pixel: il tile centrale si può ripetere quante volte si vuole, e i bordi restano solo nei tile del contorno.
- **Librerie componibili**: cinque versioni (singola, singola mezza vuota, inizio, centro, fine). Mettendo *inizio + centro + centro + fine* si ottiene uno scaffale lungo quanto si vuole.
- **Librerie alte 2 tile e Y-sort**: la parte di sopra ha `y_sort_origin = 24`, cioè "ordinami come se fossi 24 pixel più in basso", alla base della libreria. Così Subaru passa *dietro* tutta la libreria, non solo dietro metà. È lo stesso trucco degli alberi: [[TileSet#Oggetti alti più tile]].
- **I raggi di luna** sono trapezi (`Polygon2D`) con `vertex_colors`: azzurri e un po' trasparenti in alto, trasparenti del tutto in basso. Godot sfuma i colori tra i vertici da solo. Il materiale ha `blend_mode = Add` (si somma, come una luce) e `light_mode = Unshaded` (il buio del [[CanvasModulate]] non lo scurisce).
- **La camera segue Subaru** con dei limiti: la stanza (768×480) è più grande dello schermo (640×360), quindi un po' si esplora. Nella casa di Lina invece la camera è ferma.
- **Nessuno script nuovo**: la stanza usa solo pezzi che esistevano già (`level.gd`, [[Interactable]], [[Porta]], NPC, `flicker.gd`). Il NPC dell'Archivista è il personaggio 100 di [[Tiny Dungeon]].

## La musica

La biblioteca ha la sua colonna sonora: `assets/music/library_theme.wav`, un **valzer lento in re minore** (66 battiti al minuto, 32 battute, 87 secondi) che si ripete all'infinito. L'atmosfera è quella delle biblioteche dei vecchi horror fatti con RPG Maker, ma la melodia è nostra.

- **Tutto sintetizzato in Python** (numpy + scipy), senza campioni: ogni nota è una somma di onde sinusoidali che si spengono piano.
  - **Carillon**: la melodia, con armoniche "stonate" (4,2 e 6,8 volte la nota) come le lamelle di metallo vere, e un'altezza che ondeggia appena.
  - **Pianoforte**: basso sul primo battito, accordo sul secondo e sul terzo (il "um-pa-pa" del valzer).
  - **Archi**: accordi tenuti, tre voci leggermente scordate tra loro, che entrano e escono piano.
  - **Bordone** di re grave sempre sotto, e il **tic-tac di un orologio** su ogni battito.
  - Nella seconda metà, un **secondo carillon appena stonato** suona insieme al primo: qualcosa non torna.
- **Riverbero** per convoluzione: il suono viene "mescolato" con un rumore che si spegne in 3 secondi, come l'eco di una stanza grande.
- **Loop senza stacchi.** La coda del riverbero che uscirebbe dalla fine viene **sommata all'inizio**: quando il brano ricomincia, l'eco dell'ultima nota c'è ancora.
- **In Godot**: un `AudioStreamPlayer` con `autoplay`. Il loop si attiva nell'**import** del WAV (`Loop Mode: Forward`), vedi [[Audio#Musica in loop]]. Quando si esce, la scena viene liberata e la musica si ferma da sola.

## Problemi incontrati

- **Il primo pavimento sembrava di mattoni.** Le righe tra le assi erano quasi nere e le giunture capitavano tutte alla stessa distanza. Con righe più chiare e alcune file *senza* giunture, le assi sembrano più lunghe e si legge "legno".
- **Mobili invisibili sul pavimento.** Nella prima versione pavimento e mobili avevano gli stessi marroni. Un pavimento più scuro fa risaltare tutto il resto: il contrasto conta più dei dettagli.
- **Il muro era alto un tile solo** e la stanza sembrava schiacciata. Ora è alto due: mattoni sopra, boiserie di legno sotto.

## Concetti nuovi

- Raggi di luce fatti con un poligono e i colori per vertice → [[Luci 2D#Raggi di luce senza texture]]
- Tile che si ripetono senza cuciture, e tile "a pezzi" (3×3, inizio/centro/fine) → [[Pixel art#Tile che si ripetono]]
