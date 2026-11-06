param(
    [ValidateSet("Boss", "Campanha", "Guardian")][string]$Cenario = "Boss",
    [ValidatePattern('^[a-zA-Z0-9_-]{1,64}$')][string]$Perfil = "",
    [string]$Godot = "C:\Users\ovohe\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe",
    [switch]$Headless,
    [int]$QuitAfter = 0
)
$ErrorActionPreference = "Stop"
if (-not (Test-Path -LiteralPath $Godot -PathType Leaf)) { throw "Godot não encontrada: $Godot" }
$project = Split-Path -Parent $PSScriptRoot
if (-not $Perfil) { $Perfil = [guid]::NewGuid().ToString("N") }
$profile = Join-Path $project ".godot\playtest-m5g\$Perfil"
New-Item -ItemType Directory -Force -Path $profile | Out-Null
$scene = if ($Cenario -eq "Boss") { "res://scenes/dev/m5g_boss_playtest.tscn" } elseif ($Cenario -eq "Guardian") { "res://scenes/main.tscn" } else { "res://scenes/abbey/abbey_chapter.tscn" }
Write-Host "Perfil isolado: $Perfil"
Write-Host "Dados: $profile"
Write-Host "Para retomar: acrescente -Perfil $Perfil ao mesmo comando."
$arguments = @("--path", $project)
if ($Headless) { $arguments += "--headless" }
if ($QuitAfter -gt 0) { $arguments += @("--quit-after", "$QuitAfter") }
$arguments += $scene
$previousAppData = $env:APPDATA
$previousIsolation = $env:CINZAS_M5G_ISOLATED
try {
    $env:APPDATA = $profile
    $env:CINZAS_M5G_ISOLATED = $profile
    & $Godot @arguments
    $result = $LASTEXITCODE
}
finally {
    $env:APPDATA = $previousAppData
    $env:CINZAS_M5G_ISOLATED = $previousIsolation
}
exit $result
