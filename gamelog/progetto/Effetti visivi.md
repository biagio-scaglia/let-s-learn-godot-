---
tags:
  - progetto
  - grafica
  - moc
aliases:
  - Effetti
  - Polish
---

# Effetti visivi

← [[Gamelog]]

Piccoli dettagli che rendono il gioco più "vivo". Nessuno è indispensabile, insieme fanno molta differenza.

![[polvere.png|400]]

| Effetto | Come | Concetto |
|---|---|---|
| Ombre ai piedi di [[Subaru]] e del [[Saggio]] | Ovale scuro semitrasparente sotto lo sprite | [[Sprite2D]] |
| Ombre sotto gli alberi | Un livello di tile `Shadows` tra terreno e oggetti | [[TileMapLayer]], [[TileSet]] |
| Polvere quando Subaru corre | Quadratini chiari che salgono e sfumano | [[Particelle]] |
| Pollini nell'aria | Puntini gialli lenti, sempre sullo schermo | [[Particelle]], [[Camera2D]] |
| Luce calda | Tinta leggermente arancione su tutto il mondo | [[CanvasModulate]] |
| Vignettatura | Angoli dello schermo un po' più scuri | [[Shader]], [[CanvasLayer]] |
| Il Saggio respira, la nuvoletta saltella | Animazioni da codice | [[Tween]] |
| Testo a macchina da scrivere con "blip" | Lettere una alla volta, suono ogni due | [[Tween]], [[Audio]] |
| Finestra che entra sfumando | Trasparenza e posizione animate | [[Tween]] |

Ombre, icone, freccia e suono sono generati dal [[Generatore degli effetti]].

> [!tip] Regolare gli effetti
> Quasi tutto si regola dall'Inspector senza codice: la forza della vignettatura (`strength` nel materiale di `Effects/Vignette`), il colore di `Tint`, la quantità di pollini (`amount`)…
