---
name: dedup
description: "Deduplicacao de contatos no contacts.db local e/ou Supabase. Use /dedup para remover duplicatas por telefone e sincronizar a base."
model: haiku
effort: low
---

# /dedup — Deduplicacao de Contatos

Remove contatos duplicados da base local e sincroniza com o Supabase.

## Fluxo

### 1. Verificar banco local
```bash
python3 - <<'EOF'
import sqlite3
from pathlib import Path
db = Path.home() / ".operacao-ia" / "data" / "contacts.db"
if not db.exists():
    print("contacts.db nao encontrado")
    exit()
conn = sqlite3.connect(str(db))
total = conn.execute("SELECT COUNT(*) FROM contacts").fetchone()[0]
dups = conn.execute("""
    SELECT phone, COUNT(*) as c FROM contacts
    GROUP BY phone HAVING c > 1
""").fetchall()
print(f"Total: {total} contatos")
print(f"Duplicatas por telefone: {len(dups)}")
for phone, count in dups[:10]:
    print(f"  {phone}: {count} entradas")
conn.close()
EOF
```

### 2. Remover duplicatas (manter o mais recente)
```bash
python3 - <<'EOF'
import sqlite3
from pathlib import Path
db = Path.home() / ".operacao-ia" / "data" / "contacts.db"
conn = sqlite3.connect(str(db))
conn.execute("""
    DELETE FROM contacts WHERE id NOT IN (
        SELECT MAX(id) FROM contacts GROUP BY phone
    )
""")
removed = conn.total_changes
conn.commit()
conn.close()
print(f"Removidos: {removed} duplicatas")
EOF
```

### 3. Sincronizar com Supabase (se configurado)
```bash
python3 -c "
import sys, json
from pathlib import Path
config_path = Path.home() / '.operacao-ia' / 'config' / 'config.json'
if not config_path.exists():
    print('config.json nao encontrado')
    exit()
config = json.loads(config_path.read_text())
if not config.get('supabase_url'):
    print('Supabase nao configurado — pulando sincronizacao')
    exit()
print('Supabase configurado — sincronizando...')
"
```

Se Supabase configurado, use `supabase_sync.py` para re-sincronizar a base limpa.

## Formato de relatorio

```
DEDUP — {data/hora}

Base local:
  Total antes:   {N} contatos
  Duplicatas:    {N} encontradas
  Removidas:     {N} entradas
  Total apos:    {N} contatos

Supabase:      ✅ Sincronizado / ⏭ Pulado (nao configurado)

Resultado: Base limpa.
```

## Regras

- Sempre mostrar contagem antes e depois
- Nunca deletar o registro mais recente — sempre manter o ultimo
- Se Supabase nao configurado: pular silenciosamente e informar
- Se contacts.db nao existir: informar e sugerir Etapa 6
