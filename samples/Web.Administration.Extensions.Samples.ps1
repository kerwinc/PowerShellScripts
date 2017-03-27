Import-module WebAdministration

#Set the script location to the repo's root -SourceApplicationDirectoryPath
$scriptLocation = (Get-Item -LiteralPath (Split-Path -Parent $MyInvocation.MyCommand.Path)).Parent.FullName
Set-Location -LiteralPath $scriptLocation

Import-Module ".\src\File.Extentions.psm1" -Force
Import-Module ".\src\Web.Administration.Extensions.psm1" -Force

$ErrorActionPreference = "Stop"

# Write-Host "Default Web Site:" -ForegroundColor Green
# Get-SiteAppPool -SiteName "Default Web Site"

# Write-Host "Demo Site:" -ForegroundColor Green
# Get-SiteAppPool -SiteName "Default Web Site\demo"

# Write-Host "MyFancySite:" -ForegroundColor Green
# Get-SiteAppPool -SiteName "MyFancySite"

# Write-Host "MyFancySite Physical Path:" -ForegroundColor Green
# Get-SitePhysicalPath -SiteName "MyFancySite"

# Write-Host "Deploying to MyFancySite..." -ForegroundColor Green
# Backup-WebSite -SiteName "MyFancySite" -BackupDirectory "c:\backup" -Verbose
Publish-WebSite -SiteName "MyFancySite" -SourceApplicationDirectoryPath "C:\Temp\web" -Verbose

# Write-Host "Deploying to Demo..." -ForegroundColor Green
# Backup-WebSite -SiteName "Default Web Site\demo" -BackupDirectory "c:\" -Verbose
# Backup-WebSite -SiteName "Default Web Site\demo" -BackupDirectory "c:\backup" -Verbose
# Publish-WebSite -SiteName "Default Web Site\FancyFancy" -SourceApplicationDirectoryPath "C:\Temp\WeBuild" -Verbose

# Write-Host "Deploying to Demo..." -ForegroundColor Green
# Backup-WebSite -SiteName "DontExist" -BackupDirectory "c:\backup" -Verbose
# Publish-WebSite -SiteName "DontExist" -SourceApplicationDirectoryPath "C:\Temp\WeBuild" -Verbose

# New-WebSiteOrWebApplication -SiteName "MyFancySite" -Port 8081 -PhysicalPath "$env:systemdrive\inetpub\wwwroot\MyFancySite" -ApplicationPool "MyFancySite" -Force $true -Verbose
# Backup-WebSite -SiteName "MyFancySite" -BackupDirectory "c:\backup" -Verbose
# Publish-WebSite -SiteName "MyFancySite" -SourceApplicationDirectoryPath "C:\Temp\WeBuild" -Verbose

# New-IISWebSite -SiteName "MyFancySite4" -Port 8083 -ApplicationPool "MyFancySite4" -PhysicalPath "C:\inetpub\wwwroot\Demo4" -Force -Verbose
# Restore-WebSite -SiteName "MyFancySite2" -BackupZipFile "C:\Backup\MyFancySite_21-03-17_142229.zip" -Verbose

# ExtractZipFile -Zipfilename "C:\Backup\MyFancySite_18-03-17_225919.zip" -Destination "C:\Backup\MyFancySite_18-03-17_225919"
# Restore-WebSite -SiteName "MyFancySite" -BackupZipFile "C:\Backup\MyFancySite_20-03-17_181053.zip" -Verbose

# Test-SiteExists -Name "MyFancySite"
# Test-SiteExists -Name "Default Web Site\demo"

# Stop-WebApplicationPool -AppPoolName "MyFancySite" -Verbose
# Start-WebApplicationPool -AppPoolName "MyFancySite" -Verbose

# Set-SitePhysicalPath -SiteName "MyFancySite2" -NewPhysicalPath "C:\inetpub\wwwroot\MyFancySite"
# Get-WebSitesUsingPhysicalPath -PhysicalPath "C:\inetpub\wwwroot\MyFancySite"
# Get-WebApplicationsUsingPhysicalPath -PhysicalPath "C:\inetpub\wwwroot\MyFancySite"
# (Get-WebSitesUsingPhysicalPath -PhysicalPath "C:\inetpub\wwwroot\MyFancySite" | Where-Object { $_.Name -ne "MyFancySite"}).Count