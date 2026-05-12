---
name: harvest
description: "Captura aprendizados da sessao atual e salva em ~/.operacao-ia/logs/harvest/YYYY-MM-DD.md. Use /harvest ao final de qualquer sessao produtiva."
model: sonnet
effort: low
---

# /harvest — Colheita de Aprendizados

Analise a sessao atual e salve os aprendizados mais importantes.

## O que capturar

Analise a conversa atual e identifique:

1. **O que foi feito** — acoes concluidas, scripts criados/modificados, configuracoes alteradas
2. **O que funcionou** — solucoes que resolveram problemas
3. **O que nao funcionou** — tentativas que falharam e por que
4. **Decisoes tomadas** — escolhas importantes e o motivo
5. **Proximos passos** — o que ficou pendente

## Como salvar

```bash
python3 - <<'PYEOF'
from pathlib import Path
from datetime import datetime

harvest_dir = Path.home() / ".operacao-ia" / "logs" / "harvest"
harvest_dir.mkdir(parents=True, exist_ok=True)

today = datetime.now().strftime("%Y-%m-%d")
ts = datetime.now().strftime("%H:%M")
harvest_file = harvest_dir / f"{today}.md"

# Conteudo gerado pela analise da sessao
content = """
## Sessao {ts} — {resumo_de_1_linha}

### O que foi feito
{lista_de_acoes}

### O que funcionou
{lista_do_que_funcionou}

### Decisoes importantes
{lista_de_decisoes}

### Proximos passos
{lista_de_pendencias}
""".strip()

# Adicionar ao arquivo do dia (append)
with open(harvest_file, "a", encoding="utf-8") as f:
    if harvest_file.stat().st_size > 0:
        f.write("\n\n---\n\n")
    f.write(content)

print(f"Harvest salvo: {harvest_file}")
PYEOF
```

Substitua os placeholders com o conteudo real da sessao antes de executar.

## Formato do arquivo salvo

```markdown
## Sessao 14:30 — Configurei Supabase e migrei contatos

### O que foi feito
- Executei setup_supabase.py e configurei credenciais
- Migrei 127 contatos da Semana 1 para o Supabase
- Fiz deploy do Mini-CRM no Cloudflare Pages

### O que funcionou
- Migracao via SQLite → Supabase funcionou perfeitamente
- wrangler pages deploy aceitou o projeto sem erros

### Decisoes importantes
- Usamos service_role_key para a migracao (anon_key nao tem permissao de escrita com RLS)

### Proximos passos
- [ ] Testar login no CRM com email do Supabase Auth
- [ ] Configurar dominio customizado no Cloudflare Pages
```

## Regras

- Seja conciso — maximo 5 itens por secao
- Use linguagem simples, sem jargao
- Salve SEMPRE antes de encerrar a sessao
- Se a sessao foi curta (< 3 acoes), um harvest minimo ainda e valido
- Confirme o caminho do arquivo salvo ao final
