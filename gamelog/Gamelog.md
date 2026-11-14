---
tags:
  - gamelog
  - moc
aliases:
  - Home
  - Indice
---

# Gamelog

Diario del progetto: cosa è stato fatto, perché, e cosa ho imparato di Godot strada facendo.

## Da dove partire

- 📚 **[[godot-basi|Basi di Godot]]**: l'indice di tutti i concetti di Godot imparati
- 🗂️ **[[Vault Obsidian]]**: come è organizzato questo vault e cosa significano i colori del grafo

## Diario

| Data | Voce | Stato |
|---|---|---|
| 2026-11-12 | [[2026-11-12-subaru\|Sprite di Subaru: divisione, ottimizzazione, animazioni]] | Completato |
| 2026-11-12 | [[2026-11-12-mappa-e-corsa\|Una mappa vera e Subaru che corre]] | Funzionante |
| 2026-11-12 | [[2026-11-12-primo-dialogo\|Il primo dialogo, e un po' di atmosfera]] | Funzionante |
| 2026-11-12 | [[2026-11-12-interazioni-e-rifiniture\|Interazioni riutilizzabili e rifiniture]] | Funzionante |
| 2026-11-12 | [[2026-11-12-casa-di-lina\|Si entra in casa]] | Funzionante |
| 2026-11-12 | [[2026-11-12-emilia\|Arriva Emilia]] | Funzionante |
| 2026-11-12 | [[2026-11-12-subaru-v2\|Subaru, versione 2]] | Funzionante |
| 2026-11-12 | [[2026-11-12-pulizia\|Pulizia]] | Completato |
| 2026-11-12 | [[2026-11-12-menu\|Schermata iniziale e menu di pausa]] | Funzionante |
| 2026-11-13 | [[2026-11-13-chiave-e-salvataggio\|La chiave del baule, lo zaino e il salvataggio]] | Funzionante |
| 2026-11-13 | [[2026-11-13-cutscene\|La prima cutscene: Subaru arriva al villaggio]] | Funzionante |
| 2026-11-13 | [[2026-11-13-sole-e-nuvole\|Raggi di sole, ombre delle nuvole e un'alba]] | Funzionante |
| 2026-11-13 | [[2026-11-13-riordino-del-codice\|Riordino del codice]] | Completato |
| 2026-11-13 | [[2026-11-13-test-con-gdunit\|I test entrano nel progetto, con gdUnit4]] | Funzionante |
| 2026-11-14 | [[2026-11-14-ritorno-dalla-morte\|Il Ritorno dalla Morte]] | Funzionante |
| 2026-11-14 | [[2026-11-14-ottimizzazioni-e-obiettivo\|Più veloce, un obiettivo, e un mondo che nota]] | Funzionante |

## Il progetto

| Cosa | Note |
|---|---|
| Personaggi | [[Subaru]] · [[Emilia]] · [[Saggio]] · [[Lina]] |
| Oggetti | [[Oggetti]] · [[Oggetto da raccogliere]] · [[Cartello]] · [[Interactable]] · [[Porta]] |
| Storia e missioni | [[Intro]] · [[Missione della chiave]] · [[Ritorno dalla Morte]] |
| Mondo | [[Mappa principale]] · [[Casa di Lina]] · [[Effetti visivi]] |
| Stato del gioco | [[Game]] · [[Inventory]] · [[Salvataggio]] · [[Opzioni]] · [[Sfx]] |
| Interfaccia | [[Obiettivo]] · [[Zaino]] · [[Avvisi]] · [[Salvataggio]] · [[Schermata iniziale]] · [[Menu di pausa]] · [[Opzioni]] · [[MenuItem]] · [[Finestra di dialogo]] · [[Dissolvenza]] |
| Asset | [[Tiny Town]] · [[Tiny Dungeon]] · [[KenPixel]] · [[Kenney]] · [[Licenza CC0]] · [[Dove trovare asset]] |
| Strumenti (archiviati) | [[Strumenti archiviati]]: [[Generatore della mappa]] · [[Generatore della casa]] · [[Generatore degli effetti]] · [[Generatore di Subaru]] · [[Convertitore di charset]] · [[Test automatico]] · [[Test del dialogo]] · [[Test di casa]] |
| Organizzazione | [[Repository GitHub]] · [[Vault Obsidian]] |

## Come avviare il gioco

Apri Godot 4.7, importa la cartella `let's-learn-godot` e premi **F5**. Dettagli in [[Editor di Godot]].

| Tasto | Azione |
|---|---|
| Frecce / WASD | Muoversi |
| Shift | Correre |
| E / Spazio / Invio | Parlare, leggere |
| Esc | Pausa (anche per salvare) |
| Tab / I | Zaino |

## Stato del progetto

- [x] Spritesheet di Subaru pulita e ottimizzata
- [x] Animazioni idle + camminata in 4 direzioni
- [x] Scena del personaggio con movimento base
- [x] Progetto su GitHub: [let-s-learn-godot-](https://github.com/biagio-scaglia/let-s-learn-godot-)
- [x] Creare il progetto Godot e provarci dentro Subaru
- [x] Una prima mappa in cui muoversi (tileset Tiny Town di Kenney)
- [x] Subaru corre (Shift)
- [x] Un personaggio con cui parlare (dialoghi)
- [x] Effetti: ombre, polvere, pollini, luce calda, vignettatura
- [x] Cartello leggibile, il Saggio si ricorda di te, passi, dissolvenza
- [ ] Modificare la mappa a mano nell'editor
- [x] Una casa in cui entrare (cambio scena)
- [x] Schermata iniziale e menu di pausa, con le opzioni
- [x] Raccogliere oggetti (inventario) e la prima missione
- [x] Salvataggio e Continua
- [ ] Combattimento a turni
- [ ] Statistiche e livelli
- [ ] Una piccola storia dall'inizio alla fine
