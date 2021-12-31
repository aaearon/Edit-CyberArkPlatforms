function Edit-PASPlatform {
    [CmdletBinding()]
    param (
        # The path to the platform represented as .xml.
        [Parameter(Mandatory = $true)]
        [ValidateScript({ Test-Path -Path $_ })]
        [string]$FilePath,

        #The ID of the platform to edit.
        [Parameter(Mandatory = $true)]
        [string]
        $PlatformId,

        # The path inside the xml tree where the new element operation happens. Example: /Properties/Optional
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
        [Parameter(Mandatory = $true)]
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
        # XPath expands to something like //Policy[@ID='Oracle']/Properties/Optional or //Usage[@ID='SchedTask']/Properties/Optional
        $PlatformXml = $FileXml.SelectNodes("//Policy[@ID='$PlatformId']$Path | //Usage[@ID='$PlatformId']$Path")

        if ($null -eq $PlatformXml) {
            throw "Invalid path! Check that it exists."
        }

        switch ($Operation) {
            'Add' {
                $NewElement = $FileXml.CreateElement($ElementName)

                foreach ($Attribute in $ElementAttributes.GetEnumerator()) {
                    $NewElement.SetAttribute($Attribute.Key, $Attribute.Value)
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
            $FileXml.Save($FilePath)
        }
    }
}