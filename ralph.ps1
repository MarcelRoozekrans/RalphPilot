# Ralph Wiggum Method — the loop
# Usage: .\ralph.ps1 [-MaxIterations 50] [-Model "gpt-5-mini"]
#        .\ralph.ps1 -CLI claude -Model "claude-sonnet-4-5"
#        .\ralph.ps1 -Repo "https://github.com/user/repo.git" [-Branch "main"] [-Push] [-CloneDir "C:\clones"]
#        .\ralph.ps1 -WorkDir "C:\path\to\local\repo"

param(
    [int]$MaxIterations = 50,
    [string]$Model = "",
    [ValidateSet("copilot", "claude")]
    [string]$CLI = "copilot",       # Which CLI to use: "copilot" or "claude"

    # Remote / local repo support
    [string]$Repo     = "",        # Git clone URL (https or ssh)
    [string]$Branch   = "",        # Branch to clone / checkout (empty = remote default)
    [switch]$Push,                 # Push commits back to remote after the loop
    [string]$WorkDir  = "",        # Use an existing local directory instead of cloning
    [string]$CloneDir = ""         # Base directory for clones (default: one level above script root)
)

# Default model per CLI
if ($Model -eq "") {
    $Model = if ($CLI -eq "claude") { "claude-sonnet-4-5" } else { "gpt-5-mini" }
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

# ── Resolve the target working directory ──────────────────────────────────────
$isRemote  = $false
$clonedDir = ""

if ($Repo -ne "") {
    # Clone the remote repo
    $isRemote  = $true
    $repoName  = [System.IO.Path]::GetFileNameWithoutExtension(($Repo -replace '\.git$','').Split('/')[-1])

    # Default clone base: one level above the script root (outside the Ralph git repo)
    if ($CloneDir -eq "") {
        $cloneBase = Split-Path -Parent $scriptRoot
    } else {
        $cloneBase = $CloneDir
    }
    if (-not (Test-Path $cloneBase)) {
        New-Item -ItemType Directory -Path $cloneBase -Force | Out-Null
    }
    $clonedDir = Join-Path $cloneBase "ralph_${repoName}_$(Get-Date -Format 'yyyyMMdd_HHmmss')"

    if ($Branch -ne "") {
        Write-Host "  cloning $Repo (branch: $Branch) → $clonedDir" -ForegroundColor Cyan
        & git clone --branch $Branch --single-branch $Repo $clonedDir 2>&1
    } else {
        Write-Host "  cloning $Repo (default branch) → $clonedDir" -ForegroundColor Cyan
        & git clone $Repo $clonedDir 2>&1
    }
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  ERROR: git clone failed (exit $LASTEXITCODE)" -ForegroundColor Red
        exit 1
    }

    $targetDir = $clonedDir
}
elseif ($WorkDir -ne "") {
    # Use an existing local path
    if (-not (Test-Path $WorkDir)) {
        Write-Host "  ERROR: WorkDir '$WorkDir' does not exist" -ForegroundColor Red
        exit 1
    }
    $targetDir = (Resolve-Path $WorkDir).Path
}
else {
    # Default: run in the script's own directory (original behaviour)
    $targetDir = $scriptRoot
}

# ── Locate the .ralph/ folder in the target repo ─────────────────────────────
$ralphFolder = Join-Path $targetDir ".ralph"

if (-not (Test-Path $ralphFolder)) {
    # Auto-initialise .ralph/ in the target repo and stop
    $initScript = Join-Path $scriptRoot "ralph-init.ps1"
    if (Test-Path $initScript) {
        Write-Host "  .ralph/ not found — scaffolding in '$targetDir' …" -ForegroundColor Yellow
        & $initScript -Path $targetDir
        Write-Host "  Ralph will NOT start. Customise the instructions first, then run again." -ForegroundColor Yellow
        exit 0
    } else {
        Write-Host "  ERROR: No .ralph/ folder found in '$targetDir'" -ForegroundColor Red
        Write-Host "         ralph-init.ps1 not found either. Cannot continue." -ForegroundColor Red
        exit 1
    }
}

$promptFile = Join-Path $ralphFolder "prompt.md"
if (-not (Test-Path $promptFile)) {
    Write-Host "  ERROR: prompt.md not found in '$ralphFolder'" -ForegroundColor Red
    exit 1
}

Set-Location $targetDir

# ── The loop ──────────────────────────────────────────────────────────────────
$iteration = 0
$failures  = 0
$loopStart = Get-Date

$modeLabel = if ($isRemote) { "remote" } elseif ($WorkDir -ne "") { "local" } else { "self" }
Write-Host ""
Write-Host "  ralph loop  |  cli: $CLI  |  model: $Model  |  max: $MaxIterations  |  mode: $modeLabel" -ForegroundColor Cyan
Write-Host "  target: $targetDir" -ForegroundColor DarkGray
Write-Host ""

while ($iteration -lt $MaxIterations) {
    $iteration++
    Write-Host "[$iteration/$MaxIterations]  failures: $failures  |  elapsed: $((((Get-Date) - $loopStart)).ToString('hh\:mm\:ss'))" -ForegroundColor Yellow

    # Re-read the prompt each iteration (Ralph may have updated fix_plan or AGENTS.md)
    $prompt = Get-Content -Path $promptFile -Raw

    $iterStart = Get-Date
    if ($CLI -eq "claude") {
        & claude -p $prompt --dangerously-skip-permissions --model $Model 2>&1
    } else {
        & copilot -p $prompt --yolo --no-ask-user --model $Model 2>&1
    }
    $exitCode = $LASTEXITCODE
    $dur = ((Get-Date) - $iterStart).ToString('mm\:ss')

    if ($exitCode -eq 0) {
        Write-Host "  ok  ($dur)" -ForegroundColor Green
    } else {
        $failures++
        Write-Host "  fail (exit $exitCode, $dur) — continuing" -ForegroundColor Red
    }

    Start-Sleep -Seconds 2
}

Write-Host ""
Write-Host "  max iterations ($MaxIterations)  |  failures: $failures  |  time: $((((Get-Date) - $loopStart)).ToString('hh\:mm\:ss'))" -ForegroundColor Yellow

# ── Push results back to remote ───────────────────────────────────────────────
if ($isRemote -and $Push) {
    Write-Host ""
    if ($Branch -ne "") {
        Write-Host "  pushing commits to origin/$Branch …" -ForegroundColor Cyan
        & git push origin $Branch 2>&1
    } else {
        Write-Host "  pushing commits to origin …" -ForegroundColor Cyan
        & git push 2>&1
    }
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  pushed successfully" -ForegroundColor Green
    } else {
        Write-Host "  WARNING: push failed (exit $LASTEXITCODE)" -ForegroundColor Red
    }
}

if ($isRemote) {
    Write-Host ""
    Write-Host "  clone kept at: $clonedDir" -ForegroundColor DarkGray
}
