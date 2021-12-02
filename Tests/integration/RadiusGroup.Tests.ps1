#
# Copyright 2021, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

Describe "Get RADIUS Server Group" {
    BeforeAll {
        Add-ArubaCXRadiusServerGroup -group_name $pester_radius_group -group_type radius
    }

    It "Get RADIUS Server Group Does not throw an error" {
        {
            Get-ArubaCXRadiusServerGroup
        } | Should -Not -Throw
    }

    It "Get ALL RADIUS Server Group" {
        $radius_group = Get-ArubaCXRadiusServerGroup
        @($radius_group).count | Should -Not -Be $NULL
    }

    It "Get RADIUS Server Group ($pester_radius_group)" {
        $radius_group = Get-ArubaCXRadiusServerGroup -group_name $pester_radius_group
        $radius_group.group_name | Should -Be $pester_radius_group
        $radius_group.group_type | Should -Be "radius"
    }

    It "Get RADIUS Server Group ($pester_radius_group) and confirm (via Confirm-ArubaCXRadiusServerGroup)" {
        $radius_group = Get-ArubaCXRadiusServerGroup -group_name $pester_radius_group
        Confirm-ArubaCXRadiusServerGroup ($radius_group) | Should -Be $true
    }

    #Get with attribute, depth...
    Context "Selector" {

        It "Get RADIUS Server Group with selector equal configuration" {
            {
                Get-ArubaCXRadiusServerGroup -group_name $pester_radius_group -selector configuration
            } | Should -Not -Throw
        }

        It "Get RADIUS Server Group with selector equal statistics" {
            {
                Get-ArubaCXRadiusServerGroup -group_name $pester_radius_group -selector statistics
            } | Should -Not -Throw
        }

        It "Get RADIUS Server Group with selector equal status" {
            {
                Get-ArubaCXRadiusServerGroup -group_name $pester_radius_group -selector status
            } | Should -Not -Throw
        }

        It "Get RADIUS Server Group with selector equal writable" {
            {
                Get-ArubaCXRadiusServerGroup -group_name $pester_radius_group -selector writable
            } | Should -Not -Throw
        }
    }

    Context "Depth" {

        It "Get RADIUS Server Group with depth equal 1" {
            {
                Get-ArubaCXRadiusServerGroup -depth 1
            } | Should -Not -Throw
        }

        It "Get RADIUS Server Group with depth equal 2" {
            {
                Get-ArubaCXRadiusServerGroup -depth 2
            } | Should -Not -Throw
        }

        It "Get RADIUS Server Group with depth equal 3" {
            {
                Get-ArubaCXRadiusServerGroup -depth 3
            } | Should -Not -Throw
        }

        It "Get RADIUS Server Group with depth equal 4" {
            {
                Get-ArubaCXRadiusServerGroup -depth 4
            } | Should -Not -Throw
        }
    }

    Context "Attribute" {

        It "Get RADIUS Server Group with one attribute (group_type)" {
            $radius_group = Get-ArubaCXRadiusServerGroup -group_name $pester_radius_group -attribute group_type
            @($radius_group).count | Should -Be 1
            $radius_group.group_name | Should -BeNullOrEmpty
            $radius_group.group_type | Should -Not -BeNullOrEmpty
        }

        It "Get RADIUS Server Group with two attributes (group_type, origin)" {
            $radius_group = Get-ArubaCXRadiusServerGroup -group_name $pester_radius_group -attribute group_type,origin
            @($radius_group).count | Should -Be 1
            $radius_group.group_name | Should -BeNullOrEmpty
            $radius_group.group_type | Should -Be "radius"
            $radius_group.origin | Should -Be "configuration"
        }

    }

    Context "Search" {
        It "Search RADIUS Server Group by address ($pester_radius_group)" {
            $radius_group = Get-ArubaCXRadiusServerGroup -group_name $pester_radius_group
            @($radius_group).count | Should -Be 1
            $radius_group.group_name | Should -Be $pester_radius_group
            $radius_group.group_type | Should -Be "radius"
        }
    }

    AfterAll {
        Get-ArubaCXRadiusServerGroup -group_name $pester_radius_group | Remove-ArubaCXRadiusServerGroup -confirm:$false
    }
}

