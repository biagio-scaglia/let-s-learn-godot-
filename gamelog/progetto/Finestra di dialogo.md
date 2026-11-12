---
tags:
  - progetto
  - ui
aliases:
  - Dialogue
  - Dialogo
  - dialogue_box
---

# Finestra di dialogo

← [[Gamelog]]

La finestra in basso in cui parlano i personaggi. File: `ui/dialogue_box.tscn` e `ui/dialogue_box.gd`.

![[dialogo.png|500]]

## Come si usa

È un [[Autoload]] chiamato `Dialogue`, quindi da qualsiasi script:

```gdscript
Dialogue.start("Saggio", ["Prima frase.", "Seconda frase."])
```

| Tasto (azione `interact`) | Effetto |
|---|---|
| Durante la scrittura | Mostra subito tutta la frase |
| A frase finita | Passa alla prossima |
| All'ultima frase | Chiude la finestra |

`Dialogue.is_active` è vero finché è aperta, e alla chiusura manda il [[Segnali|segnale]] `finished`.

## Com'è fatta

```
DialogueBox (CanvasLayer, layer 10)   + dialogue_box.gd
├── Box (Control)                     ← si anima tutto insieme
│   ├── Panel                         ← riquadro scuro con bordo crema
│   │   ├── Text (Label)              ← il testo, font KenPixel
│   │   └── Arrow (TextureRect)       ← la freccia che saltella
│   └── NameTag (PanelContainer)
│       └── Name (Label)
└── Blip (AudioStreamPlayer)          ← il suono delle lettere
```

| Dettaglio | Concetto |
|---|---|
| Sempre sopra al gioco, ferma rispetto allo schermo | [[CanvasLayer]] |
| Riquadri, testo, ancore | [[Interfaccia (Control)]], [[StyleBox]], [[Font]] |
| Entra/esce sfumando, testo a macchina da scrivere | [[Tween]] |
| Suono delle lettere | [[Audio]] |
| Non salta la prima frase | [[Eventi di input]] |

Fa parte degli [[Effetti visivi]]. Testata da [[Test del dialogo]].
