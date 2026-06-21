---
name: harvest
description: "Captura aprendizados da sessao atual e salva nos destinos do projeto atual (Mega/repo + git, MEMORY.md, opcionalmente VPS). Project-aware: detecta automaticamente entre cardapia, dlsdigital e outros. Use /harvest ao final de qualquer sessao produtiva."
model: sonnet
effort: low
---

# /harvest — Colheita de Aprendizados (project-aware)

Analise a sessao atual e salve os aprendizados nos destinos corretos do projeto onde voce esta trabalhando AGORA.

## Deteccao do projeto

A skill detecta o projeto ativo por estas heuristicas (em ordem):

1. **Working directory** (`cwd`) — match por substring do caminho
2. **Git remote origin** — match por substring da URL
3. Fallback: pergunte ao usuario qual projeto

O registry abaixo define cada projeto, seus caminhos e se tem VPS.

## Registry de projetos

```python
PROJECTS = {
    "cardapia": {
        "match": ["cardapia", "Cardapio Digital"],
        "harvest_dir_candidates": [
            r"C:\Users\dario\Documents\MEGA\Cardapio Digital\cardapia\docs\harvest",
            r"D:\Mega\Cardapio Digital\cardapia\docs\harvest",
        ],
        "repo_candidates": [
            r"C:\Users\dario\Documents\MEGA\Cardapio Digital\cardapia",
            r"D:\Mega\Cardapio Digital\cardapia",
        ],
        "branch": "main",
        "harvest_rel_path": "docs/harvest/",
        "vps": None,  # CardapIA roda na Vercel, sem VPS
    },
    "dlsdigital": {
        "match": ["dlsdigital-operacao-ia", "operacao-ia"],
        "harvest_dir_candidates": [
            r"D:\Mega\CLAUDE CODE DJ CONTROL\dlsdigital-operacao-ia\logs\harvest",
            r"C:\Users\dario\Documents\MEGA\CLAUDE CODE DJ CONTROL\dlsdigital-operacao-ia\logs\harvest",
        ],
        "repo_candidates": [
            r"D:\Mega\CLAUDE CODE DJ CONTROL\dlsdigital-operacao-ia",
            r"C:\Users\dario\Documents\MEGA\CLAUDE CODE DJ CONTROL\dlsdigital-operacao-ia",
        ],
        "branch": "main",
        "harvest_rel_path": "logs/harvest/",
        "vps": {
            "host": "72.60.248.118",
            "user": "root",
            "password": "RNshX#i9GM6G9jyGPhoYS@",
            "path": "/root/.operacao-ia/logs/harvest/",
        },
    },
}
```

## O que capturar

Analise a conversa e identifique:

1. **O que foi feito** — acoes concluidas, scripts criados/modificados, configuracoes alteradas
2. **O que funcionou** — solucoes que resolveram problemas
3. **O que nao funcionou** — tentativas que falharam e por que
4. **Decisoes tomadas** — escolhas importantes e o motivo
5. **Proximos passos** — o que ficou pendente

## Como salvar

Execute este script Python (substitua `content` com os dados reais da sessao):

