---
tags:
  - progetto
  - combattimento
  - ui
aliases:
  - Battle
  - battle.tscn
  - Combattimento a turni
---

# Combattimento

← [[Gamelog]]

Il combattimento a turni: `ui/battle.tscn`, un [[Autoload]] chiamato `Battle`. Seconda versione: abilità, scudi e debolezze, e un'interfaccia da JRPG moderno (vedi [[2026-11-16-combattimento-v2]]). La prima, con le finestre blu, è in [[2026-11-14-primo-combattimento]].

![[combattimento_v2.png|500]]

## Come si usa

```gdscript
var result: String = await Battle.start(enemy_data)
if result == Battle.WIN:
	...
```

`start()` apre lo scontro contro un [[Nemici|EnemyData]] e **si può aspettare**: restituisce `Battle.WIN`, `Battle.LOSE` o `Battle.FLED`. Vedi [[Await]].

## Un turno a testa

```
transizione (la mappa gira, bande nere) ─► "X appare!"
        │
        ▼
┌─► Turno di Subaru: Attacca · Abilità · Oggetti · Difendi · Fuggi
│       │
│       ├─ Attacca / Abilità ─► danno; debolezza? scudo −1; scudo a 0? ROTTO
│       │                       PS del nemico a 0? ─────────────────► VITTORIA
│       ├─ Oggetti ─► Pozione
│       ├─ Difendi ─► metà danno al prossimo colpo, +2 PT
│       └─ Fuggi ───► una volta su due riesce ──────────────────────► FUGA
│       ▼
│   Turno del nemico: rotto? salta il turno (poi si riprende)
│                     altrimenti scatta e colpisce ─► PS a 0? ──────► SCONFITTA
└───────┘
```

## Le mosse

| Mossa | Costo | Potenza | Tipo | Animazione ed effetti |
|---|---|---|---|---|
| **Attacca** (Pugno) | 0 | ×1 | pugno | `jab`: scatto, fendente, scintille bianche |
| **Calcio** | 3 PT | ×1,5 | calcio | `kick`: colpo pesante, scossa, scintille arancioni |
| **Shamac** | 4 PT | ×1,2 | ombra | `charge`: lo schermo si fa viola scuro, nebbia nera sul nemico |
| **Pugno caricato** | 6 PT | ×2,4 | pugno | `charge` + aura che sale e zoom, poi `power_punch`: lampo, gran scossa, tante scintille |
| **Difendi** | — | — | — | `defend`: bagliore blu, metà danno al prossimo colpo, +2 PT |

Le mosse sono un [[Dizionari|dizionario]] `SKILLS` in cima a `battle.gd`: nome, costo, potenza, tipo, descrizione. Per aggiungerne una servono una riga lì, un bottone in `SkillWindow` e una funzione `_do_...()` per l'animazione.

