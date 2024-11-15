function Edit-PASPlatform {
    <#
    .SYNOPSIS
        Edits a CyberArk platform's General and UI and Workflow properties XML file.
    .DESCRIPTION
        Provided a CyberArk platform's General and UI and Workflow properties as XML this cmdlet allows adds new and deletes existing properties.

        It can update both Target Account Platforms and Service Account Platforms.
    .EXAMPLE
        PS C:\> Edit-PASPlatform -PlatformId Oracle -FilePath Policies.xml -Path '/Properties/Optional' -Operation Add -ElementName 'Property' -ElementAttributes @{'Name' = 'Business Department'}
        Adds a new optional property named 'Business Department' to the Oracle platform in Policies.xml.
    .EXAMPLE
        PS C:\> Edit-PASPlatform -PlatformId WinDomain -FilePath Policy-WinDomain.xml -Path '/Properties/Required' -Operation Add -ElementName 'Property' -ElementAttributes @{'Name' = 'Description'; 'Name' = 'UPN'}
        Adds two new required properties 'Description' and 'UPN' to the WinDomain platform in Policy-WinDomain.xml.
    .EXAMPLE
        PS C:\> @('WinDomain', 'Oracle', 'SchedTask') | Edit-PASPlatform -FilePath Policies.xml -Path '/Properties/Optional' -Operation Delete -ElementName 'Property' -ElementAttributes @{'Name' = 'Business Owner'}
        Deletes the existing optional property 'Business Owner' from the WinDomain, Oracle, and SchedTask platforms passed via the pipeline in Policies.xml
    #>
    [CmdletBinding()]
    param (
        # The path to the platform represented as .xml.
        [Parameter(Mandatory = $true)]
        [ValidateScript({ Test-Path -Path $_ })]
        [string]$FilePath,

        #The ID of the platform to edit.
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [string]
        $PlatformId,

        # The path inside the xml tree where the new element operation happens. Example: /Properties/Optional.
        # Provide '/' if you want to add an element to the root of the policy, for example when wanting to add
        # sections such as 'LinkedPasswords', 'ConnectionComponents', etc.
        [Parameter(Mandatory = $true)]
        [string]
        $Path,

        # The type of operation to perform.
        [Parameter(Mandatory = $true)]
        [string]
        [ValidateSet('Add', 'Delete')]
        $Operation,

        # The name of the element to be added.
        [Parameter(Mandatory = $true)]
        [string]
        $ElementName,

        # Attribute keys and values to be added to the element.
        [Parameter(Mandatory = $false)]
        [hashtable]
        $ElementAttributes,

        # If defined, saves the resulting .xml to this path.
        [Parameter(Mandatory = $false)]
        [string]
        $OutFile
    )

    begin {
        $FileXml = [xml](Get-Content -Path $FilePath)
    }

    process {
        # If the path is '/', we don't want to append it to the XPath.
        if ($Path -eq '/') {
            $Path = ''
        }

        # XPath expands to something like //Policy[@ID='Oracle']/Properties/Optional or //Usage[@ID='SchedTask']/Properties/Optional
        $SelectXPath = "//Policy[@ID='$PlatformId']$Path | //Usage[@ID='$PlatformId']$Path"
        $PlatformXml = $FileXml.SelectNodes($SelectXPath)

        if ($PlatformXml.Count -eq 0) {
            throw "No nodes found using the XPath '$SelectXPath'! Check that it correct."
        }

        switch ($Operation) {
            'Add' {
                $NewElement = $FileXml.CreateElement($ElementName)

                if ($ElementAttributes) {
                    foreach ($Attribute in $ElementAttributes.GetEnumerator()) {
                        $NewElement.SetAttribute($Attribute.Key, $Attribute.Value)
                    }
                }

                $PlatformXml.AppendChild($NewElement)
            }
            'Delete' {
                foreach ($Attribute in $ElementAttributes.GetEnumerator()) {
                    # //Property[@Name='Business Department']
                    $XPath = "//$ElementName[@$($Attribute.Key)='$($Attribute.Value)']"
                    $Nodes = $PlatformXml.SelectNodes($XPath)

                    foreach ($Node in $Nodes) {
                        $Node.ParentNode.RemoveChild($Node)
                    }
                }
            }
            Default {}
        }
    }

    end {
        if ($OutFile) {
            $FileXml.Save($OutFile)
        }
        else {
            # Full path required when saving.
            $FileXml.Save((Get-ChildItem -Path $FilePath).Fullname)
        }
    }
}