#
# Copyright 2020, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

Describe "Get Tacacs Server" {
    BeforeALL {
        Add-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port -group tacacs -default_group_priority 1 -auth_type pap -timeout 15
    }

    It "Get Tacacs Server Does not throw an error" {
        {
            Get-ArubaCXTacacsServer
        } | Should Not Throw
    }

    It "Get ALL Tacacs Server" {
        $tacacs = Get-ArubaCXTacacsServer
        $tacacs.count | Should -Not -Be $NULL
    }

    It "Get Tacacs Server ($pester_tacacs_address)" {
        $tacacs = Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port
        $tacacs.address | Should -Be $pester_tacacs_address
        $tacacs.tcp_port | Should -Be $pester_tacacs_port
    }

    It "Get Tacacs Server ($pester_tacacs_address) and confirm (via Confirm-ArubaCXVlans)" {
        $tacacs = Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port
        Confirm-ArubaCXTacacsServer ($tacacs) | Should -Be $true
    }

    #Get with attribute, depth...
    Context "Selector" {

        It "Get Tacacs Server with selector equal configuration" {
            {
                Get-ArubaCXTacacsServer -selector configuration
            } | Should Not Throw
        }

        It "Get Tacacs Server with selector equal statistics" {
            {
                Get-ArubaCXTacacsServer -selector statistics
            } | Should Not Throw
        }

        It "Get Tacacs Server with selector equal status" {
            {
                Get-ArubaCXTacacsServer -selector status
            } | Should Not Throw
        }

        It "Get Tacacs Server with selector equal writable" {
            {
                Get-ArubaCXTacacsServer -selector writable
            } | Should Not Throw
        }
    }

    Context "Depth" {

        It "Get Tacacs Server with depth equal 1" {
            {
                Get-ArubaCXTacacsServer -depth 1
            } | Should Not Throw
        }

        It "Get Tacacs Server with depth equal 2" {
            {
                Get-ArubaCXTacacsServer -depth 2
            } | Should Not Throw
        }

        It "Get Tacacs Server with depth equal 3" {
            {
                Get-ArubaCXTacacsServer -depth 3
            } | Should Not Throw
        }

        It "Get Tacacs Server with depth equal 4" {
            {
                Get-ArubaCXTacacsServer -depth 4
            } | Should Not Throw
        }
    }

    Context "Attribute" {

        It "Get Tacacs Server with one attribute (auth_type)" {
            $tacacs = Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port -attribute auth_type
            @($tacacs).count | Should -be 1
            $tacacs.address | Should -BeNullOrEmpty
            $tacacs.port | Should -Not -BeNullOrEmpty
        }

        It "Get Tacacs Server with two attributes (auth_type, timeout)" {
            $tacacs = Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port -attribute auth_type,timeout
            @($tacacs).count | Should -be 1
            $tacacs.address | Should -BeNullOrEmpty
            $tacacs.port | Should -Not -BeNullOrEmpty
            $tacacs.auth_type | Should -Be "pap"
            $tacacs.timeour | Should -Be 15
        }

    }

    Context "Search" {
        It "Search Tacacs Server by address ($pester_tacacs_address)" {
            $tacacs = Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port
            @($tacacs).count | Should -be 1
            $tacacs.address | Should -Be $pester_tacacs_address
            $tacacs.port | Should -Be $pester_tacacs_port
        }
    }

    AfterAll {
        Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port | Remove-ArubaCXTacacsServer -confirm:$false
    }
}

Describe "Add Tacacs Server" {

    AfterEach {
        Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port | Remove-ArubaCXTacacsServer -confirm:$false -ErrorAction SilentlyContinue
    }

    It "Add Tacacs Server $pester_tacacs_address (with only an address and a port, a group and a default priority for the group)" {
        Add-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port -group tacacs -default_group_priority 1
        $tacacs = Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port
        $tacacs.address | Should -Be $pester_tacacs_address
        $tacacs.port | Should -Be $pester_tacacs_port
        $tacacs.group.tacacs | Should -Be "/rest/v10.04/system/aaa_server_groups/tacacs"
        $tacacs.default_group_priority | Should -Be 1
        $tacacs.timeout | Should -Be $null
        $tacacs.passkey | Should -Be $null
        $tacacs.tracking_enable | Should -Be $false
    }

    It "Add Tacacs Server $pester_tacacs_address (with only an address and a port, a group and a default priority for the group, and a timeout)" {
        Add-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port -group tacacs -default_group_priority -timeout 10
        $tacacs = Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port
        $tacacs.address | Should -Be $pester_tacacs_address
        $tacacs.port | Should -Be $pester_tacacs_port
        $tacacs.group.tacacs | Should -Be "/rest/v10.04/system/aaa_server_groups/tacacs"
        $tacacs.default_group_priority | Should -Be 1
        $tacacs.timeout | Should -Be 10
        $tacacs.passkey | Should -Be $null
        $tacacs.tracking_enable | Should -Be $false
    }

    It "Add Tacacs Server $pester_tacacs_address (with only an address and a port, a group and a default priority for the group, a timeout, a passkey and tracking_enable)" {
        Add-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port -group tacacs -default_group_priority 1 -timeout 10 -passkey PowerArubaCX -tracking_enable
        $tacacs = Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port
        $tacacs.address | Should -Be $pester_tacacs_address
        $tacacs.port | Should -Be $pester_tacacs_port
        $tacacs.group.tacacs | Should -Be "/rest/v10.04/system/aaa_server_groups/tacacs"
        $tacacs.default_group_priority | Should -Be 1
        $tacacs.timeout | Should -Be 10
        $tacacs.passkey | Should -Not -BeNullOrEmpty
        $tacacs.tracking_enable | Should -Be $true
    }
}

Describe "Configure Tacacs Server" {
    BeforeAll {
        Add-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port -group tacacs -default_group_priority 1
    }

    It "Change Tacacs Server default_group_priority" {
        Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port | Set-ArubaCXTacacsServer -default_group_priority 10
        $tacacs = Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port
        $tacacs.default_group_priority | Should -Be 10
    }

    It "Change Tacacs Server timeout" {
        Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port | Set-ArubaCXTacacsServer -timeout 10
        $tacacs = Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port
        $tacacs.timeout | Should -Be 10
    }

    It "Change Tacacs Server tracking_enable (enable)" {
        Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port | Set-ArubaCXTacacsServer -tracking_enable:$true
        $tacacs = Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port
        $tacacs.tracking_enable | Should -Be $true
    }

    It "Change Tacacs Server tracking_enable (disable)" {
        Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port | Set-ArubaCXTacacsServer -tracking_enable:$false
        $tacacs = Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port
        $tacacs.tracking_enable | Should -Be $false
    }

    AfterAll {
        Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port | Remove-ArubaCXTacacsServer -confirm:$false
    }
}

Describe "Remove Tacacs Server" {

    BeforeEach {
        Add-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port -group tacacs -default_group_priority 1
    }

    It "Remove Tacacs Server $pester_tacacs_address by address and port" {
        Remove-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port -confirm:$false
        $tacacs = Get-ArubaCXTacacsServer
        $tacacs.$pester_tacacs_address | Should -Be $NULL
    }

    It "Remove Tacacs Server $pester_tacacs_address by pipeline" {
        $tacacs = Get-ArubaCXTacacsServer -address $pester_tacacs_address -port $pester_tacacs_port
        $tacacs | Remove-ArubaCXTacacsServer -confirm:$false
        $tacacs = Get-ArubaCXTacacsServer
        $tacacs.$pester_tacacs_address | Should -Be $NULL
    }

}

Disconnect-ArubaCX -confirm:$false