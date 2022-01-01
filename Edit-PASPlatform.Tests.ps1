BeforeAll {
    . $PSScriptRoot/Edit-PASPlatform.ps1

    Copy-Item *.xml $TestDrive
}

Describe 'Edit-PASPlatform' {
    It 'adds a new property to <File> for platform <PlatformId>' {
        $Platform = "$TestDrive\$File"

        Edit-PASPlatform -PlatformId $PlatformId -FilePath $Platform -Path '/Properties/Optional' -Operation Add -ElementName 'Property' -ElementAttributes @{'Name' = 'Business Department'}

        $Result = [xml] (Get-Content -Path $Platform)
        Select-Xml -Xml $Result -XPath "//*[@ID='$PlatformId']/Properties/Optional/Property[@Name='Business Department'][1]" | Should -Be $true

    } -TestCases @(
        @{PlatformId = 'Oracle'; File = 'Policy-Oracle.xml'}
        @{PlatformId = 'SchedTask'; File = 'Policy-SchedTask.xml'}
        @{PlatformId = 'WinDomain'; File = 'Policies.xml'}
    )

    It 'updates an existing property' {
    }

    It 'deletes an existing property in <File> for platform <PlatformId>' {
        $Platform = "$TestDrive\$File"

        Edit-PASPlatform -PlatformId $PlatformId -FilePath $Platform -Path '/Properties/Required' -Operation Delete -ElementName 'Property' -ElementAttributes @{'Name' = 'Username'}

        $Result = [xml] (Get-Content -Path $Platform)
        Select-Xml -Xml $Result -XPath "//*[@ID='$PlatformId']/Properties/Required/Property[@Name='Username'][1]" | Should -Be $null
    } -TestCases @(
        @{PlatformId = 'Oracle'; File = 'Policy-Oracle.xml'}
        @{PlatformId = 'WinDomain'; File = 'Policies.xml'}
    )

    It 'outputs to a new file when the parameter is passed' {
        $Platform = "$TestDrive\$File"

        Edit-PASPlatform -PlatformId $PlatformId -FilePath $Platform -Path '/Properties/Optional' -Operation Add -ElementName 'Property' -ElementAttributes @{'Name' = 'Business Department'} -OutFile "$Platform-new"
        Test-Path -Path "$Platform-new"

    } -TestCases @(
        @{PlatformId = 'Oracle'; File = 'Policy-Oracle.xml'}
    )

    It 'throws an exception when the provided path returns no nodes' {
        $Platform = "$TestDrive\$File"

        { Edit-PASPlatform -PlatformId $PlatformId -FilePath $Platform -Path '/Properties/Optionall' -Operation Add -ElementName 'Property' -ElementAttributes @{'Name' = 'Business Department'} } | Should -Throw
    } -TestCases @(
        @{PlatformId = 'Oracle'; File = 'Policy-Oracle.xml'}
    )
}