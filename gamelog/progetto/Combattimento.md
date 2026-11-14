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

Il combattimento a turni: `ui/battle.tscn`, un [[Autoload]] chiamato `Battle`. L'aspetto è quello dei giochi di ruolo classici (vedi [[2026-11-14-primo-combattimento#La UI in stile gioco di ruolo classico]]).

![[combattimento.png|500]]

## Come si usa

```gdscript
var result: String = await Battle.start(enemy_data)
if result == Battle.WIN:
	...
```

`start()` apre lo scontro contro un [[Nemici|EnemyData]] e **si può aspettare**: restituisce `Battle.WIN`, `Battle.LOSE` o `Battle.FLED`. Vedi [[Await]].

## Un turno a testa

```
"X appare!"
        │
        ▼
┌─► la barra d'attesa si riempie
│       ▼
│   Turno di Subaru: Attacca · Oggetti · Fuggi
│       │
│       ├─ Attacca ─► "Pugno", danno al nemico ─► PS del nemico a 0? ─► VITTORIA
│       ├─ Oggetti ─► Pozione: cura (se serve e ce n'è)
│       └─ Fuggi ───► una volta su due riesce ─────────────────────────► FUGA
│       ▼
│   Turno del nemico: scatta, colpisce ─► PS di Subaru a 0? ───────────► SCONFITTA
└───────┘
```

| Scelta | Cosa fa | Costa il turno? |
|---|---|---|
| **Attacca** | `danno = attacco − difesa + tiro` (tiro da −1 a +1, minimo 1). Vedi [[Statistiche]] | Sì |
| **Oggetti → Pozione** | `Inventory.use("pozione")`: +12 PS | Sì. Ma **no** se non ne hai o sei in piena forma. Esc torna ai comandi |
| **Fuggi** | Riesce con probabilità `flee_chance` (0,5) | Solo se fallisce |

## Come finisce

| Risultato | Cosa succede |
|---|---|
| Vittoria | Il nemico lampeggia e si scioglie, Subaru esulta, finestra "Vittoria!" con l'esperienza e l'eventuale livello. Il nemico sulla mappa svanisce e non torna più |
| Sconfitta | Subaru crolla, poi `ReturnByDeath.die()`: il [[Ritorno dalla Morte]] |
| Fuga | Subaru corre via a destra, si torna sulla mappa, il nemico resta dov'era |

## Com'è fatto

```
Battle (CanvasLayer, livello 12)     + battle.gd
├── Backdrop (ColorRect)        ← la mappa sfocata e scurita (shader pause_blur)
├── Screen (Control, filtro Nearest)
│   ├── Floor (TextureRect)     ← una sfumatura che scurisce il "pavimento"
│   ├── Stage                   ← nemico (×5) a sinistra, Subaru (×3) a destra, con le ombre
│   ├── Help (BattleWindow)     ← in alto: il nome dell'azione o un messaggio
│   ├── Bottom (HBoxContainer)
│   │   ├── EnemyWindow         ← nome e barra del nemico
│   │   ├── CommandWindow       ← Attacca, Oggetti, Fuggi (con la manina)
│   │   └── PartyWindow         ← Subaru: livello, PS, barra d'attesa
│   ├── ItemWindow              ← il sottomenu degli oggetti
│   └── Results                 ← "Vittoria!"
└── Flash (ColorRect bianco)    ← i due lampi dell'entrata
```

| Pezzo | Concetto |
|---|---|
| Le finestre blu | Variazione `BattleWindow` del [[Theme]]: uno [[StyleBox#StyleBoxTexture\|StyleBoxTexture]] in 9 pezzi |
| Mentre si combatte la mappa è ferma | `Game.in_cutscene = true`, come nelle [[Cutscene]] |
| Le voci dei menu | [[MenuItem]] con `cursor_texture` = la manina; [[Menu e focus]] |
| Barre della salute e d'attesa | [[ProgressBar]] e un [[Tween]] sul valore |
| Pugno, colpito, esultanza, caduta, in ginocchio | Le [[Subaru#Le azioni\|azioni]] di Subaru: `guard`, `punch`, `hurt`, `cheer`, `collapse`, `weak`, specchiate con `flip_h` |
| Lampo rosso, scossa, numero che rimbalza | [[Tween]]; il numero è una `Label` creata e poi distrutta |
| Le ombre seguono chi scatta | `_process()` copia la `x` dello sprite sull'ombra |
| I tiri | `Battle.rng`: vedi [[Numeri casuali]] |
| I messaggi | `_announce()` scrive e basta; `_say()` aspetta E/Invio o `message_time` secondi |
| Suoni | `Sfx.HIT`, `Sfx.HEAL`, `Sfx.LEVEL_UP` ([[Sfx]]) |

## Chi sa cosa

Ognuno conosce solo il suo pezzo ([[Responsabilità]]):

- `Stats` sa i numeri di Subaru e la formula del danno. Non sa che esiste un combattimento.
- `EnemyData` è solo dati.
- `Battle` sa i turni e cosa mostrare. Non sa dove sta il nemico sulla mappa.
- Il nemico sulla mappa sa solo: "se vinci, sparisco".

## Vedi anche

- [[Statistiche]] · [[Nemici]] · [[Scheda del personaggio]]
- [[2026-11-14-primo-combattimento]]
