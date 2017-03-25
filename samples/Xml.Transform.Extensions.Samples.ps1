#Set the script location to the repo's root
$scriptLocation = (Get-Item -LiteralPath (Split-Path -Parent $MyInvocation.MyCommand.Path)).Parent.FullName
Set-Location -LiteralPath $scriptLocation

Import-Module ".\src\XmlTransform.Extensions.psm1" -Force

$ErrorActionPreference = "Stop"

# Invoke-XmlTransform -XmlFilePath "C:\Backup\Web.config" -XdtFilePath "C:\Backup\Web.Release.config" -TransformDllDirectory "$scriptLocation\lib" -Verbose

#Test a bunch of transforms at once
$config = "C:\Backup\Web.config"
$transformFiles = Get-ChildItem -Path "C:\Backup\*.config" -Exclude "web.config"
foreach ($xdtFile in $transformFiles ) {
  Write-Host "Transforming $config with $($xdtFile.Name):"
  $xdtFilePath = 
  Invoke-XmlTransform -XmlFilePath "C:\Backup\Web.config" -XdtFilePath "$($xdtFile.FullName)" -DestinationPath "C:\Backup\output\$($xdtFile.Name)" -TransformDllDirectory "$scriptLocation\lib"
}