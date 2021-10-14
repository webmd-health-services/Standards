
# 2.0.0

* Formatting (all lines include breaks at 120 characters).
* Added section on strings: when to use single quotes, how to embed interpolated expressions, when its OK to not quote
  some strings.
* Updated function/script parameter standard:
  * Comments should now go before the `[Parameter()]` attribute instead of after.
  * There should be a space between the parameter's type and name.
* Added paragraph on how to break strings longer than 120 characters across multiple lines.


# 1.1.0

* Added standards on casing of variable and parameter names.
* Increased maximum line length from 100 characters to 120 characters.


# 1.0.1

* Created [Get-LowerCaseTypeAccelerator.ps1](Get-LowerCaseTypeAccelerator.ps1) script for getting the list of type
  accelerators.
* [Edit-PSFileContentTypeCase.ps1](Edit-PSFileContentTypeCase.ps1): Fixed regular expression for finding and changing
  type case.
* Fixed a typo.