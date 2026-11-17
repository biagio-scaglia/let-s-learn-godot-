---
data: 2026-11-16
tags:
  - gamelog
  - combattimento
  - rpg
  - animazione
stato: funzionante
aliases:
  - Combattimento v2
  - Abilità, scudi e rottura
---

# 2026-11-16 — Abilità, scudi e un combattimento che si fa sentire

← [[Gamelog]] · Voce precedente: [[2026-11-14-primo-combattimento|Il primo combattimento]] · Successiva: [[2026-11-17-vfx|Più effetti]]

## Obiettivo

Una spritesheet nuova di [[Subaru]] **che combatte** (16 pose: guardia, pugno, calcio, carica, colpito…). Usarla per dargli delle **mosse**, con **suoni ed effetti speciali**. Il combattimento resta a turni, ma con un'**interfaccia nuova**: quella che avevi in mente era uno screenshot di un JRPG moderno, con i turni in alto, il gruppo a destra e le debolezze sotto i nemici.

![[combattimento_v2.png]]

## Come provarlo

1. Avvicinati alla **Melma verde** e premi **E**. Guarda l'**ingresso**: la mappa gira e si sgrana, bande nere inclinate la coprono, poi si aprono sulla battaglia.
2. Sotto la melma ci sono uno **scudo con un numero** e due **"?"**: sono le sue debolezze, ancora da scoprire.
3. **Attacca**: è un pugno, e il primo "?" diventa un pugno. Lo scudo scende di uno.
4. **Abilità → Calcio** (3 PT): scopre la seconda debolezza e lo scudo arriva a zero. **ROTTO!** La melma barcolla e **salta il turno**: in alto, nella barra dei turni, la sua icona è grigia.
5. Contro lo **Spettro** prova **Shamac** (4 PT, una nebbia nera) e **Pugno caricato** (6 PT: Subaru si concentra, lo schermo si avvicina, lampo e scossa).
6. Finiti i PT? **Difendi**: il colpo dopo fa metà danno e ti ridà 2 PT.

![[transizione_battaglia.png|400]] ![[transizione_bande.png|400]]

## Cosa è stato fatto

