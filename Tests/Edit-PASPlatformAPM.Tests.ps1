BeforeAll {
    . $PSScriptRoot/../Edit-PASPlatformAPM.ps1

    Copy-Item *.ini $TestDrive
}

Describe 'Edit-PASPlatformAPM' {
    It 'updates an existing property in <File>' {
        # arrange
        $Platform = "$TestDrive\$File"
        $ExpectedValue = '91'
        # act
        Edit-PASPlatformAPM -FilePath $Platform -Property 'MinDelayBetweenRetries' -Value 91
        # assert
        $UpdatePlatformContent = Get-IniContent -FilePath $Platform
        $UpdatePlatformContent['_']['MinDelayBetweenRetries'] | Should -BeExactly $ExpectedValue
    } -TestCases @(
        @{File = 'Policy-Oracle.ini' }
        @{File = 'Policy-SchedTask.ini' }
        @{File = 'Policy-WinDomain.ini' }
    )

    It 'takes APM .ini files from the pipeline' {
        # arrange
        $ExpectedValue = '91'
        $Files = Get-ChildItem -Path $TestDrive\*.ini
        # act
        $Files | Edit-PASPlatformAPM -Property 'MinDelayBetweenRetries' -Value 91
        # assert
        foreach ($File in $Files) {
            $UpdatePlatformContent = Get-IniContent -FilePath $File
            $UpdatePlatformContent['_']['MinDelayBetweenRetries'] | Should -BeExactly $ExpectedValue
        }
    }
}