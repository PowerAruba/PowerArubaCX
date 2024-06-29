#
# Copyright 2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

BeforeAll {
    Connect-ArubaCX @invokeParams
}

#Only Basic check because no neighbor... (need to add some peer switch)
Describe "Get (Vrf) Neighbors (ARP Table)" {

    BeforeAll {
        Add-ArubaCXVrfs -name $pester_vrf
    }

    It "Get Neighbors not throw an error" {
        {
            Get-ArubaCXNeighbors
        } | Should -Not -Throw
    }

    It "Get Neighbors with a vrf ($pester_vrf) Does not throw an error" {
        {
            Get-ArubaCXNeighbors -vrf $pester_vrf
        } | Should -Not -Throw
    }

    It "Get Neighbors with a pipeline vrf ($pester_vrf) Does not throw an error" {
        {
            Get-ArubaCXVrfs $pester_vrf | Get-ArubaCXNeighbors
        } | Should -Not -Throw
    }

    Context "Depth" {

        It "Get Neighbor with depth equal 1" {
            {
                Get-ArubaCXNeighbors -depth 1
            } | Should -Not -Throw
        }

        It "Get Neighbors with depth equal 2" {
            {
                Get-ArubaCXNeighbors -depth 2
            } | Should -Not -Throw
        }

        It "Get Neighbors with depth equal 3" {
            {
                Get-ArubaCXNeighbors -depth 3
            } | Should -Not -Throw
        }

        It "Get Neighbors with depth equal 4" {
            {
                Get-ArubaCXNeighbors -depth 4
            } | Should -Not -Throw
        }

    }

    AfterAll {
        Get-ArubaCXVrfs -name $pester_vrf | Remove-ArubaCXVrfs -confirm:$false
        #Reverse CheckPoint ?
    }
}

AfterAll {
    Disconnect-ArubaCX -confirm:$false
}