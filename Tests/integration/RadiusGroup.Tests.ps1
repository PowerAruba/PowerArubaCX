#
# Copyright 2021, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

Describe "Get AAA Server Group" {
    BeforeAll {
        Add-ArubaCXAAAServerGroup -group_name $pester_radius_group -group_type radius
    }

    It "Get AAA Server Group Does not throw an error" {
        {
            Get-ArubaCXAAAServerGroup
        } | Should -Not -Throw
    }

    It "Get ALL AAA Server Group" {
        $radius_group = Get-ArubaCXAAAServerGroup
        @($radius_group).count | Should -Not -Be $NULL
    }

    It "Get AAA Server Group ($pester_radius_group)" {
        $radius_group = Get-ArubaCXAAAServerGroup -group_name $pester_radius_group
        $radius_group.group_name | Should -Be $pester_radius_group
        $radius_group.group_type | Should -Be "radius"
    }

    It "Get AAA Server Group ($pester_radius_group) and confirm (via Confirm-ArubaCXAAAServerGroup)" {
        $radius_group = Get-ArubaCXAAAServerGroup -group_name $pester_radius_group
        Confirm-ArubaCXAAAServerGroup ($radius_group) | Should -Be $true
    }

    #Get with attribute, depth...
    Context "Selector" {

        It "Get AAA Server Group with selector equal configuration" {
            {
                Get-ArubaCXAAAServerGroup -group_name $pester_radius_group -selector configuration
            } | Should -Not -Throw
        }

        It "Get AAA Server Group with selector equal statistics" {
            {
                Get-ArubaCXAAAServerGroup -group_name $pester_radius_group -selector statistics
            } | Should -Not -Throw
        }

        It "Get AAA Server Group with selector equal status" {
            {
                Get-ArubaCXAAAServerGroup -group_name $pester_radius_group -selector status
            } | Should -Not -Throw
        }

        It "Get AAA Server Group with selector equal writable" {
            {
                Get-ArubaCXAAAServerGroup -group_name $pester_radius_group -selector writable
            } | Should -Not -Throw
        }
    }

    Context "Depth" {

        It "Get AAA Server Group with depth equal 1" {
            {
                Get-ArubaCXAAAServerGroup -depth 1
            } | Should -Not -Throw
        }

        It "Get AAA Server Group with depth equal 2" {
            {
                Get-ArubaCXAAAServerGroup -depth 2
            } | Should -Not -Throw
        }

        It "Get AAA Server Group with depth equal 3" {
            {
                Get-ArubaCXAAAServerGroup -depth 3
            } | Should -Not -Throw
        }

        It "Get AAA Server Group with depth equal 4" {
            {
                Get-ArubaCXAAAServerGroup -depth 4
            } | Should -Not -Throw
        }
    }

    Context "Attribute" {

        It "Get AAA Server Group with one attribute (group_type)" {
            $radius_group = Get-ArubaCXAAAServerGroup -group_name $pester_radius_group -attribute group_type
            @($radius_group).count | Should -Be 1
            $radius_group.group_name | Should -BeNullOrEmpty
            $radius_group.group_type | Should -Not -BeNullOrEmpty
        }

        It "Get AAA Server Group with two attributes (group_type, origin)" {
            $radius_group = Get-ArubaCXAAAServerGroup -group_name $pester_radius_group -attribute group_type,origin
            @($radius_group).count | Should -Be 1
            $radius_group.group_name | Should -BeNullOrEmpty
            $radius_group.group_type | Should -Be "radius"
            $radius_group.origin | Should -Be "configuration"
        }

    }

    Context "Search" {
        It "Search AAA Server Group by address ($pester_radius_group)" {
            $radius_group = Get-ArubaCXAAAServerGroup -group_name $pester_radius_group
            @($radius_group).count | Should -Be 1
            $radius_group.group_name | Should -Be $pester_radius_group
            $radius_group.group_type | Should -Be "radius"
        }
    }

    AfterAll {
        Get-ArubaCXAAAServerGroup -group_name $pester_radius_group | Remove-ArubaCXAAAServerGroup -confirm:$false
    }
}

