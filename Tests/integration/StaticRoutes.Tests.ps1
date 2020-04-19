#
# Copyright 2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

Describe "Get Static Route" {

    Context "Get Static Route on VRF: default" {

        BeforeAll {
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
        }
    }

    Context "Get Static Route on VRF: $pester_vrf" {

        BeforeAll {
            #Add Vrf
            Add-ArubaCXVrfs -name $pester_vrf
            #Add a reject static route on vrf $pester_vrf
            Add-ArubaCXStaticRoutes -address_family ipv4 -prefix_ip4 $pester_sr_ip4 -prefix_ip4_mask $pester_sr_mask -type reject -vrf $pester_vrf
        }

        It "Get Static Route Does not throw an error" {
            {
                Get-ArubaCXStaticRoutes -vrf $pester_vrf
            } | Should Not Throw
        }

        It "Get ALL Static Route" {
            $sr = Get-ArubaCXStaticRoutes -vrf $pester_vrf
            $sr.count | Should -Not -Be $NULL
        }

        It "Get Static Route ($pester_sr)" {
            $sr = Get-ArubaCXStaticRoutes -prefix $pester_sr -vrf $pester_vrf
            $sr.prefix | Should -Be $pester_sr
            $sr.vrf | should -Be $pester_vrf
        }

        It "Get Static Route ($pester_sr) and confirm (via Confirm-ArubaCXStaticRoutes)" {
            $sr = Get-ArubaCXStaticRoutes -prefix $pester_sr -vrf $pester_vrf
            Confirm-ArubaCXStaticRoutes ($sr) | Should -Be $true
        }

        #Get with attribute, depth...
        Context "Selector" {

            It "Get Static Route with selector equal configuration" {
                {
                    Get-ArubaCXStaticRoutes -selector configuration -vrf $pester_vrf
                } | Should Not Throw
            }

            It "Get Static Route with selector equal statistics" {
                {
                    Get-ArubaCXStaticRoutes -selector statistics -vrf $pester_vrf
                } | Should Not Throw
            }

            It "Get Static Route with selector equal status" {
                {
                    Get-ArubaCXStaticRoutes -selector status -vrf $pester_vrf
                } | Should Not Throw
            }

            It "Get Static Route with selector equal writable" {
                {
                    Get-ArubaCXStaticRoutes -selector writable -vrf $pester_vrf
                } | Should Not Throw
            }
        }

        Context "Depth" {

            It "Get Static Route with depth equal 1" {
                {
                    Get-ArubaCXStaticRoutes -depth 1 -vrf $pester_vrf
                } | Should Not Throw
            }

            It "Get Static Route with depth equal 2" {
                {
                    Get-ArubaCXStaticRoutes -depth 2 -vrf $pester_vrf
                } | Should Not Throw
            }

            It "Get Static Route with depth equal 3" {
                {
                    Get-ArubaCXStaticRoutes -depth 3 -vrf $pester_vrf
                } | Should Not Throw
            }

            It "Get Static Route with depth equal 4" {
                {
                    Get-ArubaCXStaticRoutes -depth 4 -vrf $pester_vrf
                } | Should Not Throw
            }

        }

        Context "Attribute" {

            It "Get Static Route with one attribute (prefix)" {
                $sr = Get-ArubaCXStaticRoutes -prefix $pester_sr -vrf $pester_vrf -attribute prefix
                @($sr).count | Should -be 1
                $sr.prefix | Should -Not -BeNullOrEmpty
                $sr.vrf | Should -Be $pester_vrf
            }

            It "Get Static Route with two attributes (prefix, type)" {
                $sr = Get-ArubaCXStaticRoutes -prefix $pester_sr -vrf $pester_vrf -attribute prefix, type
                @($sr).count | Should -be 1
                $sr.prefix | Should -Not -BeNullOrEmpty
                $sr.type | Should -Not -BeNullOrEmpty
                $sr.vrf | Should -Be $pester_vrf
            }

        }

        Context "Search" {
            It "Search Static Route by name ($pester_sr)" {
                $sr = Get-ArubaCXStaticRoutes -prefix $pester_sr -vrf $pester_vrf
                @($sr).count | Should -be 1
                $sr.prefix | Should -Be $pester_sr
                $sr.vrf | Should -Be $pester_vrf
            }
        }

        AfterAll {
            Get-ArubaCXStaticRoutes -prefix $pester_sr -vrf $pester_vrf | Remove-ArubaCXStaticRoutes -confirm:$false
            Get-ArubaCXVrfs -name $pester_vrf | Remove-ArubaCXVrfs -confirm:$false
        }

    }


}