Il danno: `Stats.damage(attacco, difesa, tiro)` (vedi [[Statistiche#La formula del danno]]), per la potenza della mossa, ×1,5 se è una debolezza, ×2 se il nemico è rotto. Arrotondato, mai meno di 1.

## Scudi, debolezze e rottura

![[combattimento_rotto.png|500]]

- Sotto il nemico: lo **scudo** con il numero di punti, e una casella per ogni **debolezza**. All'inizio sono tutte "?".
- Un colpo di un tipo che lo indebolisce **scopre** la casella (il "?" diventa l'icona) e toglie **un punto scudo**.
- Scudo a zero: **ROTTO!** Lampo, schegge, il nemico barcolla e si scurisce. **Salta il suo prossimo turno** (nella barra in alto è grigio) e fino al turno dopo prende **danni ×2**.
- Al turno dopo si riprende: scudo pieno, e attacca di nuovo.

| Nemico | Scudo | Debolezze |
|---|---|---|
| Melma verde | 2 | pugno, calcio |
| Spettro | 2 | calcio, ombra |

| Scelta | Costa il turno? |
|---|---|
| Attacca, un'abilità, Difendi | Sì |
| Un'abilità senza abbastanza PT | **No**: suono di "indietro" e "Non hai abbastanza PT." in basso |
| Oggetti → Pozione | Sì. Ma **no** se non ne hai o sei in piena forma. Esc torna ai comandi |
| Fuggi | Solo se fallisce |

## Le pose del nemico

![[spettro_battaglia.png|500]]

Se il foglio del nemico ha le 5 pose ([[Nemici#L'aspetto]]):

| Momento | Posa |
|---|---|
| In attesa | Respira: un [[Tween]] in loop alterna `IDLE` e `IDLE_2` ogni 0,45 s |
| Il suo turno | `WINDUP` mentre indietreggia di 14 px, poi `ATTACK` mentre scatta verso Subaru |
| Lo colpisci | `HURT` per 0,3 s, poi torna a respirare |
| Rotto (stordito) | Resta in `HURT` finché non si riprende |
| Sconfitto | `HURT` mentre si scioglie |

`_enemy_pose(posa)` mette una posa e alza `_enemy_posing`, così il respiro non la sovrascrive; `_enemy_rest()` la abbassa. Le pose hanno un nome grazie a un [[Enum]].

## Come finisce

| Risultato | Cosa succede |
|---|---|
| Vittoria | Il nemico lampeggia e si scioglie, Subaru esulta, "Vittoria!" con l'esperienza e l'eventuale livello. Il nemico sulla mappa svanisce e non torna più |
| Sconfitta | Subaru crolla, poi `ReturnByDeath.die()`: il [[Ritorno dalla Morte]] |
| Fuga | Subaru corre via a destra, si torna sulla mappa, il nemico resta dov'era |

## Com'è fatto

```
Battle (CanvasLayer, livello 12)     + battle.gd (le regole e l'interfaccia)
├── Vfx (Node, creato dal codice)  + battle_vfx.gd: tutti gli effetti visivi
│   (TurnBar + battle_turn_bar.gd, Commands + battle_commands.gd, EnemyInfo + battle_enemy_info.gd: vedi sotto)
├── Backdrop (ColorRect)        ← la mappa sfocata e scurita (shader pause_blur)
├── Screen (Control, filtro Nearest)
│   ├── Floor, Vignette         ← il pavimento più scuro, gli angoli scuri
│   ├── Stage                   ← si scuote e fa lo zoom: qui stanno i combattenti
│   │   ├── Motes (CPUParticles2D)  ← il pulviscolo
│   │   ├── Enemy (×5) a sinistra, Hero (×3) a destra, con le ombre
│   │   ├── EnemyInfo           ← scudo, numero, debolezze, nome
│   │   └── BreakLabel          ← "ROTTO!"
│   ├── TurnBar                 ← in alto a sinistra: l'ordine dei turni
│   ├── Party                   ← in alto a destra: Subaru, Lv, PS, PT, "In guardia"
│   ├── Commands                ← Attacca, Abilità, Oggetti, Difendi, Fuggi
│   ├── SkillWindow, ItemWindow ← i sottomenu, a sinistra dei comandi
│   ├── Announce                ← in alto: il nome della mossa o un messaggio
│   ├── Help                    ← in basso: la descrizione della voce selezionata
│   └── Results                 ← "Vittoria!"
├── Transition (ColorRect)      ← la transizione d'ingresso (shader battle_transition)
└── Flash (ColorRect)           ← i lampi (bianco, viola per Shamac, azzurro per la rottura)
```

| Pezzo | Concetto |
|---|---|
| Strisce e riquadri inclinati | `StyleBoxFlat` con `skew`: [[StyleBox#Inclinato: skew]] |
| Sfumature dietro gruppo e turni | `StyleBoxTexture` con una `GradientTexture2D`: [[StyleBox#StyleBoxTexture]] |
| Icone della barra dei turni, debolezze | Create dal codice; le icone sono [[AtlasTexture]] ritagliate da `battle_icons.png` |
| Il ritratto di Subaru | La stessa [[AtlasTexture]] della [[Scheda del personaggio]] |
| Mentre si combatte la mappa è ferma | `Game.in_cutscene = true`, come nelle [[Cutscene]] |
| Le voci dei menu | [[MenuItem]] con la manina; la descrizione segue `focus_entered` ([[Menu e focus]]) |
| Il costo in PT allineato a destra | Una `Label` aggiunta dal codice dentro ogni voce, ancorata a tutto il bottone |
| Barre di PS e PT | [[ProgressBar]] e un [[Tween]] sul valore |
| Il colpo al frame giusto, l'hit stop | `frame_changed` e `speed_scale`: [[AnimatedSprite2D#Agire a un frame preciso]] |
| Scintille, aura, nebbia, schegge | [[Particelle#Particelle create dal codice]] |
| La transizione d'ingresso | [[Shader#Transizione d'ingresso nel combattimento]] |
| Scossa, zoom, lampi, numeri che rimbalzano | [[Tween]], [[Effetti visivi#Nel combattimento]] |
| I tiri | `Battle.rng`: vedi [[Numeri casuali]]. Gli effetti hanno **i loro** dadi (`Battle.vfx.rng`): girare una stella non cambia il danno del colpo dopo |
| Barra dei turni, comandi, riquadro del nemico | Tre script sui loro nodi: disegnano, e i comandi **emettono segnali** (`skill_chosen`…). Le regole restano in `battle.gd`. Vedi [[2026-11-17-congedo#Il combattimento in quattro pezzi]] |
| Gli effetti in uno script a parte | `BattleVfx` ([[Classi globali\|class_name]]): `vfx.impact()`, `vfx.shake()`, `vfx.flash_white()`… Vedi [[Responsabilità]] |
| Suoni | [[Sfx#Suoni del combattimento]] |

## Chi sa cosa

Ognuno conosce solo il suo pezzo ([[Responsabilità]]):

- `Stats` sa i numeri di Subaru e la formula del danno. Non sa che esiste un combattimento.
- `EnemyData` è solo dati.
- `Battle` sa i turni e cosa mostrare. Non sa dove sta il nemico sulla mappa.
- Il nemico sulla mappa sa solo: "se vinci, sparisco".

## Vedi anche

- [[Statistiche]] · [[Nemici]] · [[Scheda del personaggio]]
- [[2026-11-14-primo-combattimento]] · [[2026-11-16-combattimento-v2]]
