#
# Copyright 2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1


Describe "Connect to a switch (using HTTPS)" {
    It "Connect to a switch (using HTTPS and -SkipCertificateCheck) and check global variable" {
        Connect-ArubaCX @invokeParams
        $DefaultArubaCXConnection | Should -Not -BeNullOrEmpty
        $DefaultArubaCXConnection.server | Should -Be $ipaddress
        $DefaultArubaCXConnection.platform_name | Should -Not -BeNullOrEmpty
        $DefaultArubaCXConnection.port | Should -Be "443"
        $DefaultArubaCXConnection.session | Should -Not -BeNullOrEmpty
        $DefaultArubaCXConnection.api_version | Should -Not -BeNullOrEmpty
        $DefaultArubaCXConnection.version | Should -Not -BeNullOrEmpty
        $DefaultArubaCXConnection.version.major | Should -Be "10"
        $DefaultArubaCXConnection.version.minor | Should -BeIn (4..11)
        $DefaultArubaCXConnection.version.revision | Should -Not -BeNullOrEmpty
    }
    It "Disconnect to a switch (using HTTPS) and check global variable" {
        Disconnect-ArubaCX -confirm:$false
        $DefaultArubaCXConnection | Should -Be $null
    }
    #This test only work with PowerShell 6 / Core (-SkipCertificateCheck don't change global variable but only Invoke-WebRequest/RestMethod)
    #This test will be fail, if there is valid certificate...
    It "Connect to a switch (using HTTPS) and check global variable" -Skip:("Desktop" -eq $PSEdition) {
        { Connect-ArubaCX $invokeParams.server -Username $invokeParams.username -password $invokeParams.password } | Should -Throw "Unable to connect (certificate)"
    }
}

Describe "Connect to a switch (using multi connection)" {
    It "Connect to a switch (using HTTPS and store on cx variable)" {
        $script:cx = Connect-ArubaCX @invokeParams -DefaultConnection:$false
        $DefaultArubaCXConnection | Should -BeNullOrEmpty
        $cx.server | Should -Be $ipaddress
        $cx.platform_name | Should -Not -BeNullOrEmpty
        $cx.port | Should -Be "443"
        $cx.session | Should -Not -BeNullOrEmpty
        $cx.api_version | Should -Not -BeNullOrEmpty
        $cx.version | Should -Not -BeNullOrEmpty
        $cx.version.major | Should -Be "10"
        $cx.version.minor | Should -BeIn (4..11)
        $cx.version.revision | Should -Not -BeNullOrEmpty
    }

    It "Throw when try to use Invoke-ArubaCPRestMethod and not connected" {
        { Invoke-ArubaCXRestMethod -uri "rest/v10.08/system" } | Should -Throw "Not Connected. Connect to the Switch with Connect-ArubaCX"
    }

    Context "Use Multi connection for call some (Get) cmdlet (Vlan, System...)" {
        It "Use Multi connection for call Get Firmware" {
            { Get-ArubaCXFirmware -connection $cx } | Should -Not -Throw
        }
        It "Use Multi connection for call Get Interfaces" {
            { Get-ArubaCXInterfaces -connection $cx } | Should -Not -Throw
        }
        It "Use Multi connection for call Get LLDP Neighbor" {
            { Get-ArubaCXLLDPNeighbor 1/1/1 -connection $cx } | Should -Not -Throw
        }
        It "Use Multi connection for call Get System" {
            { Get-ArubaCXSystem -connection $cx } | Should -Not -Throw
        }
        It "Use Multi connection for call Get User" {
            { Get-ArubaCXUsers -connection $cx } | Should -Not -Throw
        }
        It "Use Multi connection for call Get Vlans" {
            { Get-ArubaCXVlans -connection $cx } | Should -Not -Throw
        }
        It "Use Multi connection for call Get Vrfs" {
            { Get-ArubaCXVrfs -connection $cx } | Should -Not -Throw
        }
    }

    It "Disconnect to a switch (Multi connection)" {
        Disconnect-ArubaCX -connection $cx -confirm:$false
        $DefaultArubaCXConnection | Should -Be $null
    }

}