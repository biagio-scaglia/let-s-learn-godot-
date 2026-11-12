---
tags:
  - concetto
  - ui
aliases:
  - Tema
  - theme.tres
  - Variazioni di tipo
---

# Theme

← [[godot-basi|Basi di Godot]]

Un **Theme** è una [[Risorsa]] che decide l'aspetto di tutti i nodi di [[Interfaccia (Control)|interfaccia]]: font, grandezze, colori, [[StyleBox|stili]] e icone. Si cambia in un posto solo e cambiano tutti i menu.

- Si assegna a tutto il progetto in *Impostazioni progetto → GUI → Theme → Custom*, oppure a un solo nodo (e ai suoi figli) con la proprietà `theme`.
- Si modifica con un doppio clic sul file: si apre l'**editor dei temi** in basso.
- Le proprietà sono divise per tipo di nodo: `Button/colors/font_focus_color`, `Label/colors/font_color`…
- Un nodo può comunque cambiare una singola cosa con le *Theme Overrides* nell'Inspector.

## Variazioni di tipo

Una **variazione** è uno stile in più per un tipo esistente. Nel nostro Theme ci sono quattro variazioni di `Label`:

| Variazione | Usata per |
|---|---|
| `TitleLabel` | Il titolo "ERBALTA": 64 px, contorno spesso, ombra |
| `HeaderLabel` | "PAUSA", "OPZIONI": 32 px, dorato |
| `SubtitleLabel` | Il sottotitolo: dorato, 16 px |
| `HintLabel` | Le scritte di aiuto: 16 px, semitrasparenti |

Nel nodo si sceglie con *Theme Type Variation*.

## Nel progetto

`ui/theme.tres`, applicato a tutto il progetto. Usa il [[Font]] [[KenPixel]] e i colori della [[Finestra di dialogo]] (crema e viola scuro), con l'oro per la voce selezionata.

## Vedi anche

- [[Interfaccia (Control)]] · [[StyleBox]] · [[Font]] · [[Menu e focus]]
