---
tags:
  - progetto
  - componente
aliases:
  - Pickup
  - pickup.tscn
---

# Oggetto da raccogliere

← [[Gamelog]]

Il componente `interactables/pickup.tscn`: un [[Oggetti|oggetto]] per terra.

![[chiave_a_terra.png|400]]

| Effetto | Come |
|---|---|
| Fluttua su e giù, e l'ombra si stringe quando sale | [[Tween]] |
| Luccica | Poche [[Particelle]] dorate |
| Nuvoletta quando sei vicino, E per raccoglierlo | Un [[Interactable]] **senza frasi**: niente dialogo, solo il segnale `interacted` |
| Raccolto: sale, si ingrandisce, svanisce, scintille | [[Tween]] e un'esplosione di particelle |
| [[Subaru]] esulta | `cheer()` sul nodo del gruppo `player` ([[Gruppi]]); non la si aspetta, così l'oggetto sale mentre lui festeggia |
| Suono e avviso "Hai trovato…" | [[Game]] e [[Avvisi]] |

## Non ricompare

Raccogliendolo si scrive in `Game.flags` il ricordo `"preso:<percorso>"`. All'avvio, se il ricordo c'è, l'oggetto si toglie da solo: così non ricompare tornando nel villaggio, e nemmeno dopo aver caricato un [[Salvataggio]].

Proprietà: `item_id` (quale oggetto) e `amount` (quanti).
