#Requires -Modules File.Extentions

$ErrorActionPreference = "Stop"

function Get-WebApplicationFromSiteName {
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {Test-SiteName $_})]
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)][string]$SiteName
  )
  Process {
    $siteNameArray = $SiteName.Split("\")
    $rootSiteName = $siteNameArray[0]
    $webAppName = $siteNameArray[1]
    
    $web = Get-WebApplication -Name $webAppName | Where-Object {($_.GetParentElement()["Name"]) -eq $rootSiteName }
    $web
  }
}

function Get-WebSiteName {
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {Test-SiteName $_})]
    [Parameter(Mandatory = $true)][string]$SitePath
  )
  Process {
    if ($SitePath.Contains("\")) {
      $siteNameArray = $SitePath.Split("\")
      $webAppName = $siteNameArray[1]
      return $webAppName
    }
    else {
      $site = Get-Website -Name $SitePath
      return $site.Name
    }
  }
}

function Get-SiteAppPool {
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {Test-SiteName $_})]
    [ValidateScript( {if (Test-SiteExists -Name $_) {$true} else {throw "Site does not exist: $_"}})]
    [Parameter(Mandatory = $true)][string]$SiteName
  )
  Process {
    if ($SiteName.Contains("\")) {
      $web = Get-WebApplicationFromSiteName -siteName $SiteName
      return $web.ApplicationPool
    }
    else {
      $site = Get-Website -Name $SiteName
      return $site.ApplicationPool
    }
  }
}

Export-ModuleMember -Function Get-SiteAppPool

function Get-SitePhysicalPath {
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {Test-SiteName $_})]
    [ValidateScript( {if (Test-SiteExists -Name $_) {$true} else {throw "Site does not exist: $_"}})]
    [Parameter(Mandatory = $true)][string]$SiteName
  )
  Process {
    if ($SiteName.Contains("\")) {
      $web = Get-WebApplicationFromSiteName -siteName $SiteName
      return $web.PhysicalPath
    }
    else {
      $site = Get-Website -Name $SiteName
      return $site.PhysicalPath
    }
  }
}

Export-ModuleMember -Function Get-SitePhysicalPath

function Test-AppPoolExists {
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $true)][string]$Name
  )
  Process {
    $siteAppPoolPath = "IIS:\AppPools\" + $Name
    return (Test-Path $siteAppPoolPath -pathType container)
  }
}

Export-ModuleMember -Function Test-AppPoolExists

function Test-SiteExists {
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $true)][string]$Name
  )
  Process {
    $sitePath = "IIS:\Sites\" + $Name
    return (Test-Path $sitePath -pathType container)
  }
}

Export-ModuleMember -Function Test-SiteExists

function Test-SiteName ([string]$siteName) {
  if ([System.String]::IsNullOrEmpty($siteName) -or [System.String]::IsNullOrWhiteSpace($siteName)) {
    throw "Site Name is required and cannot be empty"
  }

  #Validate that the site name does not go 2 or more levels deep
  if ($siteName.Split("\").Count -gt 2) {
    throw "Invalid site name. Nested IIS Web Applications should be limited to 1 level"
  }
  return $true
}

Export-ModuleMember -Function Test-SiteName

function Set-SitePhysicalPath {
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {Test-SiteName $_})]
    [ValidateScript( {if (Test-SiteExists -Name $_) {$true} else {throw "Site does not exist: $_"}})]
    [Parameter(Mandatory = $true)][string]$SiteName,
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $true)][string]$NewPhysicalPath
  )
  Process {
    #check if the site exists - This is happening twice but its OK for now
    $siteIISPath = "IIS:\Sites\" + $SiteName
    if (-not(Test-Path $siteIISPath -pathType container)) {
      throw "Site does not exist in IIS: $SiteName"
    }

    Write-Verbose "Setting property PhysicalPath on $siteName to $NewPhysicalPath"
    Set-ItemProperty $siteIISPath -name physicalPath -value $NewPhysicalPath

    Write-Host "Physical path for $SiteName changed to $NewPhysicalPath"  -foregroundcolor Green
  }
}

