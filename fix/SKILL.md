---
name: fix
description: "Diagnostico e correcao autonoma de problemas comuns — Evolution offline, agente travado, dispatcher com erro, LaunchAgent falhando. Use /fix para corrigir sem explicar o problema."
model: sonnet
effort: medium
---

# /fix — Diagnostico e Correcao Autonoma

Diagnostique e corrija problemas comuns da Operacao IA sem pedir ajuda ao aluno.

## Fluxo

1. **Identifique o problema** — leia logs, config, status dos processos
2. **Diagnostique a causa raiz** — nao assuma, investigue
3. **Corrija autonomamente** — execute o fix sem perguntar
4. **Confirme a correcao** — verifique que o problema foi resolvido
5. **Informe em linguagem simples** — o que estava errado e o que foi feito

## Problemas conhecidos e fixes

### Evolution API offline
```bash
# Verificar
curl -s http://localhost:8080/instance/fetchInstances -H "apikey: {key}" | head -c 200

# Se nao responder: verificar se Docker esta rodando
docker ps | grep evolution

# Reiniciar se necessario
docker restart evolution-api 2>/dev/null || docker compose -f ~/evolution-api/docker-compose.yml up -d
```

### LaunchAgent guardian parado
```bash
# Verificar
launchctl list | grep br.zxlab.operacao-ia.guardian

# Recarregar
launchctl unload ~/Library/LaunchAgents/br.zxlab.operacao-ia.guardian.watchdog.plist 2>/dev/null
launchctl load ~/Library/LaunchAgents/br.zxlab.operacao-ia.guardian.watchdog.plist
```

### Heartbeat desatualizado (> 15 min)
```bash
# Rodar manualmente para verificar
python3 ~/.operacao-ia/scripts/guardian.py --layer watchdog
cat ~/.operacao-ia/logs/heartbeat/watchdog.json
```

### contacts.db corrompido
```bash
# Verificar integridade
sqlite3 ~/.operacao-ia/data/contacts.db "PRAGMA integrity_check;"

# Se corrompido: restaurar do backup CSV se existir
ls ~/.operacao-ia/data/contacts.csv
```

### Dispatcher com erro
```bash
# Ver ultimo erro
tail -20 ~/.operacao-ia/logs/dispatcher.err.log 2>/dev/null

# Verificar imports e dependencias
python3 -c "import sys; sys.path.insert(0, '$HOME/.operacao-ia/scripts'); import dispatcher; print('OK')"
```

## Regras

- NUNCA pergunte ao aluno o que fazer — diagnostique e execute
- NUNCA mostre API keys completas
- Se nao conseguir corrigir sozinho: explique em 2 frases o que esta errado e o que o aluno precisa fazer manualmente
- Sempre confirme a correcao com um check final
- Informe o resultado em linguagem simples (nao tecnica)
