---
tags:
  - progetto
  - strumento
aliases:
  - charset_da_immagine.py
---

# Convertitore di charset

← [[Gamelog]] · [[Strumenti archiviati]]

> [!note] Script rimosso
> Lo script è stato tolto dal repository durante la [[2026-11-12-pulizia|pulizia]]: resta nella cronologia di git. Questa nota spiega come funzionava. Vedi [[Strumenti archiviati]].

Lo script `tools/charset_da_immagine.py` riporta a pixel art vera un [[Charset]] "finto": un'immagine ingrandita, con lo sfondo bianco e i colori sporcati dalla compressione JPEG (tipico delle immagini generate da un'IA).

```
python tools/charset_da_immagine.py <immagine> <uscita.png> <px_per_pixel>
```

## Come funziona

1. **Sfondo:** il bianco collegato ai bordi diventa trasparente; il bianco della maglia, chiuso dal contorno, resta.
2. **Griglia:** trova dove cadono i bordi dei "pixel" del disegno, guardando dove l'immagine cambia colore più spesso.
3. **Colori:** per ogni pixel del disegno prende il colore mediano del centro del blocco (il bordo del blocco è sporcato dalla compressione).
4. **Palette:** riduce a 32 colori e toglie i pixel isolati.

## Come trovare `px_per_pixel`

Si prova una serie di valori e si guarda quale "allinea" meglio i cambi di colore dell'immagine. Per [[Subaru]] v2 è venuto **13,2**: 1686 ÷ 13,2 ≈ 128 e 2528 ÷ 13,2 ≈ 192, cioè un charset 128×192. Dettagli in [[2026-11-12-subaru-v2]].

## Vedi anche

- [[Generatore di Subaru]] · [[Pixel art]]
