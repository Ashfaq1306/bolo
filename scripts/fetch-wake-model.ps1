<#
.SYNOPSIS
  Downloads the offline Vosk model used for the "Bolo" wake word into the
  Android assets (not committed to git because it's ~40 MB).

  Source: https://alphacephei.com/vosk/models (Apache 2.0 licence).
  The SHA-256 is checked so a changed or corrupted download is rejected.
#>
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$target = Join-Path $root "app/android/app/src/main/assets/vosk-model-en"
if (Test-Path (Join-Path $target "am/final.mdl")) { Write-Host "Wake word model already present."; exit 0 }

$name = "vosk-model-small-en-us-0.15"
$url = "https://alphacephei.com/vosk/models/$name.zip"
$expected = "30f26242c4eb449f948e42cb302dd7a686cb29a3423a8367f99ff41780942498"
$zip = Join-Path $env:TEMP "$name.zip"
Write-Host "Downloading $url ..."
Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing
$hash = (Get-FileHash $zip -Algorithm SHA256).Hash.ToLower()
if ($hash -ne $expected) { throw "Checksum mismatch for $name.zip ($hash)" }

$tmp = Join-Path $env:TEMP "bolo-vosk"
if (Test-Path $tmp) { Remove-Item -Recurse -Force $tmp }
Expand-Archive $zip -DestinationPath $tmp
New-Item -ItemType Directory -Force (Split-Path $target) | Out-Null
if (Test-Path $target) { Remove-Item -Recurse -Force $target }
Move-Item (Join-Path $tmp $name) $target
Remove-Item (Join-Path $target "README") -ErrorAction SilentlyContinue
Write-Host "Wake word model ready at $target"
