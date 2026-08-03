param(
    [Parameter(Position = 0)]
    [ValidateSet('help', 'setup', 'import', 'validate', 'test', 'test-unit', 'test-integration', 'test-simulation', 'run', 'export-windows', 'export-linux')]
    [string]$Command = 'help'
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot

function Find-Godot {
    if ($env:GODOT_BIN -and (Test-Path -LiteralPath $env:GODOT_BIN)) { return $env:GODOT_BIN }
    $fromPath = Get-Command godot, godot4 -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($fromPath) { return $fromPath.Source }
    $candidates = @(
        'C:\Program Files\Godot\Godot.exe',
        "$env:LOCALAPPDATA\Programs\Godot\Godot.exe"
    )
    foreach ($candidate in $candidates) { if (Test-Path -LiteralPath $candidate) { return $candidate } }
    $download = Get-ChildItem -Path "$env:USERPROFILE\Downloads" -Filter 'Godot_v*-stable_win64*.exe' -File -ErrorAction SilentlyContinue |
        Sort-Object Name -Descending | Select-Object -First 1
    if ($download) { return $download.FullName }
    throw 'Godot 4.x was not found. Set GODOT_BIN to the editor executable.'
}

function Invoke-Godot([string[]]$Arguments) {
    $godot = Find-Godot
    $localAppData = Join-Path $ProjectRoot '.godot-user\local'
    $roamingAppData = Join-Path $ProjectRoot '.godot-user\roaming'
    New-Item -ItemType Directory -Force $localAppData, $roamingAppData | Out-Null
    $previousLocalAppData = $env:LOCALAPPDATA
    $previousAppData = $env:APPDATA
    try {
        $env:LOCALAPPDATA = $localAppData
        $env:APPDATA = $roamingAppData
        $process = Start-Process -FilePath $godot -ArgumentList $Arguments -Wait -PassThru -NoNewWindow
        if ($process.ExitCode -ne 0) { throw "Godot exited with code $($process.ExitCode)" }
    }
    finally {
        $env:LOCALAPPDATA = $previousLocalAppData
        $env:APPDATA = $previousAppData
    }
}

function Invoke-Tests([string]$Suite) {
    Invoke-Godot @('--headless', '--path', $ProjectRoot, '--script', 'res://game/tests/run_tests.gd', '--', "--suite=$Suite")
}

switch ($Command) {
    'help' {
        @'
Shardbound Isles developer commands
  setup             Verify the local Godot dependency and import the project
  import            Import and parse the project headlessly
  validate          Import, then run all automated tests
  test              Run all automated tests
  test-unit         Run pure rule tests
  test-integration  Run scene interaction tests
  test-simulation   Run the fixed-seed gameplay smoke scenario
  run               Launch the debug game at 1280x800
  export-windows    Export a Windows x86_64 debug build
  export-linux      Export a Linux x86_64 debug build
'@ | Write-Output
    }
    'setup' { Write-Output "Godot: $(Find-Godot)"; Invoke-Godot @('--headless', '--editor', '--path', $ProjectRoot, '--quit') }
    'import' { Invoke-Godot @('--headless', '--editor', '--path', $ProjectRoot, '--quit') }
    'validate' { Invoke-Godot @('--headless', '--editor', '--path', $ProjectRoot, '--quit'); Invoke-Tests 'all' }
    'test' { Invoke-Tests 'all' }
    'test-unit' { Invoke-Tests 'unit' }
    'test-integration' { Invoke-Tests 'integration' }
    'test-simulation' { Invoke-Tests 'simulation' }
    'run' { Invoke-Godot @('--path', $ProjectRoot, '--resolution', '1280x800') }
    'export-windows' { New-Item -ItemType Directory -Force "$ProjectRoot\build\windows" | Out-Null; Invoke-Godot @('--headless', '--path', $ProjectRoot, '--export-debug', 'Windows') }
    'export-linux' { New-Item -ItemType Directory -Force "$ProjectRoot\build\linux" | Out-Null; Invoke-Godot @('--headless', '--path', $ProjectRoot, '--export-debug', 'Linux') }
}
