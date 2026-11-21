<#
.SYNOPSIS
  Publishes a new Bolo APK and tells every installed copy to update.

.DESCRIPTION
  1. Bumps the version in app/pubspec.yaml (1.0.3+4 -> 1.0.4+5), unless -NoBump.
  2. Runs the tests, then builds a signed release APK.
  3. Commits the version bump, tags it (v1.0.4) and pushes to GitHub.
  4. Creates a GitHub Release with the APK attached as "bolo.apk".
     The permanent share link always points at the newest one:
     https://github.com/Ashfaq1306/bolo/releases/latest/download/bolo.apk
  5. Only after the upload worked: updates Firebase Remote Config
     (latest_build_code etc.), so installed apps show "Update available".

  Requirements: Flutter, the GitHub CLI (gh) logged in, the Firebase CLI logged
  in, and app/android/key.properties pointing at the release keystore.

.EXAMPLE
  ./scripts/release.ps1 -NotesEn "Faster voice input" -NotesBn "দ্রুত ভয়েস ইনপুট"

.EXAMPLE
  ./scripts/release.ps1 -Mandatory -NotesEn "Security fix"   # old builds must update
#>
param(
  [string]$NotesEn = "",
  [string]$NotesBn = "",
  [switch]$Mandatory,
  [switch]$NoBump,
  [switch]$SkipTests,
  # Where pub/Gradle caches go. Useful if the default cache drive is full.
  [string]$CacheDir = ""
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$app = Join-Path $root "app"
$pubspec = Join-Path $app "pubspec.yaml"
$template = Join-Path $root "remoteconfig.template.json"
$repo = "Ashfaq1306/bolo"

function Invoke-Step([string]$what, [scriptblock]$cmd) {
  Write-Host "==> $what" -ForegroundColor Cyan
  # Judge native tools by exit code only: Windows PowerShell 5.1 would
  # otherwise abort on harmless warnings they print to stderr.
  $saved = $ErrorActionPreference
  $ErrorActionPreference = "Continue"
  try { & $cmd 2>&1 | ForEach-Object { "$_" } } finally { $ErrorActionPreference = $saved }
  if ($LASTEXITCODE -ne 0) { throw "$what failed (exit $LASTEXITCODE)" }
}

if ($CacheDir) {
  $env:PUB_CACHE = Join-Path $CacheDir "pub"
  $env:GRADLE_USER_HOME = Join-Path $CacheDir "gradle"
  $env:ANDROID_USER_HOME = Join-Path $CacheDir "android-user"
}
if (-not (Test-Path (Join-Path $app "android/key.properties"))) {
  throw "app/android/key.properties is missing: updates must be signed with the release key (see F:\bolo-signing\README.txt)."
}
if (git -C $root status --porcelain) { throw "Commit or stash your changes first; a release must match a commit." }

# ---- 1. version ----
$text = [IO.File]::ReadAllText($pubspec)
if ($text -notmatch '(?m)^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)') { throw "Couldn't read version from pubspec.yaml" }
$major = [int]$Matches[1]; $minor = [int]$Matches[2]; $patch = [int]$Matches[3]; $build = [int]$Matches[4]
if (-not $NoBump) {
  $patch++; $build++
  $text = $text -replace '(?m)^version:.*$', "version: $major.$minor.$patch+$build"
  [IO.File]::WriteAllText($pubspec, $text)  # UTF-8 without BOM
}
$name = "$major.$minor.$patch"
$tag = "v$name"
Write-Host "Releasing Bolo $name (build $build)" -ForegroundColor Green

# ---- 2. test + build ----
Push-Location $app
try {
  if (-not $SkipTests) { Invoke-Step "Tests" { flutter test } }
  Invoke-Step "Build APK" { flutter build apk --release --obfuscate --split-debug-info=build/symbols/$name }
} finally { Pop-Location }

$dist = Join-Path $root "dist"
New-Item -ItemType Directory -Force $dist | Out-Null
$apk = Join-Path $dist "bolo.apk"
Copy-Item (Join-Path $app "build/app/outputs/flutter-apk/app-release.apk") $apk -Force
$sha = (Get-FileHash $apk -Algorithm SHA256).Hash.ToLower()

# ---- 3. commit + tag ----
if (-not $NoBump) {
  Invoke-Step "Commit version" { git -C $root commit -am "Release $name (build $build)" }
}
Invoke-Step "Tag" { git -C $root tag -a $tag -m "Bolo $name" }
Invoke-Step "Push" { git -C $root push origin HEAD --follow-tags }

# ---- 4. GitHub Release ----
$notes = @"
## বলো Bolo $name

$NotesBn

$NotesEn

**Install:** download ``bolo.apk`` below on your Android phone, open it, and tap Install
(allow "Install unknown apps" for your browser if Android asks).
Already installed? Just open Bolo: it will offer the update itself.

SHA-256: ``$sha``
"@
$notesFile = Join-Path $env:TEMP "bolo-release-notes.md"
[IO.File]::WriteAllText($notesFile, $notes)
Invoke-Step "GitHub Release" { gh release create $tag "$apk#bolo.apk (Android)" --repo $repo --title "Bolo $name" --notes-file $notesFile --latest }

# ---- 5. tell installed apps ----
$rc = Get-Content $template -Raw | ConvertFrom-Json
$rc.parameters.latest_build_code.defaultValue.value = "$build"
$rc.parameters.latest_version_name.defaultValue.value = $name
$rc.parameters.update_notes_en.defaultValue.value = $NotesEn
$rc.parameters.update_notes_bn.defaultValue.value = $NotesBn
if ($Mandatory) { $rc.parameters.min_build_code.defaultValue.value = "$build" }
[IO.File]::WriteAllText($template, ($rc | ConvertTo-Json -Depth 10))
Invoke-Step "Remote Config" { firebase deploy --only remoteconfig --project bolo-bd --cwd $root }
Invoke-Step "Commit Remote Config" { git -C $root commit -m "Remote Config: latest build $build" -- $template }
Invoke-Step "Push" { git -C $root push origin HEAD }

Write-Host ""
Write-Host "Done. Share this link (always the newest version):" -ForegroundColor Green
Write-Host "  https://github.com/$repo/releases/latest/download/bolo.apk"
