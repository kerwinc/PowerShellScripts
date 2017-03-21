Import-module WebAdministration

#Set the script location to the repo's root -SourceApplicationDirectoryPath
$scriptLocation = (Get-Item -LiteralPath (Split-Path -Parent $MyInvocation.MyCommand.Path)).Parent.FullName
Set-Location -LiteralPath $scriptLocation

Import-Module ".\src\File.Extentions.psm1" -Force

$ErrorActionPreference="Stop"

# Copy-DirectoryContents -Source "C:\Temp" -Destination "C:\Backup\temp" -Verbose -Force -WhatIf
# ExtractZipFile -Zipfilename "C:\Backup\MyFancySite_18-03-17_225919.zip" -Destination "C:\Backup\MyFancySite_18-03-17_225919"
# Restore-WebSite -SiteName "MyFancySite" -BackupZipFile "C:\Backup\MyFancySite_20-03-17_181053.zip" -Verbose