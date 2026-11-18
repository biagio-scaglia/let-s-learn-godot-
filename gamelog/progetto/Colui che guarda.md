---
tags:
  - progetto
  - personaggio
  - combattimento
aliases:
  - Boss
  - WatcherBehavior
---

# Colui che guarda

← [[Gamelog]]

Il boss dell'[[Atto 3]]: un occhio enorme fatto d'ombra e di mani, nella radura in cima al [[Bosco Senza Tempo]]. Tiene Erbalta ferma nello stesso giorno, e *ricorda* Subaru: lo ha visto tornare, morire e restare, ciclo dopo ciclo.

![[boss_pose.png|600]]

## L'aspetto

`assets/enemies/colui_che_guarda.png`: 5 pose da 96×96 come gli altri [[Nemici]] (respiro ×2, carica: iride rossa e venature, attacco: le mani in avanti, colpito: occhio socchiuso con una crepa), con un alone viola per non sparire nel buio. In battaglia è grande ×2,2 (`battle_scale`).

## Le regole

`enemies/watcher_behavior.gd` (`WatcherBehavior extends BattleBehavior`, vedi [[Script come regole]]):

| Cosa | Come |
|---|---|
| L'occhio vede i colpi | Finché non è rotto, ogni colpo fa il 70% |
| **Lo Sguardo** | Al 2° turno e poi ogni 3 carica (scena rossa che pulsa, battito); al turno dopo un raggio: 70% della vita massima di Subaru (metà se ci si difende) |
| **Accecato** | Shamac (tipo ombra) mentre carica: niente raggio, scudo a zero, rotto. E Subaru se lo ricorda |
| Fase 2 (≤ 60%) | Le mani si moltiplicano: attacco +3 |
| Fase 3 (≤ 25%) | Compare l'ultimate, **Alba di cristallo** ([[Combattimento#L'ultimate]]) |
| Fuga | Impossibile |

## Il trucco del Ritorno

La prima volta quasi nessuno sa dello Shamac: lo Sguardo arriva e, prima o poi, uccide. Ma morire contro di lui scrive in `Game.memories` "sguardo_del_guardiano" ([[Ritorno dalla Morte#Quello che Subaru ricorda]]), che il Ritorno non cancella. Al tentativo dopo la debolezza "ombra" è già scoperta, e quando l'occhio carica Subaru dice: *"Lo Shamac, subito!"*. Lo stesso ricordo si impara anche scoprendolo da soli.

## Nella radura

`world/forest/watcher_arena.gd`, nodo `Watcher` del bosco: l'occhio dorme socchiuso e fluttua. Entrando nell'area `Trigger`:

1. la musica del bosco si spegne, la camera sale verso l'occhio;
2. ruggito, la camera trema, tutti gli occhi dei rovi si spalancano (`stare()`), l'occhio si apre e respira;
3. il dialogo (più corto se Subaru l'ha già visto: ricordo "guardiano_visto");
4. `Battle.start()` con la risorsa del boss;
5. vinta: l'occhio si crepa e svanisce, gli occhi dei rovi si chiudono per sempre (`close_forever()`), la luce dell'alba si scalda, la nebbia si dirada. Ricordo `guardiano_sconfitto`, punto di ritorno.

## Vedi anche

- [[Atto 3]] · [[Combattimento]] · [[Ritorno dalla Morte]] · [[Colonna sonora#Colui che guarda]] · [[2026-11-18-colui-che-guarda]]
