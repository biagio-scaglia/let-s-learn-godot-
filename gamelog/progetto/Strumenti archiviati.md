---
tags:
  - progetto
  - strumento
  - moc
aliases:
  - tools
  - Script rimossi
---

# Strumenti archiviati

← [[Gamelog]]

Fino al [[2026-11-12-pulizia]] il repository aveva una cartella `tools/` con script di supporto. Sono stati rimossi per tenere il progetto snello: **restano nella cronologia di git** e le loro note spiegano come funzionavano.

| Script | Cosa faceva | Nota |
|---|---|---|
| `genera_mappa.py` | Il villaggio e il suo TileSet | [[Generatore della mappa]] |
| `genera_casa.py` | L'interno della casa di Lina | [[Generatore della casa]] |
| `genera_effetti.py` | Ombre, icone e suoni | [[Generatore degli effetti]] |
| `genera_subaru.py` | Il foglio e le animazioni di Subaru dal charset | [[Generatore di Subaru]] |
| `charset_da_immagine.py` | Riportare a pixel art un charset ingrandito | [[Convertitore di charset]] |
| `test_corsa.gd` | Test di camminata, corsa e collisioni | [[Test automatico]] |
| `test_dialogo.gd` | Test di dialoghi, cartello, Emilia, polvere e passi | [[Test del dialogo]] |
| `test_casa.gd` | Test di entrata, uscita e memoria | [[Test di casa]] |

> [!info] I test sono tornati
> Dal [[2026-11-13-test-con-gdunit]] i test stanno di nuovo nel repository, in `test/`, scritti con [[Test con gdUnit4|gdUnit4]]. I vecchi `test_*.gd` restano archiviati.

## Cosa cambia

- **Mappe:** `main.tscn` e `house.tscn` sono ora scene normali, da modificare a mano nell'editor. Non c'è più il rischio di sovrascriverle rigenerandole.
- **Test:** non ci sono più test automatici nel repository. Per verificare una modifica si avvia il gioco con F5, oppure si scrive un test temporaneo fuori dal repository.

## Come recuperarli

Dalla cartella del repository:

```
git log --oneline -- tools/                    # i commit che li toccavano
git checkout <commit>^ -- tools/               # li riporta com'erano prima della rimozione
```
