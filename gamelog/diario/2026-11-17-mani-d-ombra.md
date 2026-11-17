---
data: 2026-11-17
tags:
  - gamelog
  - effetti
  - interfaccia
  - pulizia
stato: funzionante
aliases:
  - Mani d'ombra
  - Qualcuno ti guarda
---

# 2026-11-17 — Mani d'ombra nel titolo, e il combattimento in ordine

← [[Gamelog]] · Voce precedente: [[2026-11-17-plugin|Tre plugin per i futuri RPG]]

## Obiettivo

Nella [[Schermata iniziale]], **mani d'ombra** che afferrano le voci del menu, come se ci fosse una strega nel buio a guardarti. Poi sistemare i difetti trovati rileggendo il codice del [[Combattimento]].

![[mani_presa.png]]

## Come provarlo

1. Avvia il gioco e muoviti nel menu con le frecce: a ogni voce una mano esce da sinistra, la afferra e la tira un po'. Cambia voce in fretta: la mano lascia e si scioglie.
2. Aspetta senza toccare niente: ogni tanto si aprono due **occhi viola** nel buio (con un battito di cuore), a volte con un **sussurro**; oppure una mano si affaccia dal basso o da destra e tasta l'aria.
3. Premi **Nuova partita**: la mano stringe, ne arrivano altre quattro, gli occhi si aprono sopra il titolo e la voce viene trascinata via nel buio.

![[mani_occhi.png|400]] ![[mani_trascinata.png|400]]

## Le mani

| Pezzo | Nota |
|---|---|
| `assets/effects/shadow_hand.png`: 4 pose da 40×28 (aperta, artigli, si chiude, pugno) | [[Spritesheet]], fatta da noi |
| `assets/effects/watching_eyes.png`: occhi aperti, socchiusi, chiusi | idem |
| `effects/shadow.gdshader`: la mano ondeggia di un pixel e si scioglie a quadretti | [[Shader#Ombra viva]] |
| `ui/shadow_hand.gd` (`ShadowHand`): **una** mano col suo braccio | [[Line2D]] per il braccio |
| `ui/shadow_hands.gd` (`ShadowHands`): chi decide quando arrivano, cosa afferrano, gli occhi | nodo `UI/ShadowHands` |
| 4 test in `test/ui/shadow_hands_test.gd` | [[Test con gdUnit4]] |

![[mano_ombra_10x.png]]
![[occhi_10x.png]]

- **Come si muove una mano.** Il braccio va da `origin` (fuori dallo schermo) a `tip` (il polso). Per allungarla basta un [[Tween]] su `tip`: il braccio si ridisegna da solo in `_process()`. Per ritirarla, `tip` torna a `origin`.
- **Il polso nel punto giusto.** Lo sprite ha `centered = false` e un `offset` che mette il polso sull'origine del nodo: così la mano ruota attorno al polso, seguendo la direzione dell'ultimo pezzo di braccio.
- **Una mano alla volta.** `_grab()` aspetta che la mano arrivi (`await`), ma nel frattempo si può già essere passati a un'altra voce. Al ritorno controlla `if hand != mine`: se non è più lei la mano "giusta", non stringe niente.
- **Gli occhi** sono un `Sprite2D` con dietro una macchia di buio: un figlio con `show_behind_parent = true` e una `GradientTexture2D` radiale.

## Il combattimento in ordine

I sei difetti trovati rileggendo il codice:

| Difetto | Correzione |
|---|---|
| Gli effetti usavano i **dadi** del combattimento: una stella girata cambiava il danno dopo | `BattleVfx` ha il suo `rng`. Un test lo controlla: dopo dieci stelle e dieci scosse, il prossimo tiro di `Battle.rng` è lo stesso |
| `battle.gd` era lungo **1210 righe** | Gli effetti (circa 340 righe) sono in `ui/battle_vfx.gd`; `battle.gd` è a 904. Vedi [[Responsabilità]] |
| Il nemico diventava bianco **due volte** alla vittoria | Tolto il vecchio `modulate` |
| `sheet.get_width() / cell`: divisione tra interi | `for x in range(0, larghezza, cella)`: si scorre a passi di una cella |
| Un test aspettava **300 ms fissi** | Ora aspetta *finché* gli effetti spariscono (al massimo 2 s) |
| `_set_flash(valore, sprite)`, argomenti al contrario | `set_flash(sprite, valore)` e `flash_white(sprite, tempo)` |

## Problemi incontrati

- **Un bug vero, trovato da un test.** Il test "cambiando voce, la prima torna al suo posto" passava da solo e falliva insieme agli altri. Il motivo: la voce afferrata **trema** per un quarto di secondo. Se la lasci prima che finisca, il tremito continua *dopo* il ritorno, e la voce resta spostata di 5 pixel. Con il computer più impegnato i tempi si sovrapponevano. Soluzione: il [[Tween]] del tremito si tiene in una variabile (`_pull`) e si ferma (`kill()`) quando la mano lascia.
- **Una lambda e un oggetto cancellato.** Nel test, `func(): return not is_instance_valid(old_hand)` stampava un errore: la lambda "tiene" la mano, e la mano viene cancellata. Si tiene l'**id** (`get_instance_id()`) e si controlla con `is_instance_id_valid()`.
- **Mano troppo piccola.** Nella prima foto la mano era una macchiolina in fondo a un braccio enorme: ingrandita (×1,6) e con il bordo viola più chiaro.

## Verifica

- **gdUnit: 96 test su 96**, due volte di fila. I nuovi: la voce scelta viene afferrata; cambiando voce torna a posto e la vecchia mano si cancella; confermando la voce viene trascinata via; con le opzioni aperte le mani si spengono. E: gli effetti non usano i dadi del combattimento.
- Foto del titolo vero (quelle qui sopra) e di nuovo del combattimento, dopo lo spostamento degli effetti: identico a prima.
- **Non verificato:** l'avviso giallo della divisione tra interi l'ho tolto senza vederlo nell'editor; i suoni (battito, fruscio) vanno sentiti giocando.

## Concetti nuovi

- [[Line2D]]: linee che si ridisegnano a ogni frame
- Uno shader che fa ondeggiare e sciogliere uno sprite → [[Shader#Ombra viva]]
- Fermare un Tween con `kill()`, e perché serve
- `show_behind_parent`: un figlio disegnato **dietro** al padre
