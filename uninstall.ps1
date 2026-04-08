$ErrorActionPreference = "Stop"

function Write-Success($Message) {
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Info($Message) {
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Warn($Message) {
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Render-Menu {
    param(
        [int]$StartRow,
        [string[]]$Options,
        [int]$Cursor,
        [bool[]]$Selected,
        [bool]$AllowMultiple
    )

    [Console]::SetCursorPosition(0, $StartRow)
    $width = [Console]::WindowWidth

    for ($i = 0; $i -lt $Options.Count; $i++) {
        $arrow = if ($i -eq $Cursor) { ">" } else { " " }
        if ($AllowMultiple) {
            $marker = if ($Selected[$i]) { "[x]" } else { "[ ]" }
            $line = "  $arrow $marker $($Options[$i])"
        } else {
            $line = "  $arrow ( ) $($Options[$i])"
        }
        $line = $line.PadRight($width - 1)
        if ($i -eq $Cursor) {
            Write-Host $line -ForegroundColor Cyan
        } else {
            Write-Host $line
        }
    }
}

function Read-MenuAction {
    $keyInfo = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    switch ($keyInfo.VirtualKeyCode) {
        38 { return "Up" }
        40 { return "Down" }
        32 { return "Toggle" }
        13 { return "Enter" }
        65 { return "All" }
        default {
            if ($keyInfo.Character -eq 'a' -or $keyInfo.Character -eq 'A') {
                return "All"
            }
            return "None"
        }
    }
}

function Select-OneFallback {
    param(
        [string]$Title,
        [string[]]$Options
    )

    Write-Host ""
    Write-Host $Title -ForegroundColor White
    for ($i = 0; $i -lt $Options.Count; $i++) {
        Write-Host ("  {0}. {1}" -f ($i + 1), $Options[$i])
    }

    while ($true) {
        $answer = Read-Host "Enter one number"
        $parsed = 0
        if ([int]::TryParse($answer, [ref]$parsed)) {
            $index = $parsed - 1
            if ($index -ge 0 -and $index -lt $Options.Count) {
                return $Options[$index]
            }
        }
        Write-Warn "Invalid selection. Try again."
    }
}

function Select-ManyFallback {
    param(
        [string]$Title,
        [string[]]$Options
    )

    Write-Host ""
    Write-Host $Title -ForegroundColor White
    for ($i = 0; $i -lt $Options.Count; $i++) {
        Write-Host ("  {0}. {1}" -f ($i + 1), $Options[$i])
    }
    Write-Host "  A. Select all"

    while ($true) {
        $answer = Read-Host "Enter one or more numbers separated by commas"
        if ([string]::IsNullOrWhiteSpace($answer)) {
            Write-Warn "No selection made. Try again."
            continue
        }

        if ($answer.Trim().ToUpper() -eq "A") {
            return $Options
        }

        $selected = New-Object System.Collections.Generic.List[string]
        $valid = $true
        foreach ($part in ($answer -split ",")) {
            $trimmed = $part.Trim()
            $parsed = 0
            if (-not [int]::TryParse($trimmed, [ref]$parsed)) {
                $valid = $false
                break
            }

            $index = $parsed - 1
            if ($index -ge 0 -and $index -lt $Options.Count) {
                $value = $Options[$index]
                if (-not $selected.Contains($value)) {
                    $selected.Add($value)
                }
            } else {
                $valid = $false
                break
            }
        }

        if ($valid -and $selected.Count -gt 0) {
            return $selected.ToArray()
        }

        Write-Warn "Invalid selection. Try again."
    }
}

function Select-Many {
    param(
        [string]$Title,
        [string[]]$Options
    )

    try {
        $cursor   = 0
        $selected = New-Object bool[] $Options.Count
        [Console]::CursorVisible = $false
        Write-Host "  $Title" -ForegroundColor White
        Write-Host "  ↑↓ navigate   space select/deselect   enter confirm" -ForegroundColor DarkGray
        $startRow = [Console]::CursorTop
        Render-Menu -StartRow $startRow -Options $Options -Cursor $cursor -Selected $selected -AllowMultiple $true

        while ($true) {
            $action = Read-MenuAction
            switch ($action) {
                "Up"     { if ($cursor -gt 0)                    { $cursor-- } }
                "Down"   { if ($cursor -lt ($Options.Count - 1)) { $cursor++ } }
                "Toggle" { $selected[$cursor] = -not $selected[$cursor] }
                "All"    { for ($i = 0; $i -lt $selected.Length; $i++) { $selected[$i] = $true } }
                "Enter"  {
                    $result = @(for ($i = 0; $i -lt $Options.Count; $i++) { if ($selected[$i]) { $Options[$i] } })
                    if ($result.Count -gt 0) {
                        [Console]::CursorVisible = $true
                        Write-Host ""
                        return $result
                    }
                }
            }
            Render-Menu -StartRow $startRow -Options $Options -Cursor $cursor -Selected $selected -AllowMultiple $true
        }
    } catch {
        [Console]::CursorVisible = $true
        return Select-ManyFallback -Title $Title -Options $Options
    }
}

function Select-One {
    param(
        [string]$Title,
        [string[]]$Options
    )

    try {
        $cursor   = 0
        $selected = New-Object bool[] $Options.Count
        [Console]::CursorVisible = $false
        Write-Host "  $Title" -ForegroundColor White
        Write-Host "  ↑↓ navigate   enter select" -ForegroundColor DarkGray
        $startRow = [Console]::CursorTop
        Render-Menu -StartRow $startRow -Options $Options -Cursor $cursor -Selected $selected -AllowMultiple $false

        while ($true) {
            $action = Read-MenuAction
            switch ($action) {
                "Up"   { if ($cursor -gt 0)                    { $cursor-- } }
                "Down" { if ($cursor -lt ($Options.Count - 1)) { $cursor++ } }
                "Enter" {
                    [Console]::CursorVisible = $true
                    Write-Host ""
                    return $Options[$cursor]
                }
            }
            Render-Menu -StartRow $startRow -Options $Options -Cursor $cursor -Selected $selected -AllowMultiple $false
        }
    } catch {
        [Console]::CursorVisible = $true
        return Select-OneFallback -Title $Title -Options $Options
    }
}

function Get-InstalledSkills {
    param(
        [string[]]$Roots
    )

    $skills = New-Object System.Collections.Generic.List[string]
    foreach ($root in $Roots) {
        if (-not (Test-Path $root)) {
            continue
        }

        Get-ChildItem -Path $root -Directory | Sort-Object Name | ForEach-Object {
            if (-not $skills.Contains($_.Name)) {
                $skills.Add($_.Name)
            }
        }
    }

    return $skills.ToArray()
}

$selectedTools = @(Select-Many -Title "Select AI tool(s) to uninstall from:" -Options @(
    "Claude Code",
    "Codex (OpenAI)"
))

if ($selectedTools.Count -eq 0) {
    Write-Warn "No tool selected. Uninstall cancelled."
    exit 0
}

$removeClaude = $selectedTools -contains "Claude Code"
$removeCodex  = $selectedTools -contains "Codex (OpenAI)"

$scopeChoice = Select-One -Title "Select uninstall scope:" -Options @(
    "Global — remove from ~/.claude/skills/ or ~/.codex/skills/",
    "Project — remove from .claude/skills/ or .codex/skills/ in the current project"
)

if ($scopeChoice -like "Global*") {
    $claudeDir = Join-Path $HOME ".claude\skills"
    $codexDir = Join-Path $HOME ".codex\skills"
    $scopeLabel = "global"
} else {
    $projectRoot = (Get-Location).Path
    $claudeDir = Join-Path $projectRoot ".claude\skills"
    $codexDir = Join-Path $projectRoot ".codex\skills"
    $scopeLabel = "project ($projectRoot)"
}

$roots = @()
if ($removeClaude) { $roots += $claudeDir }
if ($removeCodex)  { $roots += $codexDir  }

Write-Info "Scanning installed skills..."
$availableSkills = @(Get-InstalledSkills -Roots $roots)
if (-not $availableSkills -or $availableSkills.Count -eq 0) {
    Write-Warn "No installed skills found for the selected tool and scope."
    exit 0
}

$selectedSkills = @(Select-Many -Title "Select skills to uninstall:" -Options $availableSkills)
if (-not $selectedSkills -or $selectedSkills.Count -eq 0) {
    Write-Warn "No skill selected. Uninstall cancelled."
    exit 0
}

$confirm = Select-One -Title "Confirm removal:" -Options @(
    "Yes - remove the selected skill folders",
    "No - cancel"
)

if ($confirm -notlike "Yes*") {
    Write-Warn "Uninstall cancelled."
    exit 0
}

Write-Host ""
Write-Info "Removing $($selectedSkills.Count) skill(s) [scope: $scopeLabel]..."

foreach ($skill in $selectedSkills) {
    Write-Host ""
    Write-Host "  $skill" -ForegroundColor White

    if ($removeClaude) {
        $target = Join-Path $claudeDir $skill
        if (Test-Path $target) {
            Remove-Item -Recurse -Force $target
            Write-Success $target
        } else {
            Write-Info "Not installed: $target"
        }
    }

    if ($removeCodex) {
        $target = Join-Path $codexDir $skill
        if (Test-Path $target) {
            Remove-Item -Recurse -Force $target
            Write-Success $target
        } else {
            Write-Info "Not installed: $target"
        }
    }
}

Write-Host ""
Write-Host "Uninstall complete!" -ForegroundColor Green
Write-Host ""
