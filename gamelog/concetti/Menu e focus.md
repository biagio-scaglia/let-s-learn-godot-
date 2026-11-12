---
tags:
  - concetto
  - ui
aliases:
  - Focus
  - grab_focus
  - Navigazione con la tastiera
---

# Menu e focus

← [[godot-basi|Basi di Godot]]

Il **focus** è il controllo "selezionato", quello che riceve i tasti. È così che un menu si usa con la tastiera o il controller.

- `grab_focus()` dà il focus a un controllo. In un menu che si apre, si dà alla prima voce.
- Con le frecce (azioni `ui_up`, `ui_down`…) il focus passa da sola al controllo più vicino in quella direzione: non serve scrivere codice.
- `ui_accept` (Invio, Spazio) "preme" il bottone con il focus; `ui_cancel` (Esc) di solito torna indietro.
- I segnali `focus_entered` e `focus_exited` avvisano quando il focus arriva o se ne va.
- Uno [[Theme]] può dare un colore diverso al bottone con il focus (`font_focus_color`).
- Per uno **slider**, le frecce sinistra e destra cambiano il valore.

## Mouse e tastiera insieme

Per non avere due "selezioni" diverse, quando il mouse passa sopra una voce le diamo il focus:

```gdscript
mouse_entered.connect(grab_focus)
```

## Nel progetto

[[MenuItem]] reagisce al focus: mostra la freccia, suona un "tic" e il Theme lo colora d'oro. Lo usano la [[Schermata iniziale]], il [[Menu di pausa]] e le [[Opzioni]].

## Vedi anche

- [[Theme]] · [[Eventi di input]] · [[Interfaccia (Control)]]
