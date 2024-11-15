BeforeAll {
    . $PSScriptRoot/../Edit-PASPlatform.ps1

    Copy-Item *.xml $TestDrive
}

Describe 'Edit-PASPlatform' {
    It 'adds a new property with a single attribute to <File> for platform <PlatformId>' {
        $Platform = "$TestDrive\$File"

        Edit-PASPlatform -PlatformId $PlatformId -FilePath $Platform -Path '/Properties/Optional' -Operation Add -ElementName 'Property' -ElementAttributes @{'Name' = 'Business Department' }

        $Result = [xml] (Get-Content -Path $Platform)
        Select-Xml -Xml $Result -XPath "//*[@ID='$PlatformId']/Properties/Optional/Property[@Name='Business Department'][1]" | Should -Be $true

    } -TestCases @(
        @{PlatformId = 'Oracle'; File = 'Policy-Oracle.xml' }
        @{PlatformId = 'SchedTask'; File = 'Policy-SchedTask.xml' }
        @{PlatformId = 'WinDomain'; File = 'Policies.xml' }
    )

    It 'adds a new property with a two attributes to <File> for platform <PlatformId>' {
        $Platform = "$TestDrive\$File"

        Edit-PASPlatform -PlatformId $PlatformId -FilePath $Platform -Path '/LinkedPasswords' -Operation Add -ElementName 'Link' -ElementAttributes @{'Name' = 'BogusAccount'; PropertyIndex = '4' }

        $Result = [xml] (Get-Content -Path $Platform)
        Select-Xml -Xml $Result -XPath "//*[@ID='$PlatformId']/LinkedPasswords/Link[@Name='BogusAccount' and @PropertyIndex='4']" | Should -Be $true

    } -TestCases @(
        @{PlatformId = 'Oracle'; File = 'Policy-Oracle.xml' }
        @{PlatformId = 'SchedTask'; File = 'Policy-SchedTask.xml' }
        @{PlatformId = 'WinDomain'; File = 'Policies.xml' }
    )


    It 'adds a new element without attributes to <File> for platform <PlatformId>' {
        $Platform = "$TestDrive\$File"

        Edit-PASPlatform -PlatformId $PlatformId -FilePath $Platform -Path '/Properties/Optional' -Operation Add -ElementName 'NoAttributeElement'

        $Result = [xml] (Get-Content -Path $Platform)
        Select-Xml -Xml $Result -XPath "//*[@ID='$PlatformId']/Properties/Optional/NoAttributeElement" | Should -Not -Be $null

    } -TestCases @(
        @{PlatformId = 'Oracle'; File = 'Policy-Oracle.xml' }
        @{PlatformId = 'SchedTask'; File = 'Policy-SchedTask.xml' }
        @{PlatformId = 'WinDomain'; File = 'Policies.xml' }
    )

    It 'updates an existing property' {
    }

    It 'deletes an existing property in <File> for platform <PlatformId>' {
        $Platform = "$TestDrive\$File"

        Edit-PASPlatform -PlatformId $PlatformId -FilePath $Platform -Path '/Properties/Required' -Operation Delete -ElementName 'Property' -ElementAttributes @{'Name' = 'Username' }

        $Result = [xml] (Get-Content -Path $Platform)
        Select-Xml -Xml $Result -XPath "//*[@ID='$PlatformId']/Properties/Required/Property[@Name='Username'][1]" | Should -Be $null
    } -TestCases @(
        @{PlatformId = 'Oracle'; File = 'Policy-Oracle.xml' }
        @{PlatformId = 'WinDomain'; File = 'Policies.xml' }
    )

    It 'outputs to a new file when the parameter is passed' {
        $Platform = "$TestDrive\$File"

        Edit-PASPlatform -PlatformId $PlatformId -FilePath $Platform -Path '/Properties/Optional' -Operation Add -ElementName 'Property' -ElementAttributes @{'Name' = 'Business Department' } -OutFile "$Platform-new"
        Test-Path -Path "$Platform-new"

    } -TestCases @(
        @{PlatformId = 'Oracle'; File = 'Policy-Oracle.xml' }
    )

    It 'throws an exception when the provided path returns no nodes' {
        $Platform = "$TestDrive\$File"

        { Edit-PASPlatform -PlatformId $PlatformId -FilePath $Platform -Path '/Properties/Optionall' -Operation Add -ElementName 'Property' -ElementAttributes @{'Name' = 'Business Department' } } | Should -Throw
    } -TestCases @(
        @{PlatformId = 'Oracle'; File = 'Policy-Oracle.xml' }
    )

    It 'accepts a list of platform IDs from the pipeline' {
        $PoliciesXml = "$TestDrive\Policies.xml"
        $PlatformIds = @('WinDomain', 'SchedTask', 'Oracle')

        $PlatformIds | Edit-PASPlatform -FilePath $PoliciesXml -Path '/Properties/Optional' -Operation Add -ElementName 'Property' -ElementAttributes @{'Name' = 'Description' }
        $Result = [xml] (Get-Content -Path $PoliciesXml)
        foreach ($Id in $PlatformIds) {
            Select-Xml -Xml $Result -XPath "//*[@ID='$Id']/Properties/Optional/Property[@Name='Description']" | Should -Be $true
        }
    }
    
    It 'handles root path correctly when adding an element' {
        $Platform = "$TestDrive\$File"
    
        Edit-PASPlatform -PlatformId $PlatformId -FilePath $Platform -Path '/' -Operation Add -ElementName 'RootElement' -ElementAttributes @{'Name' = 'RootProperty' }
    
        $Result = [xml] (Get-Content -Path $Platform)
        Select-Xml -Xml $Result -XPath "//*[@ID='$PlatformId']/RootElement[@Name='RootProperty']" | Should -Not -Be $null
    
    } -TestCases @(
        @{PlatformId = 'Oracle'; File = 'Policy-Oracle.xml' }
        @{PlatformId = 'SchedTask'; File = 'Policy-SchedTask.xml' }
        @{PlatformId = 'WinDomain'; File = 'Policies.xml' }
    )
    
    It 'handles root path correctly when deleting an element' {
        $Platform = "$TestDrive\$File"
    
        # First, add an element to the root to ensure it exists
        Edit-PASPlatform -PlatformId $PlatformId -FilePath $Platform -Path '/' -Operation Add -ElementName 'RootElement' -ElementAttributes @{'Name' = 'RootProperty' }
    
        # Now, delete the element from the root
        Edit-PASPlatform -PlatformId $PlatformId -FilePath $Platform -Path '/' -Operation Delete -ElementName 'RootElement' -ElementAttributes @{'Name' = 'RootProperty' }
    
        $Result = [xml] (Get-Content -Path $Platform)
        Select-Xml -Xml $Result -XPath "//*[@ID='$PlatformId']/RootElement[@Name='RootProperty']" | Should -Be $null
    
    } -TestCases @(
        @{PlatformId = 'Oracle'; File = 'Policy-Oracle.xml' }
        @{PlatformId = 'SchedTask'; File = 'Policy-SchedTask.xml' }
        @{PlatformId = 'WinDomain'; File = 'Policies.xml' }
    )
}    
