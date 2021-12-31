#Requires -Module psIni

function Edit-PASPlatformAPM {
    [CmdletBinding()]
    param (
        # Path to the platform's Automatic Password Management settings in .ini form.
        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path -Path $_})]
        [string]$FilePath,

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
        Get-IniContent -FilePath $FilePath | Set-IniContent -NameValuePairs @{$Property = $Value} | Out-IniFile -FilePath $FilePath -Force

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