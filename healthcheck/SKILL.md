---
name: healthcheck
description: "Verificacao rapida e leve de saude do ambiente — sem agents. Use /healthcheck para um diagnostico em segundos: processos, disco, heartbeat recente."
model: haiku
effort: medium
---

# /healthcheck — Verificacao Rapida de Saude

Execute uma verificacao rapida e leve sem abrir agents paralelos.

## Checks a executar (em ordem)

### 1. Heartbeat recente
```bash
cat ~/.operacao-ia/logs/heartbeat/watchdog.json 2>/dev/null
```
- Verifica se `updated_at` tem menos de 15 minutos
- Se mais de 15 min: alerta que o guardian pode estar parado

### 2. LaunchAgents do guardian
```bash
launchctl list | grep br.zxlab.operacao-ia
```
- Verifica se os 3 LaunchAgents (watchdog, heartbeat, last_resort) aparecem
- Nota: presenca na lista nao garante execucao recente

### 3. Espaco em disco
```bash
df -h ~ | tail -1
```
- Alerta se disco livre < 5GB

### 4. Processos relacionados
```bash
pgrep -f "guardian.py" && echo "guardian rodando" || echo "guardian nao em execucao"
```

### 5. Config.json existe e tem campos minimos
```bash
cat ~/.operacao-ia/config/config.json 2>/dev/null | python3 -c "import sys,json; c=json.load(sys.stdin); print('OK' if c.get('student_name') else 'FALTANDO campos')"
```

## Formato de saida

```
HEALTHCHECK — {hora}

Guardian:    ✅ Watchdog ha 4min
LaunchAgents: ✅ 3/3 ativos
Disco:        ✅ 45GB livres
Config:       ✅ OK

Resultado: SAUDAVEL
```

## Regras

- Seja rapido — nao abra subagents
- Se encontrar problema, sugira o comando de correcao em uma linha
- Use bash direto (nao Python) para ser mais rapido
- Se tudo OK: encerre com "Resultado: SAUDAVEL"
- Se algo errado: encerre com "Resultado: ATENCAO — {problema principal}"
