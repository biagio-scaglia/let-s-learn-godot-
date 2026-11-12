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
- La freccia è grande in proporzione al testo (6×9 px ogni 16 px di font).

Usata da [[Schermata iniziale]], [[Menu di pausa]] e [[Opzioni]].
