Import-module WebAdministration
Import-Module ".\WebAdministrationExtensions.psm1" -Force

# Get-SiteAppPool -SiteName "demo\demo\demo"

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
# Publish-WebSite -SiteName "MyFancySite" -SourceApplicationDirectoryPath "C:\ReleaseInProgress" -Verbose

# Write-Host "Deploying to Demo..." -ForegroundColor Green
# Backup-WebSite -SiteName "Default Web Site\demo" -BackupDirectory "c:\backup" -Verbose
# Publish-WebSite -SiteName "Default Web Site\demo" -SourceApplicationDirectoryPath "C:\ReleaseInProgress" -Verbose

# Write-Host "Deploying to Demo2..." -ForegroundColor Green
# Backup-WebSite -SiteName "Default Web Site\demo2" -BackupDirectory "c:\backup" -Verbose
# Publish-WebSite -SiteName "Default Web Site\demo2" -SourceApplicationDirectoryPath "C:\ReleaseInProgress" -Verbose:$false

# New-WebSiteOrWebApplication -SiteName "MyFancySite" -Port 8081 -PhysicalPath "$env:systemdrive\inetpub\wwwroot\MyFancySite" -ApplicationPool "MyFancySite" -Force $true -Verbose
# Backup-WebSite -SiteName "MyFancySite" -BackupDirectory "c:\backup" -Verbose 
# Publish-WebSite -SiteName "MyFancySite" -SourceApplicationDirectoryPath "C:\ReleaseInProgress\Web" -Verbose

#New-WebSiteOrWebApplication -SiteName "MyFancySite\Help" -PhysicalPath "$env:systemdrive\inetpub\wwwroot\MyFancySite-Help" -ApplicationPool "MyFancySite.Help" -Force $true -Verbose

#ExtractZipFile -Zipfilename "C:\Backup\MyFancySite_18-03-17_225919.zip" -Destination "C:\Backup\MyFancySite_18-03-17_225919"
#Restore-WebSite -SiteName "MyFancySite" -BackupZipFile "C:\Backup\MyFancySite_18-03-17_230739.zip" -Verbose