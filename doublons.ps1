$racine  = "$env:USERPROFILE\Documents\Classement"
$rapport = Join-Path $racine 'rapport_doublons.csv'

$fichiers = Get-ChildItem $racine -Recurse -File | Where-Object { $_.Name -notlike '*.csv' } 

$groupes = $fichiers | Get-FileHash -Algorithm SHA256 |
  Group-Object Hash | Where-Object Count -gt 1

$lignes = foreach ($g in $groupes) {
  $tri = $g.Group | Sort-Object { $_.Path.Length }
  $i = 0
  foreach ($h in $tri) {
    $i++
    [pscustomobject]@{
      Groupe = $g.Name.Substring(0, 8)
      Statut = if ($i -eq 1) { 'A GARDER' } else { 'DOUBLON' }
      Fichier = Split-Path $h.Path -Leaf
      Chemin = $h.Path
    }
  }
}

if ($lignes) {
  $lignes | Export-Csv $rapport -Delimiter ';' -NoTypeInformation -Encoding UTF8
  $lignes | Format-Table Groupe, Statut, Fichier -AutoSize
  Write-Host "Rapport : $rapport"
} else {
  Write-Host "Aucun doublon exact."
}