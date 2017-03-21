Import-module WebAdministration

#Set the script location to the repo's root -SourceApplicationDirectoryPath
$scriptLocation = (Get-Item -LiteralPath (Split-Path -Parent $MyInvocation.MyCommand.Path)).Parent.FullName
Set-Location -LiteralPath $scriptLocation

Import-Module ".\src\File.Extentions.psm1" -Force

$ErrorActionPreference = "Stop"

Copy-Directory -Directory "C:\Temp" --Destination "C:\Backup" -WhatIf
# Copy-DirectoryContents -Source "C:\Temp" -Destination "C:\Backup\temp" -Verbose -Force -WhatIf
# ExtractZipFile -Zipfilename "C:\Backup\MyFancySite_18-03-17_225919.zip" -Destination "C:\Backup\MyFancySite_18-03-17_225919"
# New-Directory -Path "c:\Backup\Temp"
# Remove-Directory -Path "C:\Backup\Temp" -Verbose -WhatIf
# Remove-DirectoryContents -Path "C:\Backup\Temp" -Verbose -WhatIf
