<#
#>
[CmdletBinding()]
param(
)

#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

[psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')::Get.GetEnumerator() |
    ForEach-Object { [pscustomobject]@{ Name = $_.Key.ToLowerInvariant() ; Type = $_.Value } } | 
    Where-Object { $_.Type.Name -notlike $_.Name -or $_.Type.Namespace -ne 'System' } |
    Where-Object { $_.Type.Name -notlike '*Attribute' } |
    Sort-Object -Property 'Name'