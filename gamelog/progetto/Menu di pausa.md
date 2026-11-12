---
tags:
  - progetto
  - ui
aliases:
  - Pause
  - pause_menu.tscn
---

# Menu di pausa

← [[Gamelog]]

Si apre con **Esc** in qualsiasi livello. È un [[Autoload]] chiamato `Pause` (`ui/pause_menu.tscn`).

![[menu_pausa.png]]

## Come funziona

- Esc (azione `pause`) mette il gioco in [[Pausa]]; il menu resta attivo perché ha `process_mode = Always`.
- Dietro, il gioco resta visibile ma **sfocato e scurito** da uno [[Shader]] (`effects/pause_blur.gdshader`). La sfocatura entra in modo graduale: il menu anima il parametro `amount` da 0 a 1 con un [[Tween]].
- Il riquadro entra con una piccola "molla" (`TRANS_BACK`).
- Si apre **solo nei livelli** (le scene del [[Gruppi|gruppo]] `level`), non nella [[Schermata iniziale]], e non durante un dialogo o un cambio di scena.

## Le voci

| Voce | Cosa fa |
|---|---|
| Riprendi (o Esc) | Chiude il menu e toglie la pausa |
| Opzioni | Apre le [[Opzioni]]; Esc torna qui |
| Torna al titolo | Sfuma al nero e torna alla [[Schermata iniziale]] |
| Esci dal gioco | Chiude il gioco |

Le voci sono [[MenuItem]]: frecce per scegliere, Invio per confermare, oppure il mouse.
