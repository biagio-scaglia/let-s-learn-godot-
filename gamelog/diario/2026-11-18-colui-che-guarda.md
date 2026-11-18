---
data: 2026-11-18
tags:
  - gamelog
  - storia
  - combattimento
  - audio
stato: funzionante
aliases:
  - Il boss
  - Colui che guarda (diario)
---

# 2026-11-18 — Atto 3, pezzo 3: Colui che guarda

← [[Gamelog]] · Voce precedente: [[2026-11-18-interpolazione|Lo scatto della camera]]

## Obiettivo

Il boss del gioco, "super figo" (parole dell'autore), con la sua colonna sonora e un'**ultimate** finale di Subaru ed Emilia insieme. E il trucco promesso: un boss che si batte davvero solo dopo essere morti una volta, grazie al [[Ritorno dalla Morte]].

![[boss_risveglio.png|500]]

## Come provarlo

1. Apri la nebbia (i tre occhi di pietra) ed entra nella radura.
2. **Il risveglio:** la camera sale verso l'occhio, un ruggito, tutti gli occhi del bosco si spalancano. *"...Ancora tu. Ogni volta torni. Ogni volta muori. E ogni volta, resti."*
3. **La battaglia**, con il tema del boss. Al secondo turno l'occhio **carica lo Sguardo**: la scena diventa rossa e pulsa. Al turno dopo parte il raggio: 70% della vita di Subaru.
4. Se muori: il Ritorno ti riporta alla nebbia aperta, ma **Subaru ricorda**. Rientrando: *"Di nuovo qui. Ma stavolta ricordo il tuo sguardo."* In battaglia la debolezza "ombra" è già scoperta, e quando l'occhio carica: *"Lo Shamac, subito!"*
5. **Shamac mentre carica:** l'occhio è ACCECATO, lo Sguardo non parte, lo scudo va in frantumi.
6. Al 60% le mani si moltiplicano; sotto il 25%: *"Subaru ed Emilia si guardano: è il momento!"* Nel menu compare **Alba di cristallo**.
7. Dopo la vittoria l'occhio si crepa e svanisce, gli occhi dei rovi si chiudono uno dopo l'altro, la nebbia si dirada, la luce si scalda. Obiettivo: *Torna a Erbalta con Emilia* (pezzo 4).

![[boss_carica.png|500]]
![[boss_sguardo.png|500]]

## L'ultimate: Alba di cristallo

![[ultimate_ritratti.png|500]]

1. Buio. Due strisce entrano dai lati: Subaru (rossa) ed Emilia (blu), e in mezzo il nome della mossa che rimbalza.
2. Emilia evoca un **anello di scaglie** attorno all'occhio; Subaru si carica d'**ombra**, nevica.
3. Dalla mano di Emilia nasce una **lancia di cristallo** enorme; partono insieme.
4. L'impatto: tre onde d'urto, il cristallo che esplode, scintille azzurre, viola e oro, e una **luce d'alba** che riempie lo schermo.

![[ultimate_lancia.png|500]]
![[ultimate_alba.png|500]]

## Cosa è stato fatto

| Pezzo | Nota |
|---|---|
| `assets/enemies/colui_che_guarda.png`: 5 pose da 96×96, con un alone viola per staccarlo dal buio | [[Colui che guarda]] |
| `enemies/colui_che_guarda.tres`: 150 PS, scudo 4, debole a ombra e ghiaccio, grande ×2,2, con la sua musica | [[Colui che guarda]] |
| `enemies/battle_behavior.gd` (`BattleBehavior`): le regole speciali di un nemico, in un file suo | [[Script come regole]] |
| `enemies/watcher_behavior.gd` (`WatcherBehavior`): Sguardo, accecamento, fasi, ultimate | [[Colui che guarda#Le regole]] |
| `battle.gd`: aggancia il comportamento, `_enemy_center()`, l'ultimate e la cutscene dei ritratti | [[Combattimento#L'ultimate]] |
| `battle_vfx.gd`: il raggio, l'anello di scaglie | [[Combattimento#L'ultimate]] |
| `Game.memories`: ciò che Subaru ricorda anche dopo la morte (salvato) | [[Ritorno dalla Morte#Quello che Subaru ricorda]] |
| `world/forest/watcher_arena.gd`: il risveglio, la battaglia, la vittoria | [[Colui che guarda#Nella radura]] |
| `thicket_eyes.gd`: `stare()` e `close_forever()` | [[Bosco Senza Tempo]] |
| `boss_theme.wav` e 6 suoni (carica, raggio, ruggito, ritratti, cristallo, alba) | [[Colonna sonora#Colui che guarda]] |
| 10 test nuovi: **179 in tutto**, tutti verdi | [[Test con gdUnit4]] |

## Come funzionano

- **Le regole del boss stanno fuori dalla battaglia.** `battle.gd` era già il file più grande (il motivo del "7 su 10"). Invece di riempirlo di `if boss`, la risorsa del nemico ha un campo `behavior` con uno script; Battle ne crea un'istanza e la chiama nei momenti giusti (`take_turn`, `modify_damage`, `on_hit`…). Un boss nuovo = un file nuovo. Vedi [[Script come regole]].
- **Ricordi che non tornano indietro.** `Game.flags` torna al punto di ritorno quando si muore; `Game.memories` no, come `Game.deaths`. È lì che sta "lo Shamac lo acceca".
- **La musica di un nemico.** `EnemyData.music`: se c'è, Battle suona quella invece del tema normale.
- **Grande senza ridisegnare.** `EnemyData.battle_scale` ingrandisce il nemico; `_enemy_center()` sa dov'è il centro del suo corpo, così scaglie, numeri e onde d'urto colpiscono al punto giusto.

## Problemi incontrati

- **I ritratti dell'ultimate al buio.** Il velo nero stava sopra di loro. Ora la striscia è figlia della battaglia, aggiunta per ultima: sopra il velo.
- **Il numero dei danni dell'ultimate usciva dallo schermo**: il boss è alto, e il numero partiva già in alto. Abbassato.
- **Le braccia del boss sparivano nel buio** della battaglia, e da colpito l'occhio chiuso sembrava una bocca che sorride. Alone viola attorno a tutto, e da colpito un occhio socchiuso con una crepa.
- **L'equilibrio non è provato a mano.** I numeri sono pensati per Subaru a livello ~5 con le pozioni: va giocato.

## Concetti nuovi

- [[Script come regole]]: uno script in una risorsa, istanziato con `.new()`
