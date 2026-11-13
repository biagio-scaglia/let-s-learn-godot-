---
tags:
  - progetto
  - autoload
  - audio
aliases:
  - sfx.gd
  - Suoni
---

# Sfx

← [[Gamelog]]

L'[[Autoload]] **`Sfx`** (`core/sfx.gd`): i suoni brevi dei menu e degli eventi.

```gdscript
Sfx.play(Sfx.CONFIRM)
pressed.connect(Sfx.play.bind(Sfx.CONFIRM))   # suona quando si preme un bottone
```

| Costante | Quando |
|---|---|
| `MOVE`, `CONFIRM`, `BACK` | Spostarsi, confermare, tornare indietro nei menu |
| `PICKUP` | Raccogliere un oggetto |
| `CHEST_OPEN` | Aprire il baule |
| `SAVE` | Partita salvata |
| `DOOR` | Attraversare una [[Porta]] |

All'avvio crea un `AudioStreamPlayer` per ogni suono, leggendo la tabella `SOUNDS` (file e volume). Per aggiungere un suono basta una riga lì e una costante. Un nome sbagliato ferma il gioco con "Suono sconosciuto: …".

Funziona anche in [[Pausa]] (`process_mode = Always`): il [[Menu di pausa]] e lo [[Zaino]] suonano mentre il gioco è fermo.

## Vedi anche

- [[Audio]] · [[Costanti]] · [[Game]]