Export-ModuleMember -Function Set-SitePhysicalPath

function Stop-WebApplicationPool {
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {if (Test-AppPoolExists -Name $_) {$true} else {throw "Application Pool does not exist: $_"}})]
    [Parameter(Mandatory = $true)][string]$AppPoolName
  )
  Begin {
    $appPoolStatus = (Get-WebAppPoolState -Name $AppPoolName).Value
    if ($appPoolStatus -eq "Stopped") {
      Write-Verbose "Application Pool ($AppPoolName) is already stopped"
    }
  }
  Process {
    if ($appPoolStatus -ne "Stopped") {
      Stop-WebAppPool -Name $AppPoolName    
    }

    $waitCount = 10
    do {
      $appPoolStatus = (Get-WebAppPoolState -Name $AppPoolName).Value
      Write-Verbose "Waiting for application pool ($AppPoolName) to stop"
      Start-Sleep -Seconds 2
      $waitCount = $waitCount - 1
    }
    until ((Get-WebAppPoolState -Name $AppPoolName).Value -eq "Stopped" -or $waitCount -lt 1)
  }
  End {
    $appPoolStatus = (Get-WebAppPoolState -Name $AppPoolName).Value
    if ($appPoolStatus -eq "Stopped") {
      Write-Verbose "Application Pool ($AppPoolName) stopped successfully"
      return
    }
  }
}

Export-ModuleMember -Function Stop-WebApplicationPool

function Start-WebApplicationPool {
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {if (Test-AppPoolExists -Name $_) {$true} else {throw "Application Pool does not exist: $_"}})]
    [Parameter(Mandatory = $true)][string]$AppPoolName
  )
  Begin {
    $appPoolStatus = (Get-WebAppPoolState -Name $AppPoolName).Value
    if ($appPoolStatus -eq "Started") {
      Write-Verbose "Application Pool ($AppPoolName) is already stopped"
    }
  }
  Process {
    if ($appPoolStatus -ne "Started") {
      Start-WebAppPool -Name $AppPoolName    
    }

    $waitCount = 10
    do {
      $appPoolStatus = (Get-WebAppPoolState -Name $AppPoolName).Value
      Write-Verbose "Waiting for application pool ($AppPoolName) to start"
      Start-Sleep -Seconds 1
      $waitCount = $waitCount - 1
    }
    until ((Get-WebAppPoolState -Name $AppPoolName).Value -eq "Started" -or $waitCount -lt 1)
  }
  End {
    $appPoolStatus = (Get-WebAppPoolState -Name $AppPoolName).Value
    if ($appPoolStatus -eq "Started") {
      Write-Verbose "Application Pool ($AppPoolName) started successfully"
      return
    }
  }
}

Export-ModuleMember -Function Start-WebApplicationPool

function Publish-WebSite {
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {Test-SiteName $_})]
    [ValidateScript( {if (Test-SiteExists -Name $_) {$true} else {throw "Site does not exist: $_"}})]
    [Parameter(Mandatory = $true)][string]$SiteName,
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {Test-Path -Path $_})]
    [Parameter(Mandatory = $true)][string]$SourceApplicationDirectoryPath
  )
  Begin {
    Write-Verbose "Getting application pool for $siteName"
    $appPool = Get-SiteAppPool -SiteName $SiteName
    if ($appPool -eq $null -or !(Test-AppPoolExists -Name $appPool)) {
      Throw "Application Pool ($appName) cannot be null and does not exist"
    }

    Write-Verbose "Getting physical path for $siteName"
    $physicalPath = Get-SitePhysicalPath -SiteName $SiteName

    #Validate the Physical Path
    if ($physicalPath -eq $null) { throw "Physical Path for site ($siteName) cannot be null" }
    if (-not(Test-DirectoryPath -Path $physicalPath)) { throw "Invalid directory path: $physicalPath"}

    Write-Verbose "Stopping application pool ($appPool) for $siteName"
    Stop-WebApplicationPool -AppPoolName $appPool
  }
  Process {
    #Clean out the site's physical path
    Write-Verbose "Removing files from $physicalPath"
    Remove-DirectoryContents -Path $physicalPath -Verbose:$VerbosePreference

    #Copy Source files to WebSite's Physical Directory
    Write-Verbose "Copying files from $SourceApplicationDirectoryPath to $physicalPath"
    Get-ChildItem -LiteralPath $SourceApplicationDirectoryPath | Copy-Item -Destination $physicalPath -Recurse
  }
  End {
    Write-Verbose "Starting application pool ($appPool) for $siteName"
    Start-WebAppPool -Name $appPool
    if ((Get-WebAppPoolState -Name $appPool).Value -eq "Started") {
      Write-Host "$appPool for $SiteName started successfully!" -ForegroundColor Green
    }

    if ($Error.Count -eq 0) {
      Write-Host "Directory published to $SiteName successfully!" -ForegroundColor Green
    }
  }
}

