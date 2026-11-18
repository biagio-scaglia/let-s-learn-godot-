---
data: 2026-11-18
tags:
  - gamelog
  - storia
  - combattimento
  - effetti
stato: funzionante
aliases:
  - Gli occhi di pietra e le Scaglie di gelo
---

# 2026-11-18 — Atto 3, pezzo 2: gli occhi di pietra ed Emilia nel party

← [[Gamelog]] · Voce precedente: [[2026-11-18-bosco|Il Bosco Senza Tempo]]

## Obiettivo

Riempire il [[Bosco Senza Tempo]]: nemici nuovi, l'enigma che apre la radura, e una **mossa speciale con Emilia**: scaglie di ghiaccio sui nemici. A metà lavoro l'autore ha aggiunto un charset d'attacco di Emilia e due richieste: **Emilia nel party** (e allora le Scaglie le usa lei) e **mob che si muovono** sulla mappa.

![[emilia_scaglie.png|500]]

## Come provarlo

1. Nel bosco, guarda la **nebbia viola** in cima al sentiero: l'obiettivo diventa *Chiudi gli occhi di pietra (0/3)*.
2. Negli slarghi ai lati ci sono tre **occhi di pietra**: spazzano il terreno con un cono di luce. Se ti vedono, un lampo ti rimanda indietro (e costa 2 PS). Arriva alle loro spalle e premi E.
3. Al primo occhio chiuso Subaru ed Emilia inventano una mossa insieme: **Cristallo infranto**. "Nuova abilità".
4. Combatti: Emilia è **nel party**, con il suo turno, i suoi PT e le sue mosse (Dardo di gelo, Scaglie di gelo, Barriera).
5. Chiudi tutti e tre gli occhi: la nebbia si dissolve. *Entra nella radura* (il boss è il pezzo 3).

![[occhio_di_pietra.png|500]]

## Cosa è stato fatto

| Pezzo | Nota |
|---|---|
| 3 nemici nuovi, 5 pose ciascuno: Occhio errante, Mano d'ombra, Guardiano dei rovi | [[Nemici]] |
| I nemici sulla mappa gironzolano (`step_towards()` con `test_move`) | [[Nemici#Gironzolano]] |
| Un tipo di colpo nuovo, **ghiaccio**, con la sua icona | [[Combattimento#Scudi, debolezze e rottura]] |
| `world/forest/stone_eye.gd` (`StoneEye`): il cono che vede, il lampo, la chiusura | [[Bosco Senza Tempo#Gli occhi di pietra]] |
| `world/forest/fog_gate.gd` (`FogGate`): i tre bagliori nella nebbia | [[Bosco Senza Tempo#Gli occhi di pietra]] |
| `world/forest/forest_quest.gd`: il raggio, l'insegnamento di Emilia, la nebbia che si apre | [[Atto 3]] |
| Le Scaglie di gelo: neve, sette scaglie, blocco di ghiaccio che va in frantumi | [[Combattimento#Scaglie di gelo]] |
| **Emilia nel party**: turno suo, PT suoi, pose d'attacco dal charset dell'autore | [[Combattimento#Emilia nel party]] |
| `characters/emilia/emilia_attack.png`: il charset d'attacco ripulito in pixel art | [[Emilia#Le pose d'attacco]] |
| 7 suoni nuovi (incantesimo, tintinnio, frantumi, occhio che si chiude, allarme, abilità nuova, nebbia che si dissolve) | [[Audio]] |
| 18 test nuovi: **167 in tutto**, tutti verdi | [[Test con gdUnit4]] |

## Come funzionano

- **Il cono di visione.** L'occhio vede un punto se è abbastanza vicino *e* nella direzione giusta: `angle_difference(rotazione_dello_sguardo, direzione_del_punto)` deve stare sotto metà dell'apertura. Vedi [[Angoli e coni di visione]].
- **Il raggio che vola alla nebbia** segue una curva di Bézier: `from.lerp(mid, k).lerp(mid.lerp(to, k), k)`, con `mid` più in alto. Sale, poi scende.
- **Un turno in più.** Prima i turni erano Subaru → nemico. Ora `_next_turn()` decide: dopo Subaru tocca a Emilia (se è nel party), dopo di lei al nemico. I comandi sono gli stessi, ma `set_actor()` cambia le voci e i PT da guardare.
- **Gironzolare senza attraversare i muri.** Prima di muoversi, un nemico chiede `test_move(global_transform, spostamento)`: "se mi spostassi così, sbatterei contro qualcosa?". Se sì, resta fermo. Vedi [[Collisioni#Provare prima di muoversi]].

## Problemi incontrati

- **Il charset era un JPG ingrandito.** Pixel grossi di circa 8,6 pixel veri (non interi), sfondo bianco e capelli quasi bianchi. Rimettendolo in pixel art, lo sfondo "entrava" nei capelli dalle fessure tra le ciocche. Soluzione: allargare prima tutto ciò che è colorato (così le fessure si chiudono), riempire lo sfondo dai bordi, poi farlo ricrescere di pochissimo. Vedi [[Emilia#Le pose d'attacco]].
- **Due "party".** In `battle.gd` `party` era già il riquadro in alto a destra: la variabile nuova si chiama `with_emilia`. Godot l'ha segnalato subito come errore.
- **Le scaglie uscivano dallo schermo.** Emilia era troppo a destra: avvicinata a Subaru.

## Concetti nuovi

- [[Angoli e coni di visione]]: `angle_difference`, `Vector2.from_angle`
- Provare un movimento prima di farlo → [[Collisioni#Provare prima di muoversi]]

## Aggiornamento: Emilia più coerente, e una mossa combinata

Dopo la prima prova l'autore ha notato due cose.

- **Gli sprite di Emilia stonavano.** In battaglia era ingrandita ×2,4 (una scala non intera: pixel di grandezze diverse) mentre Subaru è ×3, e il foglio d'attacco aveva colori suoi. Rifatto: celle 44×48 (Emilia alta ~45 pixel, come sulla mappa), **la stessa palette del suo charset** (ogni colore portato al più vicino, tranne l'azzurro del ghiaccio), il contorno scuro di 1 pixel, e ingrandimento **×3 intero** come Subaru. Un errore lungo la strada: il test "è ghiaccio?" guardava solo il blu, e il viola di Emilia (che ha tanto blu) diventava azzurro. Il ghiaccio vero ha il **verde sopra il rosso**: con questa regola non si confondono più.
- **Sbloccare le Scaglie di gelo non aveva senso**, perché Emilia nel party le ha già. Ora le Scaglie sono sue fin dal primo combattimento, e il primo occhio chiuso insegna una mossa **nuova e combinata**: *Cristallo infranto* (Subaru, 4 PT + 4 PT di Emilia): lei chiude il nemico in un blocco di ghiaccio, lui lo manda in frantumi con il pugno caricato. Tolta la vecchia versione in cui Subaru "chiamava" Emilia, che non poteva più capitare.
- **Emiliuccia.** Subaru non dice più "Emilia-tan": dice "Emiliuccia". E lei gli chiede come gli sia venuto in mente.

![[cristallo_infranto.png|500]]
