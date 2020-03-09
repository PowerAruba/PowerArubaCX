#
# Copyright 2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

Describe  "Get Vrf" {
    BeforeALL {
        Add-ArubaCXVrfs -name $pester_vrf
    }

    It "Get Vrf Does not throw an error" {
        {
            Get-ArubaCXVrfs
        } | Should Not Throw
    }

    It "Get ALL Vrf" {
        $vrf = Get-ArubaCXVrfs
        $vrf.count | Should -Not -Be $NULL
    }

    It "Get Vrf ($pester_vrf)" {
        $vrf = Get-ArubaCXVrfs -name $pester_vrf
        $vrf.name | Should -Be $pester_vrf
    }

    It "Get Vrf ($pester_vrf) and confirm (via Confirm-ArubaCXVrfs)" {
        $vrf = Get-ArubaCXVrfs -name $pester_vrf
        Confirm-ArubaCXVrfs ($vrf) | Should -Be $true
    }

    #Get with attribute, depth...
    Context "Selector" {

        It "Get Vrf with selector equal configuration" {
            {
                Get-ArubaCXVrfs -selector configuration
            } | Should Not Throw
        }

        It "Get Vrf with selector equal statistics" {
            {
                Get-ArubaCXVrfs -selector statistics
            } | Should Not Throw
        }

        It "Get Vrf with selector equal status" {
            {
                Get-ArubaCXVrfs -selector status
            } | Should Not Throw
        }

        It "Get Vrf with selector equal writable" {
            {
                Get-ArubaCXVrfs -selector writable
            } | Should Not Throw
        }
    }

    Context "Depth" {

        It "Get Vrf with depth equal 1" {
            {
                Get-ArubaCXVrfs -depth 1
            } | Should Not Throw
        }

        It "Get Vrf with depth equal 2" {
            {
                Get-ArubaCXVrfs -depth 2
            } | Should Not Throw
        }

        It "Get Vrf with depth equal 3" {
            {
                Get-ArubaCXVrfs -depth 3
            } | Should Not Throw
        }

        It "Get Vrf with depth equal 4" {
            {
                Get-ArubaCXVrfs -depth 4
            } | Should Not Throw
        }
    }

    Context "Attribute" {

        It "Get Vrf with one attribute (name)" {
            $vrf = Get-ArubaCXVrfs -name $pester_vrf -attribute name
            @($vrf).count | Should -be 1
            $vrf.name | Should -Not -BeNullOrEmpty
        }

        It "Get Vrf with two attributes (name, rd)" {
            $vrf = Get-ArubaCXVrfs -name $pester_vrf -attribute name, rd
            @($vrf).count | Should -be 1
            $vrf.rf | Should -BeNullOrEmpty
            $vrf.name | Should -Not -BeNullOrEmpty
        }

    }

    Context "Search" {
        It "Search Vrf by name ($pester_vrf)" {
            $vrf = Get-ArubaCXVrfs -name $pester_vrf
            @($vrf).count | Should -be 1
            $vrf.name | Should -Be $pester_vrf
        }

        It "Search Vrf by name (pester_vrf)" {
            $vrf = Get-ArubaCXVrfs -name pester_vrf
            @($vrf).count | Should -be 1
            $vrf.name | Should -Be $pester_vrf
        }
    }

    AfterAll {
        Get-ArubaCXVrfs -name $pester_vrf | Remove-ArubaCXVrfs -confirm:$false
        #Reverse CheckPoint ?
    }
}

