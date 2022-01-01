# Edit-CyberArkPlatforms

Two cmdlets used to edit a CyberArk platform's properties once the files have been retrieved out of the Vault.

|Cmdlet|Platform Properties|Required modules|
|------|-------------------|----------------|
|Edit-PASPlatform|'General' and 'UI and Workflow'|none|
|Edit-PASPlatformAPM|'Automatic Password Management|[PsIni](https://www.powershellgallery.com/packages/PsIni/)|

## Usage

Install the required modules available in the PowerShell gallery and import the desired cmdlet.

`Import-Module Edit-PASPlatform.ps1`

## Examples

Use `Get-Help` and pass the cmdlet name to get help and see examples on using them.
