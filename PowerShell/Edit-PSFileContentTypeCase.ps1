<#
.SYNOPSIS
Updates PowerShell files so their types use the correct case.

.DESCRIPTION
The `Edit-TypeCase.ps1` script searches a list of paths for PowerShell files (*.ps1, *.psm1) and updates them to use the correct case for their types. The WebMD Health Services standard is that all types should use the case of the underlying type, unless it is a type acclerator that is an alias to a type with a different name (e.g. `int` for `Int32`, `switch` for `SwitchParameter`, etc.).

.EXAMPLE
Edit-PSFileContentTypeCase.ps1 -Path . -WhatIf

Demonstrates how to call this script and preview the changes that will be made.

.EXAMPLE
Edit-PSFileContentTypeCase.ps1 -Path . 

Demonstrates how to call this script to make changers to your files.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    # The paths to search.
    [String[]]$Path
)

#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

function Find-Type
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [String]$Name
    )

    if( $typeNames.Count -eq 0 )
    {
        $typeNames['ordered'] = 'ordered'

        [PSObject].Assembly.GetType('System.Management.Automation.TypeAccelerators')::Get.GetEnumerator() |
            ForEach-Object { [pscustomobject]@{ Name = $_.Key ; Type = $_.Value } } |
            Where-Object { $_.Type.Name -notlike $_.Name -or $_.Type.Namespace -ne 'System' } |
            Where-Object { $_.Type.Name -notlike '*Attribute' } |
            ForEach-Object { $typeNames[$_.Name] = $_.Name.ToLowerInvariant() }

        foreach( $assembly in [AppDomain]::CurrentDomain.GetAssemblies())
        {
            try
            {
                $types = $assembly.GetExportedTypes()
            }
            catch
            {
                continue
            }

            foreach( $type in $types )
            {
                if( $type.Namespace -ne 'System' )
                {
                    continue
                }
                $typeNames[$type.Name] = $type.Name
            }
        }
    }

    if( -not $typeNames.ContainsKey($Name) )
    {
        Write-Error -Message ('Type "{0}" not found.' -f $Name)
        return
    }

    return $typeNames[$Name]
}

$typeNames = @{}

$searchRegex = [regex]'\[([A-Za-z]+)(\[\])?\]' 
Resolve-Path -Path $Path -ErrorAction Stop |
    Get-ChildItem -Include '*.ps1','*.psm1' -Recurse |
    ForEach-Object {
        $filePath = $_.FullName
        $fileRelativePath = Resolve-Path -Path $filePath -Relative
        $lines = [IO.File]::ReadAllLines($filePath)
        $changedFile = $false
        for( $idx = 0; $idx -lt $lines.Length; ++$idx )
        {
            $line = $lines[$idx]
            $newLine = $null
            $changedLine = $false

            # There might be more than one on a line.
            $matches = $searchRegex.Matches($line)
            foreach( $match in $matches )
            {
                $original = $match.Value
                $originalTypeName = $match.Groups[1].Value
                $originalSuffix = $match.Groups[2].Value

                $newTypeName = Find-Type $originalTypeName
                if( -not $newTypeName -or $newTypeName -ceq $originalTypeName )
                {
                    continue
                }

                $replacement = '[{0}{1}]' -f $newTypeName,$originalSuffix
                $newLine = $line.Remove($match.Index,$match.Length)
                $newLine = $newLine.Insert($match.Index,$replacement)
                Write-Output ([pscustomobject]@{
                    Path = $fileRelativePath;
                    Line = $idx;
                    Before =  $original;
                    After = $replacement;
                    LineBefore = $line; LineAfter = $newLine;
                })

                $line = $newLine

                $changedLine = $true
            }

            if( $changedLine )
            {
                $lines[$idx] = $newLine
                $changedFile = $true
            }
        }

        if( $changedFile -and $PSCmdlet.ShouldProcess($filePath,'update') )
        {
            [IO.File]::WriteAllLines($filePath,$lines)
        }
    }
