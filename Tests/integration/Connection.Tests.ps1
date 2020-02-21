#
# Copyright 2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1


Describe  "Connect to a switch (using HTTPS)" {
    BeforeAll {
        #Disconnect "default connection"
        Disconnect-ArubaCX -confirm:$false
    }
    It "Connect to a switch (using HTTPS and -SkipCertificateCheck) and check global variable" {
        Connect-ArubaCX $ipaddress -Username $login -password $mysecpassword -SkipCertificateCheck
        $DefaultArubaCXConnection | Should -Not -BeNullOrEmpty
        $DefaultArubaCXConnection.server | Should -Be $ipaddress
        $DefaultArubaCXConnection.port | Should -Be "443"
        $DefaultArubaCXConnection.session | Should -Not -BeNullOrEmpty
    }
    It "Disconnect to a switch (using HTTPS) and check global variable" {
        Disconnect-ArubaCX -confirm:$false
        $DefaultArubaCXConnection | Should -Be $null
    }
    #This test only work with PowerShell 6 / Core (-SkipCertificateCheck don't change global variable but only Invoke-WebRequest/RestMethod)
    #This test will be fail, if there is valid certificate...
    It "Connect to a switch (using HTTPS) and check global variable" -Skip:("Desktop" -eq $PSEdition) {
        { Connect-ArubaCX $ipaddress -Username $login -password $mysecpassword } | Should throw "Unable to connect (certificate)"
    }
}

Describe  "Connect to a switch (using multi connection)" {
    It "Connect to a switch (using HTTPS and store on cx variable)" {
        $script:cx = Connect-ArubaCX $ipaddress -Username $login -password $mysecpassword -SkipCertificate -DefaultConnection:$false
        $DefaultArubaCXConnection | Should -BeNullOrEmpty
        $cx.server | Should -Be $ipaddress
        $cx.port | Should -Be "443"
        $cx.session | Should -Not -BeNullOrEmpty
    }

    It "Throw when try to use Invoke-ArubaCPRestMethod and not connected" {
        { Invoke-ArubaCXRestMethod -uri "rest/v1/system" } | Should throw "Not Connected. Connect to the Switch with Connect-ArubaCX"
    }

    Context "Use Multi connection for call some (Get) cmdlet (Vlan, System...)" {
        It "Use Multi connection for call Get interfaces" {
            { Get-ArubaCXinterfaces -connection $cx } | Should Not throw
        }
        It "Use Multi connection for call Get LLDP Neighbor" {
            { Get-ArubaCXLLDPNeighbor 1/1/1 -connection $cx } | Should Not throw
        }
        It "Use Multi connection for call Get System" {
            { Get-ArubaCXSystem -connection $cx } | Should Not throw
        }
        It "Use Multi connection for call Get Vlans" {
            { Get-ArubaCXVlans -connection $cx } | Should Not throw
        }
    }

    It "Disconnect to a switch (Multi connection)" {
        Disconnect-ArubaCX -connection $cx -confirm:$false
        $DefaultArubaCXConnection | Should -Be $null
    }

}