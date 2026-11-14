---
tags:
  - progetto
  - componente
  - ui
aliases:
  - menu_item.gd
  - Voce di menu
---

# MenuItem

← [[Gamelog]]

La **voce di menu** usata ovunque: un `Button` con uno script (`ui/menu_item.gd`, `class_name MenuItem`, vedi [[Classi globali]]).

Quando riceve il focus ([[Menu e focus]]):

- compare una **freccia** dorata a sinistra, che oscilla avanti e indietro ([[Tween]]);
- il testo diventa **dorato** (lo decide il [[Theme]], non lo script);
- si sente un **"tic"**; premendola si sente il suono di conferma ([[Audio]]).

Altri dettagli:

- Il mouse sopra la voce le dà il focus, così mouse e tastiera non litigano.
- `focus_silently()` dà il focus **senza** il "tic": si usa quando un menu si apre, per non sovrapporre i suoni.
- Il cursore è grande in proporzione al testo (le sue misure ogni 16 px di font).
- `cursor_texture` cambia il cursore: vuoto è la freccia, il [[Combattimento]] usa una **manina** (`assets/ui/cursor_hand.png`).

Usata da [[Schermata iniziale]], [[Menu di pausa]], [[Opzioni]] e [[Combattimento]].
