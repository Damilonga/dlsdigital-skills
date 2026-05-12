---
name: status
description: "Health check completo de todos os servicos da Operacao IA. Use /status para ver WhatsApp, email, agente, guardiao e conexoes em um relatorio rapido."
model: haiku
effort: low
---

# /status — Health Check Completo

Faca um health check completo da Operacao IA do aluno.

## O que verificar

1. **WhatsApp (Evolution API)**
   - Le `evolution_api_url` e `evolution_api_key` do config.json
   - Faz GET em `{url}/instance/fetchInstances`
   - Status: conectado / desconectado / sem resposta

2. **Guardian / Heartbeat**
   - Le `~/.operacao-ia/logs/heartbeat/watchdog.json`
   - Verifica se `updated_at` tem menos de 10 minutos
   - Status: ativo / desatualizado / ausente

3. **Supabase**
   - Le `supabase_url` e `supabase_anon_key` do config.json
   - Faz GET em `{supabase_url}/rest/v1/contacts?select=id&limit=1`
   - Status: conectado / erro

4. **Contatos**
   - Verifica se `~/.operacao-ia/data/contacts.db` existe
   - Conta registros se existir

5. **Skills instaladas**
   - Verifica se as 7 skills existem em `~/.claude/skills/`

6. **RTK**
   - Verifica se `rtk` esta no PATH
   - Se sim, mostra `rtk gain`

## Formato do relatorio

```
STATUS DA OPERACAO IA — {data/hora}

WhatsApp:    ✅ Conectado (evolution)
Guardian:    ✅ Ativo (watchdog 3min atras)
Supabase:    ✅ Conectado ({N} contatos)
contacts.db: ✅ Existe ({N} registros)
Skills:      ✅ 7/7 instaladas
RTK:         ✅ Instalado

Tudo OK.
```

## Regras

- Leia o config.json em `~/.operacao-ia/config/config.json`
- Se config.json nao existir, informe que a Semana 1 ou 2 precisa ser executada
- Nunca mostre API keys completas — mostre apenas os primeiros 8 caracteres
- Se algo falhar, sugira o comando correto para corrigir
- Execute os checks em sequencia e mostre o relatorio completo no final
