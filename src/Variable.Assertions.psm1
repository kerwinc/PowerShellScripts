
$script:assertItems = @()

function Add-AssertItem {
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $true)][string]$Name,
    # [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $false)][string]$Value,
    [ValidateNotNullOrEmpty()]
    [ValidateSet("Folder", "Application Pool", "WebSite", "File")]
    [Parameter(Mandatory = $true)][string]$Type,
    [ValidateSet("Error", "Warning", "Info")]
    [Parameter()][string]$ErrorPreference = "Error"
  )
  Process {
    $item = New-Object System.Object
    $item | Add-Member -type NoteProperty -name "Variable" -value $Name
    $item | Add-Member -type NoteProperty -name "Value" -value $Value
    $item | Add-Member -type NoteProperty -name "Type" -value $Type
    $item | Add-Member -type NoteProperty -name "Status" -value $null
    $item | Add-Member -type NoteProperty -name "Error" -value $null
    $item | Add-Member -type NoteProperty -name "ErrorPreference" -value $ErrorPreference
    $script:assertItems += $item
    Write-Verbose "$Name added to assert items list"
  }
}

function Assert-Folder { 
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $true)][System.Object]$Item
  )
  Process {
    try {
      if (Test-DirectoryPath -Path $Item.Value -ErrorAction SilentlyContinue) {
        $item.Status = "Valid"
      }
      else { 
        throw "Count not find folder at path: $($item.Value)"
      }
    }
    catch {
      $item.Status = "Invalid"
      $item.Error = "$($_.Exception.Message)"
    }
  }
}

function Assert-File { 
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $true)][System.Object]$Item
  )
  Process {
    try {
      if (Test-FilePath -Path $Item.Value) {
        $item.Status = "Valid"
      }
      else { 
        throw "Count not find file at path: $($item.Value)"
      }
    }
    catch {
      $item.Status = "Invalid"
      $item.Error = "$($_.Exception.Message)"
    }
  }
}

function Assert-AppPool { 
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $true)][System.Object]$Item
  )
  Process {
    try {
      if (Test-AppPoolExists -Name $Item.Value) {
        $item.Status = "Valid"
      }
      else { 
        throw "Application Pool [$($item.Value)] does not exist"
      }
    }
    catch {
      $item.Status = "Invalid"
      $item.Error = "$($_.Exception.Message)"
    }
  }
}

function Assert-WebSite { 
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $true)][System.Object]$Item
  )
  Process {
    try {
      if (Test-SiteExists -Name $Item.Value) {
        $item.Status = "Valid"
      }
      else { 
        throw "WebSite [$($item.Value)] does not exist"
      }
    }
    catch {
      $item.Status = "Invalid"
      $item.Error = "$($_.Exception.Message)"
    }
  }
}

function Assert-Items {
  param(
    [Parameter()][switch]$ShowOutput,
    [Parameter()][switch]$ErrorIfAnyInvalid
  )
  Process {

    Write-Verbose "Variable Verification Starting"
    if ($script:assertItems.Count -gt 0) {
      ForEach ($item in $script:assertItems) {
        Write-Verbose "Validating item: $($item.Variable) => [$($item.Value)]"
        switch ($item.Type) {
          "Folder" {
            $item = Assert-Folder -Item $item
          }
          "Application Pool" {
            $item = Assert-AppPool -Item $item
          }
          "WebSite" {
            $item = Assert-WebSite -Item $item
          }
          "File" {
            $item = Assert-File -Item $item
          }
          Default {
            Write-Host "Unknown item type..."
          }
        }
      }
    }
    else {
      Write-Verbose "No items have added to verifiy"
    }

    if ($ShowOutput) {
      Show-AssertResult -ErrorIfAnyInvalid:$ErrorIfAnyInvalid
    }
    else {
      $errorItems = $script:assertItems | Where-Object {$_.Status -eq "Invalid"}
      $response = @{items = $script:assertItems; errorItems = $errorItems}
      return $response
    }
    
  }
}

function Show-AssertResult {
  param(
    [Parameter()][switch]$ErrorIfAnyInvalid
  )
  Process {
    $errorItems = $script:assertItems | Where-Object {$_.Status -eq "Invalid" -and $_.ErrorPreference -eq "Error"}
    $warningItems = $script:assertItems | Where-Object {$_.Status -eq "Invalid" -and $_.ErrorPreference -eq "Warning"}
    $validItems = $script:assertItems | Where-Object {$_.Status -eq "Valid"}

    $script:assertItems | Sort-Object  -Property Variable | Format-Table
    Write-Host "Variable Verification Summary:"
    Write-Host "Total Variables: $($script:assertItems.Count)"
    Write-Host "Valid Variables: $($validItems.Count)"
    Write-Host "Wainings: $($warningItems.Count)"
    Write-Host "Errors: $($errorItems.Count)"

    if ($errorItems.Count -gt 0) {
      Write-Host "Invalid Items:" -ForegroundColor Red
      Write-Host "----------------------------------------"
      $errorItems | Sort-Object  -Property Variable |Format-Table
      if ($ErrorIfAnyInvalid) {
        Throw "Some items did not pass validation. Process aborted."  
      }
    }
    else {
      Write-Host "All items passed validation" -ForegroundColor Green
    }
  }
}

function Clear-AssertItems { 
  Process {
    Write-Verbose "Resetting assertItems collection"
    $script:assertItems = @()
  }
}

Export-ModuleMember -function Add-AssertItem,
Assert-Items,
Clear-AssertItems,
Show-AssertResult