#Requires -Module psIni

function Edit-PASPlatformAPM {
    <#
    .SYNOPSIS
        Edits a CyberArk platform's Automatic Password Management properties .ini file.
    .DESCRIPTION
        Provided a CyberArk platform's Automatic Password Management properties as an .ini file this cmdlet allows adds new APM properties and update the values of existing ones. It also ensures there is no BOM so that the CPM will parse the file.
    .EXAMPLE
        PS C:\> Edit-PASPlatformAPM -FilePath Policy-WinDomain.ini -Property 'MinDelayBetweenRetries' -Value 91
        Changes the MinDelayBetweenRetries value to 91 in Policy-WinDomain.ini (taken directly from the Vault or from the platform export Zip file.)

        PS C:\> Edit-PASPlatformAPM -FilePath Policy-Oracle.ini -Section 'ExtraInfo' -Property 'Port' -Value 1521
        Changes the Port value to 1521 under the 'ExtraInfo' section in Policy-Oracle.ini.

        PS C:\> Get-ChildItems C:\APMIniFiles | Edit-PASPlatformAPM -Property 'ImmediateInterval' -Value 1
        Changes the ImmediateInterval value to 1 for all files in C:\APMIniFiles
    #>
    [CmdletBinding()]
    param (
        # Path to the platform's Automatic Password Management settings in .ini form.
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [ValidateScript({Test-Path -Path $_})]
        [string]$FilePath,

        # The section of the .ini file to add the new property or update the existing one. If left blank, will add the property under no section or search for an existing property under no section.
        [Parameter(Mandatory = $false)]
        [string]
        $Section = '_',

        # The property to update.
        [Parameter(Mandatory = $true)]
        [string]
        $Property,

        # The new value of the property that will be updated.
        [Parameter(Mandatory = $true)]
        [string]
        $Value
    )

    begin {

    }

    process {
        Get-IniContent -FilePath $FilePath | Set-IniContent -Section $Section -NameValuePairs @{$Property = $Value} | Out-IniFile -FilePath $FilePath -Force

        Remove-BOMInFile -Path $FilePath
    }

    end {

    }

}

# We need to move the BOM otherwise the CPM does not like it. It will not throw an error
# but the new file will not be recognized.
# Taken from https://gist.github.com/brianvanderlugt/5f517935be9b2b467c3aa64fcde3c98d.
function Remove-BOMInFile {
    param (
        $Path
    )
    $Content = Get-Content -Path $Path
    $Content = $Content -replace '\xEF\xBB\xBF',''
    $Content | Set-Content $Path
}