Describe "Add RADIUS Server Group" {

    AfterEach {
        Get-ArubaCXRadiusServerGroup -group_name $pester_radius_group | Remove-ArubaCXRadiusServerGroup -confirm:$false -ErrorAction SilentlyContinue
    }

    It "Add RADIUS Server Group $pester_radius_group (with only group_type as radius)" {
        Add-ArubaCXRadiusServerGroup -group_name $pester_radius_group -group_type radius
        $radius_group = Get-ArubaCXRadiusServerGroup -group_name $pester_radius_group
        $radius_group.group_name | Should -Be $pester_radius_group
        $radius_group.group_type | Should -Be "radius"
    }

    It "Add RADIUS Server Group $pester_radius_group (with only group_type as tacacs)" {
        Add-ArubaCXRadiusServerGroup -group_name $pester_radius_group -group_type tacacs
        $radius_group = Get-ArubaCXRadiusServerGroup -group_name $pester_radius_group
        $radius_group.group_name | Should -Be $pester_radius_group
        $radius_group.group_type | Should -Be "tacacs"
    }

}

Describe "Configure RADIUS Server Group" {
    BeforeAll {
        Add-ArubaCXRadiusServerGroup -group_name $pester_radius_group -group_type tacacs
    }

    It "Change RADIUS Server Group type (RADIUS) by pipeline" {
        Get-ArubaCXRadiusServerGroup -group_name $pester_radius_group | Set-ArubaCXRadiusServerGroup -group_type radius
        $radius_group = Get-ArubaCXRadiusServerGroup -group_name $pester_radius_group
        $radius_group.group_type | Should -Be "radius"
    }

    It "Change RADIUS Server Group type (TACACS) by pipeline" {
        Get-ArubaCXRadiusServerGroup -group_name $pester_radius_group | Set-ArubaCXRadiusServerGroup -group_type tacacs
        $radius_group = Get-ArubaCXRadiusServerGroup -group_name $pester_radius_group
        $radius_group.group_type | Should -Be "tacacs"
    }

    It "Change RADIUS Server Group type (RADIUS)" {
        Set-ArubaCXRadiusServerGroup -group_name $pester_radius_group -group_type radius
        $radius_group = Get-ArubaCXRadiusServerGroup -group_name $pester_radius_group
        $radius_group.group_type | Should -Be "radius"
    }

    It "Change RADIUS Server Group type (TACACS)" {
        Set-ArubaCXRadiusServerGroup -group_name $pester_radius_group -group_type tacacs
        $radius_group = Get-ArubaCXRadiusServerGroup -group_name $pester_radius_group
        $radius_group.group_type | Should -Be "tacacs"
    }

    AfterAll {
        Get-ArubaCXRadiusServerGroup -group_name $pester_radius_group | Remove-ArubaCXRadiusServerGroup -confirm:$false
    }
}

Describe "Remove RADIUS Server Group" {

    BeforeEach {
        Add-ArubaCXRadiusServerGroup -group_name $pester_radius_group -group_type tacacs
    }

    It "Remove RADIUS Server Group $pester_radius_group by group_name" {
        Remove-ArubaCXRadiusServerGroup -group_name $pester_radius_group -confirm:$false
        $radius_group = Get-ArubaCXRadiusServerGroup
        $radius_group.$pester_radius_group | Should -Be $NULL
    }

    It "Remove RADIUS Server Group $pester_radius_group by pipeline" {
        $radius_group = Get-ArubaCXRadiusServerGroup -group_name $pester_radius_group
        $radius_group | Remove-ArubaCXRadiusServerGroup -confirm:$false
        $radius_group = Get-ArubaCXRadiusServerGroup
        $radius_group.$pester_radius_group | Should -Be $NULL
    }

}

Disconnect-ArubaCX -confirm:$false