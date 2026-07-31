<#
.SYNOPSIS
    Generates the ALZ architecture definition JSON for a given root_id.

.DESCRIPTION
    The architecture definition JSON cannot use Terraform variables â€” it is read at plan time
    as a static file. This script renders it once, before running terraform init.

    Run this script whenever you change root_id or management_groups_config.
    The generated file is committed to the repo.

    If optional MG flags are omitted, the script prompts interactively.
    Pass them explicitly to run non-interactively (e.g. in CI).

.PARAMETER RootId
    Management group prefix (e.g. "contoso"). Must match var.root_id in terraform.tfvars.

.PARAMETER IncludeIdentity
    Include the Identity MG (recommended). Omit to be prompted.

.PARAMETER IncludeDecommissioned
    Include a Decommissioned MG. Omit to be prompted.

.PARAMETER IncludeLocal
    Include a Local MG (Azure Local / HCI only). Omit to be prompted.

.PARAMETER IncludeSandboxes
    Include a Sandboxes MG (recommended). Omit to be prompted.

.PARAMETER IncludeSecurity
    Include a Security MG (recommended). Omit to be prompted.

.EXAMPLE
    # Interactive â€” prompts for each optional MG
    .\scripts\setup-lib.ps1 -RootId "contoso"

    # Non-interactive â€” CI/CD usage
    .\scripts\setup-lib.ps1 -RootId "contoso" -IncludeIdentity $true -IncludeDecommissioned $false -IncludeLocal $false -IncludeSandboxes $true -IncludeSecurity $true
#>
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[a-z][a-z0-9-]{1,30}[a-z0-9]$')]
    [string]$RootId,

    [nullable[bool]]$IncludeIdentity,
    [nullable[bool]]$IncludeDecommissioned,
    [nullable[bool]]$IncludeLocal,
    [nullable[bool]]$IncludeSandboxes,
    [nullable[bool]]$IncludeSecurity
)

function Read-YN {
    param([string]$Question)
    $answer = Read-Host "$Question [Y/n]"
    return ($answer -eq '' -or $answer -match '^[yY]')
}

# Prompt for any flag not passed explicitly
if ($null -eq $IncludeIdentity)       { $IncludeIdentity       = Read-YN "Include Identity MG?       (recommended for most orgs)"         }
if ($null -eq $IncludeDecommissioned) { $IncludeDecommissioned = Read-YN "Include Decommissioned MG?  (add when retiring subscriptions)"  }
if ($null -eq $IncludeLocal)          { $IncludeLocal          = Read-YN "Include Local MG?           (Azure Local / HCI workloads only)" }
if ($null -eq $IncludeSandboxes)      { $IncludeSandboxes      = Read-YN "Include Sandboxes MG?       (recommended for dev/test isolation)"}
if ($null -eq $IncludeSecurity)       { $IncludeSecurity       = Read-YN "Include Security MG?        (recommended for SOC/SIEM workloads)"}

$stageDir  = Split-Path -Parent $PSScriptRoot
$outputDir = Join-Path $stageDir "lib\architecture_definition"
$template  = Join-Path $outputDir "architecture.json.tpl"

# Parse the template — it contains all MGs; we filter out the ones not selected
$arch = (Get-Content $template -Raw) -replace '__ROOT_ID__', $RootId | ConvertFrom-Json

$optionalMgs = @{
    identity       = $IncludeIdentity
    decommissioned = $IncludeDecommissioned
    local          = $IncludeLocal
    sandboxes      = $IncludeSandboxes
    security       = $IncludeSecurity
}

$excludedIds = $optionalMgs.GetEnumerator() |
    Where-Object { -not $_.Value } |
    ForEach-Object { "$RootId-$($_.Key)" }

$arch.management_groups = $arch.management_groups | Where-Object { $_.id -notin $excludedIds }

$json       = $arch | ConvertTo-Json -Depth 5
$outputFile = Join-Path $outputDir "$RootId.alz_architecture_definition.json"

Get-ChildItem $outputDir -Filter "*.alz_architecture_definition.json" | Remove-Item -Force

Set-Content -Path $outputFile -Value $json -Encoding UTF8
Write-Host ""
Write-Host "Generated: $outputFile"
Write-Host ""
Write-Host "Copy the following block into your terraform.tfvars:"
Write-Host ""
Write-Host "  root_id = `"$RootId`""
Write-Host "  management_groups_config = {"
Write-Host "    include_identity       = $($IncludeIdentity.ToString().ToLower())"
Write-Host "    include_decommissioned = $($IncludeDecommissioned.ToString().ToLower())"
Write-Host "    include_local          = $($IncludeLocal.ToString().ToLower())"
Write-Host "    include_sandboxes      = $($IncludeSandboxes.ToString().ToLower())"
Write-Host "    include_security       = $($IncludeSecurity.ToString().ToLower())"
Write-Host "  }"
