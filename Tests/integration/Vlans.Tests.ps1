#
# Copyright 2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

BeforeAll {
    Connect-ArubaCX @invokeParams
}

Describe "Get Vlan" {
    BeforeALL {
        Add-ArubaCXVlans -id $pester_vlan -name pester_vlan
    }

    It "Get Vlan Does not throw an error" {
        {
            Get-ArubaCXVlans
        } | Should -Not -Throw
    }

    It "Get ALL Vlan" {
        $vlan = Get-ArubaCXVlans
        $vlan.count | Should -Not -Be $NULL
    }

    It "Get Vlan ($pester_vlan)" {
        $vlan = Get-ArubaCXVlans -id $pester_vlan
        $vlan.id | Should -Be $pester_vlan
        $vlan.name | Should -Be "pester_vlan"
    }

    It "Get Vlan ($pester_vlan) and confirm (via Confirm-ArubaCXVlans)" {
        $vlan = Get-ArubaCXVlans -id $pester_vlan
        Confirm-ArubaCXVlans ($vlan) | Should -Be $true
    }

    #Get with attribute, depth...
    Context "Selector" {

        It "Get Vlan with selector equal configuration" {
            {
                Get-ArubaCXVlans -selector configuration
            } | Should -Not -Throw
        }

        It "Get Vlan with selector equal statistics" {
            {
                Get-ArubaCXVlans -selector statistics
            } | Should -Not -Throw
        }

        It "Get Vlan with selector equal status" {
            {
                Get-ArubaCXVlans -selector status
            } | Should -Not -Throw
        }

        It "Get Vlan with selector equal writable" {
            {
                Get-ArubaCXVlans -selector writable
            } | Should -Not -Throw
        }
    }

    Context "Depth" {

        It "Get Vlan with depth equal 1" {
            {
                Get-ArubaCXVlans -depth 1
            } | Should -Not -Throw
        }

        It "Get Vlan with depth equal 2" {
            {
                Get-ArubaCXVlans -depth 2
            } | Should -Not -Throw
        }

        It "Get Vlan with depth equal 3" {
            {
                Get-ArubaCXVlans -depth 3
            } | Should -Not -Throw
        }

        It "Get Vlan with depth equal 4" {
            {
                Get-ArubaCXVlans -depth 4
            } | Should -Not -Throw
        }
    }

    Context "Attribute" {

        It "Get Vlan with one attribute (admin)" {
            $vlan = Get-ArubaCXVlans -id $pester_vlan -attribute admin
            @($vlan).count | Should -be 1
            $vlan.id | Should -BeNullOrEmpty
            $vlan.admin | Should -Not -BeNullOrEmpty
        }

        It "Get Vlan with two attributes (admin, name)" {
            $vlan = Get-ArubaCXVlans -id $pester_vlan -attribute admin, name
            @($vlan).count | Should -be 1
            $vlan.id | Should -BeNullOrEmpty
            $vlan.admin | Should -Not -BeNullOrEmpty
            $vlan.name | Should -Be "pester_vlan"
        }

    }

    Context "Search" {
        It "Search Vlan by name ($pester_vlan)" {
            $vlan = Get-ArubaCXVlans -id $pester_vlan
            @($vlan).count | Should -be 1
            $vlan.id | Should -Be $pester_vlan
            $vlan.name | Should -Be "pester_vlan"
        }

        It "Search Vlan by name (pester_vlan)" {
            $vlan = Get-ArubaCXVlans -name pester_vlan
            @($vlan).count | Should -be 1
            $vlan.id | Should -Be $pester_vlan
            $vlan.name | Should -Be "pester_vlan"
        }
    }

    AfterAll {
        Get-ArubaCXVlans -id $pester_vlan | Remove-ArubaCXVlans -confirm:$false
        #Reverse CheckPoint ?
    }
}

