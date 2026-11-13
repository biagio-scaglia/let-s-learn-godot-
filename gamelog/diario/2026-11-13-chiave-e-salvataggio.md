---
data: 2026-11-13
tags:
  - gamelog
  - missione
  - inventario
  - salvataggio
stato: funzionante
aliases:
  - Chiave e salvataggio
---

# 2026-11-13 — La chiave del baule, lo zaino e il salvataggio

← [[Gamelog]] · Voce precedente: [[2026-11-12-menu|Menu]]

## Obiettivo

Dare al giocatore qualcosa da fare e la possibilità di riprendere: la **prima missione** (la chiave del baule di Lina), lo **zaino** e il **salvataggio** con *Continua*.

![[baule_aperto.png]]

## Come provarlo

1. *Nuova partita*.
2. Entra nella casa col tetto rosso e parla con Lina: ha perso la chiave.
3. Torna fuori: la chiave luccica vicino alla staccionata, a ovest della piazza. **E** per raccoglierla.
4. **Tab** per vedere lo zaino.
5. Torna da Lina, poi apri il baule.
6. **Esc** → *Salva*. Torna al titolo: c'è *Continua*.

## Cosa è stato fatto

| Pezzo | Nota |
|---|---|
| Gli oggetti: una [[Risorse personalizzate\|risorsa personalizzata]] `Item` e tre file `.tres` | [[Oggetti]] |
| L'inventario in `Game`, un [[Dizionari\|dizionario]] id → quantità | [[Game]] |
| La chiave per terra: fluttua, luccica, si raccoglie | [[Oggetto da raccogliere]] |
| Gli avvisi "Hai trovato…" in coda | [[Avvisi]] |
| Lo zaino con Tab o I | [[Zaino]] |
| La missione: Lina e il baule dicono cose diverse a seconda della situazione | [[Missione della chiave]] |
| Il salvataggio e *Continua* | [[Salvataggio]], [[Salvare la partita]] |
| Tre suoni nuovi (raccogliere, baule, salvare), fatti da noi | [[Audio]] |

## Decisioni e perché

- **Frasi che cambiano senza riscrivere Interactable:** ogni [[Interactable]] manda `interacted` e chi ascolta può impostare `override_lines`. La logica della missione sta in uno script a parte, non dentro Lina: un domani le missioni saranno tante.
- **Gli oggetti come file `.tres`:** per un oggetto nuovo non si tocca il codice.
- **Un solo posto per lo stato ([[Game]]):** salvare è diventato scrivere due dizionari. È la ricompensa di averlo deciso presto.
- **La scena si sistema da sola leggendo i ricordi:** la chiave già raccolta si toglie, il baule già aperto si disegna aperto. Non serve salvare com'è fatta la scena.

## Problemi incontrati

- **L'avviso copriva il titolo del menu di pausa:** il primo stile era troppo alto. Ora è più compatto, con il bordo dorato, e sta più in alto.
- **Il baule aperto non era nel TileSet della casa:** aggiunto il tile 91 con le stesse proprietà del baule chiuso.
- **I test non devono toccare i salvataggi veri:** il test temporaneo copia il salvataggio e le opzioni dell'utente prima di iniziare e li rimette a posto alla fine.

## Verifica

Un test temporaneo (fuori dal repository) ha percorso tutta la storia, con **21 controlli**, tutti ok: niente *Continua* senza salvataggio; la chiave si raccoglie senza dialogo; lo zaino si apre e mette in pausa; Lina e il baule rispondono alla chiave; il baule si disegna aperto; lo zaino contiene 2 pozioni e 5 monete; *Salva* crea il file; *Continua* riporta nella casa, nello stesso punto, con lo stesso zaino e il baule aperto.

## Collegamenti

- **Progetto:** [[Missione della chiave]] · [[Zaino]] · [[Oggetti]] · [[Oggetto da raccogliere]] · [[Avvisi]] · [[Salvataggio]] · [[Lina]] · [[Casa di Lina]] · [[Game]] · [[Menu di pausa]] · [[Schermata iniziale]]
- **Concetti:** [[Risorse personalizzate]] · [[Dizionari]] · [[Salvare la partita]] · [[ConfigFile]] · [[Segnali]] · [[Interactable]] · [[TileMapLayer]] · [[Theme]] · [[Pausa]]