Describe "Add AAA Server Group" {

    AfterEach {
        Get-ArubaCXAAAServerGroup -group_name $pester_radius_group | Remove-ArubaCXAAAServerGroup -confirm:$false -ErrorAction SilentlyContinue
    }

    It "Add AAA Server Group $pester_radius_group (with only group_type as radius)" {
        Add-ArubaCXAAAServerGroup -group_name $pester_radius_group -group_type radius
        $radius_group = Get-ArubaCXAAAServerGroup -group_name $pester_radius_group
        $radius_group.group_name | Should -Be $pester_radius_group
        $radius_group.group_type | Should -Be "radius"
    }

    It "Add AAA Server Group $pester_radius_group (with only group_type as tacacs)" {
        Add-ArubaCXAAAServerGroup -group_name $pester_radius_group -group_type tacacs
        $radius_group = Get-ArubaCXAAAServerGroup -group_name $pester_radius_group
        $radius_group.group_name | Should -Be $pester_radius_group
        $radius_group.group_type | Should -Be "tacacs"
    }

}

Describe "Configure AAA Server Group" {
    BeforeAll {
        Add-ArubaCXAAAServerGroup -group_name $pester_radius_group -group_type tacacs
    }

    It "Change AAA Server Group type (RADIUS) by pipeline" {
        Get-ArubaCXAAAServerGroup -group_name $pester_radius_group | Set-ArubaCXAAAServerGroup -group_type radius
        $radius_group = Get-ArubaCXAAAServerGroup -group_name $pester_radius_group
        $radius_group.group_type | Should -Be "radius"
    }

    It "Change AAA Server Group type (TACACS) by pipeline" {
        Get-ArubaCXAAAServerGroup -group_name $pester_radius_group | Set-ArubaCXAAAServerGroup -group_type tacacs
        $radius_group = Get-ArubaCXAAAServerGroup -group_name $pester_radius_group
        $radius_group.group_type | Should -Be "tacacs"
    }

    It "Change AAA Server Group type (RADIUS)" {
        Set-ArubaCXAAAServerGroup -group_name $pester_radius_group -group_type radius
        $radius_group = Get-ArubaCXAAAServerGroup -group_name $pester_radius_group
        $radius_group.group_type | Should -Be "radius"
    }

    It "Change AAA Server Group type (TACACS)" {
        Set-ArubaCXAAAServerGroup -group_name $pester_radius_group -group_type tacacs
        $radius_group = Get-ArubaCXAAAServerGroup -group_name $pester_radius_group
        $radius_group.group_type | Should -Be "tacacs"
    }

    AfterAll {
        Get-ArubaCXAAAServerGroup -group_name $pester_radius_group | Remove-ArubaCXAAAServerGroup -confirm:$false
    }
}

Describe "Remove AAA Server Group" {

    BeforeEach {
        Add-ArubaCXAAAServerGroup -group_name $pester_radius_group -group_type tacacs
    }

    It "Remove AAA Server Group $pester_radius_group by group_name" {
        Remove-ArubaCXAAAServerGroup -group_name $pester_radius_group -confirm:$false
        $radius_group = Get-ArubaCXAAAServerGroup
        $radius_group.$pester_radius_group | Should -Be $NULL
    }

    It "Remove AAA Server Group $pester_radius_group by pipeline" {
        $radius_group = Get-ArubaCXAAAServerGroup -group_name $pester_radius_group
        $radius_group | Remove-ArubaCXAAAServerGroup -confirm:$false
        $radius_group = Get-ArubaCXAAAServerGroup
        $radius_group.$pester_radius_group | Should -Be $NULL
    }

}

Disconnect-ArubaCX -confirm:$false