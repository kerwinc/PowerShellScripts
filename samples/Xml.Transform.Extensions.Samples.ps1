#Set the script location to the repo's root
$scriptLocation = (Get-Item -LiteralPath (Split-Path -Parent $MyInvocation.MyCommand.Path)).Parent.FullName
Set-Location -LiteralPath $scriptLocation

Import-Module ".\src\XmlTransform.Extensions.psm1" -Force
Import-Module ".\src\XmlTransform.Assertions.psm1" -Force

$ErrorActionPreference = "Stop"

$transformDllPath = "$scriptLocation\lib"
Invoke-XmlTransform -XmlFilePath "C:\Backup\Web.config" -XdtFilePath "C:\Backup\Web.Release.config" -TransformDllDirectory $transformDllPath -Verbose

# #Test a bunch of transforms at once
# $config = "C:\Backup\Web.config"
# $transformFiles = Get-ChildItem -Path "C:\Backup\*.config" -Exclude "web.config"
# foreach ($xdtFile in $transformFiles ) {
#   Add-TransformAssertItem -Config $config -Transform ($xdtFile.FullName)
# }
# Assert-Items -ShowOutput -ErrorIfAnyInvalid -Verbose