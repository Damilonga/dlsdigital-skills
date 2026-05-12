# /update-memory — Atualizar Memoria Compartilhada

Sincroniza o estado atual da operacao no arquivo `memory.json` da VPS.
Este arquivo e a "memoria viva" — qualquer sessao (Desktop ou VPS) pode ler e atualizar.

## Quando usar

- Ao final de cada sessao produtiva
- Apos adicionar novos servicos ou configuracoes
- Quando um erro importante for corrigido
- Antes de encerrar (`/encerrar`)

## O que e a Memoria

Arquivo JSON em `/root/.operacao-ia/memory.json` com:

```json
{
  "updated_at": "2026-05-12T21:00:00",
  "updated_by": "Desktop",
  "phase_completed": 4,
  "active_services": [...],
  "last_errors": [...],
  "open_tasks": [...],
  "notes": "..."
}
```

## Como executar

1. Ler o estado atual dos servicos (SSH/paramiko)
2. Perguntar ao usuario se ha notas adicionais
3. Atualizar `/root/.operacao-ia/memory.json` na VPS
4. Confirmar: "Memoria atualizada em {timestamp}"

## Campos que sempre devemos atualizar

| Campo | Origem |
|-------|--------|
| `updated_at` | datetime.utcnow() |
| `updated_by` | "Desktop" ou "VPS" |
| `phase_completed` | config.json |
| `active_services` | systemctl status |
| `last_session_summary` | resumo da sessao atual |
| `open_tasks` | lista do que ficou pendente |

## Script Python para atualizar (via paramiko)

```python
import json, datetime

memory = {
    "updated_at": datetime.datetime.utcnow().isoformat(),
    "updated_by": "Desktop",
    "phase_completed": 4,
    "active_services": [
        "operacao-ia-agent",
        "operacao-ia-crm-api",
        "operacao-ia-watchdog",
        "operacao-ia-saas-api"
    ],
    "last_session_summary": "Semana 4 finalizada: graphify, session log, memory, codex-review skill, skills-sync",
    "open_tasks": [
        "Semana 5 - Automacao Instagram"
    ],
    "notes": ""
}

with open('/root/.operacao-ia/memory.json', 'w') as f:
    json.dump(memory, f, indent=2, ensure_ascii=False)

print("Memoria atualizada:", memory["updated_at"])
```

## Leitura da Memoria (qualquer terminal)

```bash
cat /root/.operacao-ia/memory.json
```

Ou via API (se implementada):
```
GET http://72.60.248.118:8784/v2/memory
```