Describe "Add Vrf" {

    AfterEach {
        Get-ArubaCXVrfs -name $pester_vrf -ErrorAction SilentlyContinue | Remove-ArubaCXVrfs -confirm:$false -ErrorAction SilentlyContinue
        #Reverse CheckPoint ?
    }

    It "Add Vrf $pester_vrf (with only a name)" {
        Add-ArubaCXVrfs -name $pester_vrf
        $vrf = Get-ArubaCXVrfs -name $pester_vrf
        $vrf.name | Should -Be $pester_vrf
        $vrf.rd | Should -Be $null
        $vrf.type | Should -Be "user"
        $vrf.snmp_enable | Should -Be $false
        $vrf.ssh_enable | Should -BeNullOrEmpty
        $vrf.https_server | Should -BeNullOrEmpty
    }

    It "Add Vrf $pester_vrf (with a name and rd)" {
        Add-ArubaCXVrfs -name $pester_vrf -rd 65001:1
        $vrf = Get-ArubaCXVrfs -name $pester_vrf
        $vrf.name | Should -Be $pester_vrf
        $vrf.rd | Should -Be "65001:1"
        $vrf.type | Should -Be "user"
        $vrf.snmp_enable | Should -Be $false
        $vrf.ssh_enable | Should -BeNullOrEmpty
        $vrf.https_server | Should -BeNullOrEmpty
    }

    It "Add Vrf $pester_vrf (with a name and enable https/ssh/snmp)" {
        Add-ArubaCXVrfs -name $pester_vrf -snmp_enable -ssh_enable -https_server
        $vrf = Get-ArubaCXVrfs -name $pester_vrf
        $vrf.name | Should -Be $pester_vrf
        $vrf.rd | Should -Be $null
        $vrf.type | Should -Be "user"
        $vrf.snmp_enable | Should -Be $true
        $vrf.ssh_enable | Should -Be $true
        $vrf.https_server.enable | Should -Be $true
    }
}

Describe  "Configure Vrf" {
    BeforeAll {
        Add-ArubaCXVrfs -name $pester_vrf
        #Make a CheckPoint ?
    }

    It "Change Vrf RD" {
        Get-ArubaCXVrfs -name $pester_vrf | Set-ArubaCXVrfs -rd 65001:1
        $vrf = Get-ArubaCXVrfs -name $pester_vrf
        $vrf.name | Should -Be $pester_vrf
        $vrf.rd | Should -Be "65001:1"
    }

    It "Change Vrf rd using -use_pipeline" {
        $vrf = Get-ArubaCXVrfs -name $pester_vrf -selector writable
        $vrf.rd = "65001:2"
        $vrf | Set-ArubaCXVrfs -use_pipeline
        $vrf = Get-ArubaCXVrfs -name $pester_vrf
        $vrf.rd | Should -Be "65001:2"
    }

    It "Change Vrf https_server (enable)" {
        Get-ArubaCXVrfs -name $pester_vrf | Set-ArubaCXVrfs -https_server
        $vrf = Get-ArubaCXVrfs -name $pester_vrf
        $vrf.https_server.enable | Should -Be $true
    }

    It "Change Vrf http_server (disable)" {
        Get-ArubaCXVrfs -name $pester_vrf | Set-ArubaCXVrfs -https_server:$false
        $vrf = Get-ArubaCXVrfs -name $pester_vrf
        $vrf.https_server | Should -BeNullOrEmpty
    }

    It "Change Vrf snmp/ssh (enable)" {
        Get-ArubaCXVrfs -name $pester_vrf | Set-ArubaCXVrfs -snmp_enable -ssh_enable
        $vrf = Get-ArubaCXVrfs -name $pester_vrf
        $vrf.snmp_enable | Should -Be $true
        $vrf.ssh_enable | Should -Be $true
    }

    It "Change Vrf snmp/ssh (disable)" {
        Get-ArubaCXVrfs -name $pester_vrf | Set-ArubaCXVrfs -snmp_enable:$false -ssh_enable:$false
        $vrf = Get-ArubaCXVrfs -name $pester_vrf
        $vrf.snmp_enable | Should -Be $false
        $vrf.ssh_enable | Should -Be $false
    }

    AfterAll {
        Get-ArubaCXVrfs -name $pester_vrf | Remove-ArubaCXVrfs -confirm:$false
        #Reverse CheckPoint ?
    }
}

Describe  "Remove Vrf" {

    BeforeEach {
        #Always add Vrf $pester_vrf...
        Add-ArubaCXVrfs -name $pester_vrf
    }

    It "Remove Vrf $pester_vrf by id" {
        Remove-ArubaCXVrfs -name $pester_vrf -confirm:$false
        $vrf = Get-ArubaCXVrfs
        $vrf.$pester_vrf | Should -Be $NULL
    }

    It "Remove Vrf $pester_vrf by pipeline" {
        $vrf = Get-ArubaCXVrfs -name $pester_vrf
        $vrf | Remove-ArubaCXVrfs -confirm:$false
        $vrf = Get-ArubaCXVrfs
        $vrf.$pester_vrf | Should -Be $NULL
    }

}

Disconnect-ArubaCX -confirm:$false