Describe "Add Vlan" {

    AfterEach {
        Get-ArubaCXVlans -id $pester_vlan -ErrorAction SilentlyContinue | Remove-ArubaCXVlans -confirm:$false -ErrorAction SilentlyContinue
        #Reverse CheckPoint ?
    }

    It "Add Vlan $pester_vlan (with only a id and name PowerArubaCX)" {
        Add-ArubaCXVlans -id $pester_vlan -name PowerArubaCX
        $vlan = Get-ArubaCXVlans -id $pester_vlan
        $vlan.id | Should -Be $pester_vlan
        $vlan.name | Should -Be "PowerArubaCX"
        $vlan.description | Should -Be $null
        $vlan.type | Should -Be "static"
        $vlan.voice | Should -Be $false
        $vlan.admin | Should -Be "up"
        $vlan.vsx_sync | Should -Be $Null
    }

    It "Add Vlan $pester_vlan (with a id, name, description and enable voice)" {
        Add-ArubaCXVlans -id $pester_vlan -name PowerArubaCX -description "Add via PowerArubaCX" -voice
        $vlan = Get-ArubaCXVlans -id $pester_vlan
        $vlan.id | Should -Be $pester_vlan
        $vlan.name | Should -Be "PowerArubaCX"
        $vlan.description | Should -Be "Add via PowerArubaCX"
        $vlan.type | Should -Be "static"
        $vlan.voice | Should -Be $true
        $vlan.admin | Should -Be "up"
        $vlan.vsx_sync | Should -Be $Null
    }

    It "Add Vlan $pester_vlan (with only a id, name, admin stats to down and enable vsx_sync)" {
        Add-ArubaCXVlans -id $pester_vlan -name PowerArubaCX -admin down -vsx_sync
        $vlan = Get-ArubaCXVlans -id $pester_vlan
        $vlan.id | Should -Be $pester_vlan
        $vlan.name | Should -Be "PowerArubaCX"
        $vlan.description | Should -Be $null
        $vlan.type | Should -Be "static"
        $vlan.voice | Should -Be $false
        $vlan.admin | Should -Be "down"
        $vlan.vsx_sync | Should -Be $true
    }
}

Describe "Configure Vlan" {
    BeforeAll {
        Add-ArubaCXVlans -id $pester_vlan -name pester_vlan
        #Make a CheckPoint ?
    }

    It "Change Vlan name and description" {
        Get-ArubaCXVlans -id $pester_vlan | Set-ArubaCXVlans -name pester_vlan2 -description "Modified by PowerArubaCX"
        $vlan = Get-ArubaCXVlans -id $pester_vlan
        $vlan.name | Should -Be "pester_vlan2"
        $vlan.description | Should -Be "Modified by PowerArubaCX"
    }

    It "Change Vlan description using -use_pipeline" {
        $vlan = Get-ArubaCXVlans -id $pester_vlan -selector writable
        $vlan.description = "Modified by PowerArubaCX using -use_pipeline"
        $vlan | Set-ArubaCXVlans -use_pipeline
        $vlan = Get-ArubaCXVlans -id $pester_vlan
        $vlan.description | Should -Be "Modified by PowerArubaCX using -use_pipeline"
    }

    It "Change Vlan status (down)" {
        Get-ArubaCXVlans -id $pester_vlan | Set-ArubaCXVlans -admin down
        $vlan = Get-ArubaCXVlans -id $pester_vlan
        $vlan.admin | Should -Be "down"
    }

    It "Change Vlan status (up)" {
        Get-ArubaCXVlans -id $pester_vlan | Set-ArubaCXVlans -admin up
        $vlan = Get-ArubaCXVlans -id $pester_vlan
        $vlan.admin | Should -Be "up"
    }

    It "Change Vlan voice (enable)" {
        Get-ArubaCXVlans -id $pester_vlan | Set-ArubaCXVlans -voice:$true
        $vlan = Get-ArubaCXVlans -id $pester_vlan
        $vlan.voice | Should -Be $true
    }

    It "Change Vlan voice (disable)" {
        Get-ArubaCXVlans -id $pester_vlan | Set-ArubaCXVlans -voice:$false
        $vlan = Get-ArubaCXVlans -id $pester_vlan
        $vlan.voice | Should -Be $false
    }

    It "Change Vlan vsx_sync (enable)" {
        Get-ArubaCXVlans -id $pester_vlan | Set-ArubaCXVlans -vsx_sync:$true
        $vlan = Get-ArubaCXVlans -id $pester_vlan
        $vlan.vsx_sync | Should -Be $true
    }

    It "Change Vlan vsx_sync (disable)" {
        Get-ArubaCXVlans -id $pester_vlan | Set-ArubaCXVlans -vsx_sync:$false
        $vlan = Get-ArubaCXVlans -id $pester_vlan
        $vlan.vsx_sync | Should -Be $null
    }


    AfterAll {
        Get-ArubaCXVlans -id $pester_vlan | Remove-ArubaCXVlans -confirm:$false
        #Reverse CheckPoint ?
    }
}

Describe "Remove vlan" {

    BeforeEach {
        #Always add vlan $pester_vlan...
        Add-ArubaCXVlans -id $pester_vlan -name PowerArubaCX
    }

    It "Remove vlan $pester_vlan by id" {
        Remove-ArubaCXVlans -id $pester_vlan -confirm:$false
        $vlan = Get-ArubaCXVlans
        $vlan.$pester_vlan | Should -Be $NULL
    }

    It "Remove vlan $pester_vlan by pipeline" {
        $vlan = Get-ArubaCXVlans -id $pester_vlan
        $vlan | Remove-ArubaCXVlans -confirm:$false
        $vlan = Get-ArubaCXVlans
        $vlan.$pester_vlan | Should -Be $NULL
    }

}

AfterAll {
    Disconnect-ArubaCX -confirm:$false
}