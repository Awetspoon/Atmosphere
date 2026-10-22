# Read-only project sanity check, compatible with Windows PowerShell 5.1.
# Checks the original Atmosphere tree, pinned source and documentation-only
# development stage; does NOT build, install or modify anything.

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$git = 'C:\Program Files\Git\cmd\git.exe'
if (-not (Test-Path -LiteralPath $git)) {
    $discovered = Get-Command git -ErrorAction SilentlyContinue
    if (-not $discovered) { throw 'Git executable not available.' }
    $git = $discovered.Source
}

function Assert-Condition([bool]$condition, [string]$description) {
    if (-not $condition) {
        throw ('VERIFY FAIL: ' + $description)
    }
    Write-Output ('OK: ' + $description)
}

$expectedCommit = '6b0c077b4c608a3a2ee712b8dc35fee87ceb62e8'
$branch = (& $git -C $repo branch --show-current).Trim()
Assert-Condition ($branch -eq 'development/usb-storage-feasibility') 'correct development branch'

$baseCommit = (& $git -C $repo rev-parse '1.12.1^{}').Trim()
Assert-Condition ($baseCommit -eq $expectedCommit) 'Atmosphere 1.12.1 tag pinned to expected commit'

$head = (& $git -C $repo rev-parse HEAD).Trim()
& $git -C $repo merge-base --is-ancestor $expectedCommit $head
Assert-Condition ($LASTEXITCODE -eq 0) 'working commit descends from reviewed Atmosphere 1.12.1'

$upstream = (& $git -C $repo remote get-url upstream).Trim()
Assert-Condition ($upstream -eq 'https://github.com/Atmosphere-NX/Atmosphere.git') 'official fetch upstream retained'

$origin = (& $git -C $repo remote get-url origin).Trim()
Assert-Condition ($origin -eq 'https://github.com/Awetspoon/Atmosphere.git') 'owner GitHub fork set as origin'

$shallow = (& $git -C $repo rev-parse --is-shallow-repository).Trim()
Assert-Condition ($shallow -eq 'false') 'complete history available for future merges'

$essentialFiles = @(
    'Makefile',
    'atmosphere.mk',
    'LICENSE',
    'libraries\libstratosphere\include\stratosphere\fs\fs_game_card.hpp',
    'libraries\libstratosphere\source\fs\fs_game_card.cpp',
    'libraries\libstratosphere\source\fs\fs_remote_file_system_proxy.hpp',
    'libraries\libstratosphere\source\fssrv\fssrv_file_system_proxy_impl.cpp',
    'stratosphere\ams_mitm\source\fs_mitm\fsmitm_module.cpp',
    'stratosphere\sm\source\impl\sm_service_manager.cpp',
    'stratosphere\pm\source\impl\pm_spec.cpp',
    'fusee\program\source\fusee_setup_horizon.cpp',
    'emummc\README.md',
    'PROJECT_START_HERE.md',
    'AGENTS.md',
    'docs\usb-gamecard\SOURCE_MAP.md',
    'docs\usb-gamecard\INTERFACE_BOUNDARIES.md',
    'docs\usb-gamecard\IMPLEMENTATION_GATES.md',
    'docs\usb-gamecard\GITHUB_FORK_SETUP.md',
    'docs\usb-gamecard\DECISION_LOG.md'
)
$missing = @($essentialFiles | Where-Object { -not (Test-Path -LiteralPath (Join-Path $repo $_)) })
Assert-Condition ($missing.Count -eq 0) ('essential modules / mapping docs exist' + $(if ($missing.Count) { ': ' + ($missing -join ', ') } else { '' }))

# This initial phase is documentation-only. Verify that commits since the
# pinned source did not silently alter original implementation/build files.
$changed = @(& $git -C $repo diff --name-only $expectedCommit HEAD)
$unexpected = @($changed | Where-Object {
    ($_ -ne '') -and
    ($_ -ne 'AGENTS.md') -and
    ($_ -ne 'PROJECT_START_HERE.md') -and
    (-not $_.StartsWith('docs/usb-gamecard/')) -and
    (-not $_.StartsWith('tools/verify_fork.ps1'))
})
Assert-Condition ($unexpected.Count -eq 0) ('no original Atmosphere code or build files changed' + $(if ($unexpected.Count) { ': ' + ($unexpected -join ', ') } else { '' }))

& $git -C $repo diff --check
Assert-Condition ($LASTEXITCODE -eq 0) 'working source diff whitespace check'

Write-Output ''
Write-Output 'VERIFIED: local Atmosphere USB feasibility fork is intact.'
Write-Output ('Branch: ' + $branch)
Write-Output ('Base revision: ' + $expectedCommit)
Write-Output ('Current commit: ' + $head)
Write-Output 'No Switch device, SD card, firmware, USB stick or game content was accessed.'
