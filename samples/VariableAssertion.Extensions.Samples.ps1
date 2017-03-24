Import-module WebAdministration

#Set the script location to the repo's root -SourceApplicationDirectoryPath
$scriptLocation = (Get-Item -LiteralPath (Split-Path -Parent $MyInvocation.MyCommand.Path)).Parent.FullName
Set-Location -LiteralPath $scriptLocation

Import-Module ".\src\File.Extentions.psm1" -Force
Import-Module ".\src\Web.Administration.Extensions.psm1" -Force
Import-Module ".\src\VariableAssertion.Extensions.psm1" -Force

$ErrorActionPreference = "Stop"

Add-AssertItem -Name "physicalPath" -Value "C:\inetpub\wwwroot\Demo" -Type "Folder"
Add-AssertItem -Name "applicationPool" -Value "DefaultAppPool" -Type "Application Pool"
Add-AssertItem -Name "siteName" -Value "Default Web Site\Demo3" -Type "WebSite"
Add-AssertItem -Name "CustomPath" -Value "C:\inetpub\wwwroot\Demo3\index.html" -Type "File" -Verbose

$output = (Assert-Items -ErrorIfAnyInvalid)
$output.Items | Format-Table

if ($output.ErrorItems.Count -gt 0) {
  Write-Host "Invalid Items:" -ForegroundColor Red
  Write-Host "----------------------------------------"
  $output.ErrorItems | Format-Table
  Throw "Some items did not pass validation. Process aborted."
}
else {
  Write-Host "All items passed validation" -ForegroundColor Green
}