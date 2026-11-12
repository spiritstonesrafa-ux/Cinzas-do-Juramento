param(
    [ValidateSet('cemiterio','abadia','floresta')]
    [string]$Fase = 'cemiterio',
    [switch]$Verificar,
    [switch]$VerificarGrafico
)
$oldAppData = $env:APPDATA
$oldRoot = $env:SAVE_SAFETY_ISOLATED_ROOT
$oldPhase = $env:ENEMY_AI_PLAYTEST_PHASE
$oldSmoke = $env:ENEMY_AI_PLAYTEST_SMOKE
try {
    $testProfile = Join-Path ([System.IO.Path]::GetTempPath()) ('cinzas-enemy-ai-playtest-' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $testProfile -ErrorAction Stop | Out-Null
    $env:APPDATA = $testProfile
    $env:SAVE_SAFETY_ISOLATED_ROOT = $testProfile.Replace('\','/')
    $env:ENEMY_AI_PLAYTEST_PHASE = $Fase
    $env:ENEMY_AI_PLAYTEST_SMOKE = if ($Verificar -or $VerificarGrafico) { '1' } else { '0' }
    $godot = 'C:\Users\ovohe\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
    $arguments = @('--path', $PSScriptRoot, '--script', 'res://tests/playtest_enemy_ai_01.gd')
    if ($Verificar) { $arguments = @('--headless', '--fixed-fps', '60') + $arguments }
    & $godot @arguments
    if ($LASTEXITCODE -ne 0) { throw "Godot encerrou com código $LASTEXITCODE." }
} finally {
    $env:APPDATA = $oldAppData
    $env:SAVE_SAFETY_ISOLATED_ROOT = $oldRoot
    $env:ENEMY_AI_PLAYTEST_PHASE = $oldPhase
    $env:ENEMY_AI_PLAYTEST_SMOKE = $oldSmoke
}
