# Ralph Wiggum Method — initialise .ralph/ in a target repository
# Usage: .\ralph-init.ps1 [-Path "C:\path\to\repo"]
#        .\ralph-init.ps1                             # initialises in current directory

param(
    [string]$Path = "."
)

$targetDir = (Resolve-Path $Path -ErrorAction SilentlyContinue)
if (-not $targetDir) {
    Write-Host "  ERROR: Path '$Path' does not exist" -ForegroundColor Red
    exit 1
}
$targetDir = $targetDir.Path

$ralphDir = Join-Path $targetDir ".ralph"

if (Test-Path $ralphDir) {
    Write-Host "  .ralph/ already exists in '$targetDir' — skipping" -ForegroundColor Yellow
    exit 0
}

# ── Copy .ralph/ from the script root to the target ──────────────────────────
$scriptRoot  = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourceRalph = Join-Path $scriptRoot ".ralph"

if (-not (Test-Path $sourceRalph)) {
    Write-Host "  ERROR: Source .ralph/ folder not found at '$scriptRoot'" -ForegroundColor Red
    exit 1
}

Copy-Item -Path $sourceRalph -Destination $ralphDir -Recurse -Force

Write-Host ""
Write-Host "  .ralph/ scaffolded in '$targetDir'" -ForegroundColor Green
Write-Host ""
Write-Host "  !! Ralph will NOT start until you customise the instructions !!" -ForegroundColor Yellow
Write-Host ""
Write-Host "  You MUST edit these files before running Ralph:" -ForegroundColor Cyan
Write-Host "    1. .ralph/prompt.md   - change the Goal to describe YOUR project" -ForegroundColor Cyan
Write-Host "    2. .ralph/AGENTS.md   - set the build/run/test commands for YOUR stack" -ForegroundColor Cyan
Write-Host "    3. .ralph/specs/      - replace helloworld.md with YOUR application specs" -ForegroundColor Cyan
Write-Host "    4. .ralph/fix_plan.md - seed the initial TODO list for YOUR project" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Once done, commit and push, then run:" -ForegroundColor DarkGray
Write-Host "    .\ralph.ps1 -Repo <clone-url>" -ForegroundColor DarkGray
Write-Host "    .\ralph.ps1 -WorkDir '$targetDir'" -ForegroundColor DarkGray
Write-Host ""
