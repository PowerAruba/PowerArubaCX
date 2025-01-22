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
Describe "Get (Vlan) Macs (Mac Address Table)" {

    BeforeAll {
        Add-ArubaCXVlans -id $pester_vlan -name pester_vlan
    }

    It "Get MACs not throw an error" {
        {
            Get-ArubaCXMACs
        } | Should -Not -Throw
    }

    It "Get MACs with a vlan ($pester_vlan) Does not throw an error" {
        {
            Get-ArubaCXMACs -vlan $pester_vlan
        } | Should -Not -Throw
    }

    It "Get MACs with a pipeline vlan ($pester_vlan) Does not throw an error" {
        {
            Get-ArubaCXVlans -id $pester_vlan | Get-ArubaCXMACs
        } | Should -Not -Throw
    }

    Context "Depth" {

        It "Get Neighbor with depth equal 1" {
            {
                Get-ArubaCXMACs -depth 1
            } | Should -Not -Throw
        }

        It "Get MACs with depth equal 2" {
            {
                Get-ArubaCXMACs -depth 2
            } | Should -Not -Throw
        }

        It "Get MACs with depth equal 3" {
            {
                Get-ArubaCXMACs -depth 3
            } | Should -Not -Throw
        }

        It "Get MACs with depth equal 4" {
            {
                Get-ArubaCXMACs -depth 4
            } | Should -Not -Throw
        }

    }

    AfterAll {
        Get-ArubaCXVlans -id $pester_vlan | Remove-ArubaCXVlans -confirm:$false
        #Reverse CheckPoint ?
    }
}

AfterAll {
    Disconnect-ArubaCX -confirm:$false
}