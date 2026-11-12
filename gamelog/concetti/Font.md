---
tags:
  - concetto
  - ui
aliases:
  - Font pixel
  - Caratteri
---

# Font

← [[godot-basi|Basi di Godot]]

Un file `.ttf` o `.otf` messo nel progetto diventa una [[Risorsa]] *FontFile*. Si assegna a un `Label` in *Theme Overrides → Fonts*, con la grandezza in *Font Sizes*.

## Font pixel nitidi

Per un font in [[Pixel art]] bisogna cambiare le opzioni di **importazione**: seleziona il file nel FileSystem → pannello **Importa** → *Reimporta*.

| Opzione | Valore | Perché |
|---|---|---|
| Antialiasing | Nessuno | Bordi netti, niente grigi |
| Hinting | Nessuno | Non "aggiusta" le forme |
| Subpixel Positioning | Disabilitato | Le lettere cadono su pixel interi |

Usa grandezze multiple di quella per cui il font è disegnato (per KenPixel 16, 32…).

> [!tip] Controllare le lettere accentate
> Non tutti i font pixel hanno à, è, ù. Vanno provati prima: [[KenPixel]] *normale* non le ha, la versione *High Square* sì.

## Nel progetto

[[KenPixel]] High Square a 16 px nella [[Finestra di dialogo]].

## Vedi anche

- [[Interfaccia (Control)]] · [[File import e uid]]
