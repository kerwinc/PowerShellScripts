function Invoke-XmlTransform {
  [CmdletBinding()]
  param(
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {(Test-Path -Path $_ -PathType Leaf)})]
    [Parameter(Mandatory = $true)][string]$XmlFilePath,
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {(Test-Path -Path $_ -PathType Leaf )})]
    [Parameter(Mandatory = $true)][string]$XdtFilePath
  )
  Process {
    $transformTypePath = "$PSScriptRoot\Lib\Microsoft.Web.XmlTransform.dll"
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

    Write-Verbose "Saving transformed XML to $XmlFilePath"
    $xmldoc.Save($XmlFilePath)
    Write-Host "Transform completed successfully!" -ForegroundColor Green
  }
}

Export-ModuleMember -Function Invoke-XmlTransform