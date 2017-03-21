Import-module WebAdministration

Get-Module -Name
Import-Module ".\File.Extentions.psm1" -Force

$ErrorActionPreference="Stop"

# $ErrorActionPreference = "Stop"

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
# Publish-WebSite -SiteName "MyFancySite" -SourceApplicationDirectoryPath "C:\Temp\web" -Verbose

# Write-Host "Deploying to Demo..." -ForegroundColor Green
# Backup-WebSite -SiteName "Default Web Site\demo" -BackupDirectory "c:\" -Verbose
# Backup-WebSite -SiteName "Default Web Site\demo" -BackupDirectory "c:\backup" -Verbose
# Publish-WebSite -SiteName "Default Web Site\demo" -SourceApplicationDirectoryPath "C:\Temp\WeBuild" -Verbose

# Write-Host "Deploying to Demo..." -ForegroundColor Green
# Backup-WebSite -SiteName "DontExist" -BackupDirectory "c:\backup" -Verbose
# Publish-WebSite -SiteName "DontExist" -SourceApplicationDirectoryPath "C:\Temp\WeBuild" -Verbose

# New-WebSiteOrWebApplication -SiteName "MyFancySite" -Port 8081 -PhysicalPath "$env:systemdrive\inetpub\wwwroot\MyFancySite" -ApplicationPool "MyFancySite" -Force $true -Verbose
# Backup-WebSite -SiteName "MyFancySite" -BackupDirectory "c:\backup" -Verbose 
# Publish-WebSite -SiteName "MyFancySite" -SourceApplicationDirectoryPath "C:\Temp\WeBuild" -Verbose

# New-IISWebSite -SiteName "MyFancySite2" -Port 8082 -ApplicationPool "MyFancySite2Pool" -PhysicalPath "C:\inetpub\wwwroot\Demo3" -Force -Verbose
# Restore-WebSite -SiteName "MyFancySite2" -BackupZipFile "C:\Backup\demo_19-03-17_203447.zip" -Verbose

# New-WebSiteOrWebApplication -SiteName "Default Web Site\Demo3" -PhysicalPath "C:\inetpub\wwwroot\Demo3" -Verbose

# ExtractZipFile -Zipfilename "C:\Backup\MyFancySite_18-03-17_225919.zip" -Destination "C:\Backup\MyFancySite_18-03-17_225919"
# Restore-WebSite -SiteName "MyFancySite" -BackupZipFile "C:\Backup\MyFancySite_20-03-17_181053.zip" -Verbose

# Test-SiteExists -Name "MyFancySite"
# Test-SiteExists -Name "Default Web Site\demo"

# Stop-WebApplicationPool -AppPoolName "MyFancySite" -Verbose
# Start-WebApplicationPool -AppPoolName "MyFancySite" -Verbose

# Set-SitePhysicalPath -SiteName "MyFancySite2" -NewPhysicalPath "C:\inetpub\wwwroot\MyFancySite"

#  Invoke-XmlTransform -XmlFilePath "C:\Backup\Web.config" -XdtFilePath "C:\Backup\Web.Release.config" -DestinationPath "C:\Backup\Web.Error.config" -Verbose
# Invoke-XmlTransform -XmlFilePath "C:\Backup\Web.config" -XdtFilePath "C:\Backup\Web.Release.config" -Verbose