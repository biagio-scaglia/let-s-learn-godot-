---
tags:
  - progetto
  - strumento
aliases:
  - test_corsa.gd
  - Test
---

# Test automatico

← [[Gamelog]]

Lo script `tools/test_corsa.gd` avvia la [[Mappa principale]], **simula i tasti** e salva degli screenshot. Dalla cartella `let's-learn-godot`:

```
<Godot.exe> --path . -s ../tools/test_corsa.gd -- <cartella_screenshot>
```

## Cosa controlla

| Passo | Come |
|---|---|
| [[Subaru]] fermo | Screenshot iniziale |
| Camminata | Preme `move_right` per 1 s e misura i pixel percorsi (~80) |
| Corsa | Aggiunge `run` e misura di nuovo (~150) |
| [[Collisioni]] | Va verso l'alto finché un albero o il bordo lo ferma |

## Come funziona

- È uno script `extends SceneTree`, lanciato con `-s`: vedi [[Godot da riga di comando]].
- `Input.action_press(...)` finge la pressione di un tasto, vedi [[Input Map]].
- `root.get_texture().get_image().save_png(...)` salva quello che si vede.

## Vedi anche

- [[Test del dialogo]] · [[Generatore della mappa]]
