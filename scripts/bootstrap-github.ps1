# ACBF-inator: one-time/re-runnable GitHub bootstrap using the official gh CLI
# Windows PowerShell 5.1+ / PowerShell 7+
# Prerequisites: gh installed; gh auth login; gh auth refresh -s project
# Run: powershell -ExecutionPolicy Bypass -File .\scripts\bootstrap-github.ps1
# Or:  pwsh -File ./scripts/bootstrap-github.ps1
# No tokens are handled by this script; gh uses the user's own authenticated session.

$ErrorActionPreference = "Stop"
$repo = "francescodifilippo/ACBF-inator"
$owner = "francescodifilippo"
$projectTitle = "ACBF-inator - Development"

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "GitHub CLI (gh) is missing. Install from https://cli.github.com/ then run gh auth login."
}
& gh auth status
if ($LASTEXITCODE -ne 0) {
    throw "Authenticate first: gh auth login"
}

Write-Host "1/5 - Setting repository description and topics"
$description = "Open-source comic OCR and ACBF authoring toolkit for multilingual text layers, accessibility, and reusable translations."
$topics = "acbf,comics,manga,ocr,comic-translation,accessibility,multilingual,cbz,text-to-speech,open-source"
& gh repo edit $repo --description $description --add-topic $topics --enable-projects
if ($LASTEXITCODE -ne 0) { throw "Could not update repository metadata" }

$milestoneSpecs = @(
    @{ Title="M0 - Specification & benchmark baseline"; Description="ACBF schema, rights-cleared corpus, licensing, security and CI baseline"; Issues=@(1,2,13,15) },
    @{ Title="M1 - ACBF Core"; Description="ACBF read/write validation and CBZ/CBR/image import round trips"; Issues=@(3,4) },
    @{ Title="M2 - OCR & page understanding"; Description="Balloon/panel detection, reading order, OCR model benchmarks and Jev review"; Issues=@(5,6,7) },
    @{ Title="M3 - Multilingual & authentication"; Description="Language layers and optional locally authorized SIWC desktop integration"; Issues=@(8,9) },
    @{ Title="M4 - Desktop beta"; Description="Batch CLI and UI, review/edit workflow, safe packaging"; Issues=@(10) },
    @{ Title="M5 - Integrations"; Description="Self-hosted ACBF publication/adapters and derived Mihon reader"; Issues=@(11,12) }
)

Write-Host "2/5 - Creating missing release milestones"
$existingMilestones = @(& gh api "repos/$repo/milestones?state=all&per_page=100" | ConvertFrom-Json)
if ($LASTEXITCODE -ne 0) { throw "Cannot list milestones" }
foreach ($spec in $milestoneSpecs) {
    $name = $spec.Title
    if (-not @($existingMilestones | Where-Object { $_.title -eq $name }).Count) {
        & gh api -X POST "repos/$repo/milestones" -f "title=$name" -f "description=$($spec.Description)" | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "Cannot create milestone $name" }
        Write-Host "  Created $name"
    } else {
        Write-Host "  Exists: $name"
    }
}

Write-Host "3/5 - Assigning milestones to existing issues"
foreach ($spec in $milestoneSpecs) {
    foreach ($issueNo in $spec.Issues) {
        & gh issue edit $issueNo -R $repo --milestone $spec.Title | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "Could not assign issue #$issueNo to $($spec.Title)" }
        Write-Host "  #$issueNo -> $($spec.Title)"
    }
}

Write-Host "4/5 - Locating or creating GitHub Project"
& gh project list --owner $owner --format json | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "Project permissions missing. Run: gh auth refresh -s project; then retry."
}
$existingProjects = & gh project list --owner $owner --format json | ConvertFrom-Json
$project = @($existingProjects.projects | Where-Object { $_.title -eq $projectTitle } | Select-Object -First 1)
if ($project.Count -eq 0) {
    $created = & gh project create --owner $owner --title $projectTitle --format json | ConvertFrom-Json
    if ($LASTEXITCODE -ne 0) { throw "Could not create project" }
    $projectNumber = [int]$created.number
    Write-Host "  Created project #$projectNumber"
} else {
    $projectNumber = [int]$project[0].number
    Write-Host "  Reusing project #$projectNumber"
}

# Linking may already exist on reruns.
& gh project link $projectNumber --owner $owner --repo "ACBF-inator" | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "  Project link may already exist; inspect it in the GitHub UI."
}

Write-Host "5/5 - Creating optional project fields and adding issue items"
$fieldResult = & gh project field-list $projectNumber --owner $owner --format json | ConvertFrom-Json
if ($LASTEXITCODE -ne 0) { throw "Could not list project fields" }
$fields = @($fieldResult.fields)
$fieldSpecs = @(
    @{ Name="Workflow"; Options="Backlog,Ready,In progress,Review,Done" },
    @{ Name="Priority"; Options="P0,P1,P2,P3" },
    @{ Name="Area"; Options="Core,OCR,Translation,Desktop,Server,Reader,Infrastructure" }
)
foreach ($field in $fieldSpecs) {
    if (-not @($fields | Where-Object { $_.name -eq $field.Name }).Count) {
        & gh project field-create $projectNumber --owner $owner --name $field.Name --data-type SINGLE_SELECT --single-select-options $field.Options | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "Could not create project field $($field.Name)" }
        Write-Host "  Field created: $($field.Name)"
    }
}

foreach ($n in (1..13) + @(15)) {
    $issueUrl = "https://github.com/$repo/issues/$n"
    & gh project item-add $projectNumber --owner $owner --url $issueUrl | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  Item #$n already present or could not be added; check the project."
    }
}

Write-Host ""
Write-Host "Completed. Review milestones at https://github.com/$repo/milestones"
Write-Host "Review your project at https://github.com/users/$owner/projects/$projectNumber"
Write-Host "Create Board/Roadmap views from GitHub Projects UI; gh CLI does not manage these views."
Write-Host "Review and merge documentation PR #14 separately when ready."
