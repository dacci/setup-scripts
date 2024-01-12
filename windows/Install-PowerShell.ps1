$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

function Get-Releases([string] $Repo) {
  (Invoke-RestMethod https://api.github.com/repos/$Repo/releases) | Where-Object prerelease -EQ $False
}

$Releases = Get-Releases PowerShell/PowerShell | Where-Object { $_.assets | Where-Object name -Like *.msixbundle }
$Asset = $Releases[0].assets | Where-Object name -Like *.msixbundle
Add-AppxPackage $Asset.browser_download_url
