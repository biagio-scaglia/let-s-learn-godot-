---
tags:
  - progetto
  - componente
aliases:
  - interactable.tscn
  - Interazione
---

# Interactable

← [[Gamelog]]

Il **componente** per tutto ciò con cui si può interagire: personaggi, cartelli, e in futuro porte e forzieri. File: `interactables/interactable.tscn` e `interactable.gd`. Vedi [[Composizione]].

## Com'è fatto

```
Interactable (Area2D)        + interactable.gd (class_name Interactable)
├── CollisionShape2D         ← cerchio di 30 px: "abbastanza vicino"
└── Prompt (Sprite2D)        ← la nuvoletta "...", sempre sopra a tutto (z_index 10)
```

## Proprietà (dall'Inspector)

| Proprietà | Cosa fa |
|---|---|
| `speaker` | Il nome nella [[Finestra di dialogo]] |
| `lines` | Le frasi della prima volta |
| `repeat_lines` | Le frasi dalla seconda volta (se vuoto, ripete `lines`) |
| `prompt_height` | A che altezza sta la nuvoletta |

Il segnale `interacted` avvisa quando il giocatore interagisce: servirà per missioni e oggetti.

## Come funziona

1. Quando un corpo del [[Gruppi|gruppo]] `player` entra nell'[[Area2D]], se lo ricorda e mostra la nuvoletta.
2. Alla pressione di `interact` ([[Eventi di input]]) segna il tasto come usato, gira il giocatore verso di sé e apre il dialogo con l'[[Autoload]] `Dialogue`.
3. Conta le volte (`times`): dalla seconda usa `repeat_lines`.

## Usato da

- [[Saggio]] (come figlio)
- [[Cartello]] (da solo)

È una [[Classi globali|classe globale]]: `class_name Interactable`.
