---
tags:
  - progetto
  - storia
aliases:
  - Crediti nel gioco
  - Credits
---

# Titoli di coda

← [[Gamelog]]

Arrivano dopo il finale ([[2026-11-18-finale]]). **Un gioco di Biagio Scaglia.**

![[titoli_di_coda.png|480]] ![[titoli_fine.png|480]]

- **I nomi** scorrono dal basso. Sono una lista in `ui/credits.gd` (`CREDITS`): ogni riga è `[stile, testo]`, e `_build_list()` la trasforma in Label con lo stile del [[Theme]] (`TitleLabel`, `SubtitleLabel`, `HintLabel`).
- **Il cast**: personaggi e mostri con il ritratto (`Portraits`), i nomi dei mostri presi dai loro file.
- **La velocità** la decide la musica: (altezza della lista + altezza dello schermo) / (durata della musica − 16 secondi). Gli ultimi 16 sono per il cartello "Fine".
- **Sotto**, Subaru ed Emilia camminano sul posto e sono gli alberi a scorrere (quelli davanti più grandi e più veloci: sembra che ci sia profondità). Subaru usa le sue animazioni, Emilia il suo [[Charset]] con un Tween che cambia frame.
- **Il cielo** passa dalla notte all'alba al mattino seguendo il tempo; le stelle si spengono.
- **Invio tenuto premuto**: cinque volte più veloci (la musica no).
- Alla fine sbloccano la [[Galleria]] (`Progress.finish_story()`).

La musica è *Un giorno nuovo*: vedi [[Colonna sonora#Il finale]].

## Vedi anche

- [[Atto 3]] · [[Progressi permanenti]] · [[Interfaccia da codice]]
