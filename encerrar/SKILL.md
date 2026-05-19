---
name: encerrar
description: "Fechamento completo da sessao: harvest + status final + agenda proximos passos + atualiza Mission Control. Use /encerrar ao final de qualquer sessao de trabalho."
model: sonnet
effort: medium
---

# /encerrar — Fechamento Completo de Sessao

Execute o fluxo completo de encerramento — harvest, status, proximos passos, Mission Control.

## Fluxo em ordem

### Passo 1: Harvest (4 destinos)
Execute `/harvest`. Ele salva em:
- `[Mega]\CLAUDE CODE DJ CONTROL\dlsdigital-operacao-ia\logs\harvest\YYYY-MM-DD.md` — detectado automaticamente (`D:\Mega` no note casa, `C:\Users\dario\Documents\MEGA` no note trabalho)
- `/root/.operacao-ia/logs/harvest/YYYY-MM-DD.md` (VPS via paramiko)
- Git commit + push automatico
- MEMORY.md atualizado com novas infos da sessao

Confirme os 4 destinos antes de continuar.

### Passo 2: Status rapido na VPS
```python
import paramiko
c = paramiko.SSHClient()
c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
c.connect("72.60.248.118", username="root", password="RNshX#i9GM6G9jyGPhoYS@", timeout=15)

stdin, stdout, stderr = c.exec_command(
    "python3 -c \""
    "import json; from datetime import datetime; "
    "d=json.load(open('/root/.operacao-ia/logs/heartbeat/watchdog.json')); "
    "ts=d.get('updated_at',''); "
    "age=(datetime.now()-datetime.fromisoformat(ts)).total_seconds()/60; "
    "print(f'Guardian: OK ({age:.0f}min atras)')\" 2>/dev/null || echo 'Guardian: verificar'; "
    "df -h /root | awk 'NR==2 {print \"Disco: \" $4 \" livres\"}'; "
    "curl -s http://localhost:8784/health"
)
print(stdout.read().decode())
c.close()
```

### Passo 3: Agenda da proxima sessao

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
- Disco VPS: {disponivel}
- API: {health}

Harvest salvo em:
- Mega: C:\Users\dario\Documents\MEGA\...\logs\harvest\YYYY-MM-DD.md
- VPS: /root/.operacao-ia/logs/harvest/YYYY-MM-DD.md
- Git: commit {hash}
- MEMORY.md: atualizado

Proxima sessao — prioridades:
1. {tarefa 1}
2. {tarefa 2}
3. {tarefa 3}

Ate a proxima, Dario!
```

## Regras

- Confirmar os 4 destinos do harvest ANTES de mostrar mensagem final (Mega + VPS + Git + MEMORY.md)
- Sempre verificar status da VPS (guardian + disco + API health)
- Se o harvest falhar na VPS, informar mas nao bloquear o encerramento
- Mensagem de encerramento deve ser positiva e encorajadora
- Nunca encerrar sem confirmar que o harvest foi salvo ao menos no Mega e no Git
- O script detecta automaticamente o caminho Mega (`D:\Mega` no note casa, `C:\Users\dario\Documents\MEGA` no note trabalho) — nao precisa editar
