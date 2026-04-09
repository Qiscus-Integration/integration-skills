$ErrorActionPreference = "Stop"

$Owner   = "Qiscus-Integration"
$Repo    = "integration-skills"
$Branch  = "main"
$RawBase = "https://raw.githubusercontent.com/$Owner/$Repo/$Branch"
$ApiBase = "https://api.github.com/repos/$Owner/$Repo/contents/skills?ref=$Branch"

function Write-Success($Message) {
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Info($Message) {
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Warn($Message) {
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-ErrorMessage($Message) {
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Render-Menu {
    param(
        [string[]]$Options,
        [int]$Cursor,
        [bool[]]$Selected,
        [bool]$AllowMultiple,
        [switch]$First
    )

    if (-not $First) {
        # Move cursor up relative to current position — more reliable than
        # SetCursorPosition(0, $startRow) which breaks when terminal scrolls
        $n = $Options.Count
        [Console]::Write("`e[${n}A`e[0G")
    }

    $width = [Console]::WindowWidth
    if ($width -le 0) { $width = 80 }

    for ($i = 0; $i -lt $Options.Count; $i++) {
        $arrow  = if ($i -eq $Cursor) { ">" } else { " " }
        if ($AllowMultiple) {
            $marker = if ($Selected[$i]) { "[x]" } else { "[ ]" }
            $line = "  $arrow $marker $($Options[$i])"
        } else {
            $line = "  $arrow ( ) $($Options[$i])"
        }
        # Pad to window width to overwrite any previous longer line
        $line = $line.PadRight([Math]::Max(0, $width - 1))
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
        Render-Menu -Options $Options -Cursor $cursor -Selected $selected -AllowMultiple $true -First

        while ($true) {
            $action = Read-MenuAction
            switch ($action) {
                "Up"     { if ($cursor -gt 0)                   { $cursor-- } }
                "Down"   { if ($cursor -lt ($Options.Count - 1)){ $cursor++ } }
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
            Render-Menu -Options $Options -Cursor $cursor -Selected $selected -AllowMultiple $true
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
        Render-Menu -Options $Options -Cursor $cursor -Selected $selected -AllowMultiple $false -First

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
            Render-Menu -Options $Options -Cursor $cursor -Selected $selected -AllowMultiple $false
        }
    } catch {
        [Console]::CursorVisible = $true
        return Select-OneFallback -Title $Title -Options $Options
    }
}

function Get-SkillNames {
    param(
        [string]$ScriptRoot
    )

    $localSkillsPath = Join-Path $ScriptRoot "skills"
    if (Test-Path $localSkillsPath) {
        Write-Info "Using local skills."
        return Get-ChildItem -Path $localSkillsPath -Directory |
            Where-Object { $_.Name -ne "_template" } |
            Sort-Object Name |
            Select-Object -ExpandProperty Name
    }

    Write-Info "Fetching available skills from GitHub..."
    $response = Invoke-RestMethod -Uri $ApiBase
    return $response |
        Where-Object { $_.type -eq "dir" -and $_.name -ne "_template" } |
        Sort-Object name |
        Select-Object -ExpandProperty name
}

function Install-SkillFile {
    param(
        [string]$Skill,
        [string]$DestinationRoot,
        [string]$RelPath,
        [string]$ScriptRoot
    )

    $dest      = Join-Path $DestinationRoot "$Skill\$RelPath"
    $destDir   = Split-Path $dest -Parent
    if (-not (Test-Path $destDir)) { New-Item $destDir -ItemType Directory -Force | Out-Null }

    # Try local copy first
    $localPath = Join-Path $ScriptRoot "skills\$Skill\$RelPath"
    if (Test-Path $localPath) {
        Copy-Item $localPath $dest -Force
        return $true
    }

    # Fallback to remote download
    $url = "$RawBase/skills/$Skill/$($RelPath -replace '\\', '/')"
    try {
        Invoke-WebRequest -Uri $url -OutFile $dest -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
}

$ScriptRootPath = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }

$selectedTools = @(Select-Many -Title "Select AI tool(s) to install for:" -Options @(
    "Claude Code",
    "Codex (OpenAI)"
))

if ($selectedTools.Count -eq 0) {
    Write-Warn "No tool selected. Installation cancelled."
    exit 0
}

$installClaude = $selectedTools -contains "Claude Code"
$installCodex  = $selectedTools -contains "Codex (OpenAI)"

$scopeChoice = Select-One -Title "Select installation scope:" -Options @(
    "Global — available in all projects (~/.claude/skills/ or ~/.codex/skills/)",
    "Project — current project only (.claude/skills/ or .codex/skills/)"
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

$availableSkills = @(Get-SkillNames -ScriptRoot $ScriptRootPath)
if (-not $availableSkills -or $availableSkills.Count -eq 0) {
    Write-ErrorMessage "No skills found."
    exit 1
}

$selectedSkills = @(Select-Many -Title "Select skills to install:" -Options $availableSkills)
if (-not $selectedSkills -or $selectedSkills.Count -eq 0) {
    Write-Warn "No skill selected. Installation cancelled."
    exit 0
}

Write-Host ""
Write-Info "Installing $($selectedSkills.Count) skill(s) [scope: $scopeLabel]..."

foreach ($skill in $selectedSkills) {
    Write-Host ""
    Write-Host "  $skill" -ForegroundColor White

    if ($installClaude) {
        if (Install-SkillFile -Skill $skill -DestinationRoot $claudeDir -RelPath "SKILL.md" -ScriptRoot $ScriptRootPath) {
            Write-Success "Claude Code: $(Join-Path $claudeDir "$skill\SKILL.md")"
        } else {
            Write-ErrorMessage "Failed to download $skill/SKILL.md for Claude Code"
        }
        # agents/openai.yaml is optional — ignore failure
        Install-SkillFile -Skill $skill -DestinationRoot $claudeDir -RelPath "agents\openai.yaml" -ScriptRoot $ScriptRootPath | Out-Null
    }

    if ($installCodex) {
        if (Install-SkillFile -Skill $skill -DestinationRoot $codexDir -RelPath "SKILL.md" -ScriptRoot $ScriptRootPath) {
            Write-Success "Codex: $(Join-Path $codexDir "$skill\SKILL.md")"
        } else {
            Write-ErrorMessage "Failed to download $skill/SKILL.md for Codex"
        }
        Install-SkillFile -Skill $skill -DestinationRoot $codexDir -RelPath "agents\openai.yaml" -ScriptRoot $ScriptRootPath | Out-Null
    }
}

Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Green
Write-Host ""
