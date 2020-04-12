#
# Copyright 2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

Describe "Get Static Route" {
    BeforeALL {
        #Add a blackhole static route on vrf default
        Add-ArubaCXStaticRoutes -address_family ipv4 -prefix_ip4 $pester_sr_ip4 -prefix_ip4_mask $pester_sr_mask -type blackhole
    }

    It "Get Static Route Does not throw an error" {
        {
            Get-ArubaCXStaticRoutes
        } | Should Not Throw
    }

    It "Get ALL Static Route" {
        $sr = Get-ArubaCXStaticRoutes
        $sr.count | Should -Not -Be $NULL
    }

    It "Get Static Route ($pester_sr)" {
        $sr = Get-ArubaCXStaticRoutes -prefix $pester_sr
        $sr.prefix | Should -Be $pester_sr
    }

    It "Get Static Route ($pester_sr) and confirm (via Confirm-ArubaCXStaticRoutes)" {
        $sr = Get-ArubaCXStaticRoutes -prefix $pester_sr
        Confirm-ArubaCXStaticRoutes ($sr) | Should -Be $true
    }

    #Get with attribute, depth...
    Context "Selector" {

        It "Get Static Route with selector equal configuration" {
            {
                Get-ArubaCXStaticRoutes -selector configuration
            } | Should Not Throw
        }

        It "Get Static Route with selector equal statistics" {
            {
                Get-ArubaCXStaticRoutes -selector statistics
            } | Should Not Throw
        }

        It "Get Static Route with selector equal status" {
            {
                Get-ArubaCXStaticRoutes -selector status
            } | Should Not Throw
        }

        It "Get Static Route with selector equal writable" {
            {
                Get-ArubaCXStaticRoutes -selector writable
            } | Should Not Throw
        }
    }

    Context "Depth" {

        It "Get Static Route with depth equal 1" {
            {
                Get-ArubaCXStaticRoutes -depth 1
            } | Should Not Throw
        }

        It "Get Static Route with depth equal 2" {
            {
                Get-ArubaCXStaticRoutes -depth 2
            } | Should Not Throw
        }

        It "Get Static Route with depth equal 3" {
            {
                Get-ArubaCXStaticRoutes -depth 3
            } | Should Not Throw
        }

        It "Get Static Route with depth equal 4" {
            {
                Get-ArubaCXStaticRoutes -depth 4
            } | Should Not Throw
        }
    }

    Context "Attribute" {

        It "Get Static Route with one attribute (prefix)" {
            $sr = Get-ArubaCXStaticRoutes -prefix $pester_sr -attribute prefix
            @($sr).count | Should -be 1
            $sr.prefix | Should -Not -BeNullOrEmpty
        }

        It "Get Static Route with two attributes (prefix, type)" {
            $sr = Get-ArubaCXStaticRoutes -prefix $pester_sr -attribute prefix, type
            @($sr).count | Should -be 1
            $sr.prefix | Should -Not -BeNullOrEmpty
            $sr.type | Should -Not -BeNullOrEmpty
        }

    }

    Context "Search" {
        It "Search Static Route by name ($pester_sr)" {
            $sr = Get-ArubaCXStaticRoutes -prefix $pester_sr
            @($sr).count | Should -be 1
            $sr.prefix | Should -Be $pester_sr
        }

    }

    AfterAll {
        Get-ArubaCXStaticRoutes -prefix $pester_sr | Remove-ArubaCXStaticRoutes -confirm:$false
        #Reverse CheckPoint ?
    }
}

Describe "Add Static Route" {

    BeforeAll {
        #Add Vrf
        Add-ArubaCXVrfs -name $pester_vrf

    }

    AfterEach {
        Get-ArubaCXStaticRoutes -prefix $pester_sr | Remove-ArubaCXStaticRoutes -confirm:$false
        #Reverse CheckPoint ?
    }

    It "Add Static Route $pester_sr (type forward)" {
        Add-ArubaCXStaticRoutes -address_family ipv4 -prefix_ip4 $pester_sr_ip4 -prefix_ip4_mask $pester_sr_mask -type forward
        $sr = Get-ArubaCXStaticRoutes -prefix $pester_sr
        $sr.prefix | Should -Be $pester_sr
        $sr.address_family | Should -Be "ipv4"
        $sr.type | Should -Be "forward"
        $sr.vrf | Should -Be "default"
    }

    It "Add Static Route $pester_sr (type reject)" {
        Add-ArubaCXStaticRoutes -address_family ipv4 -prefix_ip4 $pester_sr_ip4 -prefix_ip4_mask $pester_sr_mask -type reject
        $sr = Get-ArubaCXStaticRoutes -prefix $pester_sr
        $sr.prefix | Should -Be $pester_sr
        $sr.address_family | Should -Be "ipv4"
        $sr.type | Should -Be "reject"
        $sr.vrf | Should -Be "default"
    }

    It "Add Static Route $pester_sr (type blackhole)" {
        Add-ArubaCXStaticRoutes -address_family ipv4 -prefix_ip4 $pester_sr_ip4 -prefix_ip4_mask $pester_sr_mask -type blackhole
        $sr = Get-ArubaCXStaticRoutes -prefix $pester_sr
        $sr.prefix | Should -Be $pester_sr
        $sr.address_family | Should -Be "ipv4"
        $sr.type | Should -Be "blackhole"
        $sr.vrf | Should -Be "default"
    }

    It "Add Static Route $pester_sr (type forward on $pester_vrf VRF)" {
        Add-ArubaCXStaticRoutes -address_family ipv4 -prefix_ip4 $pester_sr_ip4 -prefix_ip4_mask $pester_sr_mask -type forward -vrf $pester_vrf
        $sr = Get-ArubaCXStaticRoutes -prefix $pester_sr
        $sr.prefix | Should -Be $pester_sr
        $sr.address_family | Should -Be "ipv4"
        $sr.type | Should -Be "forward"
        $sr.vrf | Should -Be $pester_vrf
    }

    AfterAll {
        Get-ArubaCXVrfs -name $pester_vrf | Remove-ArubaCXVrfs -confirm:$false
    }
}

Describe "Remove Static Route" {

    BeforeEach {
        #Always add Static Route $pester_sr...
        Add-ArubaCXStaticRoutes -address_family ipv4 -prefix_ip4 $pester_sr_ip4 -prefix_ip4_mask $pester_sr_mask -type blackhole
    }

    It "Remove Static Route $pester_sr by prefix" {
        Remove-ArubaCXStaticRoutes -prefix $pester_sr -vrf default -confirm:$false
        $sr = Get-ArubaCXStaticRoutes
        $sr.$pester_sr | Should -Be $NULL
    }

    It "Remove Static Route $pester_sr by pipeline" {
        $sr = Get-ArubaCXStaticRoutes -prefix $pester_sr
        $sr | Remove-ArubaCXStaticRoutes -confirm:$false
        $sr = Get-ArubaCXStaticRoutes
        $sr.$pester_sr | Should -Be $NULL
    }

}

Disconnect-ArubaCX -confirm:$false