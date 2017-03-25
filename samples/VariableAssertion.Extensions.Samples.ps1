Import-module WebAdministration

#Set the script location to the repo's root
$scriptLocation = (Get-Item -LiteralPath (Split-Path -Parent $MyInvocation.MyCommand.Path)).Parent.FullName
Set-Location -LiteralPath $scriptLocation

Import-Module ".\src\File.Extentions.psm1" -Force
Import-Module ".\src\Web.Administration.Extensions.psm1" -Force
Import-Module ".\src\VariableAssertion.Extensions.psm1" -Force

$ErrorActionPreference = "Stop"

Add-AssertItem -Name "physicalPath" -Value "C:\inetpub\wwwroot\Demo" -Type "Folder"
Add-AssertItem -Name "applicationPool" -Value "DefaultAppPool" -Type "Application Pool"
Add-AssertItem -Name "siteName" -Value "Default Web Site\Demo3" -Type "WebSite"
Add-AssertItem -Name "CustomPath" -Value "C:\inetpub\wwwroot\Demo3\index.html1" -Type "File" -Verbose
$output = Assert-Items
Show-AssertResult -ErrorIfAnyInvalid