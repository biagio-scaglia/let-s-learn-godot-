---
tags:
  - concetto
  - nodo
  - ui
aliases:
  - Control
  - UI
  - Interfaccia
  - Ancore
---

# Interfaccia (Control)

← [[godot-basi|Basi di Godot]]

I nodi verdi di Godot sono i **Control**: servono per l'interfaccia (menu, finestre, pulsanti, testi). Si posizionano con le **ancore**, cioè rispetto ai bordi del genitore o dello schermo.

| Nodo | A cosa serve |
|---|---|
| `Control` | Contenitore vuoto |
| `Panel` | Un riquadro con uno sfondo ([[StyleBox]]) |
| `PanelContainer` | Come Panel, ma si allarga per contenere il figlio |
| `Label` | Un testo |
| `TextureRect` | Un'immagine |
| `ColorRect` | Un rettangolo colorato |

- **Ancore:** dal menu *Layout* in alto (es. "In basso a tutta larghezza"). Il riquadro resta attaccato a quel bordo anche se la finestra cambia.
- **`mouse_filter = Ignore`** sui nodi decorativi, così non "rubano" i clic.
- `Label.visible_characters` mostra solo i primi N caratteri: è il trucco della macchina da scrivere.

## Nel progetto

La [[Finestra di dialogo]]: `Panel` in basso, `Label` per il testo, `PanelContainer` per il nome, `TextureRect` per la freccia. Il testo usa il [[Font]] KenPixel.

L'aspetto di tutti questi nodi si decide in un [[Theme]].

## Vedi anche

- [[CanvasLayer]] · [[StyleBox]] · [[Font]]
