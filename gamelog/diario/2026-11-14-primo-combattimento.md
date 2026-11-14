---
data: 2026-11-14
tags:
  - gamelog
  - combattimento
  - rpg
stato: funzionante
aliases:
  - Primo combattimento
---

# 2026-11-14 — Il primo combattimento

← [[Gamelog]] · Voce precedente: [[2026-11-14-azioni-di-subaru|Subaru cade, si rialza ed esulta]]

## Obiettivo

Usare i pugni della spritesheet delle azioni per un piccolo **combattimento**, e imparare le basi di un gioco di ruolo: **statistiche**, **turni**, **danni**, **esperienza e livelli**, **oggetti che curano**, e una **scheda del personaggio**.

![[combattimento.png]]

## Come provarlo

1. In piazza, a est, c'è una **Melma verde** che saltella. Avvicinati e premi **E**.
2. Aspetta che la **barra d'attesa** si riempia, poi scegli **Attacca**: Subaru scatta e tira un pugno, poi tocca alla melma. Sconfiggila: 10 punti esperienza, e sali al **livello 2**.
3. Premi **Esc**: a sinistra del menu c'è la **scheda di Subaru** con livello, salute, attacco, difesa, esperienza e morti.
4. Più a nord-est c'è uno **Spettro**, molto più forte. Senza pozioni è dura: prendile dal baule di Lina ([[Missione della chiave]]).
5. In combattimento scegli **Oggetti → Pozione** per curarti (costa il turno; Esc torna ai comandi). Fuori, apri lo zaino con **Tab**, seleziona la pozione e premi **Invio**.
6. Prova a perdere: Subaru crolla, e parte il [[Ritorno dalla Morte]]. Al risveglio la melma è di nuovo lì e tu sei tornato al livello che avevi al punto di ritorno.

![[combattimento_pugno.png|400]] ![[scheda_personaggio.png|400]]

## Cosa è stato fatto

