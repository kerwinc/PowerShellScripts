function Invoke-XmlTransform {
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {(Test-Path -Path $_ -PathType Leaf)})]
    [Parameter(Mandatory = $true)][string]$XmlFilePath,
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {(Test-Path -Path $_ -PathType Leaf )})]
    [Parameter(Mandatory = $true)][string]$XdtFilePath,
    [ValidateNotNullOrEmpty()]
    [Parameter()][string]$DestinationPath,
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {(Test-Path -Path $_ -PathType Container )})]
    [Parameter()][string]$TransformDllDirectory,
    [Parameter()][switch]$SuppressOutput
  )
  Process {

    #Set the destination file path to the source file path if its empty. This allows the option to update the existing config or create a new one.
    if ([System.String]::IsNullOrEmpty($DestinationPath) -or [System.String]::IsNullOrWhiteSpace($DestinationPath)) {
      $DestinationPath = $XmlFilePath
    }
    try {
      #Todo: Add a function to resolve the location of the dll 
      $transformTypePath = "$TransformDllDirectory\Microsoft.Web.XmlTransform.dll"
      Write-Verbose "Loading Microsoft.Web.XmlTransform.dll from $transformTypePath"
      Add-Type -LiteralPath $transformTypePath

      Write-Verbose "Loading XML from $XmlFilePath"
      $xmldoc = New-Object Microsoft.Web.XmlTransform.XmlTransformableDocument
      $xmldoc.PreserveWhitespace = $true
      $xmldoc.Load($XmlFilePath)

      Write-Verbose "Loading Xdt from $XdtFilePath"
      $transform = New-Object Microsoft.Web.XmlTransform.XmlTransformation($XdtFilePath)

      Write-Verbose "Transforming XML"
      if ($transform.Apply($xmldoc) -eq $false) {
        throw "Transformation of $XmlFilePath from $XdtFilePath failed"
      }

      Write-Verbose "Saving transformed XML to $DestinationPath"
      $xmldoc.Save($DestinationPath)
      if (!$SuppressOutput) {
        Write-Host "Transform completed successfully!" -ForegroundColor Green  
      }
    }
    catch {
      Write-Error "Error transforming XML file. "$PSItem.Exception
    }
  }
}

Export-ModuleMember -Function Invoke-XmlTransform