| Pezzo | Nota |
|---|---|
| `subaru_fight.png`: 4×4 celle da 64×48, stessa palette della v2 | [[Subaru#Il combattimento]], [[Spritesheet]] |
| 7 animazioni nuove: `fight_idle`, `jab`, `kick`, `charge`, `power_punch`, `stagger`, `defend` | [[SpriteFrames]] |
| I **punti tecnica** (PT): 10 a livello 1, +2 a livello; anche nella scheda | [[Statistiche]], [[Scheda del personaggio]] |
| Scudi e debolezze nei nemici: `shield`, `weaknesses` | [[Nemici]] |
| Abilità: Calcio, Shamac, Pugno caricato. E il comando **Difendi** | [[Combattimento#Le mosse]] |
| **Rottura**: scudo a zero → salta un turno, danni ×2 | [[Combattimento#Scudi, debolezze e rottura]] |
| L'interfaccia nuova | più sotto, [[Combattimento#Com'è fatto]] |
| La transizione d'ingresso: `effects/battle_transition.gdshader` | [[Shader#Transizione d'ingresso nel combattimento]] |
| Effetti: scintille, scossa, *hit stop*, aura, nebbia, schegge | [[Particelle#Particelle create dal codice]], [[Effetti visivi#Nel combattimento]] |
| 6 suoni fatti da noi, 2 riusati da [[Kenney]] | [[Sfx#Suoni del combattimento]] |
| `battle_icons.png`: scudo, pugno, calcio, ombra, "?", scudo rotto | [[Pixel art]], [[AtlasTexture]] |
| 11 test nuovi: **89 in tutto** | [[Test con gdUnit4]] |

## L'interfaccia

Come l'altra volta, **niente copiato** da un gioco preciso: ho preso le idee del genere che si vedevano nello screenshot e le ho rifatte con quello che abbiamo.

| Idea | Come l'abbiamo fatta |
|---|---|
| L'ordine dei turni in alto a sinistra | `TurnBar`: le icone le crea il codice (`_refresh_turns()`): chi agisce ora è più grande con il bordo dorato, i turni saltati sono grigi, un trattino separa un giro dal successivo |
| Il gruppo in alto a destra, sopra una sfumatura scura | `Party`: uno [[StyleBox#StyleBoxTexture\|StyleBoxTexture]] con una `GradientTexture2D` orizzontale (trasparente → scuro). Barre sottili da 3 px per PS e PT |
| Comandi in una lista inclinata | Uno `StyleBoxFlat` con **`skew`**: il riquadro diventa un parallelogramma. Vedi [[StyleBox#Inclinato: skew]] |
| Scudo e debolezze sotto il nemico, "?" finché non le scopri | `EnemyInfo`, dentro lo `Stage`: segue il nemico |
| Il nome dell'azione in una striscia in alto, la descrizione in basso | `Announce` e `Help`, stesso stile inclinato. La descrizione cambia quando sposti la manina (segnale `focus_entered`) |
| Sfondo scuro con pulviscolo che sale | La mappa sfocata e scurita di più, la vignettatura, e 26 particelle lente (`Motes`) |

Le finestre blu della prima versione (`BattleWindow`) non le usa più nessuno nel combattimento, ma restano nel [[Theme]].

## Decisioni e perché

- **Le pose.** Riga 1: la guardia che "respira" (4 frame in loop, `fight_idle`). Riga 2: il pugno (carica, passo, colpo, ritorno). Riga 3: ginocchio su e calcio; l'accucciata serve sia per caricare il pugno sia per Shamac; l'ultima posa, in guardia alta, è **Difendi**. Riga 4: colpito, poi la sequenza del pugno caricato con le scintille. Le pose vecchie (`guard`, `punch`, `hurt`) restano: le usano i test e il gioco fuori dal combattimento.
- **Il colpo arriva al frame giusto.** Prima il danno arrivava a fine animazione; ora `_until_frame(2)` aspetta il segnale `frame_changed` finché l'animazione non arriva al frame del pugno teso. Il numero del danno compare nell'istante del contatto.
- **"Hit stop".** Quando un colpo va a segno l'animazione di Subaru si ferma per 0,07 secondi (`speed_scale = 0`). Non lo nota quasi nessuno, ma senza il colpo sembra "vuoto".
- **Si scuote lo `Stage`, non lo schermo.** Così le finestre restano ferme e leggibili, e tremano solo i combattenti.
- **Le debolezze si scoprono giocando.** Il "?" invoglia a provare mosse diverse; `revealed` si azzera a ogni combattimento.
- **Rottura semplice.** Rotto = salta **un** turno e prende ×2 fino al suo turno dopo, in cui si riprende con lo scudo pieno. Il colpo che rompe non ha ancora il ×2.
- **Shamac.** È una magia d'ombra che [[Subaru]] conosce nella storia originale: una nebbia nera che acceca. L'ombra è un terzo "tipo", così le debolezze non sono solo pugno e calcio.
- **PT che tornano.** Se i PT finissero per sempre si potrebbe solo dare pugni. Tornano salendo di livello, con il [[Ritorno dalla Morte]] (`heal_fully()` rimette anche i PT) e **difendendosi** (+2). Difendersi così diventa una scelta, non un turno perso.
- **La barra d'attesa è sparita.** Nella prima versione si riempiva prima di ogni turno di Subaru; con la barra dei turni in alto era un doppione.
- **Transizione in due fasi, uno shader solo.** Nella prima fase lo shader legge lo schermo (la mappa) e lo fa girare; nella seconda (`swirl = 0`) disegna solo le bande, il resto è trasparente, e sotto si vede la battaglia.

## Problemi incontrati

- **Il file giusto.** In `gamelog/assets/` era finito `subaru-combattimento.docx`, che non c'entra niente (un modulo, non un'immagine). La spritesheet era tra i Download: l'ho copiata in `sorgenti/subaru_spritesheet_combattimento.jpg`. Il `.docx` **non è nei commit**: va tolto a mano.
- **La maglietta trasparente.** L'immagine ha lo sfondo bianco, e la maglietta di Subaru è bianca anche lei. Togliendo "tutto il bianco" la maglietta spariva. Soluzione: è sfondo solo il bianco **collegato al bordo** dell'immagine; il bianco chiuso dentro la figura è disegno, tranne i buchi grandi (lo spazio tra le gambe).
- **La griglia dei pixel.** L'immagine è 1686×2528 ma ogni "pixel" della pixel art è circa 13,26 pixel veri. Ho trovato la misura esatta cercando la ripetizione dei bordi di colore, e poi preso il colore al centro di ogni quadretto.
- **Il calcio uccideva la melma troppo presto per le foto.** 14 PS: pugno + calcio bastano. Le foto delle mosse forti sono contro lo spettro.

## Verifica

- **gdUnit: 89 test su 89.** I nuovi: il calcio costa 3 PT e fa di più; senza PT l'abilità non parte e il turno resta tuo; le debolezze si scoprono colpendo; a scudo zero il nemico è rotto, salta il turno, prende il doppio e poi si riprende; difendersi dimezza e ridà PT; Shamac è di tipo ombra; la barra dei turni ha 6 icone e 2 separatori; i PT si spendono solo se bastano, tornano senza superare il massimo, e `heal_fully()` li rimette.
- Ho guardato il gioco vero a schermo, con foto a ogni fase (quelle in questa pagina). **Non ho sentito i suoni:** il volume va provato giocando.

![[combattimento_rotto.png|400]] ![[combattimento_shamac.png|400]]
![[combattimento_carica.png|400]] ![[combattimento_difesa.png|400]]

## Concetti nuovi

- `StyleBoxFlat.skew`: riquadri inclinati → [[StyleBox#Inclinato: skew]]
- Particelle create dal codice, "una botta e via" (`one_shot`, `explosiveness`) → [[Particelle#Particelle create dal codice]]
- Uno shader di transizione in due fasi → [[Shader#Transizione d'ingresso nel combattimento]]
- `frame_changed` per agire a un frame preciso, `speed_scale` per l'hit stop → [[AnimatedSprite2D]]

## Prossimi passi

- **Boost**: accumulare punti a ogni turno e spenderli per colpire più volte.
- Più nemici nello stesso combattimento (la barra dei turni è già pronta ad averne di più).
- Una vera stanza come sfondo, invece della mappa sfocata.
