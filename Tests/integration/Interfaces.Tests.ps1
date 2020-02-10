#
# Copyright 2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

Describe  "Get Interfaces" {

    It "Get Interface Does not throw an error" {
        {
            Get-ArubaCXInterfaces
        } | Should Not Throw
    }

    It "Get ALL Interfaces" {
        $int = Get-ArubaCXInterfaces
        $int.count | Should not be $NULL
    }

    It "Get Interface ($pester_interface) and confirm (via Confirm-ArubaCXInterface)" {
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        Confirm-ArubaCXInterface $int | Should be $true
    }

    #Get with attribute, depth...
    Context "Selector" {

        It "Get Interface with selector equal configuration" {
            {
                Get-ArubaCXInterfaces -selector configuration
            } | Should Not Throw
        }

        It "Get Interface with selector equal statistics" {
            {
                Get-ArubaCXInterfaces -selector statistics
            } | Should Not Throw
        }

        It "Get Interface with selector equal status" {
            {
                Get-ArubaCXInterfaces -selector status
            } | Should Not Throw
        }

        It "Get Interface with selector equal writable" {
            {
                Get-ArubaCXInterfaces -selector writable
            } | Should Not Throw
        }
    }

    Context "Depth" {

        It "Get Interface with depth equal 1" {
            {
                Get-ArubaCXInterfaces -depth 1
            } | Should Not Throw
        }

        It "Get Interface with depth equal 2" {
            {
                Get-ArubaCXInterfaces -depth 2
            } | Should Not Throw
        }

        It "Get Interface with depth equal 3" {
            {
                Get-ArubaCXInterfaces -depth 3
            } | Should Not Throw
        }

        It "Get Interface with depth equal 4" {
            {
                Get-ArubaCXInterfaces -depth 4
            } | Should Not Throw
        }
    }

    Context "Attribute" {

        #Bug with ArubaCX 10.04.0001 OVA
        It "Get Interface with one attribute (admin)" -skip:$true {
            $int = Get-ArubaCXInterfaces -interface $pester_interface -attribute status
            @($int).count | Should -be 1
            $int.name | Should -BeNullOrEmpty
            $int.status | Should -Not -BeNullOrEmpty
        }

        #Bug with ArubaCX 10.04.0001 OVA
        It "Get Interface with two attributes (admin, name)" -skip:$true {
            $int = Get-ArubaCXInterfaces -interface $pester_interface -attribute admin, name
            @($int).count | Should -be 1
            $int.id | Should -BeNullOrEmpty
            $int.status | Should -Not -BeNullOrEmpty
            $int.name | Should -Be $pester_interface
        }

    }

    Context "Search" {
        It "Search Interface by interface ($pester_interface)" {
            $int = Get-ArubaCXInterfaces -interface $pester_interface
            @($int).count | Should be 1
            $int.name | Should be "$pester_interface"
        }
        It "Search Interface by interface (using position) ($pester_interface)" {
            $int = Get-ArubaCXInterfaces $pester_interface
            @($int).count | Should be 1
            $int.name | Should be "$pester_interface"
        }
    }
}


Describe  "Configure Interface" {
    BeforeAll {
        #Make a CheckPoint ?
    }

    It "Change interface description" {
        Set-ArubaCXInterfaces -interface $pester_interface -description "Modified by PowerArubaCX"
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        $int.name | Should be "$pester_interface"
        $int.description | Should be "Modified by PowerArubaCX"
    }

    It "Change interface status (up)" {
        Set-ArubaCXInterfaces -interface $pester_interface -admin up
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        $int.user_config.admin | Should be "up"
    }

    It "Change interface status (down)" {
        Set-ArubaCXInterfaces -interface $pester_interface -admin down
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        $int.user_config.admin | Should be "down"
    }

    It "Change interface routing (disable)" {
        Set-ArubaCXInterfaces -interface $pester_interface -routing:$false
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        $int.routing | Should be $false
    }

    It "Change interface routing (enable)" {
        Set-ArubaCXInterfaces -interface $pester_interface -routing:$true
        $int = Get-ArubaCXInterfaces -interface $pester_interface
        $int.routing | Should be $true
    }

    AfterAll {
        #Reverse CheckPoint ?
    }
}

Disconnect-ArubaCX -noconfirm