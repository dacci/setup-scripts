$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

function Get-Releases([string] $Repo) {
  (Invoke-RestMethod https://api.github.com/repos/$Repo/releases) | Where-Object prerelease -EQ $False
}

$Assets = (Get-Releases PowerShell/PowerShell)[0].assets
$Package = ($Assets | Where-Object name -Like *.msixbundle)[0]
Add-AppxPackage $Package.browser_download_url
