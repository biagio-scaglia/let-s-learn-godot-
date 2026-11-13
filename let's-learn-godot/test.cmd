@echo off
:: Lancia tutti i test (cartella test/) con gdUnit4.
:: Serve il percorso di Godot: o la variabile GODOT_BIN, oppure
::     test.cmd --godot_binary C:\percorso\Godot.exe
:: -c = non fermarti al primo test fallito, falli girare tutti.
call addons\gdUnit4\runtest.cmd -a res://test -c %*
