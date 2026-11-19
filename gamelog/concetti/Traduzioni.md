---
tags:
  - concetto
aliases:
  - Localizzazione
  - tr()
  - TranslationServer
---

# Traduzioni

← [[godot-basi]]

Godot traduce i testi con il **TranslationServer**: gli dai una frase (la "chiave") e lui
restituisce la versione nella lingua attiva. In Erbalta la chiave è **la frase italiana
stessa**, così le scene e gli script restano leggibili, e l'inglese sta in un file a parte.

## Il file delle traduzioni

`locale/en.po` è nel formato *gettext*, un formato di testo semplice:

```po
msgid "Nuova partita"
msgstr "New game"

msgid "%s appare!"
msgstr "%s appears!"
```

Si registra in *Impostazioni progetto → Localizzazione → Traduzioni*
(in `project.godot`: `locale/translations`). Per l'italiano non serve nessun file: se
una frase non ha traduzione, Godot mostra la chiave, cioè l'originale. Per questo la
lingua di riserva (`locale/fallback`) è `"it"`: con `"en"`, che è il default, anche
chi sceglie Italiano vedrebbe l'inglese!

## Cambiare lingua

```gdscript
TranslationServer.set_locale("en")   # o "it"
```

Lo fa [[Autoload|Settings]] all'avvio e quando scegli la lingua nelle opzioni. La scelta
si salva con il resto delle opzioni in un [[ConfigFile]].

## Chi traduce cosa

| Dove sta il testo | Come si traduce |
|---|---|
| Il `text` di una **Label** o di un **Button** nella scena | Da solo: i nodi [[Interfaccia (Control)\|Control]] hanno *auto translate* acceso. Se cambi lingua, si aggiornano subito. |
| Un testo messo da codice in una Label: `label.text = "Pausa"` | Da solo anche lui (la Label traduce quello che mostra). |
| Una frase composta: `"%s appare!" % nome` | **A mano**, con `tr()` *prima* di riempire i segnaposto: `tr("%s appare!") % tr(nome)`. Dopo il `%` la frase non è più una chiave che esiste. |
| I dialoghi | `Dialogue.start()` chiama `tr()` su ogni riga e sul nome di chi parla. |
| Funzioni `static` (niente nodo, niente `tr()`) | `TranslationServer.translate(testo)`, che restituisce uno `StringName`: `str(...)` per usarlo con `%`. |

Un nome da non tradurre (la lingua nel selettore: "English", "Italiano") si protegge
con `auto_translate_mode = DISABLED` sul nodo.

## Gli errori da evitare

- **Segnaposto diversi**: se l'italiano ha `%d` e l'inglese `%s`, il `%` dà errore.
  Un test (`settings_test.gd`) controlla tutte le frasi di `en.po`.
- **Chiavi che non combaciano**: basta un apostrofo diverso e la frase resta in italiano.
  Lo script che ha generato `en.po` controllava che ogni `msgid` esistesse davvero nel progetto.
- **I test che leggono i testi**: ora il gioco parte in inglese, quindi i test che cercano
  frasi italiane mettono `TranslationServer.set_locale("it")` in `before_test()`.

Vedi anche: [[2026-11-19-lingue]], [[ConfigFile]], [[Autoload]]