```python
import os
import subprocess
import paramiko
from pathlib import Path
from datetime import datetime

today = datetime.now().strftime("%Y-%m-%d")
ts    = datetime.now().strftime("%H:%M")

# ── REGISTRY DE PROJETOS ─────────────────────────────────────────────────────
PROJECTS = {
    "cardapia": {
        "match": ["cardapia", "Cardapio Digital"],
        "harvest_dir_candidates": [
            r"C:\Users\dario\Documents\MEGA\Cardapio Digital\cardapia\docs\harvest",
            r"D:\Mega\Cardapio Digital\cardapia\docs\harvest",
        ],
        "repo_candidates": [
            r"C:\Users\dario\Documents\MEGA\Cardapio Digital\cardapia",
            r"D:\Mega\Cardapio Digital\cardapia",
        ],
        "branch": "main",
        "harvest_rel_path": "docs/harvest/",
        "vps": None,
    },
    "dlsdigital": {
        "match": ["dlsdigital-operacao-ia", "operacao-ia"],
        "harvest_dir_candidates": [
            r"D:\Mega\CLAUDE CODE DJ CONTROL\dlsdigital-operacao-ia\logs\harvest",
            r"C:\Users\dario\Documents\MEGA\CLAUDE CODE DJ CONTROL\dlsdigital-operacao-ia\logs\harvest",
        ],
        "repo_candidates": [
            r"D:\Mega\CLAUDE CODE DJ CONTROL\dlsdigital-operacao-ia",
            r"C:\Users\dario\Documents\MEGA\CLAUDE CODE DJ CONTROL\dlsdigital-operacao-ia",
        ],
        "branch": "main",
        "harvest_rel_path": "logs/harvest/",
        "vps": {
            "host": "72.60.248.118",
            "user": "root",
            "password": "RNshX#i9GM6G9jyGPhoYS@",
            "path": "/root/.operacao-ia/logs/harvest/",
        },
    },
}

# ── DETECCAO DO PROJETO ──────────────────────────────────────────────────────
def detect_project():
    cwd = os.getcwd()
    try:
        remote = subprocess.check_output(
            ["git", "config", "--get", "remote.origin.url"],
            text=True, stderr=subprocess.DEVNULL,
        ).strip()
    except Exception:
        remote = ""
    haystack = (cwd + " " + remote).lower()
    for key, cfg in PROJECTS.items():
        if any(m.lower() in haystack for m in cfg["match"]):
            return key, cfg
    return None, None

project_key, project = detect_project()
if not project:
    print("[ERRO] Projeto nao detectado. Adicione ao registry ou execute dentro do diretorio do projeto.")
    raise SystemExit(1)

print(f"[INFO] Projeto detectado: {project_key}")

# ── CONTEUDO DA SESSAO ───────────────────────────────────────────────────────
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

# ── 1. Salvar no Mega/repo local ─────────────────────────────────────────────
harvest_dir = next((Path(p) for p in project["harvest_dir_candidates"] if Path(p).parent.exists()), Path(project["harvest_dir_candidates"][-1]))
harvest_dir.mkdir(parents=True, exist_ok=True)
mega_file = harvest_dir / f"{today}.md"

if mega_file.exists() and mega_file.stat().st_size > 0:
    with open(mega_file, "a", encoding="utf-8") as f:
        f.write("\n\n---\n\n" + content)
else:
    with open(mega_file, "w", encoding="utf-8") as f:
        f.write(content)
print(f"[OK] Mega/repo: {mega_file}")

# ── 2. VPS (opcional, so se projeto tem VPS configurada) ─────────────────────
if project["vps"]:
    try:
        vps = project["vps"]
        c = paramiko.SSHClient()
        c.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        c.connect(vps["host"], username=vps["user"], password=vps["password"], timeout=15)
        vps_path = f"{vps['path'].rstrip('/')}/{today}.md"
        sftp = c.open_sftp()
        c.exec_command(f"mkdir -p {vps['path']}")
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
else:
    print(f"[SKIP] VPS: projeto '{project_key}' nao tem VPS configurada")

# ── 3. Commit no git ─────────────────────────────────────────────────────────
repo = next((p for p in project["repo_candidates"] if Path(p).exists()), project["repo_candidates"][-1])
rel_path = project["harvest_rel_path"]
subprocess.run(["git", "-C", repo, "add", rel_path], capture_output=True)
r = subprocess.run(
    ["git", "-C", repo, "commit", "-m", f"harvest: sessao {today} {ts}"],
    capture_output=True, text=True,
)
if "nothing to commit" in r.stdout + r.stderr:
    print("[OK] Git: sem mudancas novas")
else:
    subprocess.run(["git", "-C", repo, "push", "origin", project["branch"]], capture_output=True)
    print(f"[OK] Git: commit + push ({project_key} -> {project['branch']})")

# ── 4. MEMORY.md (lembrete) ──────────────────────────────────────────────────
memory_path = Path(r"C:\Users\dario\Documents\MEGA\.claude-memory\MEMORY.md")
if memory_path.exists():
    print(f"[LEMBRETE] Atualize MEMORY.md: {memory_path}")
    print("  -> Novas URLs/endpoints criados hoje")
    print("  -> Status do projeto atualizado")
    print("  -> Proximos passos revisados")
else:
    print(f"[AVISO] MEMORY.md nao encontrado: {memory_path}")
```

## Formato do arquivo salvo

```markdown
## Sessao 14:30 — Revisao completa saas_api + git na VPS

### O que foi feito
- Git configurado na VPS (git pull + restart substitui SFTP)
- 6 correcoes aplicadas na saas_api com Serena

### O que funcionou
- Serena com busca simbolica economizou tokens (sem ler arquivos inteiros)

### O que nao funcionou
- git clone HTTPS sem token falha em repo privado

### Decisoes importantes
- Skills em repo separado — mais limpo

### Proximos passos
- [ ] Semana 5 — Automacao do Instagram
```

## Regras

- **Detectar projeto SEMPRE** antes de salvar — nunca chumbar caminho no script
- Salvar nos destinos do projeto detectado (Mega/repo + Git + opcionalmente VPS + MEMORY.md)
- Maximo 5 itens por secao — seja conciso
- Se VPS falhar (ou projeto nao tiver), continuar com Mega (nao e motivo para nao salvar)
- **MEMORY.md e obrigatorio** — garante continuidade entre projetos e notebooks
- Confirmar os destinos salvos ao final: Mega/repo, [VPS se aplicavel], Git, MEMORY.md

## Como adicionar um novo projeto

1. Criar pasta `docs/harvest/` (ou equivalente) no repo do projeto novo
2. Adicionar entrada no dicionario `PROJECTS` desta skill com:
   - `match`: lista de substrings que identificam o projeto (path/git remote)
   - `harvest_dir_candidates`: caminhos absolutos da pasta de harvest (suporta D:\ e C:\)
   - `repo_candidates`: caminhos absolutos do repo
   - `branch`: branch principal (geralmente `main`)
   - `harvest_rel_path`: caminho relativo da pasta de harvest dentro do repo
   - `vps`: `None` ou dict com `host/user/password/path`
3. Atualizar o registry no `MEMORY.md` (secao "Harvest por projeto")

## O que atualizar no MEMORY.md (sempre)

- Novas URLs, endpoints, credenciais criadas na sessao
- Novos arquivos importantes
- Bugs conhecidos e suas solucoes
- Status das fases/semanas (marcar concluidas, adicionar data)
- Proximos passos atualizados
- Configuracoes de infra alteradas
