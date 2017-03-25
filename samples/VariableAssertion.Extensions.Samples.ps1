Import-module WebAdministration

#Set the script location to the repo's root
$scriptLocation = (Get-Item -LiteralPath (Split-Path -Parent $MyInvocation.MyCommand.Path)).Parent.FullName
Set-Location -LiteralPath $scriptLocation

Import-Module ".\src\File.Extentions.psm1" -Force
Import-Module ".\src\Web.Administration.Extensions.psm1" -Force
Import-Module ".\src\Variable.Assertions.psm1" -Force

$ErrorActionPreference = "Stop"

Add-AssertItem -Name "physicalPath" -Value "C:\inetpub\wwwroot\Demo3\" -Type Folder -Verbose
Add-AssertItem -Name "applicationPool" -Value "DefaultAppPool" -Type "Application Pool" -ErrorPreference Warning -Verbose
Add-AssertItem -Name "siteName" -Value "Default Web Site\Demo3" -Type WebSite -Verbose
Add-AssertItem -Name "CustomPath" -Value "C:\inetpub\wwwroot\Demo3\index.html" -Type File -Verbose
Assert-Items -ShowOutput -ErrorIfAnyInvalid -Verbose

Clear-AssertItems -Verbose

Add-AssertItem -Name "backupdirectory" -Value "C:\Backup" -Type Folder -Verbose
Assert-Items -ShowOutput -ErrorIfAnyInvalid -Verbose