$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

function Get-Releases([string] $Repo) {
  (Invoke-RestMethod https://api.github.com/repos/$Repo/releases) | Where-Object prerelease -EQ $False
}

switch ($Env:PROCESSOR_ARCHITECTURE) {
  AMD64 { New-Variable Arch x64 -Option Constant }
  default { New-Variable Arch $Env:PROCESSOR_ARCHITECTURE.ToLower() -Option Constant }
}

# Install Microsoft.VCLibs.14.00
Add-AppxPackage "https://aka.ms/Microsoft.VCLibs.$Arch.14.00.Desktop.appx"

# Install Microsoft.UI.Xaml.2.7
$Releases = Get-Releases microsoft/microsoft-ui-xaml | Where-Object tag_name -Like v2.7.* | Where-Object assets -NE $null
$Asset = $Releases[0].assets | Where-Object name -Like *.$Arch.appx
Add-AppxPackage $Asset.browser_download_url

# Install Windows Package Manager
$Assets = (Get-Releases microsoft/winget-cli)[0].assets

$Package = ($Assets | Where-Object name -Like *.msixbundle)[0]
$PackagePath = Join-Path $Env:TEMP $Package.name
Invoke-WebRequest $Package.browser_download_url -OutFile $PackagePath

$License = ($Assets | Where-Object name -Like *_License1.xml)[0]
$LicensePath = Join-Path $Env:TEMP $License.name
Invoke-WebRequest $License.browser_download_url -OutFile $LicensePath

Add-AppxProvisionedPackage -Online -PackagePath $PackagePath -LicensePath $LicensePath
