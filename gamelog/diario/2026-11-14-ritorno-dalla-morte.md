---
data: 2026-11-14
tags:
  - gamelog
  - storia
  - shader
  - audio
stato: funzionante
aliases:
  - Ritorno dalla Morte
  - Game over
---

# 2026-11-14 — Il Ritorno dalla Morte

← [[Gamelog]] · Voce precedente: [[2026-11-13-test-con-gdunit|Test con gdUnit]]

## Obiettivo

Il potere di Subaru: **morire e tornare indietro**. Si muore provando a uscire dal villaggio, e c'è un **game over**. Effetti sonori e sprite presi da **asset esterni**.

![[game_over.png]]

## Come provarlo

1. *Nuova partita*, guarda l'intro.
2. Raccogli la chiave vicino alla staccionata (a ovest della piazza).
3. Cammina verso un bordo della mappa, in una direzione qualsiasi. Senti il cuore battere sempre più forte…
4. Sul bordo muori. Scegli **Ritorna**.
5. Sei di nuovo in piazza, la chiave è tornata per terra, e Subaru se lo ricorda.

![[bordo_villaggio.png|400]] ![[ritorno.png|400]]

## Cosa è stato fatto

| Pezzo | Nota |
|---|---|
| Confini del villaggio con battito e vignettatura | [[Ritorno dalla Morte]] |
| L'autoload `ReturnByDeath`: crollo, nebbia, game over, ritorno | [[Ritorno dalla Morte]] |
| Shader della nebbia (`miasma.gdshader`) con *domain warping* | [[Rumore]], [[Shader]] |
| Shader del riavvolgimento (`rewind.gdshader`) | [[Shader]] |
| Punto di ritorno e conteggio delle morti in `Game` | [[Game]] |
| `collapse()` per Subaru | [[Subaru]] |
| 7 asset esterni CC0 (suoni e sprite) | [[Ritorno dalla Morte#Suoni e sprite esterni]], `CREDITS.md` |
| 5 nuovi test gdUnit (`return_by_death_test`) | [[Test con gdUnit4]] |

## Decisioni e perché

- **Un confine "a distanza", non con delle Area2D:** basta un rettangolo e un `minf()` per sapere quanto si è vicini a *qualsiasi* bordo. Con le aree ne servirebbero quattro, e il battito che cresce piano sarebbe più difficile.
- **Il punto di ritorno è una fotografia con copie:** senza `duplicate(true)` il dizionario dei ricordi sarebbe lo stesso oggetto, e ogni cosa successa dopo cambierebbe anche la "fotografia".
- **Le morti non tornano indietro:** è il cuore della meccanica. Subaru dice frasi diverse alla prima, alla seconda e dalla terza volta in poi.
- **Il cambio di scena ora sblocca il giocatore solo dopo la dissolvenza:** prima, mentre lo schermo si schiariva, si poteva già camminare. Così dopo il ritorno nessuno muove Subaru prima che parli.

## Problemi incontrati

- **La nebbia era fatta di quadrati viola.** Gli sprite del Particle Pack di Kenney **non sono trasparenti**: sono bianchi su nero opaco, e la forma sta nella luminosità. Godot disegnava ogni particella come un quadrato pieno. Ora, nel prepararli, la luminosità diventa la trasparenza.
- **…e poi non bastava:** a te non piacevano neanche gli sbuffi da soli, volevi una vera nebbia. Così è arrivato lo shader `miasma.gdshader`: rumore deformato da altro rumore (*domain warping*), che si arriccia come fumo e avanza dai bordi verso il centro. Gli sbuffi ora sono pochi e leggeri, sopra la nebbia.
- **I battiti erano WAV a 32 bit float:** convertiti a 16 bit, il formato più sicuro da importare.
- **Il test premeva "Ritorna" troppo presto,** mentre il titolo compariva ancora e il menu non era selezionabile. Il gioco era a posto: ora il test aspetta che il bottone sia selezionato.

## Verifica

- **Test visivo temporaneo, 18 controlli, tutti ok:** punto di ritorno dopo l'intro, chiave raccolta, battito vicino al bordo, morte, game over, ritorno nel punto giusto, chiave di nuovo per terra e non nello zaino, morti = 1, frase al risveglio, comandi restituiti, seconda morte dal bordo nord, ritorno al titolo pulito.
- **Si arriva davvero ai bordi camminando,** in tutte e quattro le direzioni (provato tenendo premuti i tasti, non teletrasportando Subaru).
- **gdUnit: 32 test su 32**, compresi i 5 nuovi. Passano anche i test completi del gioco di ieri (30 e 14 controlli).
- Il salvataggio vero dell'utente non è stato toccato.

## Concetti nuovi

- *Domain warping*, aggiunto alla nota [[Rumore]]
