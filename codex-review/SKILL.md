# /codex-review — Revisao de Codigo com Codex

Delega a revisao completa do codigo ao agente Codex.
Use este skill ANTES de subir atualizacoes para producao.

## Quando usar

- Antes de fazer deploy de mudancas na saas_api
- Antes de alterar scripts criticos (dispatcher, guardian, agent_bant)
- Quando adicionar novas rotas ou modelos ao FastAPI
- Apos sessoes longas de codificacao

## O que o Codex revisa

### Diretorios auditados

```
/root/.operacao-ia/saas_api/    <- API multi-tenant (FastAPI)
/root/.operacao-ia/scripts/     <- agente IA, dispatcher, guardian
D:\Mega\CLAUDE CODE DJ CONTROL\dlsdigital-operacao-ia\crm\  <- CRM HTML
```

### Checklist de revisao

1. **Seguranca**
   - Credenciais hardcoded (senhas, tokens, API keys no codigo-fonte)
   - SQL injection (queries sem parametrizacao)
   - JWT sem validacao correta de expiracao
   - Endpoints sem autenticacao que deveriam ter

2. **Multi-tenancy**
   - Rotas de cliente acessando dados de outros tenants
   - Filtro `tenant_id` faltando em queries
   - Admin bypassando tenant incorretamente

3. **Estabilidade**
   - Try/except vazios engolindo erros silenciosamente
   - Conexoes de banco sem fechar (memory leak)
   - Loops sem limite de iteracao
   - Rate limiter desativado ou mal configurado

4. **Qualidade**
   - Funcoes muito longas (>80 linhas) — sugerir refatoracao
   - Duplicacao de logica entre scripts
   - Variaveis nao usadas

5. **Anti-ban WhatsApp**
   - Delays respeitados (300-600s entre msgs WPP)
   - Limites diarios configurados
   - Validacao de numero antes de enviar

## Como executar

```
/codex-review
```

O agente Codex vai:
1. Ler os arquivos criticos da saas_api (main.py, auth.py, routers/)
2. Ler dispatcher.py, guardian.py, agent_bant.py
3. Gerar um relatorio com: CRITICO / AVISO / SUGESTAO
4. Salvar o relatorio em `~/.operacao-ia/logs/codex-review-{data}.md`

## Formato do relatorio

```
# Codex Review — {data}

## CRITICOS (0)
Nenhum.

## AVISOS (N)
- [AVISO] auth.py:99 — senha padrao "dlsdigital2026" no seed_admin.py deve ser variavel de ambiente

## SUGESTOES (N)
- [SUGESTAO] dispatcher.py:45 — extrair logica de delay para funcao separada

## Resumo
N arquivos revisados. Score: X/10
```

## Instrucoes para o Codex

Ao receber este skill:

1. Use o agente `codex:codex-rescue` com o prompt abaixo
2. Passe os caminhos dos arquivos para revisar
3. Aguarde o relatorio completo antes de responder ao usuario

**Prompt para o Codex:**

```
Faca uma revisao completa de seguranca e qualidade do codigo do projeto dlsdigital-operacao-ia.

Arquivos a revisar (leia todos antes de emitir o relatorio):
- saas_api/auth.py
- saas_api/main.py
- saas_api/models.py
- saas_api/database.py
- saas_api/routers/ (todos os arquivos)

Checklist:
1. Credenciais hardcoded
2. SQL injection
3. Multi-tenancy (tenant_id sempre filtrado?)
4. Endpoints sem auth
5. Erros silenciosos (except sem log)
6. Conexoes de banco sem fechar

Para cada problema encontrado, informe: arquivo, linha, severidade (CRITICO/AVISO/SUGESTAO), descricao e correcao sugerida.
```
