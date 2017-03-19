Import-module WebAdministration
Import-Module ".\PowerShellScripts\IIS-Configuration-Utils.psm1" -Force

# Get-SiteAppPool -SiteName "demo\demo\demo"

# Write-Host "Default Web Site:" -ForegroundColor Green
# Get-SiteAppPool -SiteName "Default Web Site"

# Write-Host "Demo Site:" -ForegroundColor Green
# Get-SiteAppPool -SiteName "Default Web Site\demo"

# Write-Host "ProjeXion:" -ForegroundColor Green
# Get-SiteAppPool -SiteName "ProjeXion"

# Write-Host "ProjeXion Physical Path:" -ForegroundColor Green
# Get-SitePhysicalPath -SiteName "ProjeXion"

# Write-Host "Deploying to ProjeXion..." -ForegroundColor Green
# Backup-WebSite -SiteName "ProjeXion" -BackupDirectory "c:\backup" -Verbose
# Publish-WebSite -SiteName "ProjeXion" -SourceApplicationDirectoryPath "C:\ReleaseInProgress" -Verbose

# Write-Host "Deploying to Demo..." -ForegroundColor Green
# Backup-WebSite -SiteName "Default Web Site\demo" -BackupDirectory "c:\backup" -Verbose
# Publish-WebSite -SiteName "Default Web Site\demo" -SourceApplicationDirectoryPath "C:\ReleaseInProgress" -Verbose

# Write-Host "Deploying to Demo2..." -ForegroundColor Green
# Backup-WebSite -SiteName "Default Web Site\demo2" -BackupDirectory "c:\backup" -Verbose
# Publish-WebSite -SiteName "Default Web Site\demo2" -SourceApplicationDirectoryPath "C:\ReleaseInProgress" -Verbose:$false

# New-WebSiteOrWebApplication -SiteName "ProjeXion" -Port 8081 -PhysicalPath "$env:systemdrive\inetpub\wwwroot\ProjeXion" -ApplicationPool "ProjeXion" -Force $true -Verbose
# Backup-WebSite -SiteName "ProjeXion" -BackupDirectory "c:\backup" -Verbose 
# Publish-WebSite -SiteName "ProjeXion" -SourceApplicationDirectoryPath "C:\ReleaseInProgress\Web" -Verbose

#New-WebSiteOrWebApplication -SiteName "ProjeXion\Help" -PhysicalPath "$env:systemdrive\inetpub\wwwroot\ProjeXion-Help" -ApplicationPool "ProjeXion.Help" -Force $true -Verbose

#ExtractZipFile -Zipfilename "C:\Backup\ProjeXion_18-03-17_225919.zip" -Destination "C:\Backup\ProjeXion_18-03-17_225919"

Restore-WebSite -SiteName "ProjeXion" -BackupZipFile "C:\Backup\demo2_18-03-17_212136.zip" -Verbose
Restore-WebSite -SiteName "ProjeXion" -BackupZipFile "C:\Backup\ProjeXion_18-03-17_230739.zip" -Verbose