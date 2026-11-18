---
tags:
  - concetto
  - codice
aliases:
  - Signal
  - Segnale
  - signal
---

# Segnali

← [[godot-basi|Basi di Godot]]

Un **segnale** è un avviso che un [[Nodo]] manda quando succede qualcosa: "un corpo è entrato", "l'animazione è finita", "il dialogo si è chiuso". Chi è interessato si **collega** e una sua funzione viene chiamata.

```gdscript
# Collegarsi a un segnale
area.body_entered.connect(_on_body_entered)

# Dichiarare e mandare un proprio segnale
signal finished
finished.emit()
```

- Si possono collegare anche dall'editor: pannello **Segnali** accanto all'Inspector.
- Servono a tenere i nodi **indipendenti**: chi manda il segnale non deve sapere chi lo ascolta.

## Nel progetto

| Segnale | Chi lo manda | Chi ascolta |
|---|---|---|
| `body_entered` / `body_exited` | [[Area2D]] | [[Interactable]], per sapere se il giocatore è vicino |
| `interacted` | [[Interactable]] | Nessuno per ora: servirà per missioni e oggetti |
| `frame_changed` | L'animazione di [[Subaru]] | Subaru, per far suonare i passi |
| `finished` di un [[Tween]] | La scrittura del testo | La [[Finestra di dialogo]], per mostrare la freccia |
| `finished` | La [[Finestra di dialogo]] | Nessuno per ora: servirà per le missioni |

## Collegamenti usa e getta

`segnale.connect(funzione, CONNECT_ONE_SHOT)` collega una funzione che verrà chiamata **una volta sola**, poi il collegamento sparisce. È un'alternativa ad `await segnale`, con una differenza importante: se il nodo che aspetta viene distrutto, il collegamento si toglie da solo.

Nel progetto: quando Emilia dice "Andiamo", `VoicesQuest` aspetta la fine del dialogo per cambiare scena. Con `await Dialogue.finished` l'attesa sarebbe rimasta "appesa" anche dopo la fine di un test, e la prima finestra chiusa in un altro test avrebbe cambiato scena. Con `Dialogue.finished.connect(_go_to_forest, CONNECT_ONE_SHOT)` no. Vedi [[2026-11-18-bosco]].

## Vedi anche

- [[Area2D]] · [[Tween]] · [[GDScript]]
