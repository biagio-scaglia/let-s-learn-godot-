"""Zippa la build Linux tenendo l'eseguibile avviabile (permesso +x).
Lo zip di Windows (Compress-Archive) i permessi Unix non li salva: su Linux il gioco
non partirebbe senza un chmod. Lo chiama export.cmd.
Uso: python export_zip_linux.py <cartella build/linux> <file .zip>
"""
import os
import sys
import zipfile

src, dst = sys.argv[1], sys.argv[2]
with zipfile.ZipFile(dst, "w", zipfile.ZIP_DEFLATED) as z:
    for name in sorted(os.listdir(src)):
        path = os.path.join(src, name)
        info = zipfile.ZipInfo.from_file(path, name)
        executable = name.endswith(".x86_64") or name.endswith(".sh")
        info.external_attr = (0o100755 if executable else 0o100644) << 16
        info.create_system = 3          # "Unix": così i permessi vengono letti
        info.compress_type = zipfile.ZIP_DEFLATED
        with open(path, "rb") as f:
            z.writestr(info, f.read())
print("zip:", dst)
