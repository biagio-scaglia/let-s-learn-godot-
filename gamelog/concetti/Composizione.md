---
tags:
  - concetto
  - architettura
aliases:
  - Componenti
  - Composition
---

# Composizione

← [[godot-basi|Basi di Godot]]

Un modo di organizzare il gioco: invece di scrivere tutto in un unico script, si fanno **piccoli pezzi riutilizzabili** (componenti) e li si **mette insieme** come figli.

In Godot è naturale: un componente è una [[Scena]] piccola che si aggiunge come [[Istanza]] dove serve.

## Esempio nel progetto

All'inizio il [[Saggio]] faceva tutto da solo: aspetto, respiro, *e* la logica "avvicinati e premi E". Volendo rendere leggibile anche il [[Cartello]], avremmo dovuto copiare quel codice.

Abbiamo invece estratto la parte di interazione in un componente, [[Interactable]]:

| Chi | Cosa aggiunge | Interactable |
|---|---|---|
| [[Saggio]] | Sprite, ombra, respiro, collisione | Come figlio |
| [[Cartello]] | Niente: il disegno è già un tile della mappa | Da solo |

Un domani: porte, forzieri, oggetti da raccogliere useranno lo stesso componente.

## Regola pratica

Se stai per **copiare e incollare** del codice da un nodo a un altro, probabilmente quel codice vuole diventare un componente.

## Vedi anche

- [[Interactable]] · [[Classi globali]] · [[Segnali]]
