---
tags:
  - concetto
  - editor
aliases:
  - Addon
  - EditorPlugin
---

# Plugin

← [[godot-basi|Basi di Godot]]

Un **plugin** (o *addon*) è una cartella dentro `addons/` che aggiunge cose a Godot: nodi nuovi, pannelli nell'editor, autoload. Spesso è scritto in GDScript come il nostro gioco.

## Come si usa

1. Si copia la cartella in `res://addons/<nome>/`. Dentro c'è un `plugin.cfg` (nome, autore, versione, script).
2. *Progetto → Impostazioni del progetto → Plugin* → spunta **Abilitato**. In `project.godot` finisce nella lista `[editor_plugins]`.
3. Abilitandolo, lo script del plugin (`extends EditorPlugin`, `_enable_plugin()`) può aggiungere i suoi [[Autoload]].

> [!info] Non sono globali
> Ogni progetto ha i suoi plugin. Per riusarli tengo una copia in `Desktop/godot-addons/` (con un `LEGGIMI.md`) da copiare nei progetti nuovi.

## Nel progetto

| Plugin | A cosa ci servirà | Autoload |
|---|---|---|
| gdUnit4 | I [[Test con gdUnit4\|test]] (già usato) | — |
| Dialogue Manager 4.2.0 | Dialoghi con scelte e condizioni, scritti in file `.dialogue` | `DialogueManager` |
| Phantom Camera 0.11.0.4 | Camere per cutscene e zone, al posto di muovere la [[Camera2D]] a mano | `PhantomCameraManager` |
| Beehave 2.9.3 | Behavior tree: l'IA dei [[Nemici]] sulla mappa | `BeehaveGlobalMetrics`, `BeehaveGlobalDebugger` |

Per ora sono **installati ma non usati**: la nostra [[Finestra di dialogo]] e la nostra camera restano quelle di prima. Vedi [[2026-11-17-plugin]].

## Vedi anche

- [[Autoload]] · [[Editor di Godot]] · [[Test con gdUnit4]]
