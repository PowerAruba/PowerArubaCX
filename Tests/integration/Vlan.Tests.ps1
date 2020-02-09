#
# Copyright 2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

Describe  "Get Vlan" {
    BeforeALL {
        Add-ArubaCXVlan -id $pester_vlan -name pester_vlan
    }

    It "Get Vlan Does not throw an error" {
        {
            Get-ArubaCXVlan
        } | Should Not Throw
    }

    It "Get ALL Vlan" {
        $vlan = Get-ArubaCXVlan
        $vlan.count | Should not be $NULL
    }

    It "Get Vlan ($pester_vlan)" {
        $vlan = Get-ArubaCXVlan -id $pester_vlan
        $vlan.id | Should -Be $pester_vlan
        $vlan.name | Should -Be "pester_vlan"
    }

    It "Get Vlan ($pester_vlan) and confirm (via Confirm-ArubaCXVlan)" {
        $vlan = Get-ArubaCXVlan -id $pester_vlan
        Confirm-ArubaCXVlan ($vlan) | Should be $true
    }

    #Get with attribute, depth...
    Context "Selector" {

        It "Get Vlan with selector equal configuration" {
            {
                Get-ArubaCXVlan -selector configuration
            } | Should Not Throw
        }

        It "Get Vlan with selector equal statistics" {
            {
                Get-ArubaCXVlan -selector statistics
            } | Should Not Throw
        }

        It "Get Vlan with selector equal status" {
            {
                Get-ArubaCXVlan -selector status
            } | Should Not Throw
        }

        It "Get Vlan with selector equal writable" {
            {
                Get-ArubaCXVlan -selector writable
            } | Should Not Throw
        }
    }

    Context "Depth" {

        It "Get Vlan with depth equal 1" {
            {
                Get-ArubaCXVlan -depth 1
            } | Should Not Throw
        }

        It "Get Vlan with depth equal 2" {
            {
                Get-ArubaCXVlan -depth 2
            } | Should Not Throw
        }

        It "Get Vlan with depth equal 3" {
            {
                Get-ArubaCXVlan -depth 3
            } | Should Not Throw
        }

        It "Get Vlan with depth equal 4" {
            {
                Get-ArubaCXVlan -depth 4
            } | Should Not Throw
        }
    }

    Context "Attribute" {

        It "Get Vlan with one attribute (admin)" {
            $vlan = Get-ArubaCXVlan -id $pester_vlan -attribute admin
            @($vlan).count | Should -be 1
            $vlan.id | Should -BeNullOrEmpty
            $vlan.admin | Should -Not -BeNullOrEmpty
        }

        It "Get Vlan with two attributes (admin, name)" {
            $vlan = Get-ArubaCXVlan -id $pester_vlan -attribute admin, name
            @($vlan).count | Should -be 1
            $vlan.id | Should -BeNullOrEmpty
            $vlan.admin | Should -Not -BeNullOrEmpty
            $vlan.name | Should -Be "pester_vlan"
        }

    }

    It "Search Vlan by name ($pester_vlan)" {
        $vlan = Get-ArubaCXVlan -id $pester_vlan
        @($vlan).count | Should -be 1
        $vlan.id | Should -Be $pester_vlan
        $vlan.name | Should -Be "pester_vlan"
    }

    It "Search Vlan by name (pester_vlan)" {
        $vlan = Get-ArubaCXVlan -name pester_vlan
        @($vlan).count | Should -be 1
        $vlan.id | Should -Be $pester_vlan
        $vlan.name | Should -be "pester_vlan"
    }

    AfterAll {
        Get-ArubaCXVlan -id $pester_vlan | Remove-ArubaCXVlan -confirm:$false
        #Reverse CheckPoint ?
    }
}

Describe  "Configure Vlan" {
    BeforeAll {
        Add-ArubaCXVlan -id $pester_vlan -name pester_vlan
        #Make a CheckPoint ?
    }

    It "Change Vlan name and description" {
        Get-ArubaCXVlan -id $pester_vlan | Set-ArubaCXVlan -name pester_vlan2 -description "Modified by PowerArubaCX"
        $vlan = Get-ArubaCXVlan -id $pester_vlan
        $vlan.name | Should be "pester_vlan2"
        $vlan.description | Should be "Modified by PowerArubaCX"
    }

    It "Change Vlan description using -use_pipeline" {
        $vlan = Get-ArubaCXVlan -id $pester_vlan -selector writable
        $vlan.description = "Modified by PowerArubaCX using -use_pipeline"
        $vlan | Set-ArubaCXVlan -use_pipeline
        $vlan = Get-ArubaCXVlan -id $pester_vlan
        $vlan.description | Should be "Modified by PowerArubaCX using -use_pipeline"
    }

    It "Change Vlan status (down)" {
        Get-ArubaCXVlan -id $pester_vlan | Set-ArubaCXVlan -admin down
        $vlan = Get-ArubaCXVlan -id $pester_vlan
        $vlan.admin | Should be "down"
    }

    It "Change Vlan status (up)" {
        Get-ArubaCXVlan -id $pester_vlan | Set-ArubaCXVlan -admin up
        $vlan = Get-ArubaCXVlan -id $pester_vlan
        $vlan.admin | Should be "up"
    }

    It "Change Vlan voice (enable)" {
        Get-ArubaCXVlan -id $pester_vlan | Set-ArubaCXVlan -voice:$true
        $vlan = Get-ArubaCXVlan -id $pester_vlan
        $vlan.voice | Should be $true
    }

    It "Change Vlan voice (disable)" {
        Get-ArubaCXVlan -id $pester_vlan | Set-ArubaCXVlan -voice:$false
        $vlan = Get-ArubaCXVlan -id $pester_vlan
        $vlan.voice | Should be $false
    }

    It "Change Vlan vsx_sync (enable)" {
        Get-ArubaCXVlan -id $pester_vlan | Set-ArubaCXVlan -vsx_sync:$true
        $vlan = Get-ArubaCXVlan -id $pester_vlan
        $vlan.vsx_sync | Should be $true
    }

    It "Change Vlan vsx_sync (disable)" {
        Get-ArubaCXVlan -id $pester_vlan | Set-ArubaCXVlan -vsx_sync:$false
        $vlan = Get-ArubaCXVlan -id $pester_vlan
        $vlan.vsx_sync | Should be $null
    }


    AfterAll {
        Get-ArubaCXVlan -id $pester_vlan | Remove-ArubaCXVlan -confirm:$false
        #Reverse CheckPoint ?
    }
}

Disconnect-ArubaCX -noconfirm