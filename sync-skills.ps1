# sync-skills.ps1
# Sincroniza as skills do Claude Code com o GitHub a cada 15 minutos
# Repositorio: https://github.com/Damilonga/dlsdigital-skills
# Executado pelo Task Scheduler: DLS-Skills-Sync

$ErrorActionPreference = "Stop"
$skillsDir = "D:\Mega\CLAUDE_SKILLS"
$logFile = "D:\Mega\CLAUDE_SKILLS\sync.log"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

function Log($msg) {
    $line = "[$timestamp] $msg"
    Add-Content -Path $logFile -Value $line -Encoding UTF8
}

try {
    Set-Location $skillsDir

    # Verificar se ha mudancas
    $status = git status --porcelain
    if ($status) {
        git add .
        $commitMsg = "auto-sync: atualizacao das skills em $timestamp"
        git commit -m $commitMsg
        git push origin master
        Log "SYNC OK: $($status.Count) arquivo(s) atualizado(s) e enviado ao GitHub"
    } else {
        # Mesmo sem mudancas locais, puxar do remoto
        git pull origin master --ff-only
        Log "SYNC OK: sem mudancas locais, repositorio atualizado do remoto"
    }
} catch {
    Log "ERRO: $($_.Exception.Message)"
    exit 1
}
