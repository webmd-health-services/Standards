<!--markdownlint-disable MD012 no-multiple-blanks-->

# PowerShell Coding and Style Guide

Version 2.0.0 (2021-10-14)

[CHANGELOG](CHANGELOG.md)

This document explains our PowerShell coding standards and guidelines. Following these will keep our code consistent and
easier to understand and maintain.

# Variables

Variable names should be in [camelCase](https://techterms.com/definition/camelcase), where the first letter of each word
in the variable is capitalized, except for the first word.

Parameter names are in [PascalCase](https://wiki.c2.com/?PascalCase) (see the [Parameters](#parameters) section for more
info.)

# Types

When declaring explicit variable or parameter types, always use the case of the type.

PowerShell has special type accelerators that are aliases to special types. It should be clear in your code that you're
using a type accelerator, so they should always be lower case if the accelerator is an alias to a type with a different
name (e.g. `[int]` for `Int32`) or not in the `System` namespace (e.g. `[ipaddress]` for `System.Net.IPAddress`).

Never use the `System`  part of a class's name. PowerShell adds it for you automatically.

```powershell
[String] $var1 = 'var1'
[ipaddress] $ip = [ipaddress]'10.1.1.2'
[int] $numTries = 10
[Object] $InputObject
[hashtable] $Parameter
[switch] $Clean
[pscustomobject]@{ 'Name' = $name }
$ErrorActionPreference = [Management.Automation.ActionPreference]::Stop
```

Use the [Get-LowerCaseTypeAccelerator.ps1](Get-LowerCaseTypeAccelerator.ps1) script to get the list of all type names
that should be lower case.

The [Edit-PSFileContentTypeCase.ps1](Edit-PSFileContentTypeCase.ps1) script will update your scripts to use this
convention.

# Strings

Always use single quotes around strings unless using string interpolation to embed expressions in the string. When using
string interpolation, surround variables with `${variable}` and all expressions  with `$()`.

```powershell
# If there's no interpolation in a string, always use single quotes.
'Just a raw string.'

# If using interpolation, always surround variables with `${}`.
"Path: ${env:Path}"

# If using interpolation, always surround expressions with `$()`.
"$($PSVersionTable['PSEdition'])
```

PowerShell allows un-quoted strings as parameter values. Always quote string parameters. If the parameter is an
enumeration or set (i.e. only a specific set of values are accepted), don't quote those values.

```powershell
# Always quote strings passed as parameters.
Get-ChildItem | Where-Object 'BaseName' -Like '.*'

# So that it is clear when you're passing an enum value.
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

# Scripts and Functions

Follow these guidelines whenever you write a standalone script.

Always support `-WhatIf` if your script/function changes something.

You should use a standard PowerShell verb as the first part of a script name (see below for the exceptions). Use a dash
to separate the verb from the noun/target in the second part of the name, e.g. `Initialize-DeveloperComputer.ps1`,
`Repair-HgCaseFoldingCollision.ps1`, `Invoke-Robocopy.ps1`. There should only be one dash in the command's name. For
help in choosing or finding a verb, see
[Approved Verbs for Windows PowerShell Commands](https://docs.microsoft.com/en-us/powershell/developer/cmdlet/approved-verbs-for-windows-powershell-commands).

Exceptions to using a standard PowerShell verb in your script's name:

* `init.ps1`: for the script that configures a computer so someone can develop and test your code.
* `build.ps1`: for the script that builds the code in your repository
* `install.ps1`: for the script that installs the software on the local computer.

Always include a synopsis, description, and at least one example in the documentation of your script. PowerShell has a
great built-in help system. Use it! See [June Blender's "PowerShell Help Deep-Dive" talk](https://youtu.be/U7c04Vwqqgk)
on how to write good documentation.

Never hard-code absolute paths. If you need to reach out to an external resource, the best approach is to use a
parameter to have the user pass you the location of that resource. If that won't work, don't hard-code absolute paths.
Use paths relative to your script. PowerShell 3+ has a pre-defined variable, `$PSScriptRoot`, which is the directory
where your script is located. Use the `Join-Path` cmdlet to make absolute paths from the script's current location or
the user's current location.

PowerShell keywords should always be in lowercase, e.g. `function`, `process`, etc.

Always enable strict mode. This will catch bugs.

```powershell
Set-StrictMode -Version 'Latest'
```

Always use full function/cmdlet names. Never use aliases, which require readers to memorize all of PowerShell's aliases.
Some aliases don't exist across operating systems. Aliases should only be used at an interactive prompt. This makes
scripts easier to understand and debug. For example, `Get-Process` not `gps`, `Get-ChildItem` not `gci`/`ls`/`dir`.

Never use positional parameters when calling a function/cmdlet. Positional parameters require readers to memorize a
command's positional parameters. Always use the parameter/switch name, e.g. `Join-Path -Path $PSScriptRoot -ChildPath
'build.ps1'` not `Join-Path $PSScriptRoot 'build.ps1'`. This improves readability and improves forward compatibility if
a command's positional parameters change.

## Parameters

For script/function parameters, attributes should be ordered this way: documentation, the `Parameter` attribute, any
validation attributes, documentation, and the parameter type (optional) and name on the same line. Put a space between
the parameter's type and the name.

Parameter names should be capitalized and Pascal-cased (i.e. every word begins with a capital letter. Abbreviations of
two letters should be in all caps, e.g. ID  instead of Id .) (See the [Types](#types) section above for how to case type
names.)

```powershell
[CmdletBinding(DefaultParameterSetName='FullPipeline')]
param(
    # The settings to use.
    [Parameter(Mandatory)]
    [String] $Environment,

    # Just build.
    [Parameter(ParameterSetName='PartialPipeline')]
    [switch] $Build,

    # Just migrate the database(s).
    [Parameter(ParameterSetName='PartialPipeline')]
    [switch] $MigrateDB,
 
    # This is an optional parameter. Note the missing [Parameter()] attribute.
    [String] $Optional
)
```

Parameter attribute property values should only be visible and set if its value is being set to a non-default value,
i.e. `[Parameter(ParameterSetName='PartialPipeline')]` not
`[Parameter(Mandatory=$false,ParameterSetName='PartialPipeline')]`. Boolean attribute property values must be omitted,
e.g. `[Parameter(Mandatory)]`, not `[Parameter(Mandatory=$true)]`.

Omit the parameter attribute entirely if it doesn't set any property values, e.g. omit any parameter attribute that
looks like `[Parameter()]`.

Always use the `CmdletBinding` attribute. All functions and scripts should begin like this:

```powershell
[CmdletBinding()]
param(
)
```

## Script Template

Use the following template for new scripts:

```powershell
<#
.SYNOPSIS
A short, one line summary of what the script does.
 
.DESCRIPTION
The `MY SCRIPT NAME.ps1` script... A detailed description of what the script does, why it does it, and how it does it.
Your future self will forget how your script was implemented and what it does. Use the description to explain that. Your
future self will thank you.
 
.EXAMPLE
MY SCRIPT NAME.ps1
Demonstrates how this script does what it does.
#>
[CmdletBinding()]
param(
)

#Require -Version 5.1
Set-StrictMode -Version 'Latest'

## Your code goes here.
```

# Line Length and Indentation

Lines over 120 characters should be shortened. It is easier to scroll up and down than left and right. You can refactor
expressions to variables:

```powershell
# Instead of this long line:
Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Arc' -Resolve) -Recurse -Filter '*.ps1' -Exclude $exclude -Include $include

# Break it into two:
$path = Join-Path -Path $PSScriptRoot -ChildPath 'Arc' -Resolve
Get-ChildItem -Path $path -Recurse -Filter '*.ps1' -Exclude $exclude -Include $include
```

If a line that calls another command is longer than 120 characters, put each parameter after the first on a new line,
indented to line up with the first parameter. When breaking a command across multiple lines, don't put more than one
parameter on a line.

```powershell
Invoke-Robocopy -Source $binSourcePath `
                -Destination $destinationBinPath `
                -IncludeFiles $binWhitelist `
                -ExcludeFiles $ExcludeBinFiles `
                -Retry 12 `
                -RetryWaitSeconds 5 `
                -Mirror
```

When a pipeline is longer than 100 characters, put each command/step of the pipeline on its own line:

```powershell
Get-ChildItem -Recurse |
    Sort-Object -Property 'Size' |
    Where-Object { $_.Size -gt 1mb } |
    Select-Object -ExpandProperty 'FullName'
```

When assigning the result of a pipeline to a variable, and the pipeline is longer than 100 characters, break each
command onto its own line, and put the first command of the pipeline on the line, indented one level:

```powershell
$largeFiles =
    Get-ChildItem -Recurse |
    Sort-Object -Property 'Size' |
    Where-Object { $_.Size -gt 1mb } |
    Select-Object -ExpandProperty 'FullName'
```

When using a script block to assign the value of a variable, indent the contents of the script block one level below the
indentation of the variable:

```powershell
$searchPaths = & {
    Join-Path -Path (Get-Location).ProviderPath -ChildPath $powerShellModulesDirectoryName
    Join-Path -Path $PSScriptRoot -ChildPath '..\Modules' -Resolve
}
```

When a string is longer than 120 characters, break it across multiple lines, using the `+` operator to concatenate the
strings together. The `+` operator should not extend past 120 characters. Indent the second and later lines to the start
of the string on the first line. Single quote the string on each line, unless it is using interpolation.

```powershell
$msg = "[$([Environment]::MachineName)] Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod " +
       'tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ' +
       'ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate ' +
       'velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in ' +
       'culpa qui officia deserunt mollit anim id est laborum.'
```


# Blocks

All blocks (except script blocks) that require curly braces must have the opening and closing curly braces on their own
lines. Parenthesis that surround block expressions should have a space before the opening parenthesis and no spaces
after the opening parenthesis or before the closing parenthesis.

```powershell
if ($true)
{
    # Something
}
else
{
    # Something else
}
```


When negating a statement, use the -not  operator.

```powershell
# Instead of using !
if (!$false)
{
}

# Use -not
if (-not $false)
{
}
```

# Output

Never use `Write-Host`. It can't be redirected, captured, or ignored.

Never use `Write-Output` to return logging information. You should only ever return objects.

Use `Write-Information` for progess-type logging information the user should always see.

Use `Write-Verbose` for messages the *user* should see if they're trying to track down a problem or understand more
about what your code is doing.

Use `Write-Debug` for developer-only messages.

# Functions

Never dot-source a script containing functions. Instead, package your functions into a module (see "Modules" section
below).

All the standards for writing scripts also apply. Additionally:

Only use `begin`/`process`/`end` blocks if your script processes pipeline input.

Never use the `filter` keyword. Instead, use `begin`/`process`/`end` blocks.

When writing a function that accepts pipeline input, put the `Set-StrictMode` declaration in the begin block.

If your function returns any strongly-typed objects, include an `OutputType` attribute underneath the `CmdletBinding`
attribute. The `OutputType` attribute enables Intellisense in various code editors.

## Function Template

### No Pipeline Input

```powershell
function ApprovedVerb-Noun
{
    <#
    .SYNOPSIS
    A short, one line summary of what the function does.

    .DESCRIPTION
    A detailed description of what the function does, why it does it, and how it does it. People want to read this
    rather than your code.

    .EXAMPLE
    Demonstrates how to use this function.
    #>
    [CmdletBinding()]
    [OutputType([Object])]
    param(
    )
 
    Set-StrictMode -Version 'Latest'
 
    # Logic here.
}
```

### Accepts Pipeline Input

```powershell
function ApprovedVerb-Noun
{
    <#
    .SYNOPSIS
    A short, one line summary of what the function does.

    .DESCRIPTION
    A detailed description of what the function does, why it does it, and how it does it. People want to read this
    rather than your code.

    .EXAMPLE
    Demonstrates how to use this function.
    #>
    [CmdletBinding()]
    [OutputType([Object])]
    param(
        # Documentation describing this parameter. Try to use a more descriptive name than InputObject. Use InputObject
        # only if the parameter takes different types/kinds of objects.
        [Parameter(Mandatory,ValueFromPipeline)]
        $InputObject
    )
 
    begin
    {
        Set-StrictMode -Version 'Latest'
     }
 
    process
    {
        # Logic here.
    }
 
    end
    {
    }
}
```

## Modules

Modules are PowerShell's unit of sharing. Common functions are packaged together into modules. If you want to share
functions, put them in a module. Never dot-source a file containing functions.


Layout a module like this:

```text
+ MyModule
  + bin
    * MyModule.dll
  + en-US
    * about_Topic1.help.txt
    * about_Topic2.help.txt
  + Formats
    * Object1.ps1xml
    * Object2.ps1xml
  + Functions
    * My-ModuleFunction1.ps1
    * My-ModuleFunction2.ps1
  * Import-MyModule.ps1
  * MyModule.psd1
  * MyModule.psm1
  * script.ps1
```

Put your module's assembly and other third-party assemblies, into a `bin` directory.

Put your about help topics into a directory whose name matches the locale name the help is written in.

Put your module's functions into a `Functions` directory. Each function should be in its own file, whose name matches
the function name.

Do ***not*** put extended type information into `ps1xml` files. A module's custom type data isn't removed when the
module is removed. So subsequent imports of that modules results in errors that the custom type information is already
present. Instead, use `Get-Member` and the `Update-TypeData` cmdlet to add custom type information only when it isn't
present.

```powershell
# Allows us to be platform agnostic in our calls of 'GetAccessControl'.
if (-not ([IO.DirectoryInfo]::New([Environment]::CurrentDirectory) | Get-Member -Name 'GetAccessControl'))
{
    Update-TypeData -MemberName 'GetAccessControl' -MemberType 'ScriptMethod' -TypeName 'IO.DirectoryInfo' -Value {
        [CmdletBinding()]
        param(
            [Security.AccessControl.AccessControlSections]$IncludeSections =
                [Security.AccessControl.AccessControlSections]::All
        )

        return [IO.FileSystemAclExtensions]::GetAccessControl($this, $IncludeSections)
    }
}
```

Put XML-based format/display data into a `Formats` directory. All formats for each object should be in its own file.

Always have a .psd1. Use `New-ModuleManifest` to create one.

Always have a .psm1 file. See the template below.

Always choose and use a default command prefix for all your module's commands to avoid name conflicts with other
modules. Add the prefix to the literal function names. Do ***not** set the prefix with the `DefaultCommandPrefix`
property in your module's manifest: PowerShell uses the non-prefixed version of commands to determine if command across
modules clobber each other. For example, Carbon uses `C`, `BuildMasterAutomation` uses `BM`, `BitbucketServerAutomation`
uses `BBServer`, `ProGetAutomation` uses `ProGet`, etc.

Never store global state in a module variable. Module variables should only hold stateless information. If your module
has state it needs to keep track of (like a connection to a server or something), follow the pattern used by PowerShell:
create a `New-Connection`/`New-Session`/`New-Context` function that returns an object containing that state. Update all
functions that need that state to take in that object as a parameter. This way, users don't need to create different
PowerShell sessions to have different state.

List your exported functions, variables, aliases, etc. in your module manifest. Don't use `Export-ModuleMember` unless
your module doesn't have a manifest.

When packaging a module for distribution and release, merge all your functions into your module's .psm1 file.
Dot-sourcing each function takes a constant amount of time (it takes about a second to import about 30 files). We use
[Whiskey](https://github.com/webmd-health-services/Whiskey/wiki) to build, test, package, and publish all our modules.
It has a [MergeFile](https://github.com/webmd-health-services/Whiskey/wiki/MergeFile-Task) task that will merge your
functions into your .psm1 file during your build.

Module functions don't inherit the preference settings from their caller's scope. This means your `Write-Verbose` and
other messages won't be seen unless the caller adds `-Verbose` when calling your function or runs that preference on
globally. All modules must include the [Use-CallerPreference](Use-CallerPreference.ps1) (as a private function) and
every function must call `Use-CallerPreference` to use the caller's preference settings. Use the function templates
above, but add `Use-CallerPreference` after `Set-StrictMode`:

```powershell
    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
```

Module variables must be prefixed with the `script:` scope to identity them as being used throughout the module.


## Module .psm1 Template

```powershell
# Declare module-level variables
$script:myModuleVar = 'fubar'
 
# Do other stuff: add types, add extended type data, etc.
 
# Include your functions for developers.
$functionRoot = Join-Path -Path $PSScriptRoot -ChildPath 'Functions'
if ((Test-Path -Path $functionRoot))
{
    Get-ChildItem -Path $functionRoot -Filter '*.ps1' | ForEach-Object { . $_.FullName }
}

# When packaging your module, merge your function files into this file here.
```
