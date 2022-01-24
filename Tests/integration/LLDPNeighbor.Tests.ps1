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
Describe "Get LLDP Neighbor" {

    It "Get LLDP Neighbor Does not throw an error" {
        {
            Get-ArubaCXLLDPNeighbor
        } | Should -Not -Throw
    }

    It "Get LLDP Neighbor with an interface ($pester_interface) Does not throw an error" {
        {
            Get-ArubaCXLLDPNeighbor $pester_interface
        } | Should -Not -Throw
    }
}

Context "Depth" {

    It "Get LLDP Neighbor with depth equal 1" {
        {
            Get-ArubaCXLLDPNeighbor -depth 1
        } | Should -Not -Throw
    }

    It "Get LLDP Neighbor with depth equal 2" {
        {
            Get-ArubaCXLLDPNeighbor -depth 2
        } | Should -Not -Throw
    }

    It "Get LLDP Neighbor with depth equal 3" {
        {
            Get-ArubaCXLLDPNeighbor -depth 3
        } | Should -Not -Throw
    }

    It "Get LLDP Neighbor with depth equal 4" {
        {
            Get-ArubaCXLLDPNeighbor -depth 4
        } | Should -Not -Throw
    }

}

AfterAll {
    Disconnect-ArubaCX -confirm:$false
}