Describe "Add Static Route" {

    Context "Add Static Route on VRF: default" {

        AfterEach {
            Get-ArubaCXStaticRoutes -prefix $pester_sr | Remove-ArubaCXStaticRoutes -confirm:$false
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

    }

    Context "Add Static Route on VRF: $pester_vrf" {

        BeforeAll {
            #Add Vrf
            Add-ArubaCXVrfs -name $pester_vrf
        }

        AfterEach {
            Get-ArubaCXStaticRoutes -prefix $pester_sr -vrf $pester_vrf | Remove-ArubaCXStaticRoutes -confirm:$false
        }

        It "Add Static Route $pester_sr (type forward)" {
            Add-ArubaCXStaticRoutes -address_family ipv4 -prefix_ip4 $pester_sr_ip4 -prefix_ip4_mask $pester_sr_mask -type forward -vrf $pester_vrf
            $sr = Get-ArubaCXStaticRoutes -prefix $pester_sr -vrf $pester_vrf
            $sr.prefix | Should -Be $pester_sr
            $sr.address_family | Should -Be "ipv4"
            $sr.type | Should -Be "forward"
            $sr.vrf | Should -Be $pester_vrf
        }

        It "Add Static Route $pester_sr (type reject)" {
            Add-ArubaCXStaticRoutes -address_family ipv4 -prefix_ip4 $pester_sr_ip4 -prefix_ip4_mask $pester_sr_mask -type reject -vrf $pester_vrf
            $sr = Get-ArubaCXStaticRoutes -prefix $pester_sr -vrf $pester_vrf
            $sr.prefix | Should -Be $pester_sr
            $sr.address_family | Should -Be "ipv4"
            $sr.type | Should -Be "reject"
            $sr.vrf | Should -Be $pester_vrf
        }

        It "Add Static Route $pester_sr (type blackhole)" {
            Add-ArubaCXStaticRoutes -address_family ipv4 -prefix_ip4 $pester_sr_ip4 -prefix_ip4_mask $pester_sr_mask -type blackhole -vrf $pester_vrf
            $sr = Get-ArubaCXStaticRoutes -prefix $pester_sr -vrf $pester_vrf
            $sr.prefix | Should -Be $pester_sr
            $sr.address_family | Should -Be "ipv4"
            $sr.type | Should -Be "blackhole"
            $sr.vrf | Should -Be $pester_vrf
        }

        AfterAll {
            Get-ArubaCXVrfs -name $pester_vrf | Remove-ArubaCXVrfs -confirm:$false
        }

    }

}

Describe "Remove Static Route" {

    Context "Add Static Route on VRF: default" {

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

    Context "Add Static Route on VRF: $pester_vrf" {

        BeforeAll {
            #Add Vrf
            Add-ArubaCXVrfs -name $pester_vrf
        }

        BeforeEach {
            #Always add Static Route $pester_sr...
            Add-ArubaCXStaticRoutes -address_family ipv4 -prefix_ip4 $pester_sr_ip4 -prefix_ip4_mask $pester_sr_mask -type blackhole -vrf $pester_vrf
        }

        It "Remove Static Route $pester_sr by prefix" {
            Remove-ArubaCXStaticRoutes -prefix $pester_sr -vrf $pester_vrf -confirm:$false
            $sr = Get-ArubaCXStaticRoutes -vrf $pester_vrf
            $sr.$pester_sr | Should -Be $NULL
        }

        It "Remove Static Route $pester_sr by pipeline" {
            $sr = Get-ArubaCXStaticRoutes  -vrf $pester_vrf -prefix $pester_sr
            $sr | Remove-ArubaCXStaticRoutes -confirm:$false
            $sr = Get-ArubaCXStaticRoutes -vrf $pester_vrf
            $sr.$pester_sr | Should -Be $NULL
        }

        AfterAll {
            #Remove vrf
            Get-ArubaCXVrfs -name $pester_vrf | Remove-ArubaCXVrfs -confirm:$false
        }

    }

}

Disconnect-ArubaCX -confirm:$false