---
tags:
  - progetto
  - storia
  - autoload
aliases:
  - Return by Death
  - ReturnByDeath
  - Game over
  - return_by_death.tscn
---

# Ritorno dalla Morte

← [[Gamelog]]

Il potere di [[Subaru]]: quando muore, torna indietro nel tempo al **punto di ritorno**. Il mondo torna com'era in quel momento, ma lui **si ricorda** di essere morto.

Nel gioco, per ora, si muore in un modo solo: **provando a uscire dal villaggio**.

![[game_over.png|500]]

## Cosa succede

1. **Avvicinandosi al bordo** della mappa si sente un battito del cuore, lento e poi veloce, e la vignettatura stringe lo schermo.
2. **Sul bordo** si sente un tonfo basso, la camera trema e Subaru crolla di lato e si scurisce.
3. **La nebbia** nera e viola striscia dai bordi verso il centro, con sbuffi di fumo e un rombo cupo.
4. **Game over:** "Sei morto." compare lettera per lettera, con sotto *Morte n. X*.
5. **"Ritorna":** lo schermo si avvita in un vortice viola, i colori si separano e virano al negativo.
6. **Risveglio** al punto di ritorno. Subaru dice qualcosa di diverso a seconda di quante volte è morto.

"Torna al titolo" invece chiude tutto e torna alla [[Schermata iniziale]].

![[ritorno.png|500]]

## Il mondo dimentica, Subaru no

Dopo un ritorno, il [[Saggio]] ed [[Emilia]] notano che Subaru ha qualcosa che non va e aggiungono due frasi alle loro solite (dalla terza morte il Saggio ne dice altre). Lo fa `quests/death_memory.gd`, con `extra_lines` di [[Interactable]]. Il ricordo "l'ha già notato" torna indietro con il ritorno: dopo ogni morte lo notano di nuovo.

Il [[Cartello]] avverte già prima: *"Non lasciate il villaggio."*

## I pezzi

| Pezzo | File | Cosa fa |
|---|---|---|
| I confini | `world/village_edge.gd` (nodo `VillageEdge` in [[Mappa principale\|main.tscn]]) | Misura la distanza di Subaru dal bordo: battito, vignettatura e morte |
| La morte e il game over | `ui/return_by_death.tscn` + `.gd`, [[Autoload]] **`ReturnByDeath`** | `die()`, la nebbia, il pannello, il ritorno |
| La nebbia | `effects/miasma.gdshader` | Foschia fatta di [[Rumore]] che avanza dai bordi |
| Il riavvolgimento | `effects/rewind.gdshader` | Vortice, colori separati, negativo ([[Shader]]) |
| Il crollo | `collapse()` in `subaru.gd` | Lo sprite ruota attorno ai piedi e si scurisce |
| Punto di ritorno e morti | [[Game]]: `checkpoint`, `set_checkpoint()`, `return_to_checkpoint()`, `deaths` | Vedi sotto |

```
ReturnByDeath (CanvasLayer 15)
├── Darkness (ColorRect)           ← il buio
├── Fog (ColorRect + miasma)       ← la nebbia vera
├── Miasma (CPUParticles2D)        ← sbuffi di fumo
├── Vortex (Sprite2D)              ← il vortice del ritorno
├── Panel                          ← "Sei morto.", Morte n. X, Ritorna / Torna al titolo
├── RewindFx (ColorRect + rewind)  ← avvita tutto quello che c'è sotto
└── Impact, Drone, Rewind, Glitch (AudioStreamPlayer)
```

## Il punto di ritorno

`Game.checkpoint` è una **fotografia** del mondo: scena, posizione, direzione, ricordi e zaino. Le ultime due sono **copie** (`duplicate(true)`), così quello che succede dopo non la cambia.

Viene scattata:

- alla fine dell'[[Intro]] (Subaru appena arrivato in piazza);
- quando si **salva** dal [[Menu di pausa]];
- dopo **Continua**.

Tornando indietro, tutto quello che è successo dopo sparisce: se hai raccolto la chiave e poi sei morto, la chiave è di nuovo per terra.

`Game.deaths` invece **non** torna indietro, perché Subaru se lo ricorda. Viene salvato nel file (chiave `morti`; i vecchi salvataggi partono da 0) e si azzera solo con *Nuova partita*.

## Suoni e sprite esterni

Sono tutti [[Licenza CC0]], e ogni cartella ha il suo `License.txt`.

| Cosa | File | Da |
|---|---|---|
| Battito lento e veloce | `assets/heartbeat_bart/` | "Heartbeat sounds" di *bart*, OpenGameArt (convertiti da WAV float a 16 bit) |
| Tonfo, rombo, riavvolgimento | `assets/kenney_sci_fi_sounds/` | "Sci-fi Sounds" di [[Kenney]] |
| Glitch del ritorno | `assets/kenney_interface_sounds/` | "Interface Sounds" di Kenney |
| Fumo e vortice | `assets/kenney_particle_pack/` | "Particle Pack" di Kenney, rimpiccioliti a 64 px |

## Vedi anche

- [[Game]] · [[Salvataggio]] · [[Rumore]] · [[Shader]] · [[2026-11-14-ritorno-dalla-morte]]
