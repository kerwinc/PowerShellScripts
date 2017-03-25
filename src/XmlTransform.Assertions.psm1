#Requires -Modules XmlTransform.Extensions

$script:assertXmlItems = @()

function Add-TransformAssertItem {
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $true)][string]$Config,
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $false)][string]$Transform,
    [ValidateSet("Error", "Warning", "Info")]
    [Parameter()][string]$ErrorPreference = "Error"
  )
  Process {
    $item = New-Object System.Object
    $item | Add-Member -type NoteProperty -name "Config" -value $Config
    $item | Add-Member -type NoteProperty -name "Transform" -value $Transform
    $item | Add-Member -type NoteProperty -name "Status" -value $null
    $item | Add-Member -type NoteProperty -name "Error" -value $null
    $item | Add-Member -type NoteProperty -name "ErrorPreference" -value $ErrorPreference
    $script:assertXmlItems += $item
    Write-Verbose "$Name added to assert items list"
  }
}

function Assert-XmlTransform {
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $true)][System.Object]$Item
  )
  Process {
    try {
      $xdtFile = Get-Item -LiteralPath ($Item.Transform)
      Invoke-XmlTransform -XmlFilePath $Item.Config -XdtFilePath "$($xdtFile.FullName)" -DestinationPath "C:\Backup\output\$($xdtFile.Name)" -TransformDllDirectory "$scriptLocation\lib" -SuppressOutput
      $item.Status = "Success"
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
    Write-Verbose "Transform Verification Starting"
    if ($script:assertXmlItems.Count -gt 0) {
      ForEach ($item in $script:assertXmlItems) {
        Write-Verbose "Validating item: $($item.Config) <= [$($item.Transform)]"
        $item = Assert-XmlTransform -Item $item
      }
    }
    else {
      Write-Verbose "No items have added to verifiy"
    }
    if ($ShowOutput) {
      Show-AssertResult -ErrorIfAnyInvalid:$ErrorIfAnyInvalid
    }
    else {
      $errorItems = $script:assertXmlItems | Where-Object {$_.Status -eq "Invalid"}
      $response = @{items = $script:assertXmlItems; errorItems = $errorItems}
      return $response
    }
  }
}

function Show-AssertResult {
  param(
    [Parameter()][switch]$ErrorIfAnyInvalid
  )
  Process {
    $errorItems = $script:assertXmlItems | Where-Object {$_.Status -eq "Invalid" -and $_.ErrorPreference -eq "Error"}
    $warningItems = $script:assertXmlItems | Where-Object {$_.Status -eq "Invalid" -and $_.ErrorPreference -eq "Warning"}
    $validItems = $script:assertXmlItems | Where-Object {$_.Status -eq "Success"}

    $script:assertXmlItems | Sort-Object  -Property Variable | Format-Table
    Write-Host "Variable Verification Summary:"
    Write-Host "Total Variables: $($script:assertXmlItems.Count)"
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
    Write-Verbose "Resetting assertXmlItems collection"
    $script:assertXmlItems = @()
  }
}

Export-ModuleMember -function Add-TransformAssertItem,
Assert-Items,
Clear-AssertItems,
Show-AssertResult