Export-ModuleMember -Function Publish-WebSite

function Backup-WebSite {
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {Test-SiteName $_})]
    [ValidateScript( {if (Test-SiteExists -Name $_) {$true} else {throw "Site does not exist: $_"}})]
    [Parameter(Mandatory = $true)][string]$SiteName,
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {Test-Path -Path $_})]
    [Parameter(Mandatory = $true)][string]$BackupDirectory
  )
  Begin {
    Write-Verbose "Resolving site name $siteName"
    $site = Get-WebSiteName -SitePath $SiteName
    if ($site -eq $null) {throw "Could not resolve website or web application name for $siteName"}

    Write-Verbose "Getting physical path for $siteName"
    $physicalPath = Get-SitePhysicalPath -SiteName $SiteName

    #Validate the Physical Path
    if ($physicalPath -eq $null) { throw "Physical Path for site ($siteName) cannot be null" }
    if (-not(Test-DirectoryPath -Path $physicalPath)) { throw "Invalid directory path: $physicalPath"}
  }
  Process {
    #Check if there any files to Backup
    $itemCount = Get-ChildItem $physicalPath -Recurse | Measure-Object | % {$_.Count}
    if ($itemCount -eq 0) {
      Write-Warning "There are currently no items to backup in $physicalPath"
      return
    }
  
    Write-Verbose "Creating Zip archive"
    $zipFileName = $site + "_" + (Get-Date -Format "dd-MM-yy_HHmmss") + ".zip"
    $zipFileFullPath = "$BackupDirectory\$zipFileName"
    ZipFiles -SourceDirectory $physicalPath -Zipfilename $zipFileFullPath
  }
  End {
    if ($itemCount -eq 0) {return}

    if ((Test-Path -Path $zipFileFullPath) -and $Error.Count -eq 0) {
      Write-Host "Backup for $SiteName was created at $zipFileFullPath successfully!" -ForegroundColor Green
    }
  }
}

Export-ModuleMember -Function Backup-WebSite

function Restore-WebSite {
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {Test-SiteName $_})]
    [ValidateScript( {if (Test-SiteExists -Name $_) {$true} else {throw "Site does not exist: $_"}})]
    [Parameter(Mandatory = $true)][string]$SiteName,
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {Test-Path -Path $_})]
    [Parameter(Mandatory = $true)][string]$BackupZipFile
  )
  Begin {
    Write-Verbose "Getting application pool for $siteName"
    $appPool = Get-SiteAppPool -SiteName $SiteName
    if ($appPool -eq $null) { throw "Application Pool for site $siteName cannot be null"}
    if (!(Test-AppPoolExists -Name $appPool)) {throw "Application Pool for site $siteName does not exist"}

    Write-Verbose "Getting physical path for $siteName"
    $physicalPath = Get-SitePhysicalPath -SiteName $SiteName

    #Validate the Physical Path
    if ($physicalPath -eq $null) { throw "Physical Path for site ($siteName) cannot be null" }
    if (-not(Test-DirectoryPath -Path $physicalPath)) { throw "Invalid directory path: $physicalPath"}

    Write-Verbose "Stopping application pool ($appPool) for $siteName"
    Stop-WebApplicationPool -AppPoolName $appPool
  }
  Process {
    #Clean out the site's physical path
    Write-Verbose "Removing files from $physicalPath"
    Remove-DirectoryContents -Path $physicalPath

    #Extract the zip file to webSite's Physical Directory
    Write-Verbose "Extracting $BackupZipFile to $physicalPath"
    ExtractZipFile -Zipfilename $BackupZipFile -Destination $physicalPath
  }
  End {
    Start-WebApplicationPool -AppPoolName $appPool

    if ($Error.Count -eq 0) {
      Write-Host "$SiteName has been restored using $BackupZipFile successfully!" -ForegroundColor Green
    }
  }
}

