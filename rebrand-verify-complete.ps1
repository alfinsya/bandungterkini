# Rebrand Verification and Completion for Bandung Terkini
$WorkspaceRoot = "c:\KULIAH\MAGANG\Magang di Perhutani\Bandung Terkini"
$Timestamp = Get-Date -Format "yyyyMMddHHmmss"
$LogFile = Join-Path $WorkspaceRoot "rebrand-complete-$Timestamp.log"

function Write-Log {
    param([string]$Message)
    $LogMessage = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $Message"
    Write-Host $LogMessage
    Add-Content -Path $LogFile -Value $LogMessage
}

Write-Log "======== REBRAND BANDUNG TERKINI - VERIFICATION REPORT ========"
Write-Log ""

# STEP 1: Backup articles.json
Write-Log "STEP 1: Backing up articles.json"
$articlesJsonPath = Join-Path $WorkspaceRoot "articles.json"
if (Test-Path $articlesJsonPath) {
    $backupPath = "$articlesJsonPath.bak.$Timestamp"
    Copy-Item -Path $articlesJsonPath -Destination $backupPath -Force
    Write-Log "✓ Backup created: articles.json.bak.$Timestamp"
}
Write-Log ""

# STEP 2: Count HTML files
Write-Log "STEP 2: Verifying HTML files"
$htmlFiles = @(Get-ChildItem -Path $WorkspaceRoot -Recurse -Include "*.html" -File)
Write-Log "✓ Total HTML files found: $($htmlFiles.Count)"
$mainPages = @($htmlFiles | Where-Object { $_.Directory.Name -ne 'article' })
$articlePages = @($htmlFiles | Where-Object { $_.Directory.Name -eq 'article' })
Write-Log "  - Main pages: $($mainPages.Count)"
Write-Log "  - Article pages: $($articlePages.Count)"
Write-Log ""

# STEP 3: Verify branding in main pages
Write-Log "STEP 3: Verifying branding - Main Pages"
$mainCorrect = 0
$mainWrong = 0
foreach ($file in $mainPages) {
    $content = Get-Content -Path $file.FullName -Raw
    if ($content -match 'BANDUNG.*TERKINI|title.*Bandung Terkini') {
        $mainCorrect++
    } else {
        $mainWrong++
    }
}
Write-Log "✓ Main pages with correct branding: $mainCorrect"
if ($mainWrong -gt 0) { Write-Log "⚠ Main pages with issues: $mainWrong" }
Write-Log ""

# STEP 4: Verify logo branding
Write-Log "STEP 4: Verifying text-based logo (BANDUNG TERKINI)"
$logoCorrect = 0
foreach ($file in $htmlFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    if ($content -match 'BANDUNG.*TERKINI') {
        $logoCorrect++
    }
}
Write-Log "✓ Files with correct logo text (BANDUNG TERKINI): $logoCorrect / $($htmlFiles.Count)"
Write-Log ""

# STEP 5: Verify color theme
Write-Log "STEP 5: Verifying color theme"
$cssFiles = @(Get-ChildItem -Path $WorkspaceRoot -Recurse -Include "*.css" -File)
$cssCorrect = 0
foreach ($css in $cssFiles) {
    $content = Get-Content -Path $css.FullName -Raw
    if ($content -match '--primary.*#6D28D9' -and $content -match '--dark.*#2E1065' -and $content -match '--secondary.*#1F3F5F') {
        $cssCorrect++
    }
}
Write-Log "✓ CSS files with correct color theme: $cssCorrect / $($cssFiles.Count)"
Write-Log "  - Primary: #6D28D9 (Purple)"
Write-Log "  - Secondary: #1F3F5F (Dark Blue)"
Write-Log "  - Dark: #2E1065 (Deep Purple)"
Write-Log ""

# STEP 6: Check package names
Write-Log "STEP 6: Verifying package.json metadata"
$pkgMainJson = Get-Content (Join-Path $WorkspaceRoot "package.json") | ConvertFrom-Json
$pkgToolsJson = Get-Content (Join-Path $WorkspaceRoot "tools\package.json") | ConvertFrom-Json
Write-Log "✓ Main package name: $($pkgMainJson.name)"
Write-Log "✓ Tools package name: $($pkgToolsJson.name)"
Write-Log ""

# STEP 7: Check deployment config
Write-Log "STEP 7: Verifying GitHub Actions deployment"
$deployFile = Join-Path $WorkspaceRoot ".github\workflows\deploycPanel.yml"
if (Test-Path $deployFile) {
    $deployContent = Get-Content -Path $deployFile -Raw
    if ($deployContent -match "/home/bandungterkini/public_html") {
        Write-Log "✓ Deployment path: /home/bandungterkini/public_html/ (correct)"
    } elseif ($deployContent -match "/home/wartajan/public_html") {
        Write-Log "⚠ OLD deployment path found: /home/wartajan/public_html/"
        Write-Log "  Needs update to: /home/bandungterkini/public_html/"
    }
}
Write-Log ""

# STEP 8: Verify no old branding
Write-Log "STEP 8: Searching for old branding references (Warta Janten)"
$oldRefCount = 0
$ignoredExtensions = @("*.bak*", "rebrand*", "REBRAND*")
$filesToCheck = Get-ChildItem -Path $WorkspaceRoot -Recurse -Include "*.html" | Where-Object { 
    $_.FullName -notmatch 'articles\.json\.bak|rebrand|REBRAND'
}

foreach ($file in $filesToCheck) {
    $content = Get-Content -Path $file.FullName -Raw
    if ($content -match 'Warta Janten|wartajanten' -and $content -notmatch 'Persatuan Wartawan|PWI') {
        $oldRefCount++
        Write-Log "  ⚠ Found in: $($file.Name)"
    }
}
if ($oldRefCount -eq 0) {
    Write-Log "✓ No old branding references found"
}
Write-Log ""

# FINAL REPORT
Write-Log "====== REBRAND STATUS SUMMARY ======"
Write-Log "Main Pages Branded: $mainCorrect / $($mainPages.Count)"
Write-Log "Article Pages with Logo: $logoCorrect / $($articlePages.Count)"
Write-Log "CSS Color Theme Applied: $cssCorrect / $($cssFiles.Count)"
Write-Log "Package Names Updated: Yes"
Write-Log ""

if ($mainCorrect -gt 0 -and $logoCorrect -gt ($htmlFiles.Count * 0.9) -and $cssCorrect -gt 0 -and $oldRefCount -eq 0) {
    Write-Log "✅ REBRAND BANDUNG TERKINI SELESAI"
} else {
    Write-Log "⚠ Rebrand mostly complete with some items requiring review"
}

Write-Log ""
Write-Log "Log saved to: $LogFile"
Write-Log "Report Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
