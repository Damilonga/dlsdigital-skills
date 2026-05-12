---
name: encerrar
description: "Fechamento completo da sessao: harvest + status final + agenda proximos passos + atualiza Mission Control. Use /encerrar ao final de qualquer sessao de trabalho."
model: sonnet
effort: medium
---

# /encerrar — Fechamento Completo de Sessao

Execute o fluxo completo de encerramento — harvest, status, proximos passos, Mission Control.

## Fluxo em ordem

### Passo 1: Harvest
Execute `/harvest` para capturar os aprendizados da sessao.

### Passo 2: Status rapido
Execute os checks essenciais:
```bash
# Guardian vivo?
cat ~/.operacao-ia/logs/heartbeat/watchdog.json 2>/dev/null | python3 -c "
import sys,json
from datetime import datetime
d=json.load(sys.stdin)
ts=d.get('updated_at','')
try:
    age=(datetime.now()-datetime.fromisoformat(ts)).total_seconds()/60
    print(f'Guardian: OK ({age:.0f}min atras)')
except:
    print('Guardian: timestamp invalido')
" 2>/dev/null || echo "Guardian: sem snapshot"

# Disco
df -h ~ | awk 'NR==2 {print "Disco: " $4 " livres"}'
```

### Passo 3: Atualizar Mission Control
```bash
python3 ~/.operacao-ia/scripts/mission_control.py --open 2>/dev/null || \
python3 -c "
import importlib.util, sys
from pathlib import Path
# Tenta usar mission_control.py de qualquer localizacao
for candidate in [
    Path.home()/'.operacao-ia/scripts/mission_control.py',
]:
    if candidate.exists():
        spec = importlib.util.spec_from_file_location('mc', candidate)
        mc = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(mc)
        mc.update_mission_control()
        break
"
```

### Passo 4: Agenda da proxima sessao

Com base no harvest e no status atual, liste:
- As 3 tarefas mais importantes para a proxima sessao
- Qualquer alerta ou problema que precisa de atencao

## Mensagem de encerramento (formato fixo)

```
SESSAO ENCERRADA — {data} {hora}

O que foi feito hoje:
{3-5 bullets do harvest}

Status da operacao:
- Guardian: {status}
- Disco: {disponivel}

Proxima sessao — prioridades:
1. {tarefa 1}
2. {tarefa 2}
3. {tarefa 3}

Mission Control atualizado. Ate a proxima!
```

## Regras

- Sempre executar harvest ANTES do status
- Sempre atualizar Mission Control no final
- Se o aluno mencionar algo pendente, adicionar automaticamente na lista de proximos passos
- Mensagem de encerramento deve ser positiva e encorajadora
- Nunca encerrar sem confirmar que o harvest foi salvo
