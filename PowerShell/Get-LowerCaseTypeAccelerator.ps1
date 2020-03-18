<#
.SYNOPSIS
Gets the type accelerators that should be lowercase.

.DESCRIPTION
The `Get-LowerCaseTypeAccelerator` gets a list of type accelerators that should be lowercase in code. Our standards dictate that only type accelerators whose names don't match the full type name of their underlying type should be lowercase.

.EXAMPLE
.\Get-LowerCaseTypeAccelerator.ps1

Demonstrates how to call this script.
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