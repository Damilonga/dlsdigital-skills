---
name: preflight
description: "Verifica o ambiente antes de sessoes criticas — disparos em massa, configuracoes importantes, deploys. Use /preflight antes de qualquer operacao de alto impacto."
model: haiku
effort: low
---

# /preflight — Verificacao Pre-Voo

Execute antes de sessoes criticas (disparos, configuracoes, deploys).

## Checks obrigatorios

### 1. RTK ativo
```bash
which rtk && echo "RTK: OK" || echo "RTK: AUSENTE"
```

### 2. Evolution API respondendo
```bash
python3 - <<'EOF'
import json, urllib.request
from pathlib import Path
cfg = json.loads((Path.home()/".operacao-ia/config/config.json").read_text())
url = cfg.get("evolution_api_url","http://localhost:8080")
key = cfg.get("evolution_api_key","")
try:
    req = urllib.request.Request(f"{url}/instance/fetchInstances", headers={"apikey": key})
    with urllib.request.urlopen(req, timeout=5) as r:
        print(f"Evolution API: OK (HTTP {r.status})")
except Exception as e:
    print(f"Evolution API: FALHOU — {e}")
EOF
```

### 3. Supabase acessivel
```bash
python3 - <<'EOF'
import json, urllib.request
from pathlib import Path
cfg = json.loads((Path.home()/".operacao-ia/config/config.json").read_text())
url = cfg.get("supabase_url","")
key = cfg.get("supabase_anon_key","")
if not url:
    print("Supabase: nao configurado")
else:
    try:
        req = urllib.request.Request(f"{url}/rest/v1/contacts?select=id&limit=1",
            headers={"apikey": key, "Authorization": f"Bearer {key}"})
        with urllib.request.urlopen(req, timeout=8) as r:
            print(f"Supabase: OK (HTTP {r.status})")
    except Exception as e:
        print(f"Supabase: FALHOU — {e}")
EOF
```

### 4. LaunchAgents guardian
```bash
launchctl list | grep br.zxlab.operacao-ia.guardian | wc -l | xargs -I{} echo "Guardian LaunchAgents: {} de 3"
```

### 5. Disco disponivel
```bash
df -h ~ | awk 'NR==2 {print "Disco: " $4 " livres (" $5 " usado)"}'
```

### 6. Heartbeat recente (< 15min)
```bash
python3 - <<'EOF'
import json
from datetime import datetime
from pathlib import Path
p = Path.home() / ".operacao-ia" / "logs" / "heartbeat" / "watchdog.json"
if not p.exists():
    print("Heartbeat: arquivo ausente")
else:
    data = json.loads(p.read_text())
    ts = data.get("updated_at","")
    try:
        age = (datetime.now() - datetime.fromisoformat(ts)).total_seconds() / 60
        print(f"Heartbeat: {'OK' if age < 15 else 'DESATUALIZADO'} ({age:.0f}min atras)")
    except:
        print(f"Heartbeat: timestamp invalido")
EOF
```

## Formato de saida

```
PRE-FLIGHT — {hora}

RTK:          ✅ Ativo
Evolution:    ✅ OK
Supabase:     ✅ OK
Guardian:     ✅ 3/3 LaunchAgents
Disco:        ✅ 45GB livres
Heartbeat:    ✅ 3min atras

STATUS: LIBERADO PARA OPERAR
```

Se qualquer item falhar:
```
STATUS: ATENCAO — corrija antes de prosseguir
[lista dos itens com problema e como corrigir]
```

## Regras

- Executar todos os checks sempre, mesmo que algum falhe
- Nao abortar no primeiro erro — coletar tudo e mostrar no final
- Se STATUS = ATENCAO: sugira /fix para corrigir automaticamente