| Pezzo | Nota |
|---|---|
| Autoload `Stats`: livello, esperienza, salute, attacco, difesa | [[Statistiche]] |
| Autoload `Battle`: il combattimento a turni | [[Combattimento]] |
| `EnemyData` e i file `melma.tres`, `spettro.tres` | [[Nemici]], [[Risorse personalizzate]] |
| `characters/enemy/enemy.tscn`: il nemico sulla mappa | [[Nemici]] |
| La pozione cura 12 PS: `heal` in `Item`, `Inventory.use()` | [[Oggetti]], [[Inventory]] |
| Lo zaino usa gli oggetti (Invio) e mostra i PS | [[Zaino]] |
| La scheda di Subaru nel menu di pausa | [[Scheda del personaggio]], [[Menu di pausa]] |
| Statistiche nel salvataggio e nel punto di ritorno | [[Salvataggio]], [[Ritorno dalla Morte]] |
| 4 animazioni nuove: `guard`, `punch`, `hurt`, `weak` | [[Subaru#Le azioni]] |
| 3 suoni nuovi fatti da noi: colpo, cura, livello | [[Sfx]] |
| La UI in stile gioco di ruolo classico: finestre blu, manina, barra d'attesa | più sotto, [[StyleBox#StyleBoxTexture]] |
| 26 test nuovi | [[Test con gdUnit4]] |

## La UI in stile gioco di ruolo classico

Dopo la prima versione (finestre viola del resto del gioco, Subaru a sinistra) hai chiesto qualcosa di più "da JRPG", tipo Final Fantasy. Non ho copiato niente di un gioco preciso: ho preso le **convenzioni del genere** e le ho disegnate da zero.

| Convenzione | Come l'abbiamo fatta |
|---|---|
| Finestre blu sfumate con la cornice chiara | Un'immagine 32×32 fatta da noi (`window_battle.png`) e uno `StyleBoxTexture` in 9 pezzi, la variazione `BattleWindow` del [[Theme]] |
| I nemici a sinistra, gli eroi a destra | Subaru è a destra e guarda a sinistra con `flip_h` (le sue azioni sono disegnate verso destra) |
| In basso: nemici · comandi · gruppo | Tre finestre in un `HBoxContainer`. Quella dei comandi resta vuota quando non tocca a te |
| La manina come cursore | `cursor_hand.png`; [[MenuItem]] ora accetta un cursore diverso (`cursor_texture`) |
| Il nome dell'azione in alto ("Pugno", "Pozione", il nome del nemico) | La finestra `Help`: `_announce()` non aspetta, `_say()` aspetta un tasto |
| La barra d'attesa che si riempie | Una [[ProgressBar]] gialla che si riempie prima di ogni tuo turno e lampeggia quando è piena |
| Sottomenu degli oggetti | Si apre sopra i comandi; Esc torna indietro |
| Numeri dei danni che rimbalzano | Una `Label` creata al volo: sale, ricade, rimbalza piano, svanisce |
| PS gialli quando sono pochi, Subaru in ginocchio | `_idle()` sceglie `weak` sotto un quarto della salute |
| Entrata con due lampi, il nemico che si scioglie, la finestra "Vittoria!" | [[Tween]] su colore, scala e posizione |

> [!note] La barra d'attesa per ora è solo scena
> Nei giochi con il tempo attivo (ATB) le barre di tutti si riempiono insieme, e chi è più veloce agisce più spesso. Qui i turni restano alternati: la barra si riempie e poi tocca a te. È il primo passo: per un ATB vero servirebbe una statistica *velocità* e una barra anche per il nemico.

![[combattimento_oggetti.png|400]] ![[combattimento_vittoria.png|400]]

![[combattimento_poca_salute.png|400]]

## Decisioni e perché

- **A turni, non in tempo reale.** I pugni della spritesheet guardano solo a destra: perfetti per uno scontro "di lato" (Subaru a sinistra, nemico a destra), scomodi per picchiare in quattro direzioni sulla mappa. E a turni ogni regola si vede una alla volta: chi attacca, quanto toglie, cosa succede dopo.
- **La formula più semplice che funziona:** `danno = attacco − difesa + tiro`, con il tiro da −1 a +1 e **mai meno di 1**. Si capisce a colpo d'occhio dalla scheda: Subaru (attacco 5) contro la melma (difesa 1) toglie 3–5.
- **I numeri di Subaru in un autoload, quelli dei nemici in risorse.** Subaru è uno solo e i suoi numeri devono sopravvivere ai cambi di scena: [[Autoload]]. I nemici sono tanti tipi con gli stessi campi: una [[Risorse personalizzate|risorsa]] per tipo, come gli [[Oggetti]]. Aggiungere un nemico = un file `.tres`, zero codice.
- **`Battle.start()` si può aspettare.** Il nemico sulla mappa scrive `var result = await Battle.start(data)` e va avanti solo a combattimento finito, con il risultato in mano. Non deve sapere niente di turni e menu.
- **Perdere è morire.** Niente "game over" a parte: la sconfitta chiama `ReturnByDeath.die()`, che c'era già. Una regola in meno da inventare, e il combattimento entra nella storia.
- **Al Ritorno si è in piena salute.** Livello ed esperienza tornano com'erano al punto di ritorno, ma i PS sono al massimo: altrimenti chi muore con 1 PS si risveglierebbe con 1 PS davanti allo stesso nemico.
- **La pozione non si spreca:** se sei in piena forma `Inventory.use()` risponde 0 e la pozione resta nello zaino; in combattimento non perdi nemmeno il turno. La regola sta in un posto solo, e la usano sia lo zaino sia il combattimento.
- **I dadi sono una variabile** (`Battle.rng`): i test fissano il *seme* e ottengono sempre gli stessi tiri. Vedi [[Numeri casuali]].
- **La scheda nel menu di pausa, non un menu in più.** Esc è già il tasto che tutti premono: la scheda è lì accanto, senza un altro tasto da ricordare.

## Problemi incontrati

- **Subaru tirava pugni all'aria.** Alla prima prova a schermo restava fermo a sinistra e colpiva il vuoto. Ora scatta fin davanti al nemico mentre parte l'animazione, e torna al suo posto dopo il messaggio.
- **Un test che cambiava scena.** Volevo provare nei test che il Ritorno rimette livello e salute, ma dentro gdUnit non esiste una "scena corrente" e `Game.set_checkpoint()` non fa niente. L'ho tolto e ho verificato quel punto giocando davvero (vedi sotto).

## Verifica

- **gdUnit: 78 test su 78.** I 26 nuovi: 11 sulle statistiche (formula del danno, cura, livelli, salvataggi vecchi), 3 sull'uso degli oggetti, 12 sul combattimento (un turno, vittoria con livello, sconfitta con morte, pozione, pozione senza averne, pozione in piena forma, fuga riuscita e fallita, la melma sulla mappa che sparisce, il sottomenu degli oggetti con Esc, Subaru in ginocchio con poca salute).
- **La nuova UI provata a schermo:** entrata, comandi, sottomenu, numero del danno, vittoria con livello, poca salute. Gli screenshot di questa pagina sono di quella prova. Al primo giro la finestra dei comandi copriva il nome del nemico e l'ombra di Subaru restava indietro quando scattava: sistemati entrambi.
- **Prova a schermo con uno script usa e getta:** melma sconfitta in 4 turni usando una pozione, livello 2 con 25/25 PS; sconfitta contro lo Spettro, game over, *Ritorna*: di nuovo livello 1 con 20/20 PS, zaino com'era, melma di nuovo sulla mappa. Le immagini di questa pagina vengono da lì.
- **Non provato a mano con la tastiera:** l'ordine dei tasti nei menu del combattimento è lo stesso degli altri menu, ma vale la pena giocarci.
- Il salvataggio vero non è stato toccato (lo script usava un file suo).

## Concetti nuovi

- [[Numeri casuali]]: `RandomNumberGenerator`, il seme, perché serve nei test
- [[ProgressBar]]: le barre della salute
- Aspettare un segnale che porta un valore: aggiunto ad [[Await]]