Export-ModuleMember -Function Restore-WebSite

function New-IISWebSite {
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {if (-not(Test-SiteExists -Name $_)) {$true} else {throw "Site already exists: $_"}})]
    [Parameter(Mandatory = $true)][string]$SiteName,
    [ValidateNotNullOrEmpty()]
    [ValidateRange(80, 65535)]
    [Parameter(Mandatory = $true)][int]$Port,
    [ValidateNotNullOrEmpty()]
    [Parameter()][string]$HostHeader,
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $true)][string]$PhysicalPath,
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $true)][string]$ApplicationPool,
    [Parameter()][Switch]$Force = $false
  )
  Begin {
    if (-not(Test-DirectoryPath -Path $PhysicalPath) -and $Force) {
      if ($Force) {
        Write-Verbose "Creating physical path ($PhysicalPath)"
        New-Directory -Path $PhysicalPath -Force:$Force
      }
      else {
        throw "Physical Path ($PhysicalPath) does not exist. Provide -Force to let us create the directory for you"
      }

      #Todo: Add validation for sites using the same port with no host header / same host header
    }
  }
  Process {
    #Create the Application Pool If It Does Not Exist
    if (-not(Test-AppPoolExists -Name $ApplicationPool)) {
      if ($Force) {
        Write-Verbose "Creating application pool: $ApplicationPool"
        New-WebAppPool $ApplicationPool
      }
      else {
        throw "Application pool does not exist. Provide -Force to let us create the application pool for you"
      }
    }
    Write-Verbose "Creating website $siteName on port $Port"
    New-WebSite -Name $SiteName -Port $Port -HostHeader $HostHeader -PhysicalPath $PhysicalPath -ApplicationPool $ApplicationPool
  }
}

Export-ModuleMember -Function New-IISWebSite

function New-IISWebApplication {
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {if (-not(Test-SiteExists -Name $_)) {$true} else {throw "Site already exists: $_"}})]
    [Parameter(Mandatory = $true)][string]$SiteName,
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $true)][string]$PhysicalPath,
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $true)][string]$ApplicationPool,
    [Parameter()][Switch]$Force = $false
  )
  Begin {
    if (-not(Test-DirectoryPath -Path $PhysicalPath) -and $Force) {
      if ($Force) {
        Write-Verbose "Creating physical path ($PhysicalPath)"
        New-Directory -Path $PhysicalPath -Force:$Force
      }
      else {
        throw "Physical Path ($PhysicalPath) does not exist. Provide -Force to let us create the directory for you"
      }
    }
  }
  Process {
    #Create the Application Pool If It Does Not Exist
    if (-not(Test-AppPoolExists -Name $ApplicationPool)) {
      if ($Force) {
        Write-Verbose "Creating application pool: $ApplicationPool"
        New-WebAppPool $ApplicationPool
      }
      else {
        throw "Application pool does not exist. Provide -Force to let us create the application pool for you"
      }
    }
    if (-not($SiteName.Contains("\"))) {
      throw "Invalid site name. Please provide the root website and web application name e.g. 'Default Web Site\MyWebApp'"
    }
    Write-Verbose "Resolving Website and Web Application Names"
    $siteNameArray = $SiteName.Split("\")
    $rootSiteName = $siteNameArray[0]
    $webAppName = $siteNameArray[1]
      
    Write-Verbose "Creating web application $webAppName under $rootSiteName"
    New-WebApplication -Name $webAppName -Site $rootSiteName -PhysicalPath $PhysicalPath -ApplicationPool $ApplicationPool
  }
}

Export-ModuleMember -Function New-IISWebApplication