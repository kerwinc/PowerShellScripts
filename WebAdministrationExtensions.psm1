Import-Module ".\IO.File.Extentions.psm1" -Force

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

function Test-AppPoolExists ([string]$Name) {
  $siteAppPoolPath = "IIS:\AppPools\" + $Name
  if ((Test-Path $siteAppPoolPath -pathType container)) {
    return $true
  }
  else {
    return $false
  }
}

function Test-SiteExists ([string]$Name) {
  $sitePath = "IIS:\Sites\" + $Name
  if ((Test-Path $sitePath -pathType container)) {
    return $true
  }
  else {
    return $false
  }
}

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

function Set-SitePhysicalPath {
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {Test-SiteName $_})]
    [Parameter(Mandatory = $true)][string]$SiteName,
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $true)][string]$NewPhysicalPath
  )

  $siteIISPath = "IIS:\Sites\" + $SiteName

  #check if the site exists
  if (!(Test-Path $siteIISPath -pathType container)) {
    Write-Host "Site does not exist in IIS: "$appName -foregroundcolor "red"
    return
  }

  Set-ItemProperty $siteIISPath -name physicalPath -value $NewPhysicalPath

  $site = Get-Website -Name $appName
  Write-Host "Physical path for "$site.name" changed to" $site.physicalPath  -foregroundcolor "green"
}

function Stop-WebApplicationPool {
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
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

function Start-WebApplicationPool {
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
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
    Test-DirectoryPath -Path $physicalPath

    Write-Verbose "Stopping application pool ($appPool) for $siteName"
    Stop-WebApplicationPool -AppPoolName $appPool
  }
  Process {
    #Clean out the site's physical path
    Write-Verbose "Removing files from $physicalPath"
    Remove-DirectoryContents -Path $physicalPath -Verbose:$VerbosePreference

    #Copy Source files to WebSite's Physical Directory
    Write-Verbose "Copying files from $SourceApplicationDirectoryPath to $physicalPath"
    Copy-Item -Path "$SourceApplicationDirectoryPath\*" -Destination $physicalPath -Recurse
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
    ZipFiles -sourcedir $physicalPath -zipfilename $zipFileFullPath
  }
  End {
    if ($itemCount -eq 0) {return}

    if ((Test-Path -Path $zipFileFullPath) -and $Error.Count -eq 0) {
      Write-Host "Backup for $SiteName was created at $zipFileFullPath successfully!" -ForegroundColor Green
    }
  }
}

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

function New-WebSiteOrWebApplication {
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $true)][string]$SiteName,
    [ValidateNotNullOrEmpty()]
    [Parameter()][int]$Port,
    [ValidateNotNullOrEmpty()]
    [Parameter()][string]$HostHeader,
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {Test-Path -Path $_ -PathType Container})]
    [Parameter(Mandatory = $true)][string]$PhysicalPath,
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $true)][string]$ApplicationPool
  )
  Begin {
    if (-not(Test-DirectoryPath -Path $PhysicalPath)) {
      Write-Verbose "Invalid physical path ($PhysicalPath). Please provide a valid directory path"
    }
  }
  Process {
    #Create the Application Pool If It Does Not Exist
    if (!(Test-AppPoolExists -Name ApplicationPool)) {
      New-WebAppPool $ApplicationPool
    }

    if ($SiteName.Contains("\")) {
      Write-Verbose "Resolving Website and Web Application Names"
      $siteNameArray = $SiteName.Split("\")
      $rootSiteName = $siteNameArray[0]
      $webAppName = $siteNameArray[1]
      
      Write-Verbose "Creating web application $webAppName under $rootSiteName"
      New-WebApplication -Name $webAppName -Site $rootSiteName -PhysicalPath $PhysicalPath -ApplicationPool $ApplicationPool
    }
    else {
      Write-Verbose "Creating website $siteName on port $Port"
      New-WebSite -Name $SiteName -Port $Port -HostHeader $HostHeader -PhysicalPath $PhysicalPath -ApplicationPool $ApplicationPool
    }
  }
}
