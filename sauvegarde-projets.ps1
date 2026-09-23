param([switch]$Simulation)

$racine  = "$env:USERPROFILE\Backups"
$dest    = Join-Path $racine (Get-Date -Format 'yyyy-MM-dd_HHmm')
$projets = @(
  "$env:USERPROFILE\projet-tbm",
  "$env:USERPROFILE\projet_DGSN",
  "$env:USERPROFILE\Downloads\Lrigobert.github.io",
  "$env:USERPROFILE\Automation"
)
$exclure = 'node_modules','.venv','venv','__pycache__','.gradle'

foreach ($p in $projets) {
  if (-not (Test-Path $p)) { Write-Host "Introuvable : $p"; continue }
  $nom  = Split-Path $p -Leaf
  $opts = @($p, (Join-Path $dest $nom), '/E', '/R:1', '/W:1', '/NFL', '/NDL', '/NJH', '/NJS', '/XD') + $exclure
  if ($Simulation) { $opts += '/L' }
  robocopy @opts | Out-Null
  if ($LASTEXITCODE -ge 8) { Write-Host "ERREUR : $nom" } else { Write-Host "OK : $nom" }

  if (Test-Path (Join-Path $p '.git')) {
    if (git -C $p status --porcelain) { Write-Host "   Git : changements non commités dans $nom" }
  }
}

if (-not $Simulation -and (Test-Path $racine)) {
  Get-ChildItem $racine -Directory | Sort-Object Name -Descending |
    Select-Object -Skip 7 | Remove-Item -Recurse -Force
}