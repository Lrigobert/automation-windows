param([switch]$Simulation)

$src     = "$env:USERPROFILE\Downloads\Documents"
$racine  = "$env:USERPROFILE\Documents\Classement"
$index   = Join-Path $racine 'index.csv'
$sensible = 'cle|mdp|password|secret|token|backup'

$cats = [ordered]@{
  'CV'  = @{ Dossier='CV';            Regex='(^|[^a-z])cv([^a-z]|$)|resume' }
  'EMP' = @{ Dossier='Emploi';        Regex='lettre|motivation|candidature|contrat|stage|cinema|offre' }
  'ADM' = @{ Dossier='Administratif'; Regex='attestation|autorisation|sejour|caf|impot|assurance|ameli|secu|visa' }
  'FIN' = @{ Dossier='Finance';       Regex='facture|releve|rib|banque|budget' }
  'ECO' = @{ Dossier='Ecole';         Regex='efrei|soutenance|memoire|rapport|dgsn|cours|questions' }
}

if (-not $Simulation) { New-Item $racine -ItemType Directory -Force | Out-Null }
$existant = if (Test-Path $index) { @(Import-Csv $index -Delimiter ';') } else { @() }
$lignes = @()

foreach ($f in Get-ChildItem $src -File) {
  if ($f.Name -match $sensible) { Write-Host "IGNORE (sensible) : $($f.Name)"; continue }

  $code = 'DIV'; $dossier = 'Divers'
  foreach ($c in $cats.Keys) {
    if ($f.BaseName.ToLower() -match $cats[$c].Regex) { $code = $c; $dossier = $cats[$c].Dossier; break }
  }

  $n = @($existant | Where-Object Categorie -eq $code).Count + @($lignes | Where-Object Categorie -eq $code).Count + 1
  $ref     = '{0}-{1}-{2:000}' -f $code, $f.LastWriteTime.ToString('yyyyMMdd'), $n
  $nouveau = "${ref}_$($f.Name)"
  $destDir = Join-Path $racine $dossier

  try {
    if (-not $Simulation) { New-Item $destDir -ItemType Directory -Force | Out-Null }
    Move-Item $f.FullName (Join-Path $destDir $nouveau) -WhatIf:$Simulation -ErrorAction Stop
    Write-Host "$ref  <-  $($f.Name)"
    $lignes += [pscustomobject]@{
      Reference = $ref; Categorie = $code; Dossier = $dossier
      NomOriginal = $f.Name; NomFinal = $nouveau
      Date = $f.LastWriteTime.ToString('yyyy-MM-dd'); Chemin = Join-Path $destDir $nouveau
    }
  } catch { Write-Host "IGNORE (fichier ouvert) : $($f.Name)" }
}

if (-not $Simulation -and $lignes.Count -gt 0) {
  $lignes | Export-Csv $index -Delimiter ';' -Append -NoTypeInformation -Encoding UTF8
}