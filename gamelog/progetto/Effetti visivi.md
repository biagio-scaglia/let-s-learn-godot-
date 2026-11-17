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
| Passi di Subaru | Un suono a ogni piede a terra | [[Audio]], [[Segnali]] |
| Il gioco compare dal nero | [[Dissolvenza]] | [[Autoload]], [[Tween]] |
| Raggi di sole dall'alto a sinistra | `Effects/SunRays`, luce sommata (`blend_add`) | [[Shader]], [[Rumore]] |
| Ombre delle nuvole che scorrono | `CloudShadows`, sopra il mondo, ferme sul terreno | [[Shader]], [[Rumore]] |
| Battito e vignettatura che si stringe vicino ai bordi | `VillageEdge` | [[Ritorno dalla Morte]], [[Audio]] |
| Nebbia nera e viola, vortice del ritorno | `miasma.gdshader`, `rewind.gdshader`, sprite del Particle Pack | [[Ritorno dalla Morte]], [[Shader]], [[Rumore]] |
| Alba nella cutscene d'apertura | Colore di `Tint` e forza dei raggi animati | [[Intro]], [[Tween]] |
| Stanza buia, torcia che tremola, luce dalla finestra | [[Casa di Lina]] | [[Luci 2D]], [[CanvasModulate]] |
| Suono della porta | Generato dal [[Generatore degli effetti]] | [[Audio]] |

Ombre, icone, freccia e suono sono generati dal [[Generatore degli effetti]].

> [!tip] Regolare gli effetti
> Quasi tutto si regola dall'Inspector senza codice: la forza della vignettatura (`strength` nel materiale di `Effects/Vignette`), il colore di `Tint`, la quantità di pollini (`amount`), la forza dei raggi (`intensity`), il vento e la quantità delle nuvole (`wind`, `coverage`)…

## Nel combattimento

Dal [[2026-11-16-combattimento-v2|combattimento v2]]:

| Effetto | Come |
|---|---|
| Transizione d'ingresso | [[Shader#Transizione d'ingresso nel combattimento]] |
| Scossa | Un [[Tween]] di tanti piccoli spostamenti casuali dello `Stage`, sempre più piccoli |
| Zoom del pugno caricato | `Stage.scale` da 1 a 1,06 mentre Subaru carica |
| Lampi | Il `ColorRect` `Flash`: bianco (colpo forte), viola scuro (Shamac), azzurro (rottura) |
| Hit stop | [[AnimatedSprite2D#Agire a un frame preciso]] |
| Scintille, aura, nebbia, schegge, pulviscolo | [[Particelle#Particelle create dal codice]] |

Dal [[2026-11-17-vfx|17 novembre]]:

| Effetto | Come |
|---|---|
| Stella d'impatto, fendente del calcio | Spritesheet disegnate a mano (`vfx_impact.png`, `vfx_slash.png`), animate da un `AnimatedSprite2D` creato dal codice, con blend **additivo** |
| Lampo bianco su chi viene colpito | [[Shader#Lampo bianco sullo sprite]] |
| Onda d'urto (pugno caricato, rottura, ingresso) | [[Shader#Onda d'urto]] + [[BackBufferCopy]] |
| Scia di Subaru che scatta | 4 copie del frame attuale, azzurre, che svaniscono |
| Polvere all'atterraggio | Due sbuffi di [[Particelle]], uno per lato |
| Colonna di luce al nuovo livello | Particelle che salgono, additive |
| Bande con la punta luminosa, colori sdoppiati | [[Shader#Transizione d'ingresso nel combattimento]] |
