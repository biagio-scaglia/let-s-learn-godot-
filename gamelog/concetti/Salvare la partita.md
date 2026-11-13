---
tags:
  - concetto
  - codice
aliases:
  - Salvataggio
  - Save
  - Caricare
---

# Salvare la partita

← [[godot-basi|Basi di Godot]]

Salvare vuol dire scrivere su file **tutto quello che serve per ricominciare da lì**, e caricare vuol dire rileggerlo e rimettere il gioco in quello stato.

## Cosa salvare

La regola: **lo stato, non le scene**. Le scene (il villaggio, la casa) sono già nei file del gioco; va salvato solo ciò che è *cambiato*:

| Cosa | Dove sta nel gioco |
|---|---|
| In quale scena sei | `current_scene.scene_file_path` |
| Posizione e direzione | Il giocatore |
| Zaino | `Game.inventory` |
| Ricordi (conversazioni, oggetti raccolti, bauli aperti) | `Game.flags` |

Tenere tutto lo stato in un unico posto ([[Game]]) rende il salvataggio facile: si scrivono due [[Dizionari]].

## Come

Con un [[ConfigFile]] in `user://salvataggio.cfg`:

```gdscript
config.set_value("partita", "posizione", player.global_position)   # anche un Vector2
config.set_value("partita", "zaino", inventory)                    # anche un dizionario
config.save(SAVE_PATH)
```

## Caricare

1. Si leggono zaino e ricordi e si rimettono in [[Game]].
2. Si cambia scena verso quella salvata ([[Cambio di scena]]).
3. Nella nuova scena, `level.gd` sposta il giocatore nella posizione salvata.
4. Ogni oggetto, all'avvio, guarda i ricordi: la chiave già raccolta si toglie da sola, il baule già aperto si disegna aperto.

Il punto 4 è il trucco: **non si salva com'è la scena, la scena si sistema da sola leggendo i ricordi**.

## Nel progetto

[[Salvataggio]] (dal [[Menu di pausa]]) e *Continua* nella [[Schermata iniziale]].

## Vedi anche

- [[ConfigFile]] · [[Game]] · [[Dizionari]]
