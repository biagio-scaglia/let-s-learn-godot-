---
tags:
  - progetto
  - componente
aliases:
  - Door
  - door.tscn
  - Uscita
---

# Porta

← [[Gamelog]]

Il componente `interactables/door.tscn`: un'[[Area2D]] che, quando il giocatore ci entra, lo porta in un'altra scena. Non serve premere niente: basta camminarci dentro.

| Proprietà | Cosa fa |
|---|---|
| `target_scene` | La scena di arrivo |
| `target_spawn` | Il Marker2D di arrivo, vedi [[Cambio di scena]] |
| `arrive_facing` | Verso dove guarda il giocatore all'arrivo |
| `size` | La grandezza della zona |

Ogni porta copia la sua forma di collisione (`duplicate()`), altrimenti tutte le porte condividerebbero la stessa [[Risorsa]] e la stessa grandezza.

## Nel progetto

| Porta | Da | A |
|---|---|---|
| `World/HouseDoor` | [[Mappa principale]] | [[Casa di Lina]], all'ingresso |
| `World/Exit` | [[Casa di Lina]] | Davanti alla porta, nel villaggio |

Il segnale `body_entered` chiama [[Game]] `change_scene()`. Vedi anche [[Composizione]].
