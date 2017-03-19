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

function ZipFiles($zipfilename, $sourcedir ) {
  Add-Type -Assembly System.IO.Compression.FileSystem
  $compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
  [System.IO.Compression.ZipFile]::CreateFromDirectory($sourcedir, $zipfilename, $compressionLevel, $false)
}

function ExtractZipFile($Zipfilename, $Destination ) {
  Add-Type -Assembly System.IO.Compression.FileSystem
  $compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
  [System.IO.Compression.ZipFile]::ExtractToDirectory($Zipfilename, $Destination)
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
    Remove-Item $Path -Recurse -Force
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
      # $items = Get-ChildItem -Path $Path -Recurse -Force
      # foreach ($item in $items) {
      #   Write-Verbose "Removing $($item.FullName)"
      # }
      Remove-Item -Path "$Path\*" -Recurse -WhatIf
      Remove-Item -Path "$Path\*" -Recurse -Force
    }
    else {
      throw "Directry Path is invalid: $path"
      exit
    }
  }
}
