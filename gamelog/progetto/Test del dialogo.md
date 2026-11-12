---
tags:
  - progetto
  - strumento
aliases:
  - test_dialogo.gd
---

# Test del dialogo

← [[Gamelog]]

Lo script `tools/test_dialogo.gd` controlla da solo il dialogo con il [[Saggio]] e la polvere della corsa. Dalla cartella `let's-learn-godot`:

```
<Godot.exe> --path . -s ../tools/test_dialogo.gd -- <cartella_screenshot>
```

## Cosa controlla (11 controlli)

1. Lontano dal Saggio la nuvoletta è nascosta, vicino compare.
2. Premendo E il dialogo si apre e [[Subaru]] si gira verso il Saggio.
3. Il testo compare un po' alla volta, a frase finita compare la freccia.
4. Durante il dialogo Subaru non si muove.
5. Premere durante la scrittura mostra tutta la frase.
6. Dopo l'ultima frase il dialogo si chiude.
7. Correndo compare la polvere, da fermo si spegne.

Esce con il numero di errori, quindi 0 = tutto ok.

## Cose imparate scrivendolo

- Per simulare un tasto che genera un evento serve `Input.parse_input_event()`, non `action_press()`: vedi [[Eventi di input]].
- La prima versione premeva E una volta di troppo: il dialogo si chiudeva e il Saggio, ancora vicino, lo riapriva. Era un errore del test, non del gioco.

## Vedi anche

- [[Test automatico]] · [[Godot da riga di comando]]
