$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

function Get-Releases([string] $Repo) {
  (Invoke-RestMethod https://api.github.com/repos/$Repo/releases) | Where-Object prerelease -EQ $False
}

switch ($Env:PROCESSOR_ARCHITECTURE) {
  AMD64 { New-Variable Arch x64 -Option Constant }
  default { New-Variable Arch $Env:PROCESSOR_ARCHITECTURE.ToLower() -Option Constant }
}

# Find Microsoft.UI.Xaml.2.8 asset
$Releases = Get-Releases microsoft/microsoft-ui-xaml | Where-Object tag_name -Like v2.8.*
$XamlAsset = $Releases[0].assets | Where-Object name -Like *.$Arch.appx

# Find Windows Terminal asset
$Releases = Get-Releases microsoft/terminal
$TerminalAsset = $Releases[0].assets | Where-Object name -Like *.msixbundle

Add-AppxPackage -Path $TerminalAsset.browser_download_url -DependencyPath $XamlAsset.browser_download_url
