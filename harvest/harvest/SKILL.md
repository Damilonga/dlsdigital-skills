---
name: harvest
description: "Captura aprendizados da sessao atual e salva em D:\\Mega\\CLAUDE CODE DJ CONTROL\\dlsdigital-operacao-ia\\logs\\harvest\\ (Mega + git), na VPS e atualiza MEMORY.md. Use /harvest ao final de qualquer sessao produtiva."
model: sonnet
effort: low
---

# /harvest — Colheita de Aprendizados

Analise a sessao atual e salve os aprendizados em TRES lugares:
1. **Mega** — `D:\Mega\CLAUDE CODE DJ CONTROL\dlsdigital-operacao-ia\logs\harvest\YYYY-MM-DD.md`
2. **VPS** — `/root/.operacao-ia/logs/harvest/YYYY-MM-DD.md` via paramiko
3. **MEMORY.md** — `C:\Users\dario\Documents\MEGA\.claude-memory\MEMORY.md` (sincroniza entre notebooks via MEGA)

## O que capturar

Analise a conversa e identifique:

1. **O que foi feito** — acoes concluidas, scripts criados/modificados, configuracoes alteradas
2. **O que funcionou** — solucoes que resolveram problemas
3. **O que nao funcionou** — tentativas que falharam e por que
4. **Decisoes tomadas** — escolhas importantes e o motivo
5. **Proximos passos** — o que ficou pendente

## Como salvar

Execute este script Python (substitua o `content` com os dados reais da sessao):

```python
import paramiko
from pathlib import Path
from datetime import datetime

today = datetime.now().strftime("%Y-%m-%d")
ts    = datetime.now().strftime("%H:%M")

content = f"""## Sessao {ts} — RESUMO_DE_1_LINHA

### O que foi feito
- item 1
- item 2

### O que funcionou
- item 1

### O que nao funcionou
- item 1 (e como foi resolvido)

### Decisoes importantes
- item 1

### Proximos passos
- [ ] tarefa 1
- [ ] tarefa 2
""".strip()

# ── 1. Salvar no Mega (dentro do repo git) ────────────────────────────────────
mega_dir = Path(r"D:\Mega\CLAUDE CODE DJ CONTROL\dlsdigital-operacao-ia\logs\harvest")
mega_dir.mkdir(parents=True, exist_ok=True)
mega_file = mega_dir / f"{today}.md"

with open(mega_file, "a", encoding="utf-8") as f:
    if mega_file.exists() and mega_file.stat().st_size > 0:
        f.write("\n\n---\n\n")
    f.write(content)
print(f"[OK] Mega: {mega_file}")

# ── 2. Salvar na VPS via paramiko ─────────────────────────────────────────────
try:
    c = paramiko.SSHClient()
    c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    c.connect("72.60.248.118", username="root", password="RNshX#i9GM6G9jyGPhoYS@", timeout=15)

    vps_path = f"/root/.operacao-ia/logs/harvest/{today}.md"
    sftp = c.open_sftp()
    # Criar diretorio se nao existir
    c.exec_command("mkdir -p /root/.operacao-ia/logs/harvest")

    # Ler conteudo existente (append)
    existing = ""
    try:
        with sftp.open(vps_path, "r") as f:
            existing = f.read().decode("utf-8")
    except FileNotFoundError:
        pass

    new_content = (existing + "\n\n---\n\n" + content) if existing else content
    with sftp.open(vps_path, "w") as f:
        f.write(new_content)

    sftp.close()
    c.close()
    print(f"[OK] VPS: {vps_path}")
except Exception as e:
    print(f"[AVISO] VPS nao salvo: {e}")

# ── 3. Commit no git ──────────────────────────────────────────────────────────
import subprocess
repo = r"D:\Mega\CLAUDE CODE DJ CONTROL\dlsdigital-operacao-ia"
subprocess.run(["git", "-C", repo, "add", "logs/harvest/"], capture_output=True)
r = subprocess.run(
    ["git", "-C", repo, "commit", "-m", f"harvest: sessao {today} {ts}"],
    capture_output=True, text=True
)
if "nothing to commit" in r.stdout + r.stderr:
    print("[OK] Git: sem mudancas novas")
else:
    subprocess.run(["git", "-C", repo, "push", "origin", "main"], capture_output=True)
    print(f"[OK] Git: commitado e enviado")

# ── 4. Atualizar MEMORY.md ────────────────────────────────────────────────────
# IMPORTANTE: Atualize manualmente as secoes relevantes do MEMORY.md com base
# no que foi feito na sessao. Foque em:
#   - Novas URLs, senhas ou credenciais
#   - Novos arquivos/endpoints criados
#   - Bugs conhecidos e suas solucoes
#   - Status das semanas (marcar concluidas, adicionar data)
#   - Proximos passos atualizados
memory_path = Path(r"C:\Users\dario\Documents\MEGA\.claude-memory\MEMORY.md")
if memory_path.exists():
    print(f"[LEMBRETE] Atualizar MEMORY.md: {memory_path}")
    print("  -> Novas URLs/endpoints criados hoje")
    print("  -> Status das semanas atualizado")
    print("  -> Proximos passos revisados")
else:
    print(f"[AVISO] MEMORY.md nao encontrado em: {memory_path}")
```

## Formato do arquivo salvo

```markdown
## Sessao 14:30 — Revisao completa saas_api + git na VPS

### O que foi feito
- Git configurado na VPS (git pull + restart substitui SFTP)
- 6 correcoes aplicadas na saas_api com Serena

### O que funcionou
- Serena com busca simbolica economizou tokens (sem ler arquivos inteiros)
- Junction Windows: uma pasta fisica, dois enderecos

### O que nao funcionou
- git clone HTTPS sem token falha em repo privado

### Decisoes importantes
- Skills em repo separado (dlsdigital-skills) — mais limpo

### Proximos passos
- [ ] Semana 5 — Automacao do Instagram
- [ ] Configurar segundo notebook
```

## Regras

- Salvar SEMPRE nos tres lugares (Mega + VPS + MEMORY.md)
- Fazer commit do harvest no git ao final
- Maximo 5 itens por secao — seja conciso
- Se VPS falhar, continuar com Mega (nao e motivo para nao salvar)
- **MEMORY.md e obrigatorio** — e o que garante continuidade no outro notebook
- Confirmar os 4 destinos salvos ao final: Mega, VPS, Git, MEMORY.md

## O que atualizar no MEMORY.md

Sempre revisar e atualizar:
- Novas URLs, endpoints, credenciais criadas na sessao
- Novos arquivos importantes (ex: `crm/app.html`)
- Bugs conhecidos e suas solucoes (ex: sessionStorage vs localStorage)
- Linha de status das semanas (ex: `✅ 2026-05-13 — ...`)
- Proximos passos atualizados (remover os feitos, adicionar novos)
- Configuracoes de infra alteradas (ex: Traefik, nginx, systemd)
