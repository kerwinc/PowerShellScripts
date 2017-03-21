$ErrorActionPreference = "Stop"

function Copy-DirectoryContents {
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {-not(Test-Path -Path $_ -PathType Container)})]
    [Parameter(Mandatory = $true)][string]$Source,
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {-not(Test-Path -Path $_ -PathType Container)})]
    [Parameter(Mandatory = $true)][string]$Destination,
    [Parameter()][switch]$Force = $false,
    [Parameter()][switch]$WhatIf = $false
  )
  Process {
    Get-ChildItem -LiteralPath $Source | Copy-Item -Destination $Destination -Recurse -Force $Force -WhatIf $WhatIf
  }
}

function Test-DirectoryPath {
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $true)][string]$Path
  )
  Process {
    if ($Path -eq $null) {
      return $false
    }
    if ([System.String]::IsNullOrEmpty($Path) -or [System.String]::IsNullOrWhiteSpace($Path)) {
      return $false
    }
    if (-not(Test-Path -Path $Path -PathType Container)) {
      return $false
    }
    if ($Path.StartsWith("\") -or $path.StartsWith("*")) {
      return $false
    }
    return $true
  }
}

function Test-FilePath {
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $true)][string]$Path
  )
  Process {
    if ($Path -eq $null) {
      return $false
    }
    if ([System.String]::IsNullOrEmpty($Path) -or [System.String]::IsNullOrWhiteSpace($Path)) {
      return $false
    }
    if (-not(Test-Path -LiteralPath $Path -PathType Leaf)) {
      return $false
    }
    if ($Path.StartsWith("\") -or $path.StartsWith("*")) {
      return $false
    }
    return $true
  }
}

function ZipFiles {
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {(Test-Path -Path $_ -PathType Container)})]
    [Parameter(Mandatory = $true)][string]$SourceDirectory,
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $true)][string]$Zipfilename
  )
  Process {
    Add-Type -Assembly System.IO.Compression.FileSystem
    $compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal

    Write-Verbose "Creating archive from $SourceDirectory to $Zipfilename"
    [System.IO.Compression.ZipFile]::CreateFromDirectory($SourceDirectory, $Zipfilename, $compressionLevel, $false)
  }
}

function ExtractZipFile {
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {(Test-Path -Path $_ -PathType Leaf)})]
    [Parameter(Mandatory = $true)][string]$Zipfilename,
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {(Test-Path -Path $_ -PathType Container)})]
    [Parameter(Mandatory = $true)][string]$Destination
  )
  Process {
    Write-Verbose "Adding Assembly Type"
    Add-Type -Assembly System.IO.Compression.FileSystem
    $compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal

    Write-Verbose "Extracting $Zipfilename to $Destination"
    [System.IO.Compression.ZipFile]::ExtractToDirectory($Zipfilename, $Destination)
  }
}

function New-Directory {
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {-not(Test-Path -Path $_ -PathType Container)})]
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter()][switch]$Force = $false
  )
  Process {
    if (Test-DirectoryPath -Path $Path) {
      throw "Directory ($path) already exists"
    }
    New-Item -ItemType Directory -Path $Path -Force
  }
}

function Remove-Directory {
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {Test-Path -Path $_ -PathType Container})]
    [Parameter(Mandatory = $true)][string]$Path
  )
  Process {
    Write-Verbose "Removing Directory: $path"
    Remove-Item -LiteralPath $Path -Recurse -Force
  }
}

function Remove-DirectoryContents {
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {Test-Path -Path $_ -PathType Container})]
    [Parameter(Mandatory = $true)][string]$Path
  )
  Process {
    if ((Test-DirectoryPath -Path $Path)) {
      Get-ChildItem -LiteralPath $Path | Remove-Item -Recurse -Force -WhatIf
      Get-ChildItem -LiteralPath $Path | Remove-Item -Recurse -Force
    }
    else {
      throw "Directry Path is invalid: $path"
      exit
    }
  }
}

Export-ModuleMember -Function Test-DirectoryPath,
Test-FilePath,
ZipFiles,
ExtractZipFile,
New-Directory,
Remove-Directory,
Remove-DirectoryContents