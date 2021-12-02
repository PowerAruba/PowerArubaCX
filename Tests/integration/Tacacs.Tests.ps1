#
# Copyright 2020, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

Describe "Get TACACS Server" {
    BeforeAll {
        Add-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port -group tacacs -default_group_priority 1 -auth_type pap -timeout 15
    }

    It "Get TACACS Server Does not throw an error" {
        {
            Get-ArubaCXTacacsServer
        } | Should -Not -Throw
    }

    It "Get ALL TACACS Server" {
        $tacacs = Get-ArubaCXTacacsServer
        @($tacacs).count | Should -Not -Be $NULL
    }

    It "Get TACACS Server ($pester_tacacs_address)" {
        $tacacs = Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port
        $tacacs.address | Should -Be $pester_tacacs_address
        $tacacs.tcp_port | Should -Be $pester_tacacs_port
    }

    It "Get TACACS Server ($pester_tacacs_address) and confirm (via Confirm-ArubaCXTacacsServer)" {
        $tacacs = Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port
        Confirm-ArubaCXTacacsServer ($tacacs) | Should -Be $true
    }

    #Get with attribute, depth...
    Context "Selector" {

        It "Get TACACS Server with selector equal configuration" {
            {
                Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port -selector configuration
            } | Should -Not -Throw
        }

        It "Get TACACS Server with selector equal statistics" {
            {
                Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port -selector statistics
            } | Should -Not -Throw
        }

        It "Get TACACS Server with selector equal status" {
            {
                Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port -selector status
            } | Should -Not -Throw
        }

        It "Get TACACS Server with selector equal writable" {
            {
                Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port -selector writable
            } | Should -Not -Throw
        }
    }

    Context "Depth" {

        It "Get TACACS Server with depth equal 1" {
            {
                Get-ArubaCXTacacsServer -depth 1
            } | Should -Not -Throw
        }

        It "Get TACACS Server with depth equal 2" {
            {
                Get-ArubaCXTacacsServer -depth 2
            } | Should -Not -Throw
        }

        It "Get TACACS Server with depth equal 3" {
            {
                Get-ArubaCXTacacsServer -depth 3
            } | Should -Not -Throw
        }

        It "Get TACACS Server with depth equal 4" {
            {
                Get-ArubaCXTacacsServer -depth 4
            } | Should -Not -Throw
        }
    }

    Context "Attribute" {

        It "Get TACACS Server with one attribute (auth_type)" {
            $tacacs = Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port -attribute auth_type
            @($tacacs).count | Should -Be 1
            $tacacs.address | Should -BeNullOrEmpty
            $tacacs.auth_type | Should -Not -BeNullOrEmpty
        }

        It "Get TACACS Server with two attributes (auth_type, timeout)" {
            $tacacs = Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port -attribute auth_type,timeout
            @($tacacs).count | Should -Be 1
            $tacacs.address | Should -BeNullOrEmpty
            $tacacs.auth_type | Should -Be "pap"
            $tacacs.timeout | Should -Be 15
        }

    }

    Context "Search" {
        It "Search TACACS Server by address ($pester_tacacs_address)" {
            $tacacs = Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port
            @($tacacs).count | Should -Be 1
            $tacacs.address | Should -Be $pester_tacacs_address
            $tacacs.tcp_port | Should -Be $pester_tacacs_port
        }
    }

    AfterAll {
        Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port | Remove-ArubaCXTacacsServer -confirm:$false
    }
}

Describe "Add TACACS Server" {

    AfterEach {
        Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port | Remove-ArubaCXTacacsServer -confirm:$false -ErrorAction SilentlyContinue
    }

    It "Add TACACS Server $pester_tacacs_address (with only an address and a port, a group and a default priority for the group)" {
        Add-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port -group tacacs -default_group_priority 1
        $tacacs = Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port -depth 2
        $tacacs.address | Should -Be $pester_tacacs_address
        $tacacs.tcp_port | Should -Be $pester_tacacs_port
        $tacacs.group.tacacs | Should -Be "@{group_name=tacacs; group_type=tacacs; origin=built-in}"
        $tacacs.default_group_priority | Should -Be 1
        $tacacs.timeout | Should -Be $null
        $tacacs.passkey | Should -Be $null
        $tacacs.tracking_enable | Should -Be $false
    }

    It "Add TACACS Server $pester_tacacs_address (with only an address and a port, a group and a default priority for the group, and a timeout)" {
        Add-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port -group tacacs -default_group_priority 1 -timeout 10
        $tacacs = Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port -depth 2
        $tacacs.address | Should -Be $pester_tacacs_address
        $tacacs.tcp_port | Should -Be $pester_tacacs_port
        $tacacs.group.tacacs | Should -Be "@{group_name=tacacs; group_type=tacacs; origin=built-in}"
        $tacacs.default_group_priority | Should -Be 1
        $tacacs.timeout | Should -Be 10
        $tacacs.passkey | Should -Be $null
        $tacacs.tracking_enable | Should -Be $false
    }

    It "Add TACACS Server $pester_tacacs_address (with only an address and a port, a group and a default priority for the group, a timeout, a passkey and tracking_enable)" {
        Add-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port -group tacacs -default_group_priority 1 -timeout 10 -passkey PowerArubaCX -tracking_enable
        $tacacs = Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port -depth 2
        $tacacs.address | Should -Be $pester_tacacs_address
        $tacacs.tcp_port | Should -Be $pester_tacacs_port
        $tacacs.group.tacacs | Should -Be "@{group_name=tacacs; group_type=tacacs; origin=built-in}"
        $tacacs.default_group_priority | Should -Be 1
        $tacacs.timeout | Should -Be 10
        $tacacs.passkey | Should -Not -BeNullOrEmpty
        $tacacs.tracking_enable | Should -Be $true
    }
}

Describe "Configure TACACS Server" {
    BeforeAll {
        Add-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port -group tacacs -default_group_priority 1
    }

    It "Change TACACS Server default_group_priority" {
        Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port | Set-ArubaCXTacacsServer -default_group_priority 10
        $tacacs = Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port
        $tacacs.default_group_priority | Should -Be 10
    }

    It "Change TACACS Server timeout" {
        Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port | Set-ArubaCXTacacsServer -timeout 10
        $tacacs = Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port
        $tacacs.timeout | Should -Be 10
    }

    It "Change TACACS Server tracking_enable (enable)" {
        Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port | Set-ArubaCXTacacsServer -tracking_enable:$true
        $tacacs = Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port
        $tacacs.tracking_enable | Should -Be $true
    }

    It "Change TACACS Server tracking_enable (disable)" {
        Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port | Set-ArubaCXTacacsServer -tracking_enable:$false
        $tacacs = Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port
        $tacacs.tracking_enable | Should -Be $false
    }

    AfterAll {
        Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port | Remove-ArubaCXTacacsServer -confirm:$false
    }
}

Describe "Remove TACACS Server" {

    BeforeEach {
        Add-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port -group tacacs -default_group_priority 1
    }

    It "Remove TACACS Server $pester_tacacs_address by address and port" {
        Remove-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port -confirm:$false
        $tacacs = Get-ArubaCXTacacsServer
        $tacacs.$pester_tacacs_address | Should -Be $NULL
    }

    It "Remove TACACS Server $pester_tacacs_address by pipeline" {
        $tacacs = Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port
        $tacacs | Remove-ArubaCXTacacsServer -confirm:$false
        $tacacs = Get-ArubaCXTacacsServer
        $tacacs.$pester_tacacs_address | Should -Be $NULL
    }

}

Disconnect-ArubaCX -confirm:$false