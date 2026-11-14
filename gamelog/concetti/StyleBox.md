---
tags:
  - concetto
  - ui
aliases:
  - StyleBoxFlat
---

# StyleBox

← [[godot-basi|Basi di Godot]]

Una [[Risorsa]] che descrive **come si disegna lo sfondo** di un nodo di [[Interfaccia (Control)|interfaccia]]. La più usata è **`StyleBoxFlat`**:

| Proprietà | Cosa fa |
|---|---|
| `bg_color` | Colore di sfondo (anche semitrasparente) |
| `border_width_*`, `border_color` | Il bordo |
| `corner_radius_*` | Angoli arrotondati |
| `content_margin_*` | Spazio interno (per i container) |
| `anti_aliasing` | Bordi sfumati: **spento** per la [[Pixel art]] |

Si assegna nell'Inspector in *Theme Overrides → Styles*.

## Nel progetto

La [[Finestra di dialogo]] ha due StyleBoxFlat: riquadro scuro con bordo color crema, e etichetta del nome color crema con bordo scuro.

## StyleBoxTexture

Invece di colori e bordi, un'**immagine**, tagliata in nove pezzi (*9-slice*) dai `texture_margin_*`:

```
┌──┬────────┬──┐   gli angoli restano come sono
├──┼────────┼──┤   i lati si allungano in una direzione
│  │ centro │  │   il centro si allunga in tutte e due
├──┼────────┼──┤
└──┴────────┴──┘
```

Così una cornice di 32×32 pixel va bene per finestre di qualsiasi misura. Nel progetto: `window_battle.png`, con margini da 5 px. Dentro, il centro è una **sfumatura verticale** di blu: allungandosi resta una sfumatura, ed è da lì che viene l'aspetto dei giochi di ruolo classici. Serve il [[Filtro Nearest]] (lo mette lo `Screen` del combattimento) perché i pixel restino netti.

## Vedi anche

- [[Interfaccia (Control)]] · [[Font]]
