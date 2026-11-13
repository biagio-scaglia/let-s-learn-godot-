---
tags:
  - progetto
  - missione
aliases:
  - key_quest.gd
  - Quest
  - Missione
---

# Missione della chiave

← [[Gamelog]]

La prima missione del gioco. Script: `quests/key_quest.gd`, nel nodo `KeyQuest` della [[Casa di Lina]].

## La storia

1. [[Lina]] ha perso la chiave del baule: "forse vicino alla staccionata, a ovest della piazza".
2. La chiave è lì, a terra ([[Oggetto da raccogliere]]).
3. Torni da Lina: "La mia chiave! … Apri pure il baule".
4. Il baule si apre (anche nel disegno) e dentro ci sono 2 pozioni rosse e 5 monete. La chiave resta nella serratura.
5. Dopo, Lina chiede se ti sono piaciute le pozioni, e il baule è vuoto.

![[baule_aperto.png|400]]

## Come funziona

Lo script **non** sta dentro Lina o il baule: li **ascolta**. Quando interagisci, [[Interactable]] manda il [[Segnali|segnale]] `interacted`; la missione guarda zaino e ricordi e, se serve, imposta `override_lines`, cioè le frasi da dire solo questa volta.

| Situazione | Lina dice | Il baule dice |
|---|---|---|
| Senza chiave | Le sue frasi normali (dove l'ha persa) | "È chiuso a chiave." |
| Con la chiave | "La mia chiave!…" | "La chiave gira nella serratura… clic!" e si apre |
| Baule aperto | "Ti sono piaciute le pozioni?" | "Il baule è vuoto." |

Il baule si apre **quando il dialogo finisce**: la missione si collega al segnale `Dialogue.finished` una volta sola (`CONNECT_ONE_SHOT`), poi:

- toglie la chiave e dà pozioni e monete ([[Game]] `add_item`);
- ricorda `"baule_aperto"` in `Game.flags`;
- cambia il tile del baule con quello aperto (`set_cell` sul [[TileMapLayer]]).

All'avvio della casa, se `"baule_aperto"` c'è già, il baule si disegna aperto: così funziona anche dopo un [[Salvataggio]].

## I nodi collegati dall'Inspector

`lina`, `chest` e `objects` sono `@export` di tipo nodo: si collegano trascinando i nodi nell'Inspector. Vedi [[Export e Inspector]].
