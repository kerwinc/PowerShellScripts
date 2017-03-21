Import-module WebAdministration

#Set the script location to the repo's root -SourceApplicationDirectoryPath
$scriptLocation = (Get-Item -LiteralPath (Split-Path -Parent $MyInvocation.MyCommand.Path)).Parent.FullName
Set-Location -LiteralPath $scriptLocation

Import-Module ".\src\XmlTransform.Extensions.psm1" -Force

$ErrorActionPreference = "Stop"

# Invoke-XmlTransform -XmlFilePath "C:\Backup\Web.config" -XdtFilePath "C:\Backup\Web.Release.config" -DestinationPath "C:\Backup\Web.Error.config" -TransformDllDirectory "$scriptLocation\lib"  -Verbose
# Invoke-XmlTransform -XmlFilePath "C:\Backup\Web.config" -XdtFilePath "C:\Backup\Web.Release.config" -TransformDllDirectory "$scriptLocation\lib" -Verbose