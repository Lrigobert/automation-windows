param([switch]$Simulation)

$src = "$env:USERPROFILE\Downloads"
$map = @{
  'Images'      = 'jpg','jpeg','png','gif','webp'
  'Documents'   = 'pdf','docx','doc','xlsx','pptx','txt','csv'
  'Archives'    = 'zip','rar','7z'
  'Installeurs' = 'exe','msi'
  'Code'        = 'py','ps1','sh','json','js'
}

foreach ($dossier in $map.Keys) {
  foreach ($ext in $map[$dossier]) {
    Get-ChildItem $src -File -Filter "*.$ext" | ForEach-Object {
      $dest = Join-Path $src $dossier
      New-Item $dest -ItemType Directory -Force -WhatIf:$Simulation | Out-Null
          Move-Item $_.FullName $dest -WhatIf:$Simulation -ErrorAction SilentlyContinue
    }